      SUBROUTINE NDINER(NUMEDD,SDDYNA,INST ,VALPLU,MEASSE,
     &                  CNINER)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT      NONE
      CHARACTER*24  NUMEDD      
      REAL*8        INST(*)
      CHARACTER*19  SDDYNA
      CHARACTER*24  VALPLU(8),CNINER
      CHARACTER*19  MEASSE(8)     
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (ALGORITHME)
C
C CALCUL DE LA FORCE D'INERTIE
C      
C ----------------------------------------------------------------------
C
C
C IN  NUMEDD : NUMEROTATION
C IN  INST   : PARAMETRES INTEGRATION EN TEMPS (T+, DT, THETA)
C IN  SDDYNA : SD LIEE A LA DYNAMIQUE (CF NDLECT)
C OUT CNINER : VECTEUR DES FORCES D'INERTIE POUR CONVERGENCE
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
      INTEGER      POINTM,JFOINE,JVITP,NEQ,JCONI,IRET
      REAL*8       A0VIT1,A0VIT
      CHARACTER*24 K24BID,VITPLU,NDYNKK
      CHARACTER*19 MASSE
      CHARACTER*8  K8BID
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C           
      CALL DISMOI('F','NB_EQUA',NUMEDD,'NUME_DDL',NEQ,K8BID,IRET)
      MASSE  = MEASSE(3)      
      CNINER = NDYNKK(SDDYNA,'CNINER')      
C
C --- DECOMPACTION DES VARIABLES CHAPEAUX
C      
      CALL DESAGG(VALPLU,K24BID,K24BID,K24BID,K24BID,
     &            VITPLU,K24BID,K24BID,K24BID)   
C
C --- CALCUL DU TERME D'INERTIE
C
      CALL JEVEUO(MASSE(1:19)//'.&INT','L',POINTM)
      CALL JEVEUO(CNINER(1:19)//'.VALE','E',JFOINE)
      CALL JEVEUO(VITPLU(1:19)//'.VALE','L',JVITP)
      CALL MRMULT('ZERO',POINTM,ZR(JVITP),'R',ZR(JFOINE),1)
      CALL JEVEUO(SDDYNA(1:15)//'.INI_CONT','L',JCONI)
      A0VIT  = ZR(JCONI+3-1)
      A0VIT1 = A0VIT/INST(2)
      CALL DSCAL(NEQ,-A0VIT1,ZR(JFOINE),1)
C
      CALL JEDEMA()
      END
