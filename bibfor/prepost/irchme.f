      SUBROUTINE IRCHME ( IFICHI, CHANOM, MODELE, PARTIE, NOCHMD,
     &                    NORESU, NOSIMP, NOPASE, NOMSYM, TYPECH,
     &                    NUMORD, NBRCMP, NOMCMP, NBNOEC, LINOEC,
     &                    NBMAEC, LIMAEC, LVARIE, CODRET )
C_______________________________________________________________________
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 20/06/2012   AUTEUR GENIAUT S.GENIAUT 
C RESPONSABLE SELLENET N.SELLENET
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C        IMPRESSION DU CHAMP CHANOM NOEUD/ELEMENT ENTIER/REEL
C        AU FORMAT MED
C     ENTREES:
C        IFICHI : UNITE LOGIQUE D'IMPRESSION DU CHAMP
C        CHANOM : NOM ASTER DU CHAM A ECRIRE
C        MODELE : NOM DU MODELE
C        PARTIE : IMPRESSION DE LA PARTIE IMAGINAIRE OU REELLE POUR
C                  UN CHAMP COMPLEXE AU FORMAT CASTEM OU GMSH OU MED
C        NORESU : NOM DU RESULTAT D'OU PROVIENT LE CHAMP A IMPRIMER.
C        NOSIMP : NOM SIMPLE ASSOCIE AU CONCEPT NORESU SI SENSIBILITE
C        NOPASE : NOM DU PARAMETRE SENSIBLE
C        NOMSYM : NOM SYMBOLIQUE DU CHAMP
C        TYPECH : TYPE DU CHAMP
C        NUMORD : NUMERO D'ORDRE DU CHAMP DANS LE RESULTAT_COMPOSE.
C        NBRCMP : NOMBRE DE COMPOSANTES A ECRIRE
C        NOMCMP : NOMS DES COMPOSANTES A ECRIRE
C        NBNOEC : NOMBRE DE NOEUDS A ECRIRE (O, SI TOUS LES NOEUDS)
C        LINOEC : LISTE DES NOEUDS A ECRIRE SI EXTRAIT
C        NBMAEC : NOMBRE DE MAILLES A ECRIRE (0, SI TOUTES LES MAILLES)
C        LIMAEC : LISTE DES MAILLES A ECRIRE SI EXTRAIT
C     SORTIES:
C        CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_______________________________________________________________________
C
C     ARBORESCENCE DE L'ECRITURE DES CHAMPS AU FORMAT MED :
C  IRCH19
C  IRCHME
C  MDNOCH RSADPA  IRCNME IRCEME
C                   .    .
C                    .  .
C                   IRCAME
C                    .  .
C                   .    .
C  MDNOMA MDEXMA IRMAIL UTLICM LRMTYP IRCMPR MDEXCH EFOUVR ...
C                   ... IRCMCC IRCMPG IRCMVA IRCMEC EFFERM
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      INCLUDE 'jeveux.h'
      CHARACTER*8 NORESU, NOSIMP, NOPASE, TYPECH
      CHARACTER*16 NOMSYM
      CHARACTER*19 CHANOM
      CHARACTER*24 NOCELK
      CHARACTER*(*) NOMCMP(*),MODELE,PARTIE
C
      INTEGER NUMORD, NBRCMP, IFICHI, IRET
      INTEGER NBNOEC, NBMAEC, ICELK
      INTEGER LINOEC(*), LIMAEC(*)
C
      LOGICAL LVARIE
C
      INTEGER CODRET
C
C 0.2. ==> COMMUNS
C
C 0.3. ==> VARIABLES LOCALES
C
      INTEGER EDNONO
      PARAMETER (EDNONO=-1)
      INTEGER EDNOPT
      PARAMETER (EDNOPT=-1)
C
      INTEGER IFM,NIVINF,NUMPT,IAUX
C
      CHARACTER*8 SAUX08,MODEL1
      CHARACTER*24 VALK(1)
      CHARACTER*64 NOCHMD
C
      REAL*8 INSTAN
C
C====
C 1. PREPARATIFS
C====
C
      CALL INFNIV ( IFM, NIVINF )
C
10000 FORMAT(/,81('='),/,81('='),/)
10001 FORMAT(81('-'),/)
      IF ( NIVINF.GT.1 ) THEN
        CALL UTFLSH (CODRET)
        WRITE (IFM,10000)
        CALL U2MESK('I','MED_90',1,CHANOM)
      ENDIF
C
C 1.1. ==> NOM DU CHAMP DANS LE FICHIER MED
C
      IF ( NOPASE.EQ.'        ' ) THEN
        SAUX08 = NORESU
      ELSE
        SAUX08 = NOSIMP
      ENDIF
C
      IF ( CODRET.EQ.0 ) THEN
        IF ( NIVINF.GT.1 ) THEN
           WRITE (IFM,11000) SAUX08
           WRITE (IFM,11001) NOMSYM
        ENDIF
        IF ( NOPASE.NE.'        ' ) THEN
          WRITE (IFM,11002) NOPASE
        ENDIF
        IF ( NIVINF.GT.1 ) THEN
          WRITE (IFM,11003) TYPECH
          WRITE (IFM,11004) NOCHMD
        ENDIF
      ELSE
         CALL U2MESS('A','MED_91')
         CALL U2MESK('A','MED_44',1,CHANOM)
         CALL U2MESK('A','MED_45',1,NORESU)
      ENDIF
C
11000 FORMAT(1X,'RESULTAT           : ',A8)
11001 FORMAT(1X,'CHAMP              : ',A16)
11002 FORMAT(1X,'PARAMETRE SENSIBLE : ',A8)
11003 FORMAT(1X,'TYPE DE CHAMP      : ',A)
11004 FORMAT(3X,'==> NOM MED DU CHAMP : ',A64,/)
C
C 1.2. ==> INSTANT CORRESPONDANT AU NUMERO D'ORDRE
C
      IF ( CODRET.EQ.0 ) THEN
C
        IF ( NORESU.NE.' ' ) THEN
          INSTAN=999.999D0
C         -- DANS UN EVOL_NOLI, IL PEUT EXISTER INST ET FREQ.
C            ON PREFERE INST :
          CALL JENONU(JEXNOM(NORESU//'           .NOVA','INST'),IRET)
          IF ( IRET.NE.0 ) THEN
            CALL RSADPA ( NORESU, 'L', 1, 'INST', NUMORD, 0, IAUX,
     &                    SAUX08 )
            INSTAN = ZR(IAUX)
          ELSE
            CALL JENONU(JEXNOM(NORESU//'           .NOVA','FREQ'),IRET)
            IF ( IRET.NE.0 ) THEN
              CALL RSADPA ( NORESU, 'L', 1, 'FREQ', NUMORD, 0, IAUX,
     &                      SAUX08 )
              INSTAN = ZR(IAUX)
            ELSE
              CALL JENONU(JEXNOM(NORESU//'           .NOVA',
     &                    'CHAR_CRIT'),IRET)
              IF ( IRET.NE.0 ) THEN
                CALL RSADPA ( NORESU, 'L', 1, 'CHAR_CRIT', NUMORD, 0,
     &                        IAUX,SAUX08 )
                INSTAN = ZR(IAUX)
              ENDIF
            ENDIF
        ENDIF
        NUMPT = NUMORD
C
      ELSE
C
        NUMORD = EDNONO
        NUMPT = EDNOPT
C
      ENDIF

      ENDIF
C
C 1.3. ==> NOM DU MODELE ASSOCIE, DANS LE CAS D'UNE STRUCTURE RESULTAT
C
      IF ( CODRET.EQ.0 ) THEN
C
        IF(TYPECH(1:4).NE.'ELGA')THEN
          MODEL1 = ' '
        ELSE
          IF ( NORESU.NE.' ' ) THEN
            CALL RSADPA ( NORESU, 'L', 1, 'MODELE', NUMORD, 0, IAUX,
     &                  SAUX08 )
            MODEL1 = ZK8(IAUX)
          ELSE
            IF ( MODELE.EQ.' ' ) THEN
              NOCELK = CHANOM//'.CELK'
              CALL JEVEUO(NOCELK,'L',ICELK)
              MODEL1 = ZK24(ICELK)
            ELSE
              MODEL1 = MODELE
            ENDIF
          ENDIF
          CALL JEEXIN ( MODEL1//'.MAILLE', IRET)
          IF(IRET.EQ.0)THEN
            VALK (1) = CHANOM
            CALL U2MESG('F', 'MED_82',1,VALK,0,0,0,0.D0)
          ENDIF
        ENDIF
C
        IF ( NIVINF.GT.1 ) THEN
          WRITE (IFM,13001) MODEL1
13001 FORMAT(2X,'MODELE ASSOCIE AU CHAMP : ',A)
        ENDIF
      ENDIF
C
C====
C 2. ECRITURE DANS LE FICHIER MED
C====
C
      IF ( CODRET.EQ.0 ) THEN
C
        IF ( TYPECH(1:4).EQ.'NOEU' ) THEN
          CALL IRCNME ( IFICHI, NOCHMD, CHANOM, TYPECH, MODEL1,
     &                  NBRCMP, NOMCMP, PARTIE,
     &                  NUMPT, INSTAN, NUMORD,
     &                  NBNOEC, LINOEC,
     &                  CODRET )
        ELSE IF ( TYPECH(1:2).EQ.'EL' ) THEN
C
C         SI ON EST DANS LE CAS VARI ET QU'ON A DEMANDE L'EXPLOSION
C         DU CHAMP SUIVANT LE COMPORTEMENT, ON DOIT RAJOUTER 
C         CERTAINS TRAITEMENT
          IF ( (NOMSYM(1:5).EQ.'VARI_').AND.LVARIE ) THEN
            CALL IRVARI ( IFICHI, NOCHMD, CHANOM, TYPECH, MODEL1,
     &                    NBRCMP, NOMCMP, PARTIE,
     &                    NUMPT, INSTAN, NUMORD,
     &                    NBMAEC, LIMAEC, NORESU,
     &                    CODRET )
          ELSE
            CALL IRCEME ( IFICHI, NOCHMD, CHANOM, TYPECH, MODEL1,
     &                    NBRCMP, NOMCMP, ' ', PARTIE,
     &                    NUMPT, INSTAN, NUMORD,
     &                    NBMAEC, LIMAEC,
     &                    CODRET )
          ENDIF
        ELSE IF ( TYPECH(1:4).EQ.'CART' ) THEN
C
          CALL IRCEME ( IFICHI, NOCHMD, CHANOM, TYPECH, MODEL1,
     &                  NBRCMP, NOMCMP, ' ', PARTIE,
     &                  NUMPT, INSTAN, NUMORD,
     &                  NBMAEC, LIMAEC,
     &                  CODRET )
        ELSE
          CODRET = 1
          CALL U2MESK('A','MED_92',1,TYPECH(1:4))
        ENDIF
C
      ENDIF
C
C====
C 3. BILAN
C====
C
      IF ( CODRET.NE.0 ) THEN
         CALL U2MESK('A','MED_89',1,CHANOM)
      ENDIF
C
      IF ( NIVINF.GT.1 ) THEN
        CALL U2MESK('I','MED_93',1,CHANOM)
        WRITE (IFM,10000)
        CALL UTFLSH (CODRET)
        WRITE (IFM,10001)
      ENDIF
C
      END
