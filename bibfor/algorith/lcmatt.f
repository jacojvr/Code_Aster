      SUBROUTINE LCMATT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,POUM,COMP,
     1                    COEFEL,COEFPL,TYPMA, NDT,NDI,NR,NVI )
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/06/2012   AUTEUR PROIX J-M.PROIX 
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
C     ROUTINE GENERIQUE DE RECUPERATION DU MATERIAU A T ET T+DT
C     ----------------------------------------------------------------
C     IN  FAMI   :  FAMILLE DE POINT DE GAUSS (RIGI,MASS,...)
C         KPG,KSP:  NUMERO DU (SOUS)POINT DE GAUSS
C         MOD    :  TYPE DE MODELISATION
C         IMAT   :  ADRESSE DU MATERIAU CODE
C         NMAT   :  DIMENSION  DE MATER
C         POUM   :  '+' ou '-'
C         COMP   :  COMPORTEMENT
C     OUT        :  COEFFICIENTS MATERIAU A T- OU T+
C         COEFEL :  CARACTERISTIQUES ELASTIQUES
C         COEFPL :  CARACTERISTIQUES PLASTIQUES
C         TYPMA  :  TYPE DE MATRICE TANGENTE
C         NDT    :  NB TOTAL DE COMPOSANTES TENSEURS
C         NDI    :  NB DE COMPOSANTES DIRECTES  TENSEURS
C         NR     :  NB DE COMPOSANTES SYSTEME NL
C         NVI    :  NB DE VARIABLES INTERNES
C     ----------------------------------------------------------------
      INTEGER       KPG,KSP,NMAT,NDT,NDI,NR,NVI,IMAT
      REAL*8        COEFEL(NMAT),COEFPL(NMAT)
      CHARACTER*(*) FAMI,POUM
      CHARACTER*16  LOI,COMP(*)
      CHARACTER*8   MOD,TYPMA
C     ----------------------------------------------------------------
C
C -   NB DE COMPOSANTES DES TENSEURS
C
      NDT = 6
      NDI = 3
      TYPMA = 'COHERENT'
      LOI = COMP(1)
      
      IF  ( LOI(1:8) .EQ. 'HAYHURST' ) THEN
         CALL HAYMAT ( FAMI,KPG,KSP,MOD,IMAT,NMAT,POUM,
     1                 COEFEL,COEFPL,NVI)
      ELSE
         CALL ASSERT( .FALSE. )      
      ENDIF
      
      NR  = NDT + NVI
C
      END
