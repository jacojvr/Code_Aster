      REAL*8 FUNCTION TRIGOM(FONC,X)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 22/11/2001   AUTEUR VABHHTS J.PELLET 
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
C RESPONSABLE VABHHTS J.PELLET
C TOLE CRP_6
      IMPLICIT NONE
      CHARACTER*4 FONC
C ----------------------------------------------------------------------
C  BUT : CALCULER ASIN(X) OU ACOS(X) SANS RISQUER DE SE PLANTER SI
C        X SORT LEGEREMENT DE L'INTERVALLE (-1,1) (TOLERANCE 1.D-12)

C    IN:
C       FONC    K4 : /'ASIN'   /'ACOS'   : FONCTION A EVALUER
C       X       R8 : NOMBRE DONT ON CHERCHE ARC-SINUS (OU ARC-COSINUS)
C    OUT:
C       TRIGOM  R8 : ARC-SINUS OU (ARC-COSINUS) DE X

C ----------------------------------------------------------------------
      REAL*8 X,EPS,X2
      EPS = 1.D-12

      IF ((X.GT.1.D0+EPS) .OR. (X.LT.-1.D0-EPS)) CALL UTMESS('F',
     &    'TRIGOM','NOMBRE EN DEHORS DE (-1,1)')


      X2 = X
      IF (X.GT.1.D0) X2 = 1.D0
      IF (X.LT.-1.D0) X2 = -1.D0

      IF (FONC.EQ.'ASIN') THEN
        TRIGOM = ASIN(X2)
      ELSE IF (FONC.EQ.'ACOS') THEN
        TRIGOM = ACOS(X2)
      ELSE
        CALL UTMESS('F','TRIGOM','ASIN/ACOS SVP')
      END IF


      END
