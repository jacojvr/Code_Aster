      SUBROUTINE TE0172(OPTION,NOMTE)
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C.......................................................................
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     BUT: CALCUL DES MATRICES DE RIGIDITE  ELEMENTAIRES EN MECANIQUE
C          ELEMENTS 2D DE COUPLAGE ACOUSTICO-MECANIQUE
C
C          OPTION : 'MASS_MECA '
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C          ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................
C
      INTEGER ICODRE
      CHARACTER*16       NOMTE,OPTION
      REAL*8             A(4,4,27,27),SX(27,27),SY(27,27)
      REAL*8             SZ(27,27),NORM(3),RHO
      INTEGER            IGEOM,IMATE
      INTEGER            I,J,K,L,IK,IJKL,IDEC,JDEC,LDEC,KDEC,KCO,INO,JNO
      INTEGER            NDIM,NNO,IPG,NNOS,NPG2
      INTEGER            IPOIDS,IVF,IDFDX,IDFDY,IMATUU,JGANO
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG2,IPOIDS,IVF,IDFDX,JGANO)
      IDFDY  = IDFDX  + 1
C
      CALL JEVECH('PGEOMER','L',IGEOM)
C
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PMATUUR','E',IMATUU)
C
C    CALCUL DES PRODUITS VECTORIELS OMI X OMJ POUR LE CALCUL
C    DE L'ELEMENT DE SURFACE AU POINT DE GAUSS
C
      DO 1 INO=1,NNO
        I = IGEOM + 3*(INO-1) -1
          DO 2 JNO=1,NNO
            J = IGEOM + 3*(JNO-1) -1
              SX(INO,JNO) = ZR(I+2)*ZR(J+3) - ZR(I+3)*ZR(J+2)
              SY(INO,JNO) = ZR(I+3)*ZR(J+1) - ZR(I+1)*ZR(J+3)
              SZ(INO,JNO) = ZR(I+1)*ZR(J+2) - ZR(I+2)*ZR(J+1)
2         CONTINUE
1     CONTINUE
C
C     INITIALISATION DE LA MATRICE
C
      DO 112 K=1,4
         DO 112 L=1,4
            DO 112 I=1,NNO
            DO 112 J=1,I
                A(K,L,I,J) = 0.D0
112   CONTINUE
C
C    BOUCLE SUR LES POINTS DE GAUSS
C
      DO 113 IPG=1,NPG2
C
         KDEC = (IPG-1)*NNO*NDIM
         LDEC = (IPG-1)*NNO
C
C    CALCUL DE LA NORMALE DE LA SURFACE AU POINT DE GAUSS
C
      DO 114 KCO=1,3
         NORM(KCO) = 0.D0
114   CONTINUE
C
      DO 120 I=1, NNO
         IDEC = (I-1)*NDIM
      DO 120 J=1,NNO
         JDEC =(J-1)*NDIM
C
         NORM(1) = NORM(1) +
     &        ZR(IDFDX+KDEC+IDEC) * ZR(IDFDY+KDEC+JDEC) * SX(I,J)
         NORM(2) = NORM(2) +
     &        ZR(IDFDX+KDEC+IDEC) * ZR(IDFDY+KDEC+JDEC) * SY(I,J)
         NORM(3) = NORM(3) +
     &        ZR(IDFDX+KDEC+IDEC) * ZR(IDFDY+KDEC+JDEC) * SZ(I,J)
C
120     CONTINUE
C
        CALL RCVALA ( ZI(IMATE),' ','FLUIDE',0,' ',R8B,1,'RHO',
     &                RHO, ICODRE, 1)
C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C       CALCUL DU TERME PHI*(U.N DS)       C
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
C
        DO 130 INO=1,NNO
           DO 140 JNO=1,INO
              DO 150 KCO=1,3
C
              A(KCO,4,INO,JNO) = A(KCO,4,INO,JNO) +
     &            ZR(IPOIDS+IPG-1) * NORM(KCO) * RHO *
     &            ZR(IVF+LDEC+INO-1) * ZR(IVF+LDEC+JNO-1)
C
150           CONTINUE
140        CONTINUE
130      CONTINUE
113     CONTINUE
C
      DO 151 INO=1,NNO
        DO 152 JNO=1,INO
           DO 153 KCO=1,3
             A(4,KCO,INO,JNO) = A(KCO,4,INO,JNO)
153        CONTINUE
152     CONTINUE
151   CONTINUE
C
C PASSAGE DU STOCKAGE RECTANGULAIRE (A) AU STOCKAGE TRIANGULAIRE (ZR)
C
      IJKL = 0
      IK = 0
      DO 160 K=1,4
         DO 160 L=1,4
            DO 160 I=1,NNO
                IK = ((4*I+K-5) * (4*I+K-4)) / 2
            DO 160 J=1,I
                IJKL = IK + 4 * (J-1) + L
                ZR(IMATUU+IJKL-1) = A(K,L,I,J)
160          CONTINUE
C
      END
