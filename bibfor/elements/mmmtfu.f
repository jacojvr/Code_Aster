      SUBROUTINE MMMTFU(PHASEP,NDIM  ,NNL   ,NNE   ,NNM   ,
     &                  NBCPS ,WPG   ,JACOBI,FFL   ,FFE   ,
     &                  FFM   ,TAU1  ,TAU2  ,MPROJT,RESE  ,
     &                  NRESE ,LAMBDA,COEFFF,MATRFE,MATRFM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 17/10/2011   AUTEUR ABBAS M.ABBAS 
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
C TOLE CRP_21
C
      IMPLICIT NONE
      CHARACTER*9  PHASEP
      INTEGER      NDIM,NNE,NNL,NNM,NBCPS
      REAL*8       FFE(9),FFL(9),FFM(9)
      REAL*8       WPG,JACOBI
      REAL*8       TAU1(3),TAU2(3) 
      REAL*8       RESE(3),NRESE        
      REAL*8       MPROJT(3,3)           
      REAL*8       LAMBDA
      REAL*8       COEFFF        
      REAL*8       MATRFE(18,27),MATRFM(18,27)              
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - UTILITAIRE)
C
C CALCUL DES MATRICES LAGR_F/DEPL
C
C ----------------------------------------------------------------------
C
C
C IN  PHASEP : PHASE DE CALCUL
C              'CONT'      - CONTACT
C              'CONT_PENA' - CONTACT PENALISE
C              'ADHE'      - ADHERENCE
C              'ADHE_PENA' - ADHERENCE PENALISE
C              'GLIS'      - GLISSEMENT
C              'GLIS_PENA' - GLISSEMENT PENALISE
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NBCPS  : NB DE DDL DE LAGRANGE
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNL    : NOMBRE DE NOEUDS DE LAGRANGE 
C IN  TAU1   : PREMIER VECTEUR TANGENT
C IN  TAU2   : SECOND VECTEUR TANGENT
C IN  MPROJT : MATRICE DE PROJECTION TANGENTE
C IN  WPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C IN  FFM    : FONCTIONS DE FORMES DEPL. MAIT.
C IN  FFE    : FONCTIONS DE FORMES DEPL. ESCL.
C IN  FFL    : FONCTIONS DE FORMES LAGR. 
C IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
C IN  RESE   : SEMI-MULTIPLICATEUR GTK DE FROTTEMENT 
C               GTK = LAMBDAF + COEFAF*VITESSE
C IN  NRESE  : RACINE DE LA NORME DE RESE
C IN  LAMBDA : VALEUR DU MULT. DE CONTACT (SEUIL DE TRESCA)
C IN  COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
C OUT MATRFE : MATRICE ELEMENTAIRE LAGR_F/DEPL_E
C OUT MATRFM : MATRICE ELEMENTAIRE LAGR_F/DEPL_M
C
C ----------------------------------------------------------------------
C
C
C --- LAGR_F/DEPL_E
C
      CALL MMMTFE(PHASEP,NDIM  ,NNE   ,NNL   ,NBCPS ,
     &            WPG   ,JACOBI,FFE   ,FFL   ,TAU1  ,
     &            TAU2  ,MPROJT,RESE  ,NRESE ,LAMBDA,
     &            COEFFF,MATRFE)
C
C --- LAGR_F/DEPL_M
C
      CALL MMMTFM(PHASEP,NDIM  ,NNM   ,NNL   ,NBCPS ,
     &            WPG   ,JACOBI,FFM   ,FFL   ,TAU1  ,
     &            TAU2  ,MPROJT,RESE  ,NRESE ,LAMBDA,
     &            COEFFF,MATRFM)
C
      END
