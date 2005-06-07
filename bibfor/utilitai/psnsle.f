      SUBROUTINE PSNSLE ( INPSCO, NRPASE, TYPEST,
     >                    NOMSTR )
C
C     PARAMETRES SENSIBLES - NOM DES STRUCTURES - LECTURE
C     *          *           *       *            **
C ----------------------------------------------------------------------
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
C RESPONSABLE GNICOLAS G.NICOLAS
C ----------------------------------------------------------------------
C     LIT, DANS LA STRUCTURE DE MEMORISATION, LE NOM DE LA STRUCTURE
C     ASSOCIE A UN PARAMETRE DE SENSIBILITE ET UN RANG
C     POUR LA COMMANDE EN COURS DE TRAITEMENT
C     CELA EST APPLICABLE AU COURS DU TRAITEMENT D'UNE COMMANDE
C     A PRIORI, CE PROGRAMME NE DOIT ETRE APPELE QUE PAR UN AUTRE PSXXXX
C ----------------------------------------------------------------------
C
C IN  INPSCO  : STRUCTURE CONTENANT LA LISTE DES NOMS
C               SA TAILLE ET SON CONTENU SONT DEFINIS DANS SEGICO
C IN  NRPASE  : NUMERO DU PARAMETRE SENSIBLE CONCERNE
C IN  TYPEST  : NUMERO DU TYPE DE STRUCTURE QUE L'ON VEUT LIRE
C               ENTRE 0 ET NBPSCO
C OUT NOMSTR  : NOM DE LA STRUCTURE. ON COMPLETE PAR DES BLANCS
C
C ----------------------------------------------------------------------
C
      IMPLICIT   NONE
C
C 0.1. ==> ARGUMENTS
C
      INTEGER NRPASE, TYPEST
C
      CHARACTER*(*) INPSCO
      CHARACTER*(*) NOMSTR
C
C 0.2. ==> COMMUNS
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'PSNSLE' )
C
      INTEGER LXLGUT
C
      INTEGER ADPSCO, NBPSCO
      INTEGER LGNOST
      INTEGER IAUX, JAUX
C
      CHARACTER*08 SAUX08
      CHARACTER*24 SAUX24
C
C====
C 1. RECUPERATION
C====
C
C 1.1. ==> CARACTERISTIQUES DE LA STRUCTURE DE SAUVEGARDE
C
      CALL SEGICO ( 2,
     >              SAUX08, IAUX, SAUX24, SAUX24,
     >              INPSCO, NBPSCO, JAUX )
C
      CALL SEGICO ( 3,
     >              SAUX08, IAUX, SAUX24, SAUX24,
     >              INPSCO, ADPSCO, JAUX )
C
C 1.2. ==> TRANSFERT
C
      IF ( TYPEST.GE.0 .AND. TYPEST.LE.NBPSCO ) THEN
C
        SAUX24 = ZK24 ( ADPSCO + (NBPSCO+1)*NRPASE + TYPEST )
C
        LGNOST = LXLGUT(SAUX24)
        IAUX = LEN(NOMSTR)
C
        IF ( LGNOST.GT.IAUX ) THEN
C
          CALL UTDEBM ( 'A', NOMPRO, 'PROBLEME DE DECLARATION' )
          CALL UTIMPI (
     >    'L', 'LA CHAINE NOMSTR EST DE LONGUEUR ', 1, IAUX )
          CALL UTIMPI ( 'L',
     >    'ON VEUT Y METTRE '//SAUX24//' DE LONGUEUR ', 1, LGNOST )
          CALL UTFINM
          CALL UTMESS ( 'F', NOMPRO, 'ERREUR DE PROGRAMMATION' )
C
        ENDIF
C
        NOMSTR(1:LGNOST) = SAUX24(1:LGNOST)
        DO 12 , IAUX = LGNOST+1 , IAUX
          NOMSTR(IAUX:IAUX) = ' '
   12   CONTINUE
C
C 1.3. ==> PROBLEME
C
      ELSE
C
        CALL UTDEBM ( 'A', NOMPRO, 'MAUVAISE VALEUR POUR TYPEST' )
        CALL UTIMPI ( 'L', 'IL FAUT ENTRE 0 ET ', 1, NBPSCO )
        CALL UTIMPI ( 'L', 'MAIS ON A DONNE ', 1, TYPEST )
        CALL UTFINM
        CALL UTMESS ( 'F', NOMPRO, 'ERREUR DE PROGRAMMATION' )
C
      ENDIF
C
      END
