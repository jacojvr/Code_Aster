      SUBROUTINE NTINIT(RESULT,MODELE,INFCHA,CHARGE,INFOCH,
     &                  SOLVEU,NUMEDD,PARMER,LOSTAT,EVOL  ,
     &                  TIME  ,SDDISC,DERNIE,LISINS,NBPASE,
     &                  INPSCO,VHYDR ,SDOBSE,MAILLA,CRITHE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 01/09/2008   AUTEUR DURAND C.DURAND 
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
C RESPONSABLE                            DURAND C.DURAND
C TOLE CRP_21
C ---------------------------------------------------------------------
C     THERMIQUE : INITIALISATIONS.
C     *           ****
C   -------------------------------------------------------------------
C     SUBROUTINES APPELLEES:
C       JEVEUX: JEDETR,COPISD,UTCRRE.
C       PARAMETRE DE CMD: GETRES,NTINST.
C       SENSIBILITE: PSNSLE,PSGENC.
C       MSG: INFNIV.
C       MANIP SD: VTCREB.
C       LECTURE DONNEES: NTDOET,NTDOED.
C       MATRICE: NUMERO.
C
C     FONCTIONS INTRINSEQUES:
C       AUCUNE.
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C       30/11/01 (OB): MODIFICATIONS DES MODES D'INITIALISATIONS DES
C                      CALCULS DE SENSIBILITE. DESORMAIS, IL EST FIXE
C                      PAR LE MOT-CLE 'ETAT_INIT' DU PB STD.
C       12/02/02 (OB): ACCEPTATION DES SENSIBILITES EN NON-LINEAIRE.
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
      IMPLICIT NONE

C 0.1. ==> ARGUMENTS

      LOGICAL      LOSTAT,EVOL
      INTEGER      NUMFIN,NBPASE
      INTEGER      DERNIE
      REAL*8       PARMER(2)
      CHARACTER*19 INFCHA,SOLVEU,LISINS,SDDISC
      CHARACTER*24 RESULT,MODELE,CHARGE,INFOCH,NUMEDD,
     &             VHYDR,TIME,HYDRIN,CRITHE
      CHARACTER*(*) INPSCO
      CHARACTER*14 SDOBSE
      CHARACTER*8  MAILLA

C 0.2. ==> COMMUNS
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16            ZK16
      CHARACTER*24                    ZK24
      CHARACTER*32                            ZK32
      CHARACTER*80                                    ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

C 0.3. ==> VARIABLES LOCALES

      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'NTINIT' )
      INTEGER      NEQ,IRET,IERR,NRPASE,INITPR,IAUX,JAUX,IBID
      INTEGER      NIV,IFM
      LOGICAL      LLIN
      CHARACTER*8  K8BID,NOPASE
      CHARACTER*14 NUPOSS
      CHARACTER*16 TYPRES,NOMCMD
      CHARACTER*24 SDSUIV
      CHARACTER*24 TEMPIN,TEMPI0,VTEMP,VTEMPM,RESUIN,RESUID,NOOJB
      CHARACTER*24 VALK(2)
      INTEGER      NUMINI
      REAL*8       INSTAM
C      
      DATA SDSUIV            /'&&NTINIT.SUIVI'/         
      
C ---------------------------------------------------------------------

C====
C 1. PREALABLE
C====
      CALL INFNIV(IFM,NIV)
      CALL GETRES ( K8BID, TYPRES, NOMCMD )
C      CALL RSCRSD (RESULT,TYPRES,100)
      TIME   = RESULT(1:8)//'.CHTPS'
      IF (NOMCMD(1:13).EQ.'THER_LINEAIRE') THEN
        LLIN = .TRUE.
      ELSE
        LLIN = .FALSE.
      ENDIF
      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA,IBID)

C====
C 2. NUMEROTATION ET CREATION DU PROFIL DE LA MATRICE
C====

C                123456789012345678901234
      NUMEDD =  '12345678.NUMED          '
      NOOJB='12345678.00000.NUME.PRNO'
      CALL GNOMSD ( NOOJB,10,14 )
      NUMEDD=NOOJB(1:14)
      CALL RSNUME(RESULT,'TEMP',NUPOSS)
      CALL NUMERO(NUPOSS,MODELE,INFCHA,SOLVEU,'VG',NUMEDD )

C====
C 3. SAISIE DE L'ETAT THERMIQUE ET LISTE D'INSTANTS DE CALCUL
C====

      DO 31 , NRPASE = 0 , NBPASE

C 3.1. ==> CREATION DES CHAMPS DE TEMPERATURES INITIALES

        IAUX = NRPASE
        JAUX = 4
        CALL PSNSLE ( INPSCO, IAUX, JAUX, VTEMP )
        CALL VTCREB ( VTEMP, NUMEDD, 'V', 'R', NEQ )
        JAUX = 7
        CALL PSNSLE ( INPSCO, IAUX, JAUX, TEMPIN )
        IF ( TEMPIN(1:2).EQ.'&&' ) THEN
          CALL VTCREB ( TEMPIN, NUMEDD, 'V', 'R', NEQ )
          TEMPI0 = TEMPIN
        ELSE
          TEMPI0 = ' '
        ENDIF

C 3.2. ==> SAISIE DU TYPE DE CALCUL ET DU CHAMP INITIAL
C 3.2.1 ==> CALCUL PRINCIPAL
C           S'IL Y AURA UN CALCUL DE DERIVEE IL FAUT CREER LE TABLEAU
C           DE LA TEMPERATURE A T MOINS 1

        IF ( NRPASE.EQ.0 ) THEN
C PB STD: LECTURE DES PARAMETRES DE CAUCHY
C OUT LOSTAT : LOGIQUE INDIQUE SI L'ON CALCULE UN CAS STATIONNAIRE
C OUT INITPR : TYPE D'INITIALISATION
C              -1 : PAS D'INITIALISATION. (VRAI STATIONNAIRE)
C               0 : CALCUL STATIONNAIRE
C               1 : VALEUR UNIFORME
C               2 : CHAMP AUX NOEUDS
C               3 : RESULTAT D'UN AUTRE CALCUL
C OUT RESUIN : NOM DU RESULTAT PRECEDENT SI INITPR = 3
C I/O TEMPIN : CHAMP DE TEMPERATURE INITIALE
C              SI INITPR = -1 OU 0 : RIEN
C              SI INITPR = 1 : ON REMPLIT LE TABLEAU PAR LA CONSTANTE
C              SI INITPR = 2 OU 3 : ON DONNE LE NOM DU CHAMP DE DEPART
C                                   A LA VARIABLE TEMPIN
C OUT HYDRIN : CHAMP D HYDRATATION INITIALE
          CALL NTDOET(MODELE,LOSTAT,INITPR,RESUIN,NUMINI,INSTAM,
     &                TEMPIN,HYDRIN)
C CREATION DU CHAMP A T- POUR LA DERIVEE SI ON EST EN TRANSITOIRE
          IF ((NBPASE.GT.0).AND.(INITPR.NE.-1)) THEN
            IAUX = NRPASE
            JAUX = 5
            CALL PSNSLE ( INPSCO, IAUX, JAUX, VTEMPM )
            CALL VTCREB ( VTEMPM, NUMEDD, 'V', 'R', NEQ )
          ENDIF

C 3.2.2. ==> CALCULS DERIVES
C            LE TYPE DE CALCUL EST LE MEME (INITPR)
C            ON DOIT EVENTUELLEMENT RECUPERER LE NOM DU RESULTAT
C            QUI SERT A INITIALISER (INITPR=3)

        ELSE
C PB DERIVE: ON UTILISE LE MEME PARAMETRE DE CAUCHY QUE POUR LE PB STD
C DANS LE CAS D'UNE REPRISE (INITPR.EQ.3) IL FAUT LIRE LA DERIVEE DU
C NOUVEAU CHAMP INITIAL CORRESPONDANTE.
C DANS LES AUTRES CAS IL FAUT CONSTRUIRE UN CHAMP INITIAL NUL, SAUF EN
C VRAI STATIONNAIRE (.NOT.LOSTAT) OU IL Y'A RIEN A FAIRE

          IF (INITPR.EQ.3) THEN
            IAUX = NRPASE
            JAUX = 1
            CALL PSNSLE ( INPSCO, IAUX, JAUX, NOPASE )
            CALL PSGENC ( RESUIN, NOPASE, RESUID, IRET )
            IF ( IRET.NE.0 ) THEN
              VALK(1) = RESUIN
              VALK(2) = NOPASE//'                '
              CALL U2MESK('A','SENSIBILITE_3', 2 ,VALK)
              CALL U2MESK('F','UTILITAI7_99', 1 ,NOMPRO)
            ENDIF
          ENDIF

C AFFICHAGE DU TYPE D'INITIALISATION
        IF (NIV.EQ.2) THEN
          WRITE(IFM,*)
          WRITE(IFM,*)'TYPE D''INITIALISATION :',INITPR
          WRITE(IFM,*)
        ENDIF
C ON N'A PAS BESOIN D'INITIALISER LA DONNEE DE CAUCHY DANS UN VRAI
C STATIONNAIRE ET POUR UN TRANSITOIRE DEBUTANT PAR UNE PHASE STATIO.
          IF (.NOT.LOSTAT) THEN
            CALL NTDOED(INITPR,RESUID,NUMINI,TEMPIN)
          ENDIF

        ENDIF

C 3.3. ==> COPIE DES CHAMPS INITIAUX DANS LA VARIABLE DE CALCUL

        IF (.NOT.LOSTAT) THEN
          CALL VTCOPY(TEMPIN,VTEMP,IERR)
        ENDIF

C 3.4. ==> MENAGE DE LA STRUCTURE TEMPORAIRE

        IF (TEMPI0.NE.' ') THEN
          CALL JEDETR(TEMPI0)
        ENDIF

   31 CONTINUE

C EN NON-LINEAIRE, RECOPIE DU CHAMP D'HYDRATATION
      IF (.NOT.LLIN) THEN
        CALL COPISD('CHAMP_GD','V',HYDRIN,VHYDR)
      ENDIF
      
C 3.4. ==> LISTE DES INSTANTS DE CALCUL ET DIVERS COMPTEURS

      CALL TIINIT(MAILLA,RESULT(1:8),INSTAM,LOSTAT,SDDISC,
     &            DERNIE,LISINS,SDOBSE,SDSUIV,NUMFIN,EVOL  )

C====
C 4. ALLOCATION DES STRUCTURES DE RESULTAT
C====
      CALL UTCRRE ( NBPASE, INPSCO, DERNIE+NUMFIN+1 )

C====
C 5. CREATION DE LA SD POUR ARCHIVAGE DES INFORMATIONS DE CONVERGENCE
C====
      CALL NTCRCV(CRITHE(1:19))


C----------------------------------------------------------------------
      END
