      SUBROUTINE EXFONC(FONACT,PARMET,METHOD,SOLVEU,DEFICO,
     &                  SDDYNA)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/01/2013   AUTEUR TARDIEU N.TARDIEU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
      INCLUDE 'jeveux.h'
      INTEGER      FONACT(*)
      CHARACTER*19 SOLVEU,SDDYNA
      CHARACTER*24 DEFICO
      REAL*8       PARMET(*)
      CHARACTER*16 METHOD(*)
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (INITIALISATION)
C
C FONCTIONNALITES INCOMPATIBLES
C
C ----------------------------------------------------------------------
C
C
C IN  DEFICO : SD DE DEFINITION DU CONTACT
C IN  SOLVEU : NOM DU SOLVEUR DE NEWTON
C IN  METHOD : DESCRIPTION DE LA METHODE DE RESOLUTION
C                1 : NOM DE LA METHODE NON LINEAIRE (NEWTON OU IMPLEX)
C                2 : TYPE DE MATRICE EN CORRECTION
C                3 : PAS UTILISE
C                4 : PAS UTILISE
C                5 : TYPE DE PREDICTION
C                6 : NOM CONCEPT EVOL_NOLI SI PREDI. 'DEPL_CALCULE'
C IN  SDDYNA : SD DYNAMIQUE
C IN  PARMET : PARAMETRES DES METHODES DE RESOLUTION
C IN  FONACT : FONCTIONNALITES SPECIFIQUES ACTIVEES
C
C
C
C
      INTEGER      REINCR
      INTEGER      JSOLVE,N1
      LOGICAL      ISFONC,NDYNLO,CFDISL
      LOGICAL      LCONT,LALLV,LCTCC,LCTCD,LPENA
      LOGICAL      LFETI,LPILO,LRELI,LMACR,LUNIL
      LOGICAL      LMVIB,LFLAM,LEXPL,LXFEM,LMODIM
      LOGICAL      LRCMK,LGCPC,LPETSC,LAMG,LSYME,LIMPEX
      LOGICAL      LONDE,LDYNA,LGROT,LTHETA,LNKRY
      LOGICAL      LENER,LPROJ,LMATDI,LLDSP,LCTGCP
      INTEGER      IFM,NIV
      CHARACTER*24 TYPILO,TYPREL
      INTEGER      IARG
C
C ---------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('MECA_NON_LINE',IFM,NIV)
C
C --- FONCTIONNALITES ACTIVEES
C
      LFETI  = ISFONC(FONACT,'FETI')
      LXFEM  = ISFONC(FONACT,'XFEM')
      LCTCC  = ISFONC(FONACT,'CONT_CONTINU')
      LCTCD  = ISFONC(FONACT,'CONT_DISCRET')
      LCONT  = ISFONC(FONACT,'CONTACT')
      LUNIL  = ISFONC(FONACT,'LIAISON_UNILATER')
      LPILO  = ISFONC(FONACT,'PILOTAGE')
      LRELI  = ISFONC(FONACT,'RECH_LINE')
      LMACR  = ISFONC(FONACT,'MACR_ELEM_STAT')
      LMVIB  = ISFONC(FONACT,'MODE_VIBR')
      LFLAM  = ISFONC(FONACT,'CRIT_STAB')
      LONDE  = NDYNLO(SDDYNA,'ONDE_PLANE')
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LEXPL  = ISFONC(FONACT,'EXPLICITE')
      LGROT  = ISFONC(FONACT,'GD_ROTA')
      LTHETA = NDYNLO(SDDYNA,'THETA_METHODE')
      LIMPEX = ISFONC(FONACT,'IMPLEX')
      LNKRY  = ISFONC(FONACT,'NEWTON_KRYLOV')
      LENER  = ISFONC(FONACT,'ENERGIE')
      LPROJ  = ISFONC(FONACT,'PROJ_MODAL')
      LMATDI = ISFONC(FONACT,'MATR_DISTRIBUEE')
C
C --- INITIALISATIONS
C
      REINCR = NINT(PARMET(1))
C
C --- TYPE DE SOLVEUR
C
      CALL  JEVEUO(SOLVEU//'.SLVK','E',JSOLVE)
      LRCMK  = .FALSE.
      LGCPC  = .FALSE.
      LPETSC = .FALSE.
      LAMG   = .FALSE.
      LLDSP  = .FALSE.
      IF (ZK24(JSOLVE-1+4).EQ.'RCMK') THEN
        LRCMK = .TRUE.
      ENDIF
      IF (ZK24(JSOLVE)(1:4).EQ.'GCPC') THEN
        LGCPC = .TRUE.
      ENDIF
      IF (ZK24(JSOLVE)(1:5).EQ.'PETSC') THEN
        LPETSC = .TRUE.
      ENDIF
      IF ((ZK24(JSOLVE-1+2).EQ.'ML') .OR.
     &    (ZK24(JSOLVE-1+2).EQ.'BOOMER')) THEN
        LAMG = .TRUE.
      ENDIF
      IF (ZK24(JSOLVE-1+2).EQ.'LDLT_SP') THEN
        LLDSP = .TRUE.
      ENDIF
      LSYME  = ZK24(JSOLVE-1+5).EQ.'OUI'
C
C --- FETI
C
      IF (LFETI) THEN
        IF (LMACR) THEN
          CALL U2MESS('F','MECANONLINE3_70')
        ENDIF
        IF (LONDE) THEN
          CALL U2MESS('F','MECANONLINE3_71')
        ENDIF
        IF (LDYNA) THEN
          CALL U2MESS('F','MECANONLINE3_73')
        ENDIF
        IF (LCTCD) THEN
          CALL U2MESS('F','MECANONLINE3_78')
        ENDIF
        IF (LCTCC) THEN
          CALL U2MESS('F','MECANONLINE3_79')
        ENDIF
      ENDIF
C
C --- CONTACT DISCRET
C
      IF (LCTCD) THEN
        LMODIM = CFDISL(DEFICO,'MODI_MATR_GLOB')
        LALLV  = CFDISL(DEFICO,'ALL_VERIF')
        LPENA  = CFDISL(DEFICO,'CONT_PENA')
        LCTGCP = CFDISL(DEFICO,'CONT_GCP')
        IF (LPILO) THEN
          CALL U2MESS('F','MECANONLINE_43')
        ENDIF
        IF (LRELI.AND.(.NOT.LALLV)) THEN
          CALL U2MESS('A','MECANONLINE3_89')
        ENDIF
        IF (LGCPC.OR.LPETSC) THEN
          IF (.NOT.(LALLV.OR.LPENA.OR.LCTGCP)) THEN
            CALL U2MESK('F','MECANONLINE3_90',1,ZK24(JSOLVE))
          ENDIF
          IF (LCTGCP.AND..NOT.LLDSP) THEN
            CALL U2MESS('F','MECANONLINE3_88')
          ENDIF
        ENDIF
        IF (REINCR.EQ.0) THEN
          IF (LMODIM) THEN
            CALL U2MESS('F','CONTACT_88')
          ENDIF
        ENDIF
C       ON FORCE SYME='OUI' AVEC LE CONTACT DISCRET
        IF (.NOT.(LSYME.OR.LALLV)) THEN
          ZK24(JSOLVE+4)='OUI'
          CALL U2MESS('A','CONTACT_1')
        ENDIF
      ENDIF
C
C --- CONTACT CONTINU
C
      IF (LCTCC) THEN
        IF (LPILO.AND.(.NOT.LXFEM)) THEN
C         LEVEE D INTERDICTION TEMPORAIRE POUR X-FEM
          CALL U2MESS('F','MECANONLINE3_92')
        ENDIF
        IF (LRELI) THEN
          CALL U2MESS('F','MECANONLINE3_91')
        ENDIF
        IF (LRCMK) THEN
          CALL U2MESK('F','MECANONLINE3_93',1,ZK24(JSOLVE))
        ENDIF
        IF (LAMG) THEN
          CALL U2MESK('F','MECANONLINE3_97',1,ZK24(JSOLVE-1+2))
        ENDIF
      ENDIF
C
C --- LIAISON UNILATERALE
C
      IF (LUNIL) THEN
        IF (LPILO) THEN
          CALL U2MESS('F','MECANONLINE3_94')
        ENDIF
        IF (LRELI) THEN
          CALL U2MESS('A','MECANONLINE3_95')
        ENDIF
        IF (LGCPC.OR.LPETSC) THEN
          CALL U2MESK('F','MECANONLINE3_96',1,ZK24(JSOLVE))
        ENDIF
C       ON FORCE SYME='OUI' AVEC LIAISON_UNILATER
        IF (.NOT.LSYME) THEN
          ZK24(JSOLVE+4)='OUI'
          CALL U2MESS('A','UNILATER_1')
        ENDIF
      ENDIF
C
C --- CALCUL DE MODES/FLAMBEMENT: PAS GCPC/PETSC
C
      IF (LMVIB.OR.LFLAM) THEN
        IF (LGCPC.OR.LPETSC) THEN
          CALL U2MESK('F','FACTOR_52',1,ZK24(JSOLVE))
        ENDIF
      ENDIF
C
C --- EXPLICITE
C
      IF (LEXPL) THEN
        IF (LCONT) THEN
          CALL U2MESS('F','MECANONLINE5_22')
        ENDIF
        IF (LUNIL) THEN
          CALL U2MESS('F','MECANONLINE5_23')
        ENDIF
        IF (LGROT) THEN
          CALL U2MESS('A','MECANONLINE5_24')
        ENDIF
      ENDIF
C
C --- DYNAMIQUE
C
      IF (LDYNA) THEN
        IF (LPILO) THEN
          CALL U2MESS('F','MECANONLINE5_25')
        ENDIF
        IF (LTHETA) THEN
          IF (LGROT) THEN
            CALL U2MESS('F','MECANONLINE5_27')
          ENDIF
        ENDIF
        IF (LXFEM) THEN
          CALL U2MESS('F','MECANONLINE5_28')
        ENDIF
        IF (LIMPEX) THEN
          CALL U2MESS('F','MECANONLINE5_33')
        ENDIF
      ENDIF
C
C --- PILOTAGE
C
      IF (LPILO) THEN
        CALL GETVTX('PILOTAGE','TYPE'   ,1,IARG,1,TYPILO,N1)
        IF (LRELI) THEN
          IF (TYPILO.EQ.'DDL_IMPO' ) THEN
            CALL U2MESS('F','MECANONLINE5_34')
          ENDIF
        ENDIF
        IF ((METHOD(5).EQ.'DEPL_CALCULE').OR.
     &      (METHOD(5).EQ.'EXTRAPOLE')) THEN
          CALL U2MESS('F','MECANONLINE5_36')
        ENDIF
      ENDIF
      IF (LRELI) THEN
        CALL GETVTX('RECH_LINEAIRE','METHODE' ,1,IARG,1,TYPREL,N1)
        IF ((TYPREL.EQ.'PILOTAGE').AND.(.NOT.LPILO)) THEN
          CALL U2MESS('F','MECANONLINE5_35')
        ENDIF
      ENDIF
C
C --- NEWTON_KRYLOV
C
      IF (LNKRY)THEN
        IF (LPILO) CALL U2MESS('F','MECANONLINE5_48')
        IF ((.NOT.LGCPC).AND.(.NOT.LPETSC)) THEN
          CALL U2MESS('F','MECANONLINE5_51')
        ENDIF
      ENDIF
C
C --- ENERGIES
C
      IF (LENER) THEN
        IF (LFETI)  CALL U2MESS('F','MECANONLINE5_2')
        IF (LPROJ)  CALL U2MESS('F','MECANONLINE5_6')
        IF (LMATDI) CALL U2MESS('F','MECANONLINE5_8')
      ENDIF
C
      CALL JEDEMA()
      END
