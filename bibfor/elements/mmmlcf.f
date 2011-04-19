      SUBROUTINE MMMLCF(COEFFF,COEFCR,COEFCS,COEFCP,COEFFR,
     &                  COEFFS,COEFFP,LPENAC,LPENAF)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/04/2011   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      REAL*8   COEFCR,COEFCS,COEFCP
      REAL*8   COEFFR,COEFFS,COEFFP
      REAL*8   COEFFF
      LOGICAL  LPENAC,LPENAF
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - CALCUL)
C
C PREPARATION DES CALCULS - RECUPERATION DES COEFFICIENTS
C
C ----------------------------------------------------------------------
C
C
C OUT LPENAC : .TRUE. SI CONTACT PENALISE
C OUT LPENAF : .TRUE. SI FROTTEMENT PENALISE
C OUT COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
C OUT COEFCP : COEF_PENA_CONT
C OUT COEFCS : COEF_STAB_CONT
C OUT COEFCR : COEF_REGU_CONT
C OUT COEFFP : COEF_PENA_FROT
C OUT COEFFS : COEF_STAB_FROT
C OUT COEFFR : COEF_REGU_FROT
C 
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER      JPCF
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- RECUPERATION DES DONNEES DU CHAM_ELEM DU CONTACT
C
      CALL JEVECH('PCONFR','L',JPCF )
      COEFCR = ZR(JPCF-1+17)
      COEFCS = ZR(JPCF-1+18)
      COEFCP = ZR(JPCF-1+19)
      COEFFF = ZR(JPCF-1+21)
      COEFFR = ZR(JPCF-1+22)
      COEFFS = ZR(JPCF-1+23)
      COEFFP = ZR(JPCF-1+24)
C
C --- TERMES DE PENALISATION
C
      LPENAF = ((COEFFR.EQ.0.D0).AND.(COEFFS.EQ.0.D0)
     &         .AND.(COEFFP.NE.0.D0))
      LPENAC = ((COEFCR.EQ.0.D0).AND.(COEFCS.EQ.0.D0)
     &         .AND.(COEFCP.NE.0.D0))
C
      CALL JEDEMA()
C
      END
