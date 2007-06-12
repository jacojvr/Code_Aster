      FUNCTION NBAREQ(TYPEMA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/01/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INTEGER      NBAREQ
      CHARACTER*8  TYPEMA
C      
C ----------------------------------------------------------------------
C
C CONSTRUCTION DE BOITES ENGLOBANTES POUR UN GROUPE DE MAILLES
C
C RETOURNE LE NOMBRE D'ARETES QUADRATIQUES
C
C ----------------------------------------------------------------------
C
C
C IN  TYPEMA : TYPE DE MAILLE
C
C ROUTINE SOEUR : NOAREQ
C
C ----------------------------------------------------------------------
C
      IF (TYPEMA(1:5).EQ.'TRIA6') THEN
        NBAREQ = 3
      ELSEIF (TYPEMA(1:5).EQ.'QUAD6') THEN
        NBAREQ = 2
      ELSEIF ((TYPEMA(1:5).EQ.'QUAD8').OR.
     &        (TYPEMA(1:5).EQ.'QUAD9')) THEN
        NBAREQ = 4
      ELSEIF (TYPEMA(1:7).EQ.'TETRA10') THEN
        NBAREQ = 6
      ELSEIF ((TYPEMA(1:7).EQ.'PENTA12').OR.
     &        (TYPEMA(1:7).EQ.'PENTA14')) THEN
        NBAREQ = 6
      ELSEIF (TYPEMA(1:7).EQ.'PENTA15') THEN
        NBAREQ = 9
      ELSEIF((TYPEMA(1:6).EQ.'HEXA16').OR.
     &       (TYPEMA(1:6).EQ.'HEXA18')) THEN
        NBAREQ = 8
      ELSEIF((TYPEMA(1:6).EQ.'HEXA20').OR.
     &       (TYPEMA(1:6).EQ.'HEXA27'))THEN
        NBAREQ = 12
      ELSE
        WRITE(6,*) 'MAILLE INCONNUE: ',TYPEMA
        CALL ASSERT(.FALSE.) 
      ENDIF

      END
