      SUBROUTINE TE0232(OPTION,NOMTE)
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
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
C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          COQUE 1D
C                          OPTION : 'CHAR_MECA_ROTA_R'
C                          ELEMENT: MECXSE3,METCSE3,METDSE3
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 ELREFE
      INTEGER ICODRE
      REAL*8 ZERO,DFDX(3),NX,NY,POIDS,COUR,RX,RY
      INTEGER NNO,KP,K,NPG,I,IVECTU,IROTA,ICACO
      INTEGER IPOIDS,IVF,IDFDK,IGEOM,IMATE

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

      CALL ELREF1(ELREFE)

      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDK,JGANO)


      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PROTATR','L',IROTA)
C
C VERIFICATIONS SUR LE CHARGEMENT ROTATION
C
      IF(NOMTE(3:4).EQ.'TD'.OR.NOMTE(3:4).EQ.'TC') THEN
C AXE=direction Oz
         IF(ZR(IROTA+3).LE.R8MIEM()) THEN
            CALL U2MESS('F','MODELISA9_99')
         END IF
         IF(ZR(IROTA+1).GT.R8MIEM().OR.ZR(IROTA+2).GT.R8MIEM()) THEN
            CALL U2MESS('F','MODELISA10_3')
         END IF
      ELSEIF(NOMTE(3:4).EQ.'CX') THEN
C AXE=Oy et CENTRE=ORIGINE
         IF(ZR(IROTA+1).GT.R8MIEM().OR.ZR(IROTA+3).GT.R8MIEM()) THEN
            CALL U2MESS('F','MODELISA10_1')
         END IF
         IF(ZR(IROTA+4).GT.R8MIEM().OR.ZR(IROTA+5).GT.R8MIEM()
     &     .OR.ZR(IROTA+6).GT.R8MIEM()) THEN
            CALL U2MESS('F','MODELISA10_2')
         END IF
      ENDIF
      CALL JEVECH('PCACOQU','L',ICACO)
      CALL JEVECH('PVECTUR','E',IVECTU)
      ZERO = 0.D0
      CALL RCVALA(ZI(IMATE),' ','ELAS',0,' ',R8B,1,'RHO',RHO,
     &            ICODRE,1)

      DO 40 KP = 1,NPG
        K = (KP-1)*NNO
        CALL DFDM1D(NNO,ZR(IPOIDS+KP-1),ZR(IDFDK+K),ZR(IGEOM),DFDX,COUR,
     &              POIDS,NX,NY)
        POIDS = POIDS*RHO*ZR(IROTA)**2*ZR(ICACO)
        RX = ZERO
        RY = ZERO
        DO 10 I = 1,NNO
          RX = RX + ZR(IGEOM+2*I-2)*ZR(IVF+K+I-1)
          RY = RY + ZR(IGEOM+2*I-1)*ZR(IVF+K+I-1)
   10   CONTINUE
        IF (NOMTE.EQ.'MECXSE3') THEN
          POIDS = POIDS*RX
          DO 20 I = 1,NNO
            ZR(IVECTU+3*I-3) = ZR(IVECTU+3*I-3) +
     &                         POIDS*ZR(IROTA+2)**2*RX*ZR(IVF+K+I-1)
   20     CONTINUE
        ELSE
          RX = RX - ZR(IROTA+4)
          RY = RY - ZR(IROTA+5)
          DO 30 I = 1,NNO
            ZR(IVECTU+3*I-3) = ZR(IVECTU+3*I-3) +
     &                         POIDS*ZR(IROTA+3)**2*RX*ZR(IVF+K+I-1)
            ZR(IVECTU+3*I-2) = ZR(IVECTU+3*I-2) +
     &                         POIDS*ZR(IROTA+3)**2*RY*ZR(IVF+K+I-1)
   30     CONTINUE
        END IF
   40 CONTINUE
      END
