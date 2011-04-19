      SUBROUTINE TE0141(OPTION,NOMTE)
      IMPLICIT NONE
      CHARACTER*(*) OPTION,NOMTE
C     ------------------------------------------------------------------
C MODIF ELEMENTS  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     CALCULE LA MATRICE DE MASSE ELEMENTAIRE DES ELEMENTS DE POUTRE
C     D'EULER ET DE TIMOSHENKO
C     ------------------------------------------------------------------
C IN  OPTION : K16 : NOM DE L'OPTION A CALCULER
C       'MASS_MECA'      : CALCUL DE LA MATRICE DE MASSE COHERENTE
C       'MASS_MECA_DIAG' : CALCUL DE LA MATRICE DE MASSE CONCENTREE
C       'MASS_MECA_EXPLI': ......
C       'MASS_FLUI_STRU' : CALCUL DE LA MATRICE DE MASSE AJOUTEE
C       'M_GAMMA'        : CALCUL DU VECTEUR M_GAMMA
C IN  NOMTE  : K16 : NOM DU TYPE ELEMENT
C       'MECA_POU_D_E'  : POUTRE DROITE D'EULER       (SECTION VARIABLE)
C       'MECA_POU_D_T'  : POUTRE DROITE DE TIMOSHENKO (SECTION VARIABLE)
C       'MECA_POU_C_T'  : POUTRE COURBE DE TIMOSHENKO(SECTION CONSTANTE)
C       'MECA_POU_D_EM' : POUTRE DROITE MULTIFIBRE D EULER (SECT. CONST)
C       'MECA_POU_D_TG' : POUTRE DROITE DE TIMOSHENKO (GAUCHISSEMENT)
C       'MECA_POU_D_TGM': POUTRE DROITE DE TIMOSHENKO (GAUCHISSEMENT)
C                         MULTI-FIBRES SECTION CONSTANTE
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

      INTEGER NBRES
      PARAMETER (NBRES=6)
      REAL*8 VALRES(NBRES),VALPAR
      INTEGER CODRES(NBRES)
      CHARACTER*8 NOMPAR,NOMRES(NBRES),NOMAIL
      CHARACTER*16 CH16
      INTEGER I, LMATER, IRET, NBPAR, LCAGE, LABSC
      INTEGER LORIEN, IACCE, IVECT, LRCOU, LMAT
      INTEGER NNO, NC, NTC, NBV, KANL
      INTEGER ITYPE, ISTRUC, LSECT, LX,IADZI,IAZK24
      REAL*8  XL, RAD, ANGS2
      REAL*8  ZERO, UN, DEUX, ABSMOY, ANGARC, TRIGOM
      REAL*8  E, G, XNU, RHO, RHOS, RHOFI, RHOFE, CM, PHIE, PHII
      REAL*8  A, XIY, XIZ, ALFAY, ALFAZ, EY, EZ
      REAL*8  PGL(3,3),PGL1(3,3),PGL2(3,3),MLV(105)
      REAL*8  MATV(105),MATP(14,14),MATP1(105)
C     ------------------------------------------------------------------
      DATA NOMRES/'E','NU','RHO','RHO_F_IN','RHO_F_EX','CM'/
C     ------------------------------------------------------------------
      ZERO = 0.D0
      UN   = 1.D0
      DEUX = 2.D0
C     ------------------------------------------------------------------

C     --- CARACTERISTIQUES DES ELEMENTS
C
      NNO = 2
      NC = 6
      IF(NOMTE.EQ.'MECA_POU_D_TG' .OR. NOMTE.EQ.'MECA_POU_D_TGM') THEN
         NNO    = 2
         NC     = 7
         ITYPE  = 0
         ISTRUC = 1
      ENDIF
      NTC = NC*NNO
      NBV = NTC*(NTC+1)/2
C
C     --- RECUPERATION DES CARACTERISTIQUES MATERIAUX ---

      DO 10 I = 1,NBRES
         VALRES(I) = ZERO
10    CONTINUE

      CALL JEVECH('PMATERC','L',LMATER)
      CALL MOYTEM('RIGI',2,1,'+',VALPAR,IRET)
      NOMPAR = 'TEMP'
      NBPAR = 1

      IF (OPTION.EQ.'MASS_FLUI_STRU') THEN
         CALL JEVECH('PCAGEPO','L',LCAGE)
         CALL JEVECH('PABSCUR','L',LABSC)
         ABSMOY = (ZR(LABSC-1+1)+ZR(LABSC-1+2))/DEUX
         CALL RCVALA(ZI(LMATER),' ','ELAS_FLUI',1,'ABSC',ABSMOY,NBRES,
     &               NOMRES,VALRES,CODRES,1)
         E = VALRES(1)
         XNU = VALRES(2)
         RHOS = VALRES(3)
         RHOFI = VALRES(4)
         RHOFE = VALRES(5)
         CM = VALRES(6)
         PHIE = ZR(LCAGE-1+1)*DEUX
         G   = E / ( DEUX * ( UN + XNU ) )
         IF (PHIE.EQ.0.D0) THEN
            CALL U2MESS('F','ELEMENTS3_26')
         END IF
         PHII = (PHIE-DEUX*ZR(LCAGE-1+2))
         CALL RHOEQU(RHO,RHOS,RHOFI,RHOFE,CM,PHII,PHIE)

      ELSE IF (OPTION.EQ.'MASS_MECA' .OR.
     &         OPTION.EQ.'MASS_MECA_DIAG' .OR.
     &         OPTION.EQ.'MASS_MECA_EXPLI' .OR.
     &         OPTION.EQ.'M_GAMMA') THEN
         IF(NOMTE.NE.'MECA_POU_D_EM')THEN
            CALL RCVALA(ZI(LMATER),' ','ELAS',NBPAR,NOMPAR,VALPAR,3,
     &                  NOMRES,VALRES,CODRES,1)
            E = VALRES(1)
            XNU = VALRES(2)
            RHO = VALRES(3)
            G   = E / ( DEUX * ( UN + XNU ) )
         ENDIF
      ELSE
         CH16 = OPTION
         CALL U2MESK('F','ELEMENTS2_47',1,CH16)
      END IF
C     --- CARACTERISTIQUES GENERALES DES SECTIONS ---
      IF(NOMTE.EQ.'MECA_POU_D_TG'.OR. NOMTE.EQ.'MECA_POU_D_TGM')THEN
         CALL JEVECH('PCAGNPO','L',LSECT)
         LSECT = LSECT - 1
         A = ZR(LSECT+1)
         XIY = ZR(LSECT+2)
         XIZ = ZR(LSECT+3)
         ALFAY = ZR(LSECT+4)
         ALFAZ = ZR(LSECT+5)
         EY = -ZR(LSECT+6)
         EZ = -ZR(LSECT+7)
      ENDIF
C     --- COORDONNEES DES NOEUDS ---
      CALL JEVECH('PGEOMER','L',LX)
      LX = LX - 1
      XL = SQRT( (ZR(LX+4)-ZR(LX+1))**2 +
     &           (ZR(LX+5)-ZR(LX+2))**2 +
     &           (ZR(LX+6)-ZR(LX+3))**2)
      IF (XL.EQ.ZERO) THEN
        CALL TECAEL(IADZI,IAZK24)
        NOMAIL = ZK24(IAZK24-1+3)(1:8)
        CALL U2MESK('F','ELEMENTS2_43',1,NOMAIL)
      ENDIF

C     --- RECUPERATION DES ORIENTATIONS ---
      CALL JEVECH('PCAORIE','L',LORIEN)

C     --- CALCUL DE LA MATRICE DE MASSE LOCALE ---
      KANL = 1
      IF (OPTION.EQ.'MASS_MECA_DIAG' .OR.
     &    OPTION.EQ.'MASS_MECA_EXPLI') KANL = 0

      IF (NOMTE.EQ.'MECA_POU_D_EM') THEN
         CALL PMFMAS(NOMTE,ZI(LMATER),KANL,MLV)
      ELSE IF (NOMTE.EQ.'MECA_POU_D_TG'.OR.
     &         NOMTE.EQ.'MECA_POU_D_TGM') THEN
         DO 20 I = 1 , 105
            MATP1(I) = 0.0D0
20       CONTINUE
         CALL PTMA01(KANL,ITYPE,MATP1,ISTRUC,RHO,E,A,A,XL,XIY,XIY,XIZ,
     &                XIZ,G,ALFAY,ALFAY,ALFAZ,ALFAZ,EY,EZ )
         DO 100 I = 1 , 21
            MLV(I) = MATP1(I)
100      CONTINUE
         DO 102 I = 22 , 28
            MLV(I) = 0.D0
102      CONTINUE
         DO 104 I = 29 , 34
            MLV(I) = MATP1(I-7)
104      CONTINUE
         MLV(35) = 0.D0
         DO 106 I = 36 , 42
            MLV(I) = MATP1(I-8)
106      CONTINUE
         MLV(43) = 0.D0
         DO 108 I = 44 , 51
            MLV(I) = MATP1(I-9)
108      CONTINUE
         MLV(52) = 0.D0
         DO 110 I = 53 , 61
            MLV(I) = MATP1(I-10)
110      CONTINUE
         MLV(62) = 0.D0
         DO 112 I = 63 , 72
            MLV(I) = MATP1(I-11)
112      CONTINUE
         MLV(73) = 0.D0
         DO 114 I = 74 , 84
            MLV(I) = MATP1(I-12)
114      CONTINUE
         MLV(85) = 0.D0
         DO 116 I = 86 , 91
            MLV(I) = MATP1(I-13)
116      CONTINUE
         DO 118 I = 92 , 105
            MLV(I) = 0.D0
118      CONTINUE
      ELSE
         CALL POMASS(NOMTE,E,XNU,RHO,KANL,MLV)
      END IF

      IF (OPTION.EQ.'M_GAMMA') THEN
         CALL JEVECH('PDEPLAR','L',IACCE)
         CALL JEVECH('PVECTUR','E',IVECT)
         IF (NOMTE(1:12).EQ.'MECA_POU_D_E' .OR.
     &       NOMTE(1:12).EQ.'MECA_POU_D_T') THEN
            CALL MATROT(ZR(LORIEN),PGL)
            CALL UTPSLG(NNO,NC,PGL,MLV,MATV)

         ELSE IF (NOMTE.EQ.'MECA_POU_C_T') THEN
            CALL JEVECH('PCAARPO','L',LRCOU)
            RAD = ZR(LRCOU)
            ANGARC = ZR(LRCOU+1)
            ANGS2 = TRIGOM('ASIN',XL/ (DEUX*RAD))
            CALL MATRO2(ZR(LORIEN),ANGARC,ANGS2,PGL1,PGL2)
            CALL CHGREP('LG',PGL1,PGL2,MLV,MATV)

         ELSE
            CH16 = NOMTE
            CALL U2MESK('F','ELEMENTS2_42',1,CH16)
         END IF
         CALL VECMA(MATV,NBV,MATP,NTC)
         CALL PMAVEC('ZERO',NTC,MATP,ZR(IACCE),ZR(IVECT))
      ELSE
         CALL JEVECH('PMATUUR','E',LMAT)

         IF (NOMTE(1:12).EQ.'MECA_POU_D_E' .OR.
     &       NOMTE(1:12).EQ.'MECA_POU_D_T') THEN
            CALL MATROT(ZR(LORIEN),PGL)
            CALL UTPSLG(NNO,NC,PGL,MLV,ZR(LMAT))
         ELSE IF (NOMTE.EQ.'MECA_POU_C_T') THEN
            CALL JEVECH('PGEOMER','L',LX)
            CALL JEVECH('PCAARPO','L',LRCOU)
            RAD = ZR(LRCOU)
            ANGARC = ZR(LRCOU+1)
            ANGS2 = TRIGOM('ASIN',XL/ (DEUX*RAD))
            CALL MATRO2(ZR(LORIEN),ANGARC,ANGS2,PGL1,PGL2)
            CALL CHGREP('LG',PGL1,PGL2,MLV,ZR(LMAT))
         ELSE
            CH16 = NOMTE
            CALL U2MESK('F','ELEMENTS2_42',1,CH16)
         END IF
      END IF

      END
