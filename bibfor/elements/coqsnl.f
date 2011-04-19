      SUBROUTINE COQSNL( NOMTE, OPT, GEOM, IMATE, IMATSE,
     &                   COMPOR, CACOQ, CAC3D, NBCOU, LGPG, UM, UP,
     &                   SIGMOS, VARMOS, SIGMOI, VARMOI, STYPSE, SIGPAS,
     &                   SIGPLU, VARPLU, US, DUS, VECTU, SIGPLS, VARPLS)
      IMPLICIT  NONE
      INTEGER         NBCOU, LGPG, IMATE, IMATSE
      REAL*8          GEOM(3,9), UM(*), UP(*), CACOQ(6)
      REAL*8          SIGMOS(6,*), VARMOS(LGPG,*), US(*), DUS(*)
      REAL*8          SIGMOI(6,*), VARMOI(LGPG,*), CAC3D
      REAL*8          SIGPLU(6,*), VARPLU(LGPG,*), SIGPAS(6,*)
      REAL*8          VECTU(*), SIGPLS(6,*), VARPLS(LGPG,*)
      CHARACTER*16    NOMTE, OPT, COMPOR(6)
      CHARACTER*24    STYPSE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
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
C TOLE CRP_20
C TOLE CRP_21
C     ------------------------------------------------------------------
C     CALCULS DE SENSIBILITE POUR L'ELEMENT COQUE_3D
C     ------------------------------------------------------------------
C IN  NOMTE    : NOM DU TYPE ELEMENT
C IN  OPT      : OPTION A CALCULER :
C         'MECA_SENS_MATE'  SENSIBILITE PAR RAPPORT AU MATERIAU
C         'MECA_SENS_CHAR'  SENSIBILITE PAR RAPPORT AU CHARGEMENT
C         'MECA_SENS_RAPH'  CONTRAINTES ET VARIABLES INTERNES SENSIBLES
C IN  GEOM    : COORDONNEES DES NOEUDS EN GLOBAL
C IN  IMATE   : MATERIAU CODE
C IN  IMATSE  : MATERIAU CODE SENSIBLE
C IN  COMPOR  : COMPORTEMENT
C IN  CACOQ   : CARAC COQUES
C IN  CAC3D   : COEF ROTATION FICTIVE
C IN  NBCOU   : NOMBRE DE COUCHES (INTEGRATION DE LA PLASTICITE)
C IN  LGPG    : "LONGUEUR" DES VARIABLES INTERNES POUR 1 POINT DE GAUSS
C               CETTE LONGUEUR EST UN MAJORANT DU NBRE REEL DE VAR. INT.
C IN  UM      : DEPLACEMENT A L'INSTANT -
C IN  UP      : INCREMENT DE DEPLACEMENT
C IN  SIGMOS  : CONTRAINTES SENSIBLE A L'INSTANT -
C IN  VARMOS  : V. INTERNES SENSIBLE A L'INSTANT -
C IN  SIGMOI  : CONTRAINTES A L'INSTANT PRECEDENT
C IN  VARMOI  : V. INTERNES A L'INSTANT -
C IN  STYPSE  : SOUS-TYPE DE SENSIBILITE
C IN  SIGPAS  : CONTRAINTES SENSIBLES PARTIELLES A L'INSTANT +
C IN  SIGPLU  : CONTRAINTES A L'INSTANT +
C IN  VARPLU  : V. INTERNES A L'INSTANT +
C IN  US      : DEPLACEMENT SENSIBLE A L'INSTANT -
C IN  DUS     : INCR DE DEPLACEMENT SENSIBLE
C OUT VECTU   : FORCES NODALES (MECA_SENS_MATE ET MECA_SENS_CHAR)
C OUT SIGPLS  : CONTRAINTES SENSIBLES A L'INSTANT +
C OUT VARPLS  : V. INTERNES SENSIBLES A L'INSTANT +
C     ------------------------------------------------------------------
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
      INTEGER VALRET(2)
      CHARACTER*8 NOMRES(2),TYPMOD(2)
      CHARACTER*10 PHENOM
      INTEGER NB1,NB2,NDDLE,NPGE,NPGSR,NPGSN,ITAB(8),IB
      INTEGER KSP,LZI,LZR,NBVARI,NBV,KWGT,KPGS,INTE,INTSR,INTSN
      INTEGER IRET,IVSP, J, NBSP, I, ICOU, ICPG, KL
      REAL*8 SIGM(6),SIGP(6),SIGMS(6),SIGPS(6),SIPAS(6),DEDT(6),RAC2
      REAL*8 VECTA(9,2,3),VECTN(9,3),VECTPT(9,2,3),VECPT(9,3,3),HSF(3,9)
      REAL*8 HSFM(3,9),HSS(2,9),HSJ1M(3,9),HSJ1S(2,9),HSJ1FX(3,9),WGT
      REAL*8 BTDM(4,3,42),BTDS(4,2,42),EPS2D(4),DEPS2D(4),DEDT2D(4)
      REAL*8 BTDF(3,42),BTILD(5,42),E,NU,ES,NUS,DERCIS,UNPLNU,DEPSI(5)
      REAL*8 VECTG(2,3),VECTT(3,3),VALRES(26),EPAIS,KAPPA,CISAIL
      REAL*8 DEPLM(42),DEPLP(42),DEPLMS(42),DEPLPS(42),ROTFCM(9),EPSI(5)
      REAL*8 SGMTD(5),EFFINT(42),VECL(48),VECLL(51),ROTFCP(9)
      REAL*8 CRF,ZMIN,HIC,ZIC,COEF,KSI3S2,X,GXZ,GYZ

      PARAMETER (NPGE=3)
C ----------------------------------------------------------------------
C
      RAC2 = SQRT(2.D0)
      TYPMOD(1) = 'C_PLAN  '
      TYPMOD(2) = '        '
      NBV    = 2
      NOMRES(1) = 'E'
      NOMRES(2) = 'NU'

      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESI',' ',LZI)
      NB1 = ZI(LZI-1+1)
      NB2 = ZI(LZI-1+2)
      NPGSR = ZI(LZI-1+3)
      NPGSN = ZI(LZI-1+4)

      NDDLE = 5*NB1 + 2
      DO 20 I = 1,NDDLE
        EFFINT(I) = 0.D0
   20 CONTINUE

      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESR',' ',LZR)
C
      IF (NBCOU.LE.0) CALL U2MESS('F','ELEMENTS_12')
      IF (NBCOU.GT.10) CALL U2MESS('F','ELEMENTS_13')
      READ (COMPOR(2),'(I16)') NBVARI
      CALL TECACH('OON','PVARIMR',7,ITAB,IRET)
      NBSP  = ITAB(7)
      EPAIS = CACOQ(1)
      CRF   = CAC3D
      KAPPA = CACOQ(4)
      ZMIN  = -EPAIS/2.D0
      HIC   = EPAIS/NBCOU

      CALL VECTAN(NB1,NB2,GEOM,ZR(LZR),VECTA,VECTN,VECTPT)
      CALL RCCOMA(IMATE,'ELAS',PHENOM,VALRET)

      IF ( PHENOM.NE.'ELAS') THEN
         CALL U2MESS('F','ELEMENTS_42')
      END IF

C===============================================================
C     CALCULS DES 2 DDL INTERNES
C    DEPLM ET DEPLP SONT EN REPERE LOCAL
      CALL TRNDGL(NB2,VECTN,VECTPT,UM,DEPLM,ROTFCM)
      CALL TRNDGL(NB2,VECTN,VECTPT,UP,DEPLP,ROTFCP)
      IF(OPT(1:14).EQ.'MECA_SENS_RAPH') THEN
        CALL TRNDGL(NB2,VECTN,VECTPT,US,DEPLMS,ROTFCM)
        CALL TRNDGL(NB2,VECTN,VECTPT,DUS,DEPLPS,ROTFCP)
      END IF
C
      KWGT = 0
      KPGS = 0
      DO 140 ICOU = 1,NBCOU
        DO 130 INTE = 1,NPGE
          IF (INTE.EQ.1) THEN
            ZIC = ZMIN + (ICOU-1)*HIC
            COEF = 1.D0/3.D0
          ELSE IF (INTE.EQ.2) THEN
            ZIC = ZMIN + HIC/2.D0 + (ICOU-1)*HIC
            COEF = 4.D0/3.D0
          ELSE
            ZIC = ZMIN + HIC + (ICOU-1)*HIC
            COEF = 1.D0/3.D0
          END IF
          KSI3S2 = ZIC/HIC

C     CALCUL DE BTDMR, BTDSR : M=MEMBRANE , S=CISAILLEMENT , R=REDUIT

          DO 60 INTSR = 1,NPGSR
            CALL MAHSMS(0,NB1,GEOM,KSI3S2,INTSR,ZR(LZR),HIC,VECTN,VECTG,
     &                  VECTT,HSFM,HSS)

            CALL HSJ1MS(HIC,VECTG,VECTT,HSFM,HSS,HSJ1M,HSJ1S)

            CALL BTDMSR(NB1,NB2,KSI3S2,INTSR,ZR(LZR),HIC,VECTPT,
     &                  HSJ1M,HSJ1S,BTDM,BTDS)
   60     CONTINUE

C     BOUCLE SUR LES PTS DE GAUSS
          DO 120 INTSN = 1,NPGSN
            KSP = (ICOU-1)*NPGE+INTE
            ICPG = (INTSN-1)*NBSP + KSP
            IVSP = (ICOU-1)*NPGE*NBVARI + NBVARI*(INTE-1)+1
C     CALCUL DE BTDFN : F=FLEXION , N=NORMAL
C     ET DEFINITION DE WGT=PRODUIT DES POIDS ASSOCIES AUX PTS DE GAUSS
C                          (NORMAL) ET DU DETERMINANT DU JACOBIEN

            CALL MAHSF(1,NB1,GEOM,KSI3S2,INTSN,ZR(LZR),HIC,VECTN,VECTG,
     &                 VECTT,HSF)

            CALL HSJ1F(INTSN,ZR(LZR),HIC,VECTG,VECTT,HSF,KWGT,
     &                 HSJ1FX,WGT)

C     PRODUIT DU POIDS DES PTS DE GAUSS DANS L'EPAISSEUR ET DE WGT

            WGT = COEF*WGT

            CALL BTDFN(1,NB1,NB2,KSI3S2,INTSN,ZR(LZR),HIC,VECTPT,
     &                 HSJ1FX,BTDF)

C     CALCUL DE BTDMN, BTDSN
C     ET
C     FORMATION DE BTILD

            CALL BTDMSN(1,NB1,INTSN,NPGSR,ZR(LZR),BTDM,BTDF,
     &                  BTDS,BTILD)

C     CALCULS DES COMPOSANTES DE DEFORMATIONS TRIDIMENSIONNELLES :
C     EPSXX, EPSYY, EPSXY, EPSXZ, EPSYZ (CE SONT LES COMPOSANTES TILDE)
            KPGS = KPGS + 1
            IF(OPT.EQ.'MECA_SENS_MATE'.OR.OPT.EQ.'MECA_SENS_CHAR') THEN
              CALL EPSEFF('DEFORM',NB1,DEPLM,BTILD,X,EPSI,WGT,X)
              EPS2D(1) = EPSI(1)
              EPS2D(2) = EPSI(2)
              EPS2D(3) = 0.D0
              EPS2D(4) = EPSI(3)/RAC2

              CALL EPSEFF('DEFORM',NB1,DEPLP,BTILD,X,DEPSI,WGT,X)
              DEPS2D(1) = DEPSI(1)
              DEPS2D(2) = DEPSI(2)
              DEPS2D(3) = 0.D0
              DEPS2D(4) = DEPSI(3)/RAC2

              GXZ = EPSI(4) + DEPSI(4)
              GYZ = EPSI(5) + DEPSI(5)
C
            ELSE IF(OPT(1:14).EQ.'MECA_SENS_RAPH') THEN
              CALL EPSEFF('DEFORM',NB1,DEPLMS,BTILD,X,EPSI,WGT,X)
              EPS2D(1) = EPSI(1)
              EPS2D(2) = EPSI(2)
              EPS2D(3) = 0.D0
              EPS2D(4) = EPSI(3)/RAC2

              CALL EPSEFF('DEFORM',NB1,DEPLPS,BTILD,X,DEPSI,WGT,X)
              DEPS2D(1) = DEPSI(1)
              DEPS2D(2) = DEPSI(2)
              DEPS2D(3) = 0.D0
              DEPS2D(4) = DEPSI(3)/RAC2

              GXZ = EPSI(4) + DEPSI(4)
              GYZ = EPSI(5) + DEPSI(5)
C
              CALL EPSEFF('DEFORM',NB1,DEPLP,BTILD,X,DEDT,WGT,X)
              DEDT2D(1) = DEDT(1)
              DEDT2D(2) = DEDT(2)
              DEDT2D(3) = 0.D0
              DEDT2D(4) = DEDT(3)/RAC2
            END IF

            DO 44 I = 1,3
              SIGMS(I) = SIGMOS(I,ICPG)
   44       CONTINUE
            DO 50 I = 4,6
              SIGMS(I) = SIGMOS(I,ICPG)*RAC2
   50       CONTINUE
C
            DO 41 I = 1,3
              SIGM(I) = SIGMOI(I,ICPG)
   41       CONTINUE
            DO 51 I = 4,6
              SIGM(I) = SIGMOI(I,ICPG)*RAC2
   51       CONTINUE
C
            DO 42 I = 1,3
              SIGP(I) = SIGPLU(I,ICPG)
   42       CONTINUE
            DO 52 I = 4,6
              SIGP(I) = SIGPLU(I,ICPG)*RAC2
   52       CONTINUE

            IF (OPT(1:14).EQ.'MECA_SENS_RAPH') THEN
              DO 54 I = 1,3
               SIPAS(I) = SIGPAS(I,ICPG)
   54         CONTINUE
              DO 56 I = 4,6
                SIPAS(I) = SIGPAS(I,ICPG)*RAC2
   56         CONTINUE
            ELSE
              DO 57 I = 1,6
                SIPAS(I) = 0.D0
   57         CONTINUE
            ENDIF

C   -- APPEL A NSCOMP POUR RESOUDRE LE PB DERIVE SUR LA COUCHE :
C   ------------------------------------------------------------
           CALL NSCOMP(OPT,TYPMOD,COMPOR,3,IMATE,IMATSE,EPS2D,
     &                 DEPS2D,DEDT2D,SIGMS,VARMOS(IVSP,INTSN),
     &                 VARMOI(IVSP,INTSN),SIGM,VARPLU(IVSP,INTSN),
     &                 SIPAS,SIGP,SIGPS,VARPLS(IVSP,INTSN),STYPSE)

C            DIVISION DE LA CONTRAINTE DE CISAILLEMENT PAR SQRT(2)
C            POUR STOCKER LA VALEUR REELLE
           DO 90 KL = 1,3
             SIGPLS(KL,ICPG) = SIGPS(KL)
   90      CONTINUE
           DO 95 KL = 4,6
             SIGPLS(KL,ICPG) = SIGPS(KL)/RAC2
   95      CONTINUE
C
            IF (PHENOM.EQ.'ELAS') THEN
              NBV = 2
              NOMRES(1) = 'E'
              NOMRES(2) = 'NU'
            ELSE
              CALL U2MESS('F','ELEMENTS_42')
            END IF

            CALL RCVALB('MASS',INTSN,KSP,'+',IMATE,' ',PHENOM,
     &                    0,' ',0.D0,NBV,NOMRES,VALRES,VALRET,1)

            E=VALRES(1)
            NU=VALRES(2)
            UNPLNU=1.D0+NU
            CISAIL = E/UNPLNU
C
            IF(OPT.EQ.'MECA_SENS_MATE'.OR.
     &         OPT.EQ.'MECA_SENS_CHAR') THEN

C    CALCULS DES EFFORTS INTERIEURS
              SGMTD(1) = SIGPLS(1,ICPG)
              SGMTD(2) = SIGPLS(2,ICPG)
              SGMTD(3) = SIGPLS(4,ICPG)
              SGMTD(4) = SIGPLS(5,ICPG)
              SGMTD(5) = SIGPLS(6,ICPG)
              IF(OPT.EQ.'MECA_SENS_MATE') THEN
                CALL RCVALB('MASS',INTSN,KSP,'+',IMATSE,' ',PHENOM,
     &                      0,' ',0.D0,NBV,NOMRES,VALRES,VALRET,1)
                ES =VALRES(1)
                NUS=VALRES(2)
                DERCIS=(ES*UNPLNU-E*NUS)/(UNPLNU*UNPLNU)
                SGMTD(4) = DERCIS*KAPPA*GXZ/2.D0
                SGMTD(5) = DERCIS*KAPPA*GYZ/2.D0
              ELSE IF(OPT.EQ.'MECA_SENS_CHAR') THEN
                SGMTD(4) = 0.D0
                SGMTD(5) = 0.D0
              END IF
              SIGPLS(5,ICPG) = SGMTD(4)
              SIGPLS(6,ICPG) = SGMTD(5)

              CALL EPSEFF('EFFORI',NB1,X,BTILD,SGMTD,X,WGT,EFFINT)

            ELSE IF(OPT(1:14).EQ.'MECA_SENS_RAPH') THEN
              SIGPLS(5,ICPG) = SIPAS(5)/RAC2 + CISAIL*KAPPA*GXZ/2.D0
              SIGPLS(6,ICPG) = SIPAS(6)/RAC2 + CISAIL*KAPPA*GYZ/2.D0
            END IF
C
 120     CONTINUE
 130     CONTINUE
 140   CONTINUE
C
      IF(OPT.EQ.'MECA_SENS_MATE'.OR.
     &   OPT.EQ.'MECA_SENS_CHAR') THEN

C       -- CALCUL DU SECOND MEMBRE DR/DPS:
C       ---------------------------------
        CALL VEXPAN(NB1,EFFINT,VECL)

        DO 150 I = 1,6*NB1
          VECLL(I) = VECL(I)
  150   CONTINUE
        VECLL(6*NB1+1) = EFFINT(5*NB1+1)
        VECLL(6*NB1+2) = EFFINT(5*NB1+2)
        VECLL(6*NB1+3) = 0.D0

C     CONTRIBUTION DES DDL DE LA ROTATION FICTIVE DANS EFFINT

        DO 160 I = 1,NB1
          VECLL(6*I) = CRF* (ROTFCM(I)+ROTFCP(I))
  160   CONTINUE
        VECLL(6*NB1+3) = CRF* (ROTFCM(NB2)+ROTFCP(NB2))
C     TRANFORMATION DANS REPERE GLOBAL PUIS STOCKAGE
        DO 190 IB = 1,NB2
          DO 180 I = 1,2
            DO 170 J = 1,3
              VECPT(IB,I,J) = VECTPT(IB,I,J)
  170       CONTINUE
  180     CONTINUE
          VECPT(IB,3,1) = VECTN(IB,1)
          VECPT(IB,3,2) = VECTN(IB,2)
          VECPT(IB,3,3) = VECTN(IB,3)
  190   CONTINUE

        CALL TRNFLG(NB2,VECPT,VECLL,VECTU)

        DO 155 I = 1,51
          VECTU(I)=-VECTU(I)
  155   CONTINUE

      ENDIF

      END
