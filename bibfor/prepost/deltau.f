      SUBROUTINE DELTAU(JRWORK, JNBPG, NBPGT, NBORDR, NMAINI, NBMAP,
     &                  NUMPAQ, TSPAQ, NOMMET, NOMCRI,NOMFOR,
     &                  GRDVIE,FORVIE, CESR)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 17/10/2011   AUTEUR TRAN V-X.TRAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.
C
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.
C
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE F1BHHAJ J.ANGLES
C TOLE  CRP_20
      IMPLICIT     NONE
      INTEGER      JRWORK, JNBPG, NBPGT, NBORDR, NMAINI, NUMPAQ, NBMAP
      INTEGER      TSPAQ
      CHARACTER*8  GRDVIE
      CHARACTER*16 NOMCRI, NOMMET,NOMFOR ,FORVIE
      CHARACTER*19 CESR
C ---------------------------------------------------------------------
C BUT: DETERMINER LE PLAN INCLINE POUR LEQUEL DELTA_TAU EST MAXIMUM
C      POUR CHAQUE POINT DE GAUSS D'UN <<PAQUET>> DE MAILLES.
C ---------------------------------------------------------------------
C ARGUMENTS:
C JRWORK     IN    I  : ADRESSE DU VECTEUR DE TRAVAIL CONTENANT
C                       L'HISTORIQUE DES TENSEURS DES CONTRAINTES
C                       ATTACHES A CHAQUE POINT DE GAUSS DES MAILLES
C                       DU <<PAQUET>> DE MAILLES.
C JNBPG      IN    I  : ADRESSE DU VECTEUR CONTENANT LE NOMBRE DE
C                       POINT DE GAUSS DE CHAQUE MAILLE DU MAILLAGE.
C NBPGT      IN    I  : NOMBRE TOTAL DE POINTS DE GAUSS A TRAITER.
C NBORDR     IN    I  : NOMBRE DE NUMERO D'ORDRE STOCKE DANS LA
C                       STRUCTURE DE DONNEES RESULTAT.
C NMAINI     IN    I  : NUMERO DE LA 1ERE MAILLE DU <<PAQUET>> DE
C                       MAILLES COURANT.
C NBMAP      IN    I  : NOMBRE DE MAILLES DANS LE <<PAQUET>> DE
C                       MAILLES COURANT.
C NUMPAQ     IN    I  : NUMERO DU PAQUET DE MAILLES COURANT.
C TSPAQ      IN    I  : TAILLE DU SOUS-PAQUET DU <<PAQUET>> DE MAILLES
C                       COURANT.
C NOMMET     IN    K16: NOM DE LA METHODE DE CALCUL DU CERCLE
C                       CIRCONSCRIT.
C NOMCRI     IN    K16: NOM DU CRITERE AVEC PLANS CRITIQUES.
C CESR       IN    K19: NOM DU CHAMP SIMPLE DESTINE A RECEVOIR LES
C                       RESULTATS.
C
C REMARQUE :
C  - LA TAILLE DU SOUS-PAQUET EST EGALE A LA TAILLE DU <<PAQUET>> DE
C    MAILLES DIVISEE PAR LE NOMBRE DE NUMERO D'ORDRE (NBORDR).
C-----------------------------------------------------------------------

C---- COMMUNS NORMALISES  JEVEUX
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ------------------------------------------------------------------
      INTEGER      I, J, KWORK, N, JCERD, JCERL, JCERV, JAD
      INTEGER      IRET, IMAP, ICESD, ICESL, ICESV, IBID
      INTEGER      IPG, TNECES, TDISP, JVECPG, JVECTN
      INTEGER      JVECTU, JVECTV, NGAM, DIM, TAB2(18)
      INTEGER      NBPG, SOMPGW, NBPGP, L, JDTAUM, JRESUN
      INTEGER      LOR8EM, LOISEM,ICMP, VALI(2)
      REAL*8       DGAM, GAMMA, PI, R8PI, DPHI, TAB1(18)
      REAL*8       PHI0, VALA, VALB, COEFPA, VRESU2(24)
      INTEGER      ICODWO, IARG
      CHARACTER*8  CHMAT1, NOMMAT
      CHARACTER*10 OPTIO
      CHARACTER*19 CHMAT, CESMAT
      
C
C-----------------------------------------------------------------------
C234567                                                              012
C-----------------------------------------------------------------------
      DATA  TAB1/ 180.0D0, 60.0D0, 30.0D0, 20.0D0, 15.0D0, 12.857D0,
     &             11.25D0, 10.588D0, 10.0D0, 10.0D0, 10.0D0, 10.588D0,
     &             11.25D0, 12.857D0, 15.0D0, 20.0D0, 30.0D0, 60.0D0 /
C
      DATA  TAB2/ 1, 3, 6, 9, 12, 14, 16, 17, 18, 18, 18, 17, 16, 14,
     &           12, 9, 6, 3 /
C
      PI = R8PI()
C-----------------------------------------------------------------------
C
      CALL JEMARQ()

C CONSTRUCTION DU VECTEUR CONTENANT DELTA_TAU_MAX
C CONSTRUCTION DU VECTEUR CONTENANT LA VALEUR DU POINTEUR PERMETTANT
C              DE RETROUVER LE VECTEUR NORMAL ASSOCIE A DELTA_TAU_MAX

      CALL WKVECT('&&DELTAU.DTAU_MAX', 'V V R', 209, JDTAUM)
      CALL WKVECT('&&DELTAU.RESU_N', 'V V I', 209, JRESUN)

C CONSTRUCTION DU VECTEUR NORMAL SUR UNE DEMI SPHERE
C CONSTRUCTION DU VECTEUR U DANS LE PLAN TANGENT, SUR UNE DEMI SPHERE
C CONSTRUCTION DU VECTEUR V DANS LE PLAN TANGENT, SUR UNE DEMI SPHERE

      CALL WKVECT( '&&DELTAU.VECT_NORMA', 'V V R', 630, JVECTN )
      CALL WKVECT( '&&DELTAU.VECT_TANGU', 'V V R', 630, JVECTU )
      CALL WKVECT( '&&DELTAU.VECT_TANGV', 'V V R', 630, JVECTV )

C OBTENTION DES ADRESSES '.CESD', '.CESL' ET '.CESV' DU CHAMP SIMPLE
C DESTINE A RECEVOIR LES RESULTATS : DTAUM, ....

      CALL JEVEUO(CESR//'.CESD','L',JCERD)
      CALL JEVEUO(CESR//'.CESL','E',JCERL)
      CALL JEVEUO(CESR//'.CESV','E',JCERV)


C RECUPERATION MAILLE PAR MAILLE DU MATERIAU DONNE PAR L'UTILISATEUR

      CALL GETVID(' ','CHAM_MATER',1,IARG,1,CHMAT1,IRET)
      CHMAT = CHMAT1//'.CHAMP_MAT'
      CESMAT = '&&DELTAU.CESMAT'
      CALL CARCES(CHMAT,'ELEM',' ','V',CESMAT,IRET)
      CALL JEVEUO(CESMAT//'.CESD','L',ICESD)
      CALL JEVEUO(CESMAT//'.CESL','L',ICESL)
      CALL JEVEUO(CESMAT//'.CESV','L',ICESV)

      TNECES = 209*NBORDR*2
      CALL JEDISP(1, TDISP)
      TDISP =  (TDISP * LOISEM()) / LOR8EM()
      IF (TDISP .LT. TNECES ) THEN
         VALI (1) = TDISP
         VALI (2) = TNECES
         CALL U2MESG('F', 'PREPOST5_8',0,' ',2,VALI,0,0.D0)
      ELSE
         CALL WKVECT( '&&DELTAU.VECTPG', 'V V R', TNECES, JVECPG )
         CALL JERAZO( '&&DELTAU.VECTPG', TNECES, 1 )
      ENDIF

      DGAM = 10.0D0

      N = 0
      DIM = 627
      DO 300 J=1, 18
         GAMMA=(J-1)*DGAM*(PI/180.0D0)
         DPHI=TAB1(J)*(PI/180.0D0)
         NGAM=TAB2(J)
         PHI0=DPHI/2.0D0

         CALL VECNUV(1, NGAM, GAMMA, PHI0, DPHI, N, 1, DIM,
     &               ZR(JVECTN), ZR(JVECTU), ZR(JVECTV))

 300  CONTINUE

C CONSTRUCTION DU VECTEUR : CONTRAINTE = F(NUMERO D'ORDRE) EN CHAQUE
C POINT DE GAUSS DU PAQUET DE MAILLES.
      L = 1
      NBPG = 0
      NBPGP = 0
      KWORK = 0
      SOMPGW = 0

      DO 400 IMAP=NMAINI, NMAINI+(NBMAP-1)
         IF ( IMAP .GT. NMAINI ) THEN
           KWORK = 1
           SOMPGW = SOMPGW + ZI(JNBPG + IMAP-2)
         ENDIF
         NBPG = ZI(JNBPG + IMAP-1)
C SI LA MAILLE COURANTE N'A PAS DE POINTS DE GAUSS, LE PROGRAMME
C PASSE DIRECTEMENT A LA MAILLE SUIVANTE.
         IF (NBPG .EQ. 0) THEN
           GOTO 400
         ENDIF

         NBPGP = NBPGP + NBPG
         IF ( (L*INT(NBPGT/10.0D0)) .LT. NBPGP ) THEN
           WRITE(6,*)NUMPAQ,'   ',(NBPGP-NBPG)
           L = L + 1
         ENDIF

C RECUPERATION DU NOM DU MATERIAU AFFECTE A LA MAILLE COURANTE
C ET DES PARAMETRES ASSOCIES AU CRITERE CHOISI POUR LA MAILLE COURANTE.

         OPTIO = 'DOMA_ELGA'
         CALL RNOMAT (ICESD, ICESL, ICESV, IMAP, NOMCRI, IBID, IBID,
     &                IBID, OPTIO, VALA, VALB, COEFPA, NOMMAT)

         CALL RCPARE( NOMMAT, 'FATIGUE', 'WOHLER', ICODWO )
         IF ( ICODWO .EQ. 1 ) THEN
            CALL U2MESK('F','FATIGUE1_90',1,NOMCRI(1:16))
         ENDIF

         DO 420 IPG=1, NBPG

            CALL JERAZO( '&&DELTAU.VECTPG', TNECES, 1 )
            
C REMPACER PAR ACMATA                  
            CALL ACGRDO ( JVECTN, JVECTU, JVECTV, NBORDR, KWORK,
     &                    SOMPGW, JRWORK, TSPAQ, IPG, JVECPG,JDTAUM, 
     &                    JRESUN, NOMMET, NOMMAT, NOMCRI,VALA,
     &                    COEFPA, NOMFOR, GRDVIE, FORVIE, VRESU2)

C 
C C AFFECTATION DES RESULTATS DANS UN CHAM_ELEM SIMPLE

            DO 550 ICMP=1, 24
               CALL CESEXI('C',JCERD,JCERL,IMAP,IPG,1,ICMP,JAD)

C              -- TOUTES LES MAILLES NE SAVENT PAS CALCULER LA FATIGUE :
               IF (JAD.EQ.0) THEN
                 CALL ASSERT (ICMP.EQ.1)
                 CALL ASSERT (IPG.EQ.1)
                 GOTO 400
               ENDIF
               JAD = ABS(JAD)
               ZL(JCERL - 1 + JAD) = .TRUE.
               ZR(JCERV - 1 + JAD) = VRESU2(ICMP)

 550        CONTINUE

 420     CONTINUE
 400  CONTINUE

C MENAGE

      CALL DETRSD('CHAM_ELEM_S',CESMAT)

      CALL JEDETR('&&DELTAU.DTAU_MAX')
      CALL JEDETR('&&DELTAU.RESU_N')
      CALL JEDETR('&&DELTAU.VECT_NORMA')
      CALL JEDETR('&&DELTAU.VECT_TANGU')
      CALL JEDETR('&&DELTAU.VECT_TANGV')

      CALL JEDETR('&&DELTAU.VECTPG')
C
      CALL JEDEMA()
      END
