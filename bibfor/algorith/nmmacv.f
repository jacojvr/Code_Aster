      SUBROUTINE NMMACV(VECDEP,MESSTR,SSTRU ,VECTOZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_21
C
      IMPLICIT NONE
      CHARACTER*8   MESSTR
      CHARACTER*19  SSTRU                
      CHARACTER*24  VECDEP
      CHARACTER*(*) VECTOZ 
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL - MACRO_ELEMENT)
C
C CALCUL DE LA CONTRIBUTION AU SECOND MEMBRE DES MACRO-ELEMENTS
C      
C ----------------------------------------------------------------------
C
C
C IN  VECDEP : VECTEUR DEPLACEMENT
C IN  MESSTR : MATRICES ELEMENTAIRES DES SOUS-ELEMENTS STATIQUES
C IN  SSTRU  : MATRICE ASSEMBLEE DES SOUS-ELEMENTS STATIQUES
C OUT VECTOR : VECT_ASSE CALCULE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C     
      CHARACTER*24 CNTRAV
      CHARACTER*19 VECTOR
      INTEGER      JCNFI,JTRAV,JDEPL,JRSST    
      INTEGER      IRET             
C      
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C      
      CNTRAV = '&&CNPART.CHP3'             
      VECTOR = VECTOZ
      IF (VECTOR(1:14).EQ.'&&CNPART.CHP3') THEN
        CALL ASSERT(.FALSE.)
      ENDIF      
C
C --- CALCUL MATR_ASSE(MACR_ELEM) = MATR_ELEM(MACR_ELEM) * VECT_DEPL
C
      CALL JEVEUO(VECTOR(1:19)//'.VALE','E',JCNFI)
      CALL JEEXIN(MESSTR(1:8) //'.REFE_RESU',IRET)
      IF (IRET.NE.0) THEN
        CALL JEVEUO(CNTRAV(1:19)//'.VALE','E',JTRAV)
        CALL JEVEUO(VECDEP(1:19)//'.VALE','L',JDEPL)
        CALL JEVEUO(SSTRU(1:19) //'.&INT','L',JRSST)
        CALL MRMULT('ZERO',JRSST,ZR(JDEPL),'R',ZR(JTRAV),1)
        CALL VTAXPY((1.D0),CNTRAV,VECTOR)
      ENDIF
C
      CALL JEDEMA()      
C
      END
