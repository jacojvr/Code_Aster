      SUBROUTINE CMTREF(CHMAT,NOMAIL)
      IMPLICIT   NONE
      CHARACTER*8 CHMAT,NOMAIL
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 16/10/2007   AUTEUR SALMONA L.SALMONA 
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
C ======================================================================
C  IN/VAR : CHMAT   : CHAM_MATER
C  IN     : NOMAIL  : MAILLAGE
C ----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL,DBG
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C ----------------------------------------------------------------------
C
      INTEGER IRET,JDCM1,JVCM1,JLCM1,JDTRF,JVTRF,JLTRF,NOCC
      INTEGER NBCM1,NBTRF,KCM1,KTRF,CODCM1,CODTRF,IGD,K
      INTEGER NCCM1,NCTRF,JNCMP,JVALV,NUCM1,NUTRF,KK,IOCC
      INTEGER ICO,IBID,NM,NBMA,NINTER,CODINT,JLINT,NCM1,NTRF
      REAL*8 TREF,R8VIDE
      CHARACTER*8 K8B,NOCP,MATER
      CHARACTER*8 KTREF,NOMGD
      CHARACTER*19 CARCM1,CARCM2,CARTRF
      CHARACTER*32 JEXNUM,JEXATR,JEXNOM
C ----------------------------------------------------------------------
C
      CALL JEMARQ()

      CARCM1 = CHMAT//'.CHAMP_MAT'
      CARCM2 = CHMAT//'.CHAMP_MA2'
      CARTRF = CHMAT//'.TEMP    .1'


C     1) IL N'Y A RIEN LIEU DE FAIRE S'IL N'Y A PAS DE AFFE_VARC/'TEMP':
C     ------------------------------------------------------------------
      CALL JEEXIN(CARTRF//'.DESC',IRET)
      IF (IRET.EQ.0) GOTO 50
      CALL DISMOI('F','NB_MA_MAILLA',NOMAIL,'MAILLAGE',NBMA,K8B,IRET)
      IF (NBMA.EQ.0) GOTO 50
      CALL WKVECT('&&CMTREF.LISMAIL','V V I',NBMA,JLINT)


C     1BIS) VERIF: SI AFFE_VARC/'TEMP', ON N'UTILISE PAS AFFE/TEMP_REF
C     ------------------------------------------------------------------
      CALL GETFAC('AFFE',NOCC)
      DO 10, IOCC=1,NOCC
         CALL GETVR8('AFFE','TEMP_REF',IOCC,1,1,TREF,IBID)
         IF (IBID.NE.0) CALL U2MESS('F','CALCULEL6_9')
   10   CONTINUE


C     2) MISE EN MEMOIRE DES OBJETS DE CARCM1 ET CARTRF :
C     ---------------------------------------------------------------
      CALL JEVEUO(CARCM1//'.DESC','L',JDCM1)
      CALL JEVEUO(CARCM1//'.VALE','L',JVCM1)
      NBCM1 = ZI(JDCM1-1+3)
      IGD = ZI(JDCM1-1+1)
      CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',IGD),NOMGD)
      CALL ASSERT(NOMGD.EQ.'NEUT_F')
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'LONMAX',NCCM1,K8B)
      CALL ASSERT(NCCM1.GE.30)

      CALL JEVEUO(CARTRF//'.DESC','L',JDTRF)
      CALL JEVEUO(CARTRF//'.VALE','L',JVTRF)
      NBTRF = ZI(JDTRF-1+3)
      IGD = ZI(JDTRF-1+1)
      CALL JENUNO(JEXNUM('&CATA.GD.NOMGD',IGD),NOMGD)
      CALL ASSERT(NOMGD.EQ.'NEUT_R')
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP',NOMGD),'LONMAX',NCTRF,K8B)



C     3) ALLOCATION DE CARCM2 :
C     ---------------------------------------------------------------
      CALL ALCART('V',CARCM2,NOMAIL,'NEUT_F')
      CALL JEVEUO(CARCM2//'.NCMP','E',JNCMP)
      CALL JEVEUO(CARCM2//'.VALV','E',JVALV)


C     4) REMPLISSAGE DE CARCM2 :
C     ---------------------------------------------------------------
      DO 40,KCM1 = 1,NBCM1
        CODCM1 = ZI(JDCM1-1+3+2* (KCM1-1)+1)
        CALL ASSERT(CODCM1.EQ.1 .OR. CODCM1.EQ.3)
        NUCM1 = ZI(JDCM1-1+3+2* (KCM1-1)+2)

C        -- ON STOCKE LES NOMS DES MATERIAUX AFFECTES (28 MAX) :
        ICO = 0
        NOCP='X'
        DO 20,KK = 1,28
          MATER = ZK8(JVCM1-1+NCCM1* (KCM1-1)+KK)
          IF (MATER.EQ.' ') GOTO 20
          ICO = ICO + 1
          ZK8(JVALV-1+ICO) = MATER
          CALL CODENT(ICO,'G',NOCP(2:4))
          ZK8(JNCMP+ICO-1) = NOCP
   20   CONTINUE
        NM = ICO
        CALL ASSERT(NM.GT.0 .AND. NM.LE.28)
        ZK8(JNCMP-1+NM+1) = 'X29'
        ZK8(JVALV-1+NM+1) = 'TREF=>'
        ZK8(JNCMP-1+NM+2) = 'X30'


C        -- LISTE DES MAILLES CONCERNEES PAR KCM1 :
        IF (CODCM1.EQ.3) THEN
           CALL JEVEUO(JEXNUM(CARCM1//'.LIMA',NUCM1),'L',JLCM1)
           CALL JELIRA(JEXNUM(CARCM1//'.LIMA',NUCM1),'LONMAX',NCM1,K8B)
        ENDIF

C       -- POUR NE PAS PERDRE LES MAILLES QUI NE SONT
C          CONCERNEES PAR AUCUN KTRF :
        ZK8(JVALV-1+NM+2) = 'NAN'
        IF (CODCM1.EQ.1) THEN
          CALL NOCART(CARCM2,1,K8B,K8B,0,K8B,IBID,' ',NM+2)

        ELSE
          CALL NOCART(CARCM2,3,K8B,'NUM',NCM1,K8B,ZI(JLCM1),' ',
     &                NM+2)
        ENDIF


        DO 30,KTRF = 1,NBTRF
          CODTRF = ZI(JDTRF-1+3+2* (KTRF-1)+1)
          CALL ASSERT(CODTRF.EQ.1 .OR. CODTRF.EQ.3)
          NUTRF = ZI(JDTRF-1+3+2* (KTRF-1)+2)
          TREF = ZR(JVTRF-1+NCTRF* (KTRF-1)+1)
          IF (TREF.EQ.R8VIDE()) THEN
            KTREF='NAN'
          ELSE
            CALL ASSERT(TREF.GT.-275.D0 .AND. TREF.LT.4000.D0)
            WRITE (KTREF,'(F8.2)') TREF
          ENDIF
          ZK8(JVALV-1+NM+2) = KTREF

C           -- LISTE DES MAILLESCONCERNEES PAR KTRF :
          IF (CODTRF.EQ.3) THEN
            CALL JEVEUO(JEXNUM(CARTRF//'.LIMA',NUTRF),'L',JLTRF)
            CALL JELIRA(JEXNUM(CARTRF//'.LIMA',NUTRF),'LONMAX',NTRF,K8B)
          ENDIF

C           -- CALCUL DE LA LISTE DES MAILLES CONCERNEES PAR KCM1/KTRF:
          CALL CMTRF2(CODCM1,CODTRF,NCM1,ZI(JLCM1),NTRF,ZI(JLTRF),
     &                NBMA,CODINT,ZI(JLINT),NINTER)
          CALL ASSERT(CODINT.EQ.1 .OR. CODINT.EQ.3)
          IF (NINTER.EQ.0) GOTO 30

          IF (CODINT.EQ.1) THEN
            CALL NOCART(CARCM2,1,K8B,K8B,0,K8B,IBID,' ',NM+2)

          ELSE
            CALL NOCART(CARCM2,3,K8B,'NUM',NINTER,K8B,ZI(JLINT),' ',
     &                  NM+2)
          ENDIF


   30   CONTINUE
   40 CONTINUE


C     5) RECOPIE DE CARCM2 DANS CARCM1 :
C     ---------------------------------------------------------------
C     -- ON UTILISE TECART POUR ELIMINER LES OCCURENCES INUTILES
C        ET EVITER DE SE PLANTER BETEMENT DANS RCMACO/ALFINT :
      CALL TECART(CARCM2)

      DBG=.TRUE.
      DBG=.FALSE.
      IF (DBG) THEN
         CALL UTIMSD(6,2,.FALSE.,.TRUE.,CARCM1,1,' ')
         CALL UTIMSD(6,2,.FALSE.,.TRUE.,CARCM2,1,' ')
         CALL UTIMSD(6,2,.FALSE.,.TRUE.,CARTRF,1,' ')
         CALL IMPRSD('CHAMP',CARCM1,6,'CHAM_MATER:'//CARCM1)
         CALL IMPRSD('CHAMP',CARCM2,6,'CHAM_MATER:'//CARCM2)
         CALL IMPRSD('CHAMP',CARCM2,6,'CHAM_MATER:'//CARTRF)
      ENDIF
      CALL DETRSD('CHAMP',CARCM1)
      CALL COPISD('CHAMP','G',CARCM2,CARCM1)
      CALL DETRSD('CHAMP',CARCM2)


C     6) MENAGE :
C     ---------------------------------------------------------------
      CALL JEDETR('&&CMTREF.LISMAIL')


   50 CONTINUE
      CALL JEDEMA()
      END
