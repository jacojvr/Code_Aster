      SUBROUTINE MMMLCF(COEFFF,COEFAC,COEFAF,LPENAC,LPENAF,
     &                  IRESOF,IRESOG,LAMBDS)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 25/06/2012   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INCLUDE 'jeveux.h'
      REAL*8   COEFAC,COEFAF
      REAL*8   COEFFF,LAMBDS
      LOGICAL  LPENAC,LPENAF
      INTEGER  IRESOF,IRESOG
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
C OUT COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
C OUT COEFAC : COEF_AUGM_CONT
C OUT COEFAF : COEF_AUGM_FROT
C OUT LPENAC : .TRUE. SI CONTACT PENALISE
C OUT LPENAF : .TRUE. SI FROTTEMENT PENALISE
C OUT IRESOF : ALGO. DE RESOLUTION POUR LE FROTTEMENT
C              0 - POINT FIXE
C              1 - NEWTON
C OUT IRESOG : ALGO. DE RESOLUTION POUR LA GEOMETRIE
C              0 - POINT FIXE
C              1 - NEWTON
C
C ----------------------------------------------------------------------
C
      INTEGER      JPCF
      INTEGER      IALGOC,IALGOF
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- RECUPERATION DES DONNEES DU CHAM_ELEM DU CONTACT
C
      CALL JEVECH('PCONFR','L',JPCF )
      COEFAC =      ZR(JPCF-1+16)
      COEFAF =      ZR(JPCF-1+19)
      COEFFF =      ZR(JPCF-1+20)
      IALGOC = NINT(ZR(JPCF-1+15))
      IALGOF = NINT(ZR(JPCF-1+18))
      IRESOF = NINT(ZR(JPCF-1+17))
      IRESOG = NINT(ZR(JPCF-1+28))
      LAMBDS =      ZR(JPCF-1+13)
C
C --- PENALISATION ?
C
      LPENAF = (IALGOF.EQ.3)
      LPENAC = (IALGOC.EQ.3)
C
      CALL JEDEMA()
C
      END
