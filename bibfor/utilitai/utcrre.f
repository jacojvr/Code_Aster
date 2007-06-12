      SUBROUTINE UTCRRE ( NBPASE, INPSCO, NBVAL )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 17/06/2002   AUTEUR GNICOLAS G.NICOLAS 
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
C ----------------------------------------------------------------------
C     UTILITAIRE : CREATION DES RESULTATS
C     **           **           **
C ----------------------------------------------------------------------
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER NBPASE, NBVAL
C
      CHARACTER*(*) INPSCO
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
CC      CHARACTER*6 NOMPRO
CC      PARAMETER ( NOMPRO = 'UTCRRE' )
C
      INTEGER IRET
      INTEGER NRPASE
      INTEGER IAUX, JAUX
C
      CHARACTER*8  K8BID, NOMSTR
      CHARACTER*16 TYPRES, NOMCMD 
C
C ----------------------------------------------------------------------
C
C====
C 1. PREALABLE
C====
C
      CALL GETRES ( K8BID, TYPRES, NOMCMD )
C
C====
C 2. ALLOCATION DES STRUCTURES DE RESULTAT
C====
C
      DO 21 , NRPASE = 0 , NBPASE
C
C 2.1. ==> NOM DE LA STRUCTURE : NOM DE BASE OU NOM DERIVE
C
        IAUX = NRPASE
        JAUX = 3
C
        CALL PSNSLE ( INPSCO, IAUX, JAUX, NOMSTR )
C
C 2.2. ==> ALLOCATION (ON DIMENSIONNE PAR DEFAUT A 100)
C
C                                   9012345678901234  
        CALL JEEXIN ( NOMSTR(1:8)//'           .DESC', IRET )
C
C 2.2.1. ==> SI LE RESULTAT N'EXISTE PAS, ON ALLOUE A NBVAL VALEURS
C
        IF ( IRET.EQ.0 ) THEN
C
          CALL RSCRSD ( NOMSTR, TYPRES, NBVAL )
C
C 2.2.2. ==> S'IL EXISTE, ON DETRUIT TOUT CE QUI SERAIT AU DELA DE NBVAL
C
        ELSE
C
          CALL RSRUSD ( NOMSTR, NBVAL+1 )
C
        ENDIF
C
   21 CONTINUE
C
C-----------------------------------------------------------------------
      END
