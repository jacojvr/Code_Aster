      SUBROUTINE NTREP0 ( NUMORD, TPSNP1, VHYDR, NBPASE, INPSCO,
     &                    MODELE, MATE, CARELE, LISCHA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/05/2004   AUTEUR LEBOUVIE F.LEBOUVIER 
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
C
C ----------------------------------------------------------------------
C COMMANDES DE THERMIQUE : SAUVEGARDE DES ETATS INITIAUX
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER      NUMORD
      INTEGER NBPASE
C
      REAL*8       TPSNP1
C
      CHARACTER*24 VHYDR
      CHARACTER*(*) INPSCO,MODELE,MATE,CARELE
      CHARACTER*19 LISCHA,K19B
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
CC      CHARACTER*6 NOMPRO
CC      PARAMETER ( NOMPRO = 'NTREP0' )
C
      INTEGER      IAUX, JAUX
      INTEGER      NRPASE
      CHARACTER*24 RESULT, VTEMP, NOMCH
C
C====
C 1. ON BOUCLE SUR TOUS LES RESULTATS
C====
C
      DO 11 , NRPASE = 0 , NBPASE
C
C 1.1. ==> NOM DES STRUCTURES : RESULTAT, TEMPERATURE
C
        IAUX = NRPASE
C
        JAUX = 3
        CALL PSNSLE ( INPSCO, IAUX, JAUX, RESULT )
C
        JAUX = 4
        CALL PSNSLE ( INPSCO, IAUX, JAUX, VTEMP )
C
C 1.2. ==> ARCHIVAGE
C
        CALL NTREPR ( RESULT, NUMORD, TPSNP1, VTEMP, VHYDR, NOMCH,
     &                MODELE(1:8), MATE(1:8), CARELE(1:8), LISCHA)
C
   11 CONTINUE
C
      END
