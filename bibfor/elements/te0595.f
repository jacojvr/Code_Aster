      SUBROUTINE TE0595(OPTION,NOMTE)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 21/07/2009   AUTEUR LEBOUVIER F.LEBOUVIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C-----------------------------------------------------------------------
C    - CE PROGRAMME EST INSPIRE DE TE0075
C      LES MODIFICATIONS DE L'UN OU DE L'AUTRE DOIVENT ETRE SIMULTANEES

C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          OPTION : 'CHAR_DLAG_FLUN_F'

C      ( THTIMP.(Q+) + (1-THTIMP).(Q-) ) . DIV_SURF(THETA) . T*
C    + THETA . ( THTIMP.(GRAD(Q+)) + (1-THTIMP).(GRAD(Q-)) ) . T*

C    - LE FLUX EST CONSTANT PAR ELEMENT, DONC LE SECOND TERME EST NUL
C      ON EST FORCEMENT EN TRANSITOIRE, VU QUE LE FLUX DEPENT DU TEMPS

C    - BORDS D'ELEMENTS ISOPARAMETRIQUES 2D

C    - ON NE FAIT AUCUN CALCUL SUR UN ELEMENT OU LE CHAMP THETA EST NUL
C      SUR TOUS LES NOEUDS. EN EFFET, DANS CE CAS LA DIVERGENCE
C      SURFACIQUE DE THETA EST NULLE SUR TOUS LES POINTS DE GAUSS DE
C      L'ELEMENT. DU COUP, LA CONTRIBUTION AU SECOND MEMBRE EST NULLE.

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C       JEVEUX: JEVETE, JEVECH.
C       ELEMENT_FINI: CONNEC, VFF2DN.
C       GEOM. DIFF. : SUBAC1, SUMETR, SUBACV.
C       DIVERS: FOINTE.

C     FONCTIONS INTRINSEQUES:
C       R8PREM, ABS.
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C      28/08/00 (OB): TOILETTAGE FORTRAN, REMPLACEMENT DU TEST SUR
C                     GRAD_THETA PAR UN TEST EN THETA. CALCUL DE LA
C                     DIVERGENCE SURFACIQUE PAR LA BASE CONTRAVARIANTE
C                     -> SUPPRESSION DU RECOURS AU GRADIENT ET A LA
C                     DIVERGENCE VOLUMIQUE APPROXIMES DE THETA QUI EST
C                     PAR DEFINITION SURFACIQUE !
C                     CORRECTION DU CALCUL DU POIDS EN AXI.
C-----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      CHARACTER*16 OPTION,NOMTE

C DECLARATION VARIABLES LOCALES
      INTEGER NBRES
      PARAMETER (NBRES=3)

      CHARACTER*8 NOMPAR(NBRES), ELREFE,ALIAS8

      REAL*8 COORSE(18),VECTT(9),R,Z,NX,NY,POIDS
      REAL*8 R8AUX,THETAR,EPSI,R8PREM,THTIMP,UNMTHE
      REAL*8 FLUX,FLUN,VALPAR(NBRES)
      REAL*8 COVA(3,3),METR(2,2),JAC,CNVA(3,2),A(2,2),DIVS
      INTEGER IGEOM,IVECTT,IPOIDS,IVF,IDFDE
      INTEGER NNO,NNOS,JGANO,NDIM,NPG,NSE,NNOP2,C(6,9),ISE,KP,I,K,IDEB
      INTEGER IFIN,ICODE,IFLU,ITHETA,ITEMPS,IBID
      LOGICAL THTNUL,AXI,THEGA1,LTEATT

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

C====
C 1. INITIALISATIONS ET CONTROLE DE LA NULLITE DE THETA
C====
      EPSI = R8PREM()
      CALL ELREF1(ELREFE)
C
      IF ( LTEATT(' ','LUMPE','OUI')) THEN
         CALL TEATTR(' ','S','ALIAS8',ALIAS8,IBID)
         IF (ALIAS8(6:8).EQ.'SE3')  ELREFE='SE2'
      END IF
C
      CALL ELREF4(ELREFE,'RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,
     +            IVF,IDFDE,JGANO)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PVECTTH','L',ITHETA)
      CALL JEVECH('PVECTTR','E',IVECTT)
      CALL CONNEC(NOMTE,NSE,NNOP2,C)

      DO 10,I = 1,NNOP2
        VECTT(I) = 0.D0
   10 CONTINUE

      IDEB = ITHETA
      IFIN = ITHETA + 2*NNO - 1
      THTNUL = .TRUE.
      DO 20,I = IDEB,IFIN
        IF (ABS(ZR(I)).GT.EPSI) THEN
          THTNUL = .FALSE.
        END IF
   20 CONTINUE

C====
C 2. CALCUL QUAND LE VECTEUR THETA N'EST PAS NUL
C====

      IF (.NOT.THTNUL) THEN

C 2.1. ==> FIN DES INITIALISATIONS


        CALL JEVECH('PFLUXNF','L',IFLU)
        CALL JEVECH('PTEMPSR','L',ITEMPS)

        THTIMP = ZR(ITEMPS+2)
        UNMTHE = 1.D0 - THTIMP
        IF (ABS(UNMTHE).LE.EPSI) THEN
          THEGA1 = .TRUE.
        ELSE
          THEGA1 = .FALSE.
        END IF

        IF (LTEATT(' ','AXIS','OUI')) THEN
          AXI = .TRUE.
        ELSE
          AXI = .FALSE.
        END IF

        NOMPAR(1) = 'X'
        NOMPAR(2) = 'Y'
        NOMPAR(3) = 'INST'

C 2.2. ==> BOUCLE SUR LES SOUS-ELEMENTS

        DO 80,ISE = 1,NSE

C 2.2.1. ==> COORDONNEES LOCALES

          DO 30,I = 1,NNO
            COORSE(2*I-1) = ZR(IGEOM+2*C(ISE,I)-2)
            COORSE(2*I) = ZR(IGEOM+2*C(ISE,I)-1)
   30     CONTINUE

C 2.2.2. ==> BOUCLE SUR LES POINTS DE GAUSS

          DO 70,KP = 1,NPG

            K = (KP-1)*NNO

C 2.2.3. ==> CALCUL DES ELEMENTS DE GEOMETRIE DIFFERENTIELLE

C CALCUL DE LA BASE COVARIANTE
            CALL SUBAC1(NDIM,AXI,NNO,KP,IVF,IDFDE,ZR(IGEOM),COVA)

C CALCUL DU TENSEUR METRIQUE
            CALL SUMETR(COVA,METR,JAC)

C CALCUL DES DEUX PREMIERS VECTEURS DE LA BASE CONTRAVARIANTE
            CALL SUBACV(COVA,METR,JAC,CNVA,A)

C 2.2.4. ==> CALCUL DE LA DIVERGENCE SURFACIQUE PROPREMENT DITE

C CALCUL DE LA NORMALE ET DU POIDS
            CALL VFF2DN(NDIM,NNO,KP,IPOIDS,IDFDE,COORSE,NX,NY,POIDS)

C CALCUL DIRECT DE LA DIVERGENCE SURFACIQUE EN 1D
C DIV_SURF(THETA) = SIGMA SUR LES NOEUDS DE
C                 DERIVEE_FONCT_FORME/PREMIERE_VAR (POINT_DE_GAUSS) *
C                (THETA_X(PDG)*PREMIER_VECTEUR_CONTRAVARIANT_X(PDG) +
C                 IDEM EN Y)
            DIVS = 0.D0
            R = 0.D0
            Z = 0.D0
            DO 40,I = 1,NNO
              R8AUX = ZR(IVF+K+I-1)
              R = R + COORSE(2*I-1)*R8AUX
              Z = Z + COORSE(2*I)*R8AUX
              R8AUX = ZR(IDFDE-1+NDIM*K+NDIM*(I-1)+1)
              DIVS = DIVS + R8AUX* (ZR(ITHETA+2*I-2)*CNVA(1,1)+
     &               ZR(ITHETA+2*I-1)*CNVA(2,1))
   40       CONTINUE

C 2.2.5. ==> TRAITEMENT PARTICULIER LIE A L'AXI (1/R ET POIDS)

C EN 2D-AXI, MODIFICATION DU POIDS ET TERME COMPLEMENTAIRE SUR LA
C DIVERGENCE EN THETAR/R
C IL N'Y A AUCUN RISQUE QUE R SOIT NUL, CAR CELA SIGNIFIERAIT UNE
C CL DE FLUX SUR L'AXE, CE QUI EST IMPOSSIBLE. DONC ON PEUT DIVISER
C PAR R.

            IF (AXI) THEN
              THETAR = 0.D0
              DO 50,I = 1,NNO
                THETAR = THETAR + ZR(ITHETA+2*C(ISE,I)-2)*ZR(IVF+K+I-1)
   50         CONTINUE
              POIDS = POIDS*R
              DIVS = DIVS + THETAR/R
            END IF

C CALCUL DU FLUX INSTANTANE

            VALPAR(1) = R
            VALPAR(2) = Z
            VALPAR(3) = ZR(ITEMPS)

            CALL FOINTE('FM',ZK8(IFLU),3,NOMPAR,VALPAR,FLUX,ICODE)
            IF (.NOT.THEGA1) THEN
              VALPAR(3) = ZR(ITEMPS) - ZR(ITEMPS+1)
              CALL FOINTE('FM',ZK8(IFLU),3,NOMPAR,VALPAR,FLUN,ICODE)
              FLUX = THTIMP*FLUX + UNMTHE*FLUN
            END IF

C 2.2.6. ==> CALCUL DE LA PREMIERE INTEGRALE

C CUMUL DE FLUX.DIV_SURF(THETA).T*
            R8AUX = FLUX*DIVS*POIDS
            DO 60,I = 1,NNO
              VECTT(C(ISE,I)) = VECTT(C(ISE,I)) + R8AUX*ZR(IVF+K+I-1)
   60       CONTINUE

   70     CONTINUE

   80   CONTINUE

      END IF

C====
C 3. BASCULE DANS LE VECTEUR GENERAL
C====

      DO 90,I = 1,NNOP2
        ZR(IVECTT-1+I) = VECTT(I)
   90 CONTINUE

      END
