      SUBROUTINE TUMASS(NOMTE,NBRDDL,MASS)
      IMPLICIT NONE
C MODIF ELEMENTS  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
C TOLE CRS_1404
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*16 NOMTE
      INTEGER NBRDDL
      REAL*8 MASS(NBRDDL,NBRDDL)
C ......................................................................

C    - FONCTION REALISEE:  CALCUL DES MATRICES ELEMENTAIRES
C                          TUYAU
C                          OPTION :  MASS_MECA
C    - ARGUMENTS:
C        DONNEES:      NVEC, TNVEC, MASS1,MASS,K : MATRICES
C                      DIMENSIONNEES PAR LE TE0582 APPELANT

C ......................................................................

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------

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

C     VARIABLES LOCALES
      INTEGER NBRES,ICOUDE,NBSECM,NBCOUM,NSPG
      PARAMETER (NBRES=9)
      CHARACTER*8 NOMRES(NBRES),NOMPAR
      INTEGER ICODRE(NBRES)
      PARAMETER (NBSECM=32,NBCOUM=10)
      REAL*8 POICOU(2*NBCOUM+1),POISEC(2*NBSECM+1)
      REAL*8 VALRES(NBRES),VALPAR,THETA
      REAL*8 RHO,H,A,L
      REAL*8 PI,DEUXPI,FI,SINFI,COSFI,SINMFI,COSMFI,HK
      REAL*8 POIDS,R,R8PI,RAYON,XPG(4)
      REAL*8 PGL(3,3),CK,SK,PGL4(3,3)
      REAL*8 PGL1(3,3),PGL2(3,3),PGL3(3,3),OMEGA,TK(4)
      INTEGER NNO,NPG,NBCOU,NBSEC,M,INO,I1,N
      INTEGER IPOIDS,IVF,IBLOC,ICOLON
      INTEGER IMATE,ICAGEP,IGEOM,NBPAR,ICOUD2,MMT
      INTEGER IGAU,ICOU,ISECT,I,J,LORIEN
      INTEGER JCOOPG,JNBSPI,IRET
      INTEGER NDIM,NNOS,IDFDK,JDFD2,JGANO
      REAL*8 NVEC(6,NBRDDL),TNVEC(NBRDDL,6)
      REAL*8 MASS1(NBRDDL,NBRDDL)
C --------------------------------------------------------------------
      CALL ELREF5(' ','MASS',NDIM,NNO,NNOS,NPG,IPOIDS,JCOOPG,IVF,IDFDK,
     &            JDFD2,JGANO)


      PI = R8PI()
      DEUXPI = 2.D0*PI

      CALL JEVECH('PNBSP_I','L',JNBSPI)
      NBCOU = ZI(JNBSPI-1+1)
      NBSEC = ZI(JNBSPI-1+2)

C     -- CALCUL DES POIDS DES COUCHES ET DES SECTEURS:
      POICOU(1) = 1.D0/3.D0
      DO 10 I = 1,NBCOU - 1
        POICOU(2*I) = 4.D0/3.D0
        POICOU(2*I+1) = 2.D0/3.D0
   10 CONTINUE
      POICOU(2*NBCOU) = 4.D0/3.D0
      POICOU(2*NBCOU+1) = 1.D0/3.D0
      POISEC(1) = 1.D0/3.D0
      DO 20 I = 1,NBSEC - 1
        POISEC(2*I) = 4.D0/3.D0
        POISEC(2*I+1) = 2.D0/3.D0
   20 CONTINUE
      POISEC(2*NBSEC) = 4.D0/3.D0
      POISEC(2*NBSEC+1) = 1.D0/3.D0


      M = 3
      IF (NOMTE.EQ.'MET6SEG3') M = 6



      DO 30 I = 1,NPG
        XPG(I) = ZR(JCOOPG-1+I)
   30 CONTINUE

C A= RMOY, H = EPAISSEUR
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PCAGEPO','L',ICAGEP)
      H = ZR(ICAGEP+1)
      A = ZR(ICAGEP) - H/2.D0

C     --- RECUPERATION DES ORIENTATIONS ---

      CALL JEVECH('PCAORIE','L',LORIEN)
      CALL CARCOU(ZR(LORIEN),L,PGL,RAYON,THETA,PGL1,PGL2,PGL3,PGL4,NNO,
     &            OMEGA,ICOUD2)
      IF (ICOUD2.GE.10) THEN
        ICOUDE = ICOUD2 - 10
        MMT = 0
      ELSE
        ICOUDE = ICOUD2
        MMT = 1
      END IF

      CALL JEVECH('PMATERC','L',IMATE)

C       -- CALCUL DES TEMPERATURES INF, SUP ET MOY
C          (MOYENNE DES NNO NOEUDS) ET DES COEF. DES POLY. DE DEGRE 2 :
C          ------------------------------------------------------------
      NSPG=(2*NBSEC + 1)*(2*NBCOU + 1)
      IRET=0
      CALL MOYTEM('RIGI',NPG,NSPG,'+',VALPAR,IRET)
      IF(IRET.NE.0) VALPAR=0.D0
      NBPAR = 1
      NOMPAR = 'TEMP'

C ======   OPTION MASS_MECA    =======

      NOMRES(1) = 'RHO'
      CALL RCVALA(ZI(IMATE),' ','ELAS',NBPAR,NOMPAR,VALPAR,1,NOMRES,
     &            VALRES,ICODRE,1)
      RHO = VALRES(1)
      DO 70 I = 1,NBRDDL
        DO 50 J = 1,NBRDDL
          MASS(I,J) = 0.D0
   50   CONTINUE
        DO 60 J = 1,6
          NVEC(J,I) = 0.D0
          TNVEC(I,J) = 0.D0
   60   CONTINUE
   70 CONTINUE

      IF (NNO.EQ.3) THEN
        TK(1) = 0.D0
        TK(2) = THETA
        TK(3) = THETA/2.D0
      ELSE IF (NNO.EQ.4) THEN
        TK(1) = 0.D0
        TK(2) = THETA
        TK(3) = THETA/3.D0
        TK(4) = 2.D0*THETA/3.D0
      END IF

C BOUCLE SUR LES POINTS DE GAUSS

      DO 150 IGAU = 1,NPG

C BOUCLE SUR LES POINTS DE SIMPSON DANS L'EPAISSEUR

        DO 140 ICOU = 1,2*NBCOU + 1
C CALCUL DU RAYON DU POINT ICOU ( A= RMOY, H = EPAISSEUR)
          IF (MMT.EQ.0) THEN
            R = A
          ELSE
            R = A + (ICOU-1)*H/ (2.D0*NBCOU) - H/2.D0
          END IF

C BOUCLE SUR LES POINTS DE SIMPSON SUR LA CIRCONFERENCE

          DO 130 ISECT = 1,2*NBSEC + 1
C CALCUL DE L'ANGLE FI DU POINT ISECT
            FI = (ISECT-1)*DEUXPI/ (2.D0*NBSEC)
C                        IF(ICOUDE.EQ.1) FI = FI - OMEGA
            COSFI = COS(FI)
            SINFI = SIN(FI)
            DO 100 INO = 1,NNO
              HK = ZR(IVF-1+NNO* (IGAU-1)+INO)
              IF (ICOUDE.EQ.1) THEN
                CK = COS((1.D0+XPG(IGAU))*THETA/2.D0-TK(INO))
                SK = SIN((1.D0+XPG(IGAU))*THETA/2.D0-TK(INO))
              ELSE
                CK = 1.D0
                SK = 0.D0
              END IF

              IBLOC = (9+6* (M-1))* (INO-1)
              DO 80 I1 = 1,3
                NVEC(I1,IBLOC+I1) = HK*CK
                TNVEC(IBLOC+I1,I1) = HK*CK
   80         CONTINUE
              NVEC(1,IBLOC+2) = HK*SK
              NVEC(1,IBLOC+4) = HK*R*COSFI*SK
              NVEC(1,IBLOC+5) = -HK*R*COSFI*CK
              NVEC(1,IBLOC+6) = HK*R*SINFI
              NVEC(2,IBLOC+1) = -HK*SK
              NVEC(2,IBLOC+4) = HK*R*COSFI*CK
              NVEC(2,IBLOC+5) = HK*R*COSFI*SK
              NVEC(3,IBLOC+3) = HK
              NVEC(3,IBLOC+4) = -HK*R*SINFI*CK
              NVEC(3,IBLOC+5) = -HK*R*SINFI*SK
              TNVEC(IBLOC+2,1) = HK*SK
              TNVEC(IBLOC+4,1) = HK*R*COSFI*SK
              TNVEC(IBLOC+5,1) = -HK*R*COSFI*CK
              TNVEC(IBLOC+6,1) = HK*R*SINFI
              TNVEC(IBLOC+1,2) = -HK*SK
              TNVEC(IBLOC+4,2) = HK*R*COSFI*CK
              TNVEC(IBLOC+5,2) = HK*R*COSFI*SK
              TNVEC(IBLOC+3,3) = HK
              TNVEC(IBLOC+4,3) = -HK*R*SINFI*CK
              TNVEC(IBLOC+5,3) = -HK*R*SINFI*SK

              DO 90 N = 2,M
                ICOLON = IBLOC + 6 + 6* (N-2)
                COSMFI = COS(N*FI)
                SINMFI = SIN(N*FI)
                NVEC(4,ICOLON+1) = HK*COSMFI
                NVEC(4,ICOLON+4) = HK*SINMFI
                NVEC(5,ICOLON+2) = HK*SINMFI
                NVEC(5,ICOLON+5) = HK*COSMFI
                NVEC(6,ICOLON+3) = HK*COSMFI
                NVEC(6,ICOLON+6) = HK*SINMFI

                TNVEC(ICOLON+1,4) = HK*COSMFI
                TNVEC(ICOLON+4,4) = HK*SINMFI
                TNVEC(ICOLON+2,5) = HK*SINMFI
                TNVEC(ICOLON+5,5) = HK*COSMFI
                TNVEC(ICOLON+3,6) = HK*COSMFI
                TNVEC(ICOLON+6,6) = HK*SINMFI
   90         CONTINUE
              ICOLON = IBLOC + 6* (M-1) + 6
              NVEC(5,ICOLON+2) = HK*SINFI
              NVEC(5,ICOLON+3) = -HK*COSFI
              NVEC(6,ICOLON+1) = HK
              NVEC(6,ICOLON+2) = HK*COSFI
              NVEC(6,ICOLON+3) = HK*SINFI

              TNVEC(ICOLON+2,5) = HK*SINFI
              TNVEC(ICOLON+3,5) = -HK*COSFI
              TNVEC(ICOLON+1,6) = HK
              TNVEC(ICOLON+2,6) = HK*COSFI
              TNVEC(ICOLON+3,6) = HK*SINFI
  100       CONTINUE
            CALL PROMAT(TNVEC,NBRDDL,NBRDDL,6,NVEC,6,6,NBRDDL,MASS1)
            IF (ICOUDE.EQ.1) L = THETA* (RAYON+R*SINFI)
            POIDS = ZR(IPOIDS-1+IGAU)*POICOU(ICOU)*POISEC(ISECT)*
     &              (L/2.D0)*H*DEUXPI/ (4.D0*NBCOU*NBSEC)*R*RHO
            DO 120 I = 1,NBRDDL
              DO 110 J = 1,I
                MASS(I,J) = MASS(I,J) + POIDS*MASS1(I,J)
                MASS(J,I) = MASS(I,J)
  110         CONTINUE
  120       CONTINUE
  130     CONTINUE
  140   CONTINUE
  150 CONTINUE

      IF (ICOUDE.EQ.0) THEN
        CALL KLG(NNO,NBRDDL,PGL,MASS)
      ELSE IF (ICOUDE.EQ.1) THEN
        CALL KLGCOU(NNO,NBRDDL,PGL1,PGL2,PGL3,PGL4,MASS)
      END IF

      END
