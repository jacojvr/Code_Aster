      SUBROUTINE CAIMCH (CHARGZ)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 15/02/2005   AUTEUR NICOLAS O.NICOLAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C.======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
C
C       CAIMCH -- TRAITEMENT DU MOT FACTEUR CHAMNO_IMPO
C
C      TRAITEMENT DU MOT FACTEUR CHAMNO_IMPO DE AFFE_CHAR_MECA
C      CE MOT FACTEUR PERMET D'IMPOSER SUR DES DDL DES NOEUDS 
C      D'UN MODELELES VALEURS DES COMPOSANTES DU CHAM_NO DONNE 
C      APRES LE MOT CLE : CHAM_NO.
C
C -------------------------------------------------------
C  CHARGE        - IN    - K8   - : NOM DE LA SD CHARGE
C                - JXVAR -      -   LA  CHARGE EST ENRICHIE
C                                   DE LA RELATION LINEAIRE DECRITE
C                                   CI-DESSUS.
C -------------------------------------------------------
C
C.========================= DEBUT DES DECLARATIONS ====================
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE /ZK8(1),ZK16(1),ZK24(1),ZK32(1), ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ------
C
C -----  ARGUMENTS
      CHARACTER*(*) CHARGZ
C ------ VARIABLES LOCALES
      CHARACTER*1   K1BID
      CHARACTER*2   TYPLAG
      CHARACTER*4   TYCH, TYPVAL, TYPCOE
      CHARACTER*8   K8BID, CHAMNO, NOMA, NOMCMP, NOMNOE, BETAF, M8BLAN
      CHARACTER*8   CHARGE,POSLAG,NOMGD
      CHARACTER*16  MOTFAC
      CHARACTER*19  LISREL, CHAM19, PRCHNO
      CHARACTER*24  NOEUMA
C
      REAL*8        BETA, ALPHA
      COMPLEX*16    BETAC
C
      LOGICAL       EXISDG
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
      CALL JEMARQ()
C
      MOTFAC = 'CHAMNO_IMPO'
C
      CALL GETFAC(MOTFAC,NLIAI)
      IF (NLIAI.EQ.0) GOTO 99999
C
C --- INITIALISATIONS :
C     ---------------
      ZERO = 0.0D0
C --- ALPHA EST LE COEFFICIENT REEL DE LA
C --- RELATION LINEAIRE
C
      ALPHA=1.0D0
C --- BETA, BETAC ET BETAF SONT LES VALEURS DU SECOND MEMBRE DE LA
C --- RELATION LINEAIRE SUIVANT QUE C'EST UN REEL, UN COMPLEXE OU
C --- UNE FONCTION, DANS NOTRE CAS C'EST UN REEL
C
      BETA  = ZERO
      BETAC = (0.0D0,0.0D0)
      BETAF  = '&FOZERO'
C
      CHAM19 = '                   '
      CHARGE = CHARGZ
C
C --- TYPE DES VALEURS AU SECOND MEMBRE DE LA RELATION
C
      TYPVAL = 'REEL'
C
C --- TYPE DES VALEURS DES COEFFICIENTS
C
      TYPCOE = 'REEL'
C
C --- NOM DE LA LISTE_RELA
C
      LISREL = '&CAIMCH.RLLISTE'
C
C --- BOUCLE SUR LES OCCURENCES DU MOT-FACTEUR CHAMNO_IMPO :
C     -------------------------------------------------------
      DO 10 IOCC = 1, NLIAI
C
C ---   ON REGARDE SI LES MULTIPLICATEURS DE LAGRANGE SONT A METTRE
C ---   APRES LES NOEUDS PHYSIQUES LIES PAR LA RELATION DANS LA MATRICE
C ---   ASSEMBLEE :
C ---   SI OUI TYPLAG = '22'
C ---   SI NON TYPLAG = '12'
C
        CALL GETVTX (MOTFAC,'NUME_LAGR',IOCC,1,1,POSLAG,IBID)
        IF (POSLAG.EQ.'APRES') THEN
            TYPLAG = '22'
        ELSE
            TYPLAG = '12'
        ENDIF
C
C ---   RECUPERATION DU CHAMNO
C       ----------------------
         CALL GETVID(MOTFAC,'CHAM_NO',IOCC,1,1,CHAMNO,NB)
         IF (NB.EQ.0) THEN
             CALL UTMESS('F','CAIMCH',
     +                   'ON DOIT UTILISER LE MOT CLE CHAM_NO'//
     +                   ' POUR DONNER LE CHAM_NO DONT LES COMPOSANTES'
     +                 //' SERONT LES SECONDS MEMBRES DE LA RELATION '//
     +                   'LINEAIRE.')
         ENDIF
C
         CHAM19(1:8) = CHAMNO
C
C ---   VERIFICATION DE L'EXISTENCE DU CHAMNO
C       -------------------------------------
         CALL JEEXIN(CHAM19//'.VALE', IRET)
         IF (IRET.EQ.0) THEN
             CALL UTMESS('F','CAIMCH',
     +                   'IL FAUT QUE LE CHAM_NO DONT LES TERMES '//
     +                   ' SERVENT DE SECONDS MEMBRES A LA RELATION'
     +                 //' LINEAIRE A ECRIRE AIT ETE DEFINI. ')
         ENDIF
C
C ---   VERIFICATION DU TYPE DU CHAMP
C       -----------------------------
         CALL DISMOI('F','TYPE_CHAMP',CHAMNO,'CHAM_NO',IBID,TYCH,IER)
C
         IF (TYCH.NE.'NOEU') THEN
             CALL UTMESS('F','CAIMCH',
     +                   'ON DOIT DONNER UN CHAM_NO APRES LE MOT CLE'//
     +                   ' CHAM_NO DERRIERE LE MOT FACTEUR '//
     +                   'CHAMNO_IMPO .')
         ENDIF
C
C ---   RECUPERATION DE LA VALEUR DU SECOND MEMBRE DE LA RELATION
C ---   LINEAIRE
C       --------
         CALL GETVR8(MOTFAC,'COEF_MULT',IOCC,1,1,ALPHA,NB)
         IF (NB.EQ.0) THEN
             CALL UTMESS('F','CAIMCH',
     +                   'IL FAUT DEFINIR LA VALEUR DU COEFFICIENT '//
     +                   ' DE LA RELATION LINEAIRE APRES LE MOT CLE'//
     +                   ' COEF_MULT DERRIERE LE MOT FACTEUR '//
     +                   'CHAMNO_IMPO .')
         ENDIF
C
C ---   RECUPERATION DE LA GRANDEUR ASSOCIEE AU CHAMNO :
C       ----------------------------------------------
         CALL DISMOI('F','NOM_GD',CHAMNO,'CHAM_NO',IBID,NOMGD,IER)
C
C ---   RECUPERATION DU NOMBRE DE MOTS SUR-LESQUELS SONT CODEES LES
C ---   LES INCONNUES ASSOCIEES A LA GRANDEUR DE NOM NOMGD
C       --------------------------------------------------
         CALL DISMOI('F','NB_EC',NOMGD,'GRANDEUR',NBEC,K8BID,IER)
         IF (NBEC.GT.10) THEN
             CALL UTMESS('F','CAIMCH',
     +                   'LE DESCRIPTEUR_GRANDEUR DE LA GRANDEUR'//
     +                    ' DE NOM '//NOMGD//
     +                    ' NE TIENT PAS SUR DIX ENTIERS CODES')
         ENDIF
C
C ---   RECUPERATION DU MAILLAGE ASSOCIE AU CHAM_NO
C       -------------------------------------------
         CALL DISMOI('F','NOM_MAILLA',CHAMNO,'CHAM_NO',IBID,NOMA,IER)
C
C ---   RECUPERATION DU NOMBRE DE NOEUDS DU MAILLAGE
C       --------------------------------------------
         CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOEU,K8BID,
     +               IER)
C
C ---   RECUPERATION DU NOMBRE DE TERMES DU CHAM_NO
C       -------------------------------------------
         CALL DISMOI('F','NB_EQUA',CHAMNO,'CHAM_NO',NEQUA,K8BID,IER)
C
C ---   RECUPERATION DU PROF_CHNO DU CHAM_NO
C       ------------------------------------
         CALL DISMOI('F','PROF_CHNO',CHAMNO,'CHAM_NO',IBID,PRCHNO,IER)
C
C ---   RECUPERATION DU NOMBRE DE COMPOSANTES ASSOCIEES A LA LA GRANDEUR
C       ----------------------------------------------------------------
         CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'LONMAX',NBCMP,
     +               K1BID)
C
C ---   RECUPERATION DU NOM DES COMPOSANTES ASSOCIEES A LA LA GRANDEUR
C       --------------------------------------------------------------
         CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'L',INOCMP)
C
C ---   RECUPERATION DU .VALE DU CHAM_NO
C       --------------------------------
         CALL JEVEUO(CHAM19//'.VALE','E',IDVALE)
C
C ---   RECUPERATION DU .DEEQ DU PROF_CHNO
C       ----------------------------------
         CALL JEVEUO(PRCHNO//'.DEEQ','L',IDEEQ)
C
         NBTERM = NEQUA
C
C ---   CREATION DES TABLEAUX DE TRAVAIL NECESSAIRES A L'AFFECTATION
C ---   DE LA LISTE_RELA
C       ----------------
C ---     VECTEUR DU NOM DES NOEUDS
         CALL WKVECT ('&&CAIMCH.LISNO','V V K8',NBTERM,IDNOEU)
C ---     VECTEUR DU NOM DES DDLS
         CALL WKVECT ('&&CAIMCH.LISDDL','V V K8',NBTERM,IDDDL)
C ---      VECTEUR DES COEFFICIENTS REELS
        CALL WKVECT ('&&CAIMCH.COER','V V R',NBTERM,IDCOER)
C ---     VECTEUR DES COEFFICIENTS COMPLEXES
         CALL WKVECT ('&&CAIMCH.COEC','V V C',NBTERM,IDCOEC)
C ---     VECTEUR DES DIRECTIONS DES DDLS A CONTRAINDRE
         CALL WKVECT ('&&CAIMCH.DIRECT','V V R',3*NBTERM,IDIREC)
C ---     VECTEUR DES DIMENSIONS DE CES DIRECTIONS
         CALL WKVECT ('&&CAIMCH.DIME','V V I',NBTERM,IDIMEN)
C
C ---   COLLECTION DES NOMS DES NOEUDS DU MAILLAGE
C       ------------------------------------------
         NOEUMA = NOMA//'.NOMNOE'
C
C ---   AFFECTATION DES TABLEAUX DE TRAVAIL :
C       -----------------------------------
         K = 0
C
C ---   BOUCLE SUR LES TERMES DU CHAM_NO
C
         DO 30 IEQUA = 1, NEQUA
C
C ---     INO  : NUMERO DU NOEUD INO CORRESPONDANT AU DDL IEQUA
C
            INO = ZI(IDEEQ+2*(IEQUA-1)+1-1)
C
C ---     NUCMP  : NUMERO DE COMPOSANTE CORRESPONDANTE AU DDL IEQUA
C
            NUCMP = ZI(IDEEQ+2*(IEQUA-1)+2-1)
C
C ---     ON NE PREND PAS EN COMPTE LES MULTIPLICATEURS DE LAGRANGE
C ---     (CAS OU NUCMP < 0)
C
            IF (NUCMP.GT.0) THEN
C
C ---       RECUPERATION DU NOM DU NOEUD INO
C
              CALL JENUNO(JEXNUM(NOEUMA,INO),NOMNOE)
C
              VALE = ZR(IDVALE+IEQUA-1)
C
              K = K + 1
              NOMCMP          = ZK8(INOCMP+NUCMP-1)
              ZK8(IDNOEU+K-1) = NOMNOE
              ZK8(IDDDL+K-1)  = NOMCMP
              ZR(IDCOER+K-1)  = ALPHA
              BETA  = VALE
C
C ---       AFFECTATION DE LA RELATION A LA LISTE_RELA  :
C
              CALL AFRELA (ZR(IDCOER+K-1), ZC(IDCOEC+K-1), 
     +                     ZK8(IDDDL+K-1), ZK8(IDNOEU+K-1), 
     +                     ZI(IDIMEN+K-1), RBID, 1, BETA , 
     +                     BETAC, BETAF, TYPCOE, TYPVAL, 
     +                     TYPLAG, LISREL)
            ENDIF
C
 30      CONTINUE
C
         NBTERM = K
C
C ---   MENAGE :
C       ------
         CALL JEDETR('&&CAIMCH.LISNO')
         CALL JEDETR('&&CAIMCH.LISDDL')
         CALL JEDETR('&&CAIMCH.COER')
         CALL JEDETR('&&CAIMCH.COEC')
         CALL JEDETR('&&CAIMCH.DIRECT')
         CALL JEDETR('&&CAIMCH.DIME')
C
 10   CONTINUE
C
C --- AFFECTATION DE LA LISTE_RELA A LA CHARGE :
C     ----------------------------------------
      CALL AFLRCH(LISREL,CHARGE)
C
C --- MENAGE :
C     ------
      CALL JEDETR(LISREL)
C
99999 CONTINUE
C
      CALL JEDEMA()
C.============================ FIN DE LA ROUTINE ======================
      END
