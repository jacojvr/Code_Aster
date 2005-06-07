      SUBROUTINE  DMATMC(MODELI,MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,
     +                   XYZGAU,NBSIG,D,LSENS)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 06/03/2002   AUTEUR CIBHHLV L.VIVAN 
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
C.======================================================================
      IMPLICIT NONE
C
C      DMATMC :   CALCUL DE LA MATRICE DE HOOKE POUR LES ELEMENTS
C                 ISOPARAMETRIQUES POUR DES MATERIAUX ISOTROPE,
C                 ORTHOTROPE ET ISOTROPE TRANSVERSE
C
C   ARGUMENT        E/S  TYPE         ROLE
C    MODELI         IN     K8       MODELISATION (AXI,FOURIER,...)
C    MATER          IN     I        MATERIAU
C    TEMPE          IN     R        TEMPERATURE AU POINT D'INTEGRATION
C    HYDR           IN     R        HYDRATATION AU POINT D'INTEGRATION
C    SECH           IN     R        SECHAGE AU POINT D'INTEGRATION
C    INSTAN         IN     R        INSTANT DE CALCUL (0 PAR DEFAUT)
C    REPERE(7)      IN     R        VALEURS DEFINISSANT LE REPERE
C                                   D'ORTHOTROPIE
C    XYZGAU(3)      IN     R        COORDONNEES DU POINT D'INTEGRATION
C    NBSIG          IN     I        NOMBRE DE CONTRAINTES ASSOCIE A
C                                   L'ELEMENT
C    LSENS          IN     L        FAIT-ON UN CALCUL DE SENSIBILITE?
C    D(NBSIG,1)     OUT    R        MATRICE DE HOOKE
C
C
C
C.========================= DEBUT DES DECLARATIONS ====================
C -----  ARGUMENTS
           CHARACTER*8  MODELI
           INTEGER      MATER,NBSIG
           REAL*8       REPERE(7), XYZGAU(1), D(NBSIG,1), INSTAN
           REAL*8       HYDR,SECH,TEMPE
           LOGICAL      LSENS
C
C.========================= DEBUT DU CODE EXECUTABLE ==================
C
C       ------------------------
C ----  CAS MASSIF 3D ET FOURIER
C       ------------------------
      IF (MODELI(1:2).EQ.'CA'.OR.MODELI(1:2).EQ.'FO') THEN
C
         IF ( LSENS ) THEN
            CALL DM3DSE(MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,XYZGAU,D)
         ELSE
            CALL DMAT3D(MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,XYZGAU,D)
         ENDIF
C
C       ----------------------------------------
C ----  CAS DEFORMATIONS PLANES ET AXISYMETRIQUE
C       ----------------------------------------
      ELSEIF (MODELI(1:2).EQ.'DP'.OR.MODELI(1:2).EQ.'AX') THEN
C
         IF ( LSENS ) THEN
            CALL DMDPSE(MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,D)
         ELSE
            CALL DMATDP(MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,D)
         ENDIF
C
C       ----------------------
C ----  CAS CONTRAINTES PLANES
C       ----------------------
      ELSEIF (MODELI(1:2).EQ.'CP') THEN
C
         IF ( LSENS ) THEN
            CALL DMCPSE(MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,D)
         ELSE
            CALL DMATCP(MATER,TEMPE,HYDR,SECH,INSTAN,REPERE,D)
         ENDIF
C
      ELSE
         CALL UTMESS('F','DMATMC','LA MODELISATION : '//MODELI//
     &               'N''EST PAS TRAITEE.')
      ENDIF
C.============================ FIN DE LA ROUTINE ======================
      END
