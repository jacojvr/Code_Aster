      SUBROUTINE NDEXPL(MODELE,NUMEDD,NUMFIX,MATE  ,CARELE,
     &                  COMREF,COMPOR,LISCHA,METHOD,FONACT,
     &                  CARCRI,PARCON,SDIMPR,SDSTAT,SDNUME,
     &                  SDDYNA,SDDISC,SDTIME,SDERRO,VALINC,
     &                  NUMINS,SOLALG,SOLVEU,MATASS,MAPREC,
     &                  MEELEM,MEASSE,VEELEM,VEASSE,NBITER)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 30/10/2012   AUTEUR ABBAS M.ABBAS 
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
C TOLE CRP_21
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INTEGER      NUMINS
      INTEGER      FONACT(*)
      CHARACTER*16 METHOD(*)
      REAL*8       PARCON(*)
      CHARACTER*24 CARCRI
      CHARACTER*24 SDSTAT,SDTIME,SDERRO,SDIMPR
      CHARACTER*19 SDNUME,SDDYNA,SDDISC
      CHARACTER*19 VALINC(*),SOLALG(*)
      CHARACTER*19 MEELEM(*),VEELEM(*)
      CHARACTER*19 MEASSE(*),VEASSE(*)
      CHARACTER*19 LISCHA
      CHARACTER*19 SOLVEU,MAPREC,MATASS
      CHARACTER*24 MODELE,NUMEDD,NUMFIX
      CHARACTER*24 COMREF,COMPOR
      CHARACTER*24 MATE  ,CARELE
      INTEGER      NBITER
C
C ----------------------------------------------------------------------
C
C OPERATEUR NON-LINEAIRE MECANIQUE
C
C ALGORITHME DYNAMIQUE EXPLICITE
C
C ----------------------------------------------------------------------
C
C IN  MODELE : MODELE
C IN  NUMEDD : NUME_DDL (VARIABLE AU COURS DU CALCUL)
C IN  NUMFIX : NUME_DDL (FIXE AU COURS DU CALCUL)
C IN  MATE   : CHAMP MATERIAU
C IN  CARELE : CARACTERISTIQUES DES ELEMENTS DE STRUCTURE
C IN  COMREF : VARIABLES DE COMMANDE DE REFERENCE
C IN  COMPOR : COMPORTEMENT
C IN  LISCHA : L_CHARGES
C IN  METHOD : INFORMATIONS SUR LES METHODES DE RESOLUTION
C IN  SOLVEU : SOLVEUR
C IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
C IN  CARCRI : PARAMETRES DES METHODES D'INTEGRATION LOCALES
C IN  SDSTAT : SD STATISTIQUES
C IN  SDDISC : SD DISCRETISATION TEMPORELLE
C IN  SDTIME : SD TIMER
C IN  NUMINS : NUMERO D'INSTANT
C IN  VALINC : VARIABLE CHAPEAU POUR INCREMENTS VARIABLES
C IN  SOLALG : VARIABLE CHAPEAU POUR INCREMENTS SOLUTIONS
C IN  MEELEM : VARIABLE CHAPEAU POUR NOM DES MATR_ELEM
C IN  MEASSE : VARIABLE CHAPEAU POUR NOM DES MATR_ASSE
C IN  VEELEM : VARIABLE CHAPEAU POUR NOM DES VECT_ELEM
C IN  VEASSE : VARIABLE CHAPEAU POUR NOM DES VECT_ASSE
C IN  SDDYNA : SD DYNAMIQUE
C IN  MATASS : NOM DE LA MATRICE DU PREMIER MEMBRE ASSEMBLEE
C IN  MAPREC : NOM DE LA MATRICE DE PRECONDITIONNEMENT (GCPC)
C OUT NBITER : NOMBRE D'ITERATIONS DE NEWTON
C
C ----------------------------------------------------------------------
C
      CHARACTER*24 K24BLA
      LOGICAL      LERRIT
C
C ----------------------------------------------------------------------
C
      K24BLA = ' '
C
C --- INITIALISATION DES CHAMPS D'INCONNUES POUR LE NOUVEAU PAS DE TEMPS
C
      CALL NDXNPA(MODELE,MATE  ,CARELE,LISCHA,FONACT,
     &            SDDISC,SDDYNA,SDNUME,NUMEDD,NUMINS,
     &            VALINC,SOLALG)
C
C --- CALCUL DES CHARGEMENTS CONSTANTS AU COURS DU PAS DE TEMPS
C
      CALL NMCHAR('FIXE',' '   ,
     &            MODELE,NUMEDD,MATE  ,CARELE,COMPOR,
     &            LISCHA,CARCRI,NUMINS,SDTIME,SDDISC,
     &            PARCON,FONACT,K24BLA,K24BLA,COMREF,
     &            VALINC,SOLALG,VEELEM,MEASSE,VEASSE,
     &            SDDYNA)
C
C --- PREDICTION D'UNE DIRECTION DE DESCENTE
C
      CALL NDXPRE(MODELE,NUMEDD,NUMFIX,MATE  ,CARELE,
     &            COMREF,COMPOR,LISCHA,METHOD,SOLVEU,
     &            FONACT,CARCRI,SDDISC,SDSTAT,SDTIME,
     &            NUMINS,VALINC,SOLALG,MATASS,MAPREC,
     &            SDDYNA,SDERRO,MEELEM,MEASSE,VEELEM,
     &            VEASSE,LERRIT)
C
      IF (LERRIT) GOTO 315
C
C --- CALCUL PROPREMENT DIT DE L'INCREMENT DE DEPLACEMENT
C
      CALL NDXDEP(NUMEDD,FONACT,NUMINS,SDDISC,SDDYNA,
     &            SDNUME,VALINC,SOLALG,VEASSE)
C
C --- ESTIMATION DE LA CONVERGENCE
C
 315  CONTINUE
      CALL NDXCVG(SDDISC,SDERRO,VALINC)
C
C --- EN L'ABSENCE DE CONVERGENCE ON CHERCHE A SUBDIVISER LE PAS
C --- DE TEMPS SI L'UTILISATEUR A FAIT LA DEMANDE
C
      CALL NDXDEC(SDIMPR,SDDISC,SDERRO,SOLVEU,NUMINS)
C
      NBITER = 1
C
      END
