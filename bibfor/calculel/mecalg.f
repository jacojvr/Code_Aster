      SUBROUTINE MECALG(OPTIOZ,RESULT,MODELE,DEPLA,THETA,MATE,NCHAR,
     &                  LCHAR,SYMECH,COMPOR,EXITIM,TIME,IORD,NBPRUP,
     &                 NOPRUP,NOPASE,TYPESE,CHDESE,CHEPSE,CHSISE,
     &                 CHVITE,CHACCE,LMELAS,NOMCAS,KCALC)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 20/06/2012   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C-----------------------------------------------------------------------

C     - FONCTION REALISEE:   CALCUL DU TAUX DE RESTITUTION D'ENERGIE
C                          ET DE SA DERIVEE PAR RAPPORT A UNE VARIATION
C                          DE DOMAINE OU PAR RAPPORT A E

C     - ARGUMENTS   :

C IN/OUT    OPTION       --> CALC_G    (G SI CHARGES REELLES)
C                        --> CALC_G_F  (G SI CHARGES FONCTIONS)
C                        --> CALC_DG_E   (DG/DE SI CHARGES REELLES)
C                        --> CALC_DG_E_F (DG/DE SI CHARGES FONCTIONS)
C                        --> CALC_DG_FORC   (DG/DF SI CHARGES REELLES)
C                        --> CALC_DG_FORC_F (DG/DF SI CHARGES FONCTIONS)
C IN    RESULT       --> NOM UTILISATEUR DU RESULTAT ET TABLE
C IN    MODELE       --> NOM DU MODELE
C IN    DEPLA        --> CHAMP DES DEPLACEMENTS
C IN    THETA        --> CHAMP THETA (DE TYPE CHAM_NO)
C IN    MATE         --> CHAMP DU MATERIAU
C IN    NCHAR        --> NOMBRE DE CHARGES
C IN    LCHAR        --> LISTE DES CHARGES
C IN    SYMECH       --> SYMETRIE DU CHARGEMENT
C IN    EXITIM       --> VRAI SI L'INSTANT EST DONNE
C IN    TIME         --> INSTANT DE CALCUL
C IN    IORD         --> NUMERO D'ORDRE DE LA SD
C IN    NOPASE       --> NOM DU PARAMETRE SENSIBLE
C IN    TYPESE       --> TYPE DE SENSIBILITE (VOIR METYSE)
C IN    CHDESE       --> CHAMP DU DEPLACEMENT SENSIBLE (CALC_DG_E ET _F)
C IN    CHEPSE       --> CHAMP DE DEFORMATION SENSIBLE (CALC_DG_E ET _F)
C IN    CHSISE       --> CHAMP DE CONTRAINTE SENSIBLE (CALC_DG_E ET _F)
C IN    LMELAS       --> TRUE SI LE TYPE DE LA SD RESULTAT EST MULT_ELAS
C IN    NOMCAS       --> NOM DU CAS DE CHARGE SI LMELAS
C IN    KCALC        --> = 'NON' : ON RECUPERE LES CHAMPS DE CONTRAINTES
C                                  ET D'ENERGIE DE LA SD RESULTAT
C                        = 'OUI' :ON RECALCULE LES CHAMPS DE CONTRAINTES
C                                  ET D'ENERGIE
C   -------------------------------------------------------------------
C     ASTER INFORMATIONS:
C      11/12/00 (OB): TOILETTAGE FORTRAN, INTRODUCTION DU CALCUL DE DG.
C      04/07/03 (GN): MISE EN PLACE DU MECANISME DES SENSIBILITES
C----------------------------------------------------------------------
C CORPS DU PROGRAMME
C TOLE CRP_21 CRP_20 CRS_1404
      IMPLICIT NONE

C DECLARATION PARAMETRES D'APPELS
      INCLUDE 'jeveux.h'
      INTEGER TYPESE
      CHARACTER*8 MODELE,LCHAR(*),RESULT,SYMECH
      CHARACTER*8 NOPASE,KCALC
      CHARACTER*16 OPTIOZ,NOPRUP(*),NOMCAS
      CHARACTER*24 DEPLA,MATE,COMPOR,THETA,CHDESE,CHEPSE,CHSISE
      CHARACTER*24 CHVITE,CHACCE
      REAL*8 TIME
      INTEGER IORD,NCHAR,NBPRUP
      LOGICAL EXITIM,LMELAS


C DECLARATION VARIABLES LOCALES

      CHARACTER*2 CODRET
      CHARACTER*6 NOMPRO
      PARAMETER (NOMPRO='MECALG')

      INTEGER IBID,IRET,NRES,IFM,NIV,ICHA,NUMFON,VALI(2)
      INTEGER IERD,NCHIN,INCR,INIT,NSIG,NDEP,EXICHA
      REAL*8 G,VAL(2)
      COMPLEX*16 CBID
      LOGICAL EXIGEO,EXITHE,FONC,EPSI,LXFEM
      CHARACTER*8 RESU,LPAIN(50),LPAOUT(2),K8B,NOMCHS,NOMCH0
      CHARACTER*8 LCHARS(NCHAR),FISS
      CHARACTER*16 OPTION,VALK
      CHARACTER*19 CF1D2D,CF2D3D,CHPRES,CHROTA,CHPESA,CHVOLU,CHEPSI
      CHARACTER*19 CF12SS,CF23SS,CHPRSS,CHROSS,CHPESS,CHVOSS,CHEPSS
      CHARACTER*19 CHVREF,CHVARC
      CHARACTER*19 BASLOC,PINTTO,CNSETO,HEAVTO,LONCHA,LNNO,LTNO,PMILTO
      CHARACTER*19 PINTER,AINTER,CFACE,LONGCO,BASECO
      CHARACTER*24 LIGRMO,CHGEOM,LCHIN(50),LCHOUT(2),CHTESE
      CHARACTER*24 CHTIME
      CHARACTER*24 PAVOLU,PA1D2D,PA2D3D,PAPRES,PEPSIN
      CHARACTER*24 CHSIG,CHEPSP,CHVARI,CHSIGI,CHDEPI,TYPE, THETAS
      INTEGER      IARG
      DATA CHVARC/'&&MECALG.CH_VARC_R'/
      DATA CHVREF/'&&MECALG.CHVREF'/



      CALL JEMARQ()
      CHTIME = ' '
      OPTION = OPTIOZ
      CALL INFNIV(IFM,NIV)

C INITIALISATIONS
      G = 0.D0

      CF12SS = '&&MECALG.12SS'
      CF1D2D = '&&MECALG.1D2D'
      CF23SS = '&&MECALG.23SS'
      CF2D3D = '&&MECALG.2D3D'
      CHEPSI = '&&MECALG.EPSI'
      CHEPSS = '&&MECALG.EPSS'
      CHPESA = '&&MECALG.PESA'
      CHPESS = '&&MECALG.PESS'
      CHPRES = '&&MECALG.PRES'
      CHPRSS = '&&MECALG.PRSS'
      CHROSS = '&&MECALG.ROSS'
      CHROTA = '&&MECALG.ROTA'
      CHTESE = '&&MECALG.DLAG_TEMP'
      CHTIME = '&&MECALG.CH_INST_R'
      CHVOLU = '&&MECALG.VOLU'
      CHVOSS = '&&MECALG.VOSS'

      CALL GETVID('THETA','FISSURE',1,IARG,1,FISS,IBID)
      LXFEM = .FALSE.
      IF (IBID.NE.0) LXFEM = .TRUE.

C- RECUPERATION DU CHAMP GEOMETRIQUE

      CALL MEGEOM(MODELE,' ',EXIGEO,CHGEOM)

C- RECUPERATION DU COMPORTEMENT

      CALL GETFAC('COMP_INCR',INCR)

      IF (INCR.NE.0 .AND. LXFEM) THEN
        CALL U2MESS('F','RUPTURE1_43')
      ENDIF

      IF (INCR.NE.0) THEN
        CALL GETVID(' ','RESULTAT',0,IARG,1,RESU,NRES)
        CALL DISMOI('F','TYPE_RESU',RESU,'RESULTAT',IBID,TYPE,IERD)
        IF (TYPE.NE.'EVOL_NOLI') THEN
          CALL U2MESS('F','RUPTURE1_15')
        END IF
        CALL RSEXCH(RESU,'SIEF_ELGA',IORD,CHSIG,IRET)
        IF (IRET.NE.0) THEN
          VALK='SIEF_ELGA'
          CALL U2MESK('F','RUPTURE1_16',1,VALK)
        END IF
        CALL RSEXCH(RESU,'EPSP_ELNO',IORD,CHEPSP,IRET)
        IF (IRET.NE.0) THEN
          VALK='EPSP_ELNO'
          CALL U2MESK('F','RUPTURE1_16',1,VALK)
        END IF
        CALL RSEXCH(RESU,'VARI_ELNO',IORD,CHVARI,IRET)
        IF (IRET.NE.0) THEN
          VALK='VARI_ELNO'
          CALL U2MESK('F','RUPTURE1_16',1,VALK)
        END IF
      END IF

C- RECUPERATION DE L'ETAT INITIAL

      CALL GETFAC('ETAT_INIT',INIT)
      IF (INIT.NE.0) THEN
        CALL GETVID('ETAT_INIT','SIGM',1,IARG,1,CHSIGI,NSIG)
        IF (NSIG.NE.0)THEN
          CALL CHPVER('F',CHSIGI(1:19),'ELXX','SIEF_R',IERD)
        ENDIF
        CALL GETVID('ETAT_INIT','DEPL',1,IARG,1,CHDEPI,NDEP)
        IF (NDEP.NE.0)THEN
          CALL CHPVER('F',CHDEPI(1:19),'NOEU','DEPL_R',IERD)
        ENDIF
        IF ((NSIG.EQ.0) .AND. (NDEP.EQ.0)) THEN
          CALL U2MESS('F','RUPTURE1_12')
        END IF
      END IF

C- RECUPERATION (S'ILS EXISTENT) DES CHAMP DE TEMPERATURES (T,TREF)
      K8B = '        '
      CALL VRCINS(MODELE,MATE,K8B,TIME,CHVARC,CODRET)
      CALL VRCREF(MODELE,MATE(1:8),K8B,CHVREF)


C RECUPERATION DE LA DERIVEE DU CHAMP DE TEMPERATURE
C DANS LA SD DU MOT-CLE CHARGE  + CALCUL DE THETAS
      IF (OPTION.EQ.'CALC_DG') THEN
        IBID = 0
        CALL RSEXC2(1,1,NOPASE,'THETA',IBID,THETAS,OPTION,IRET)
        IF (IRET.GT.0) THEN
          CALL U2MESK('F','SENSIBILITE_4',1,NOPASE)
        ENDIF

        CALL NMDETE(MODELE,MATE,' ',NCHAR,LCHAR,TIME,
     &              TYPESE,NOPASE,CHTESE,EXITHE)
      END IF

C - TRAITEMENT DES CHARGES

      CALL GCHARG(MODELE,NCHAR,LCHAR,CHVOLU,CF1D2D,CF2D3D,CHPRES,CHEPSI,
     &            CHPESA,CHROTA,FONC,EPSI,TIME,IORD)
      IF (FONC) THEN
        PAVOLU = 'PFFVOLU'
        PA1D2D = 'PFF1D2D'
        PA2D3D = 'PFF2D3D'
        PAPRES = 'PPRESSF'
        PEPSIN = 'PEPSINF'
        IF (OPTION.EQ.'CALC_DG') THEN
          OPTION = 'CALC_DG_F'
        ELSE IF (OPTION.EQ.'CALC_G') THEN
          OPTION = 'CALC_G_F'
        ELSE IF (OPTION.EQ.'CALC_G_GLOB') THEN
          OPTION = 'CALC_G_GLOB_F'
        ELSE IF (OPTION.EQ.'CALC_DG_E') THEN
          OPTION = 'CALC_DG_E_F'
        ELSE IF (OPTION.EQ.'CALC_DGG_E') THEN
          OPTION = 'CALC_DGG_E_F'
        ELSE IF (OPTION.EQ.'CALC_DG_FORC') THEN
          OPTION = 'CALC_DG_FORC_F'
        ELSE IF (OPTION.EQ.'CALC_DGG_FORC') THEN
          OPTION = 'CALC_DGG_FORC_F'
        END IF
      ELSE
        PAVOLU = 'PFRVOLU'
        PA1D2D = 'PFR1D2D'
        PA2D3D = 'PFR2D3D'
        PAPRES = 'PPRESSR'
        PEPSIN = 'PEPSINR'
      END IF
C
C - RECUPERATION DES CHARGES DERIVEES DANS LE CAS DG/DF
C
      IF (OPTION(1:12).EQ.'CALC_DG_FORC'.OR.
     &    OPTION(1:13).EQ.'CALC_DGG_FORC') THEN
        DO 70 ICHA = 1,NCHAR
          NOMCH0 = LCHAR(ICHA)(1:8)
          CALL PSGENC(NOMCH0,NOPASE,NOMCHS,EXICHA)
          IF(EXICHA.EQ.0) THEN
            LCHARS(ICHA)(1:8) = NOMCHS
          ELSE IF(EXICHA.EQ.1) THEN
            LCHARS(ICHA)(1:8) = ' '
          ELSE
            CALL U2MESS('F','SENSIBILITE_16')
          ENDIF
70      CONTINUE
C - TRAITEMENT DES CHARGES DERIVEES

        CALL GCHARG(MODELE,NCHAR,LCHARS,CHVOSS,CF12SS,CF23SS,CHPRSS,
     &              CHEPSS,CHPESS,CHROSS,FONC,EPSI,TIME,IORD)
      ENDIF

      IF  (LXFEM) THEN
C       RECUPERATION DES DONNEES XFEM (TOPOSE)
        PINTTO = MODELE//'.TOPOSE.PIN'
        CNSETO = MODELE//'.TOPOSE.CNS'
        HEAVTO = MODELE//'.TOPOSE.HEA'
        LONCHA = MODELE//'.TOPOSE.LON'
        PMILTO = MODELE//'.TOPOSE.PMI'
        LNNO   = FISS//'.LNNO'
        LTNO   = FISS//'.LTNO'
        BASLOC = FISS//'.BASLOC'

C       RECUPERATION DES DONNEES XFEM (TOPOFAC)
        PINTER = MODELE//'.TOPOFAC.OE'
        AINTER = MODELE//'.TOPOFAC.AI'
        CFACE  = MODELE//'.TOPOFAC.CF'
        LONGCO = MODELE//'.TOPOFAC.LO'
        BASECO = MODELE//'.TOPOFAC.BA'

      ENDIF

      LPAOUT(1) = 'PGTHETA'
      LCHOUT(1) = '&&'//NOMPRO//'.CH_G'
      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = CHGEOM
      LPAIN(2) = 'PDEPLAR'
      LCHIN(2) = DEPLA
      LPAIN(3) = 'PTHETAR'
      LCHIN(3) = THETA
      LPAIN(4) = 'PMATERC'
      LCHIN(4) = MATE
      LPAIN(5) = 'PVARCPR'
      LCHIN(5) = CHVARC
      LPAIN(6) = 'PVARCRR'
      LCHIN(6) = CHVREF
      LPAIN(7) = PAVOLU(1:8)
      LCHIN(7) = CHVOLU
      LPAIN(8) = PA1D2D(1:8)
      LCHIN(8) = CF1D2D
      LPAIN(9) = PA2D3D(1:8)
      LCHIN(9) = CF2D3D
      LPAIN(10) = PAPRES(1:8)
      LCHIN(10) = CHPRES
      LPAIN(11) = 'PPESANR'
      LCHIN(11) = CHPESA
      LPAIN(12) = 'PROTATR'
      LCHIN(12) = CHROTA
      LPAIN(13) = PEPSIN(1:8)
      LCHIN(13) = CHEPSI
      LPAIN(14) = 'PCOMPOR'
      LCHIN(14) = COMPOR

      LIGRMO = MODELE//'.MODELE'
      NCHIN = 14

      IF (LXFEM) THEN
        LPAIN(15) = 'PCNSETO'
        LCHIN(15) = CNSETO
        LPAIN(16) = 'PHEAVTO'
        LCHIN(16) = HEAVTO
        LPAIN(17) = 'PLONCHA'
        LCHIN(17) = LONCHA
        LPAIN(18) = 'PLSN'
        LCHIN(18) = LNNO
        LPAIN(19) = 'PLST'
        LCHIN(19) = LTNO
        LPAIN(20) = 'PBASLOR'
        LCHIN(20) = BASLOC
        LPAIN(21) = 'PPINTTO'
        LCHIN(21) = PINTTO
        LPAIN(22) = 'PPMILTO'
        LCHIN(22) = PMILTO
        LPAIN(23) = 'PPINTER'
        LCHIN(23) = PINTER
        LPAIN(24) = 'PAINTER'
        LCHIN(24) = AINTER
        LPAIN(25) = 'PCFACE'
        LCHIN(25) = CFACE
        LPAIN(26) = 'PLONGCO'
        LCHIN(26) = LONGCO
        LPAIN(27) = 'PBASECO'
        LCHIN(27) = BASECO

        NCHIN = 27

      END IF

      IF ((OPTION.EQ.'CALC_G_F') .OR. (OPTION.EQ.'CALC_DG_F') .OR.
     &(OPTION.EQ.'CALC_DG_E_F').OR.(OPTION.EQ.'CALC_G_GLOB_F').OR.
     &(OPTION.EQ.'CALC_DGG_E_F').OR.(OPTION.EQ.'CALC_DGG_FORC_F').OR.
     &(OPTION.EQ.'CALC_DG_FORC_F')) THEN
        CALL MECACT('V',CHTIME,'MODELE',LIGRMO,'INST_R  ',1,'INST   ',
     &              IBID,TIME,CBID,K8B)
        LPAIN(NCHIN+1) = 'PTEMPSR'
        LCHIN(NCHIN+1) = CHTIME
        NCHIN = NCHIN + 1
      END IF

      IF (INCR.NE.0) THEN
        LPAIN(NCHIN+1) = 'PCONTRR'
        LCHIN(NCHIN+1) = CHSIG
        LPAIN(NCHIN+2) = 'PDEFOPL'
        LCHIN(NCHIN+2) = CHEPSP
        LPAIN(NCHIN+3) = 'PVARIPR'
        LCHIN(NCHIN+3) = CHVARI
        NCHIN = NCHIN + 3
      END IF
      IF (INIT.NE.0) THEN
        IF (NSIG.NE.0) THEN
          LPAIN(NCHIN+1) = 'PSIGINR'
          LCHIN(NCHIN+1) = CHSIGI
          NCHIN = NCHIN + 1
        END IF
        IF (NDEP.NE.0) THEN
          LPAIN(NCHIN+1) = 'PDEPINR'
          LCHIN(NCHIN+1) = CHDEPI
          NCHIN = NCHIN + 1
        END IF
      END IF

      IF (CHVITE.NE.' ') THEN
        LPAIN(NCHIN+1) = 'PVITESS'
        LCHIN(NCHIN+1) =  CHVITE
        LPAIN(NCHIN+2) = 'PACCELE'
        LCHIN(NCHIN+2) =  CHACCE
        NCHIN = NCHIN + 2
      END IF

C SI DG:
C INCORPORATION DES CHAMPS CONTENANT LES DERIVEES DU
C DEPLACEMENT (CHDESE), DE LA TEMPERATURE (CHTESE) ET LES VALEURS
C DU CHAMP THETA ASSOCIES A CETTE DERIVATION (THETAS)
C REMARQUE : EN FONCTION DU TYPE DE SENSIBILITE, LES CHAMPS
C            A PASSER PEUVENT VARIER
      IF ( OPTION(1:9).EQ.'CALC_DG_E'
     & .OR.OPTION(1:12).EQ.'CALC_DG_FORC'
     & .OR.OPTION(1:13).EQ.'CALC_DGG_FORC'
     & .OR.OPTION(1:10).EQ.'CALC_DGG_E') THEN
        LPAIN(NCHIN+1) = 'PDEPLSE'
        LCHIN(NCHIN+1) = CHDESE
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = 'PDEFOSE'
        LCHIN(NCHIN+1) = CHEPSE
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = 'PSIGMSE'
        LCHIN(NCHIN+1) = CHSISE
        NCHIN = NCHIN + 1
      ELSE IF ( OPTION(1:7).EQ.'CALC_DG' ) THEN
        LPAIN(NCHIN+1) = 'PDEPLSE'
        LCHIN(NCHIN+1) = CHDESE
        NCHIN = NCHIN + 1
        IF ( TYPESE.EQ.-1 ) THEN
          LPAIN(NCHIN+1) = 'PVECTTH'
          LCHIN(NCHIN+1) = THETAS
          NCHIN = NCHIN + 1
          LPAIN(NCHIN+1) = 'PVARCMR'
          LCHIN(NCHIN+1) = CHTESE
          NCHIN = NCHIN + 1
        ENDIF
      ENDIF
      IF(OPTION(1:12).EQ.'CALC_DG_FORC'.OR.
     &   OPTION(1:13).EQ.'CALC_DGG_FORC') THEN
        IF (FONC) THEN
          PAVOLU = 'PFFVOSS'
          PA1D2D = 'PFF12SS'
          PA2D3D = 'PFF23SS'
          PAPRES = 'PPRESSSF'
          PEPSIN = 'PEPSISSF'
        ELSE
          PAVOLU = 'PFRVOSS'
          PA1D2D = 'PFR12SS'
          PA2D3D = 'PFR23SS'
          PAPRES = 'PPRESSSR'
          PEPSIN = 'PEPSISSR'
        END IF
        LPAIN(NCHIN+1) = PAVOLU(1:8)
        LCHIN(NCHIN+1) = CHVOSS
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = PA1D2D(1:8)
        LCHIN(NCHIN+1) = CF12SS
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = PA2D3D(1:8)
        LCHIN(NCHIN+1) = CF23SS
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = PAPRES(1:8)
        LCHIN(NCHIN+1) = CHPRSS
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = 'PPESASS'
        LCHIN(NCHIN+1) = CHPESS
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = 'PROTASS'
        LCHIN(NCHIN+1) = CHROSS
        NCHIN = NCHIN + 1
        LPAIN(NCHIN+1) = PEPSIN(1:8)
        LCHIN(NCHIN+1) = CHEPSS
        NCHIN = NCHIN + 1
      END IF
      IF(KCALC.EQ.'NON')THEN
          CALL GETVID(' ','RESULTAT',0,IARG,1,RESU,IRET)
          CALL RSEXCH(RESU,'SIEF_ELGA',IORD,CHSIG,IRET)
          LPAIN(NCHIN+1) = 'PCONTGR'
          LCHIN(NCHIN+1) =  CHSIG
          NCHIN = NCHIN + 1
      ENDIF


C-  SOMMATION DES G ELEMENTAIRES
      CALL CALCUL('S',OPTION,LIGRMO,NCHIN,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &            'V','OUI')

      CALL MESOMM(LCHOUT(1),1,IBID,G,CBID,0,IBID)
      IF (SYMECH.NE.'NON') THEN
        G = 2.D0*G
      END IF

C- IMPRESSION DE G ET ECRITURE DANS LA TABLE RESULT
C
      CALL GETVIS('THETA','NUME_FOND',1,IARG,1,NUMFON,IBID)
      IF(LMELAS)THEN
        CALL TBAJLI(RESULT,NBPRUP,NOPRUP,IORD,G,CBID,NOMCAS,0)
      ELSE
        VAL(1) = TIME
        VAL(2) = G
        IF (LXFEM)   THEN
          VALI(1) = NUMFON
          VALI(2) = IORD
        ELSE
          VALI(1) = IORD
        ENDIF
        CALL TBAJLI(RESULT,NBPRUP,NOPRUP,VALI,VAL,CBID,K8B,0)
      ENDIF

      CALL DETRSD('CHAMP_GD',CF12SS)
      CALL DETRSD('CHAMP_GD',CF1D2D)
      CALL DETRSD('CHAMP_GD',CF23SS)
      CALL DETRSD('CHAMP_GD',CF2D3D)
      CALL DETRSD('CHAMP_GD',CHEPSI)
      CALL DETRSD('CHAMP_GD',CHEPSS)
      CALL DETRSD('CHAMP_GD',CHPESA)
      CALL DETRSD('CHAMP_GD',CHPESS)
      CALL DETRSD('CHAMP_GD',CHPRES)
      CALL DETRSD('CHAMP_GD',CHPRSS)
      CALL DETRSD('CHAMP_GD',CHROSS)
      CALL DETRSD('CHAMP_GD',CHROTA)
      CALL DETRSD('CHAMP_GD',CHTESE)
      CALL DETRSD('CHAMP_GD',CHTIME)
      CALL DETRSD('CHAMP_GD',CHVOLU)
      CALL DETRSD('CHAMP_GD',CHVOSS)

      CALL JEDEMA()
      END
