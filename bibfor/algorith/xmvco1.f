       SUBROUTINE XMVCO1(NDIM,NNO,NNOL,NNOF,
     &                  SIGMA,PLA,IPGF,IVFF,IFA,CFACE,LACT ,
     &                  DTANG,NFH,DDLS,JAC,FFC,FFP,
     &                  SINGU,E,RR,NOEUD,CSTACO,ND,TAU1,TAU2,
     &                  VTMP)


      IMPLICIT NONE
      INTEGER     NDIM,NNO,NNOL,NNOF
      INTEGER     NFH,DDLS,PLA(27),LACT(8),CFACE(5,3)
      INTEGER     SINGU,IPGF,IVFF,IFA
      REAL*8      VTMP(400),SIGMA(6)
      REAL*8      FFP(27),JAC
      REAL*8      DTANG(3),E,ND(3),TAU1(3),TAU2(3)
      REAL*8      RR,FFC(8),CSTACO
      LOGICAL     NOEUD

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/02/2011   AUTEUR MASSIN P.MASSIN 
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

C TOLE CRP_21
C
C ROUTINE CONTACT (METHODE XFEM HPP - CALCUL ELEM.)
C
C --- CALCUL DES SECONDS MEMBRES DE COHESION
C      
C ----------------------------------------------------------------------
C
C IN  NDIM   : DIMENSION DE L'ESPACE
C IN  NNO    : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C IN  SIGMA  : VECTEUR CONTRAINTE EN REPERE LOCAL
C IN  NFH    : NOMBRE DE FONCTIONS HEAVYSIDE
C IN  DDLS   : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C IN  JAC    : PRODUIT DU JACOBIEN ET DU POIDS
C IN  FFP    : FONCTIONS DE FORME DE L'ELEMENT PARENT
C IN  SINGU  : 1 SI ELEMENT SINGULIER, 0 SINON
C IN  RR     : DISTANCE AU FOND DE FISSURE
C I/O VTMP   : VECTEUR ELEMENTAIRE DE CONTACT/FROTTEMENT 
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
C
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

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      INTEGER I,J,K,PLI,NLI
      REAL*8  TAU(3)
      REAL*8  FFI,TTX(3),DDOT,EPS,R8PREM,SQRTAN,SQTTAN
C
C ---------------------------------------------------------------------
C
C DIRECTION DU SAUT DE DEPLACEMENT TANGENT
C
      CALL VECINI(3,0.D0,TAU)
      EPS=R8PREM()
      SQRTAN=DTANG(1)**2+DTANG(2)**2+DTANG(3)**2
      IF(SQRTAN.GT.EPS) SQTTAN=SQRT(SQRTAN)
      IF(SQTTAN.GT.EPS) THEN
         DO 110 I=1,NDIM
            TAU(I)=DTANG(I)/SQTTAN
110      CONTINUE
      ENDIF
                      
      DO 450 I = 1,NNO
         DO 451 J = 1,NFH*NDIM 
              VTMP(DDLS*(I-1)+NDIM+J) =
     &        VTMP(DDLS*(I-1)+NDIM+J)+ 
     &            (2.D0*SIGMA(1)*ND(J)*FFP(I)*JAC)+
     &            (2.D0*SIGMA(2)*TAU1(J)*FFP(I)*JAC)
            IF(NDIM.EQ.3) THEN
              VTMP(DDLS*(I-1)+NDIM+J) =
     &        VTMP(DDLS*(I-1)+NDIM+J)+             
     &            (2.D0*SIGMA(3)*TAU2(J)*FFP(I)*JAC) 
            ENDIF 

 451     CONTINUE
         DO 452 J = 1,SINGU*NDIM
           VTMP(DDLS*(I-1)+NDIM*(1+NFH)+J) =
     &        VTMP(DDLS*(I-1)+NDIM*(1+NFH)+J)+
     &         (2.D0*SIGMA(1)*ND(J)*FFP(I)*JAC*RR)+
     &         (2.D0*SIGMA(2)*TAU1(J)*FFP(I)*JAC*RR)
            IF(NDIM.EQ.3) THEN
              VTMP(DDLS*(I-1)+NDIM*(1+NFH)+J) =
     &        VTMP(DDLS*(I-1)+NDIM*(1+NFH)+J)+            
     &         (2.D0*SIGMA(3)*TAU2(J)*FFP(I)*JAC*RR)
            ENDIF  
 452    CONTINUE
 450  CONTINUE

      CALL VECINI(3,0.D0,TTX)

      DO 460 I = 1,NNOL
         PLI=PLA(I)
         IF (NOEUD) THEN
            FFI=FFC(I)
            NLI=LACT(I)
            IF (NLI.EQ.0) GOTO 460
         ELSE
             FFI=ZR(IVFF-1+NNOF*(IPGF-1)+I)
             NLI=CFACE(IFA,I)
         ENDIF
         TTX(1)=DDOT(NDIM,TAU1,1,TAU,1)
         IF (NDIM .EQ.3) TTX(2)=DDOT(NDIM,TAU2,
     &                               1,TAU,1)
         DO 465 K=1,NDIM-1
             VTMP(PLI+K) = VTMP(PLI+K)
     &     + SQRT(SIGMA(2)**2+SIGMA(3)**2)*TTX(K)*FFI*JAC
 465     CONTINUE
 460   CONTINUE
  
       DO 470 I = 1,NNOL
          PLI=PLA(I)
          IF (NOEUD) THEN
             FFI=FFC(I)
             NLI=LACT(I)
             IF (NLI.EQ.0) GOTO 470
          ELSE
             FFI=ZR(IVFF-1+NNOF*(IPGF-1)+I)
             NLI=CFACE(IFA,I)
          ENDIF
          DO 475 K = 1, NDIM
              VTMP(PLI) = VTMP(PLI) + 
     &          SIGMA(1)*ND(K)*ND(K)*FFI*JAC/CSTACO*E
 475      CONTINUE
 470   CONTINUE 

       END
