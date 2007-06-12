      LOGICAL FUNCTION LTEATT (TYPEL,NOATTR,VATTR)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 11/07/2005   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
      CHARACTER*(*) TYPEL,NOATTR,VATTR
C---------------------------------------------------------------------
C BUT : TESTER SI L'ATTRIBUT NOATTR EXISTE ET A LA VALEUR VATTR
C---------------------------------------------------------------------
C     ARGUMENTS:
C     ----------
C     IN TYPEL  (K16) : NOM DU TYPE_ELEMENT A INTERROGER
C                        (OU ' ' SI L'ON EST "SOUS" LA ROUTINE TE0000)
C     IN NOATTR (K16) : NOM DE L'ATTRIBUT
C     IN VATTR  (K16) : VALEUR DE L'ATTRIBUT
C    OUT LTEATT (L)   : .TRUE. : L'ATTRIBUT EXISTE POUR LE TYPE_ELEMENT
C                                ET SA VALEUR VAUT VATTR
C                       .FALSE. : SINON
C-----------------------------------------------------------------------
C  CETTE ROUTINE EST ACCESSIBLE PARTOUT DANS LE CODE. SI ELLE EST
C  APPELEE EN DEHORS DE TE0000 (OU AVEC TYPEL != ' '), ELLE NECESSITE
C  DES APPELS JEVEUX, ELLE DEVIENT DONC UN PEU COUTEUSE.
C-----------------------------------------------------------------------
C  VARIABLES LOCALES :
      CHARACTER*16 VATTR2
      INTEGER IRET

C----------------------------------------------------------------------
      CALL TEATTR (TYPEL,'C',NOATTR,VATTR2,IRET)
      IF ((IRET.EQ.0).AND.(VATTR.EQ.VATTR2)) THEN
         LTEATT=.TRUE.
      ELSE
         LTEATT=.FALSE.
      ENDIF
      END
