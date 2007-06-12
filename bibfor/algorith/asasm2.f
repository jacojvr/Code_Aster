      SUBROUTINE ASASM2 (MRIGIZ,MDIRIZ,NUMDDZ,MATASS,SOLVEZ,INFCHA)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/10/2006   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*24       MERIGI,MEDIRI,NUMEDD
      CHARACTER*(*)      MATASS
      CHARACTER*(*)      MRIGIZ,MDIRIZ,NUMDDZ,SOLVEZ
      CHARACTER*19       SOLVEU, INFCHA
C ----------------------------------------------------------------------
C     ASSEMBLAGE DES MATRICES
C
C DUPLICATA DE ASASMA DEDIE A POST_ZAC
C A SUPPRIMER
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      INTEGER            NBMAT,JMED
      CHARACTER*8        TLIMAT(2)
C DEB ------------------------------------------------------------------
C
      CALL JEMARQ()
      MERIGI = MRIGIZ
      MEDIRI = MDIRIZ
      NUMEDD = NUMDDZ
      SOLVEU = SOLVEZ
C
      TLIMAT(1) = MERIGI(1:8)
      CALL JEVEUO(MEDIRI,'L',JMED)
      IF ( ZK24(JMED)(1:8) .EQ. '        ' ) THEN
        NBMAT = 1
      ELSE
        NBMAT = 2
        TLIMAT(2) = MEDIRI(1:8)
      ENDIF
      CALL ASMATR(NBMAT,TLIMAT,' ',NUMEDD,SOLVEU,INFCHA
     &           ,'ZERO','V',1,MATASS(1:15))

      CALL JEDEMA()
      END
