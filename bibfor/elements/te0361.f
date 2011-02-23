      SUBROUTINE TE0361(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 23/02/2011   AUTEUR LAVERNE J.LAVERNE 
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
C RESPONSABLE LAVERNE J.LAVERNE

      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  FORC_NODA ET REFE_FORC_NODA
C                          POUR ELEMENTS D'INTERFACE
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 LIELRF(10)
      LOGICAL AXI
      INTEGER N,NNO1,NNO2,NPG,IVF2,IDF2,NNOS,JGN
      INTEGER IW,IVF1,IDF1,IGEOM,ICONTM,IREFCO,IVECTU,NDIM,NTROU,ICAMAS
      INTEGER IU(3,18),IM(3,9),IT(18)
      REAL*8  ANG(24),SIGREF,DEPREF,R8VIDE
      
      LOGICAL LTEATT
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

      CALL ELREF2(NOMTE,2,LIELRF,NTROU)
      CALL ELREF4(LIELRF(1),'RIGI',NDIM,NNO1,NNOS,NPG,IW,IVF1,IDF1,JGN)
      CALL ELREF4(LIELRF(2),'RIGI',NDIM,NNO2,NNOS,NPG,IW,IVF2,IDF2,JGN)
      NDIM = NDIM + 1
      AXI = LTEATT(' ','AXIS','OUI') 
      
C - DECALAGE D'INDICE POUR LES ELEMENTS D'INTERFACE       
      CALL EIINIT(NOMTE,IU,IM,IT)

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PVECTUR','E',IVECTU)
      
C --- ORIENTATION DE L'ELEMENT D'INTERFACE : REPERE LOCAL 
C     RECUPERATION DES ANGLES NAUTIQUES DEFINIS PAR AFFE_CARA_ELEM

      CALL JEVECH('PCAMASS','L',ICAMAS)
      IF (ZR(ICAMAS).EQ.-1.D0) CALL U2MESS('F','ELEMENTS5_47')

C     DEFINITION DES ANGLES NAUTIQUES AUX NOEUDS SOMMETS : ANG
      
      CALL EIANGL(NDIM,NNO2,ZR(ICAMAS+1),ANG)

C      OPTIONS FORC_NODA ET REFE_FORC_NODA

      IF (OPTION .EQ. 'FORC_NODA') THEN

        CALL JEVECH('PCONTMR','L',ICONTM)
        CALL EIFONO(NDIM,AXI,NNO1,NNO2,NPG,ZR(IW),ZR(IVF1),ZR(IVF2),
     &   ZR(IDF2),ZR(IGEOM),ANG,IU,IM,ZR(ICONTM),ZR(IVECTU))

      ELSE

        CALL JEVECH('PREFCO','L',IREFCO)
        SIGREF = ZR(IREFCO)
        DEPREF = ZR(IREFCO+1)

        IF (SIGREF.EQ.R8VIDE()) CALL U2MESS('F','ALGORITH10_36')
        IF (DEPREF.EQ.R8VIDE()) CALL U2MESS('F','ALGORITH17_3')
    
        CALL EIFORE(NDIM,AXI,NNO1,NNO2,NPG,ZR(IW),ZR(IVF1),ZR(IVF2),
     &   ZR(IDF2),ZR(IGEOM),ANG,IU,IM,SIGREF,DEPREF,ZR(IVECTU))
      
      ENDIF
      
      END
