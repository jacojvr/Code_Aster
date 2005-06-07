      SUBROUTINE USENCO ( AI1, BI1, ALPHAD, ALPHAF, NDIM, VECT )
      IMPLICIT   NONE
      INTEGER             NDIM
      REAL*8              AI1, BI1, VECT(*), ALPHAD, ALPHAF
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 11/08/2004   AUTEUR CIBHHLV L.VIVAN 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C-----------------------------------------------------------------------
      INTEGER      I, IND
      REAL*8       THETA, P
C-----------------------------------------------------------------------
C
      IND = 0
      DO 10 I = 1 , NDIM
         IF ( VECT(2*I-1) .GE. ALPHAD ) THEN
            IND = I
            GOTO 12
         ENDIF
 10   CONTINUE
      CALL UTMESS ('F','USENCO','BUG !')
 12   CONTINUE
C
      DO 20 I = IND , NDIM
C
         THETA = VECT(2*I-1)
C
         IF ( THETA .GT. ALPHAF ) GOTO 9999
C
         P = AI1*THETA - BI1
C
         VECT(2*I) = VECT(2*I) + P
C
 20   CONTINUE
C
 9999 CONTINUE
C
      END
