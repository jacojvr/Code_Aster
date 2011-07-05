      SUBROUTINE NTCRAR(RESULT,SDDISC,LREUSE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/07/2011   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT     NONE
      CHARACTER*19 SDDISC
      CHARACTER*8  RESULT
      LOGICAL      LREUSE
C
C ----------------------------------------------------------------------
C
C ROUTINE THER_* (STRUCTURES DE DONNES)
C
C CREATION SD ARCHIVAGE
C
C ----------------------------------------------------------------------
C
C
C IN  RESULT : NOM DE LA SD RESULTAT
C IN  LREUSE : .TRUE. SI CONCEPT REENTRANT
C IN  SDDISC : SD DISCRETISATION
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      INTEGER      ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8       ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16   ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL      ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8  ZK8
      CHARACTER*16    ZK16
      CHARACTER*24        ZK24
      CHARACTER*32            ZK32
      CHARACTER*80                ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      INTEGER      NOCC,IOCC
      INTEGER      NUMDER
      CHARACTER*16 MOTFAC,MOTPAS
      INTEGER      NUMARC
      CHARACTER*24 ARCINF
      INTEGER      JARINF
      CHARACTER*19 SDARCH
      INTEGER      IFM,NIV
      CHARACTER*1  BASE
      REAL*8       INSDER
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<THERNONLINE> ... CREATION SD ARCHIVAGE'
      ENDIF
C
C --- INITIALISATIONS
C
      MOTFAC = 'ARCHIVAGE'
      MOTPAS = 'PAS_ARCH'
      BASE   = 'V'
      IOCC   = 1
      NUMARC = -1
      CALL GETFAC(MOTFAC,NOCC  )
      CALL ASSERT(NOCC.LE.1)
C
C --- NOM SD ARCHIVAGE
C
      SDARCH = SDDISC(1:14)//'.ARCH'
      ARCINF = SDARCH(1:19)//'.AINF'
C
C --- DERNIER NUMERO ARCHIVE DANS L'EVOL SI REUSE
C
      CALL NMDIDE(LREUSE,RESULT,NUMDER,INSDER)
C
C --- LECTURE LISTE INSTANTS D'ARCHIVAGE
C
      CALL NMCRPX(MOTFAC,MOTPAS,IOCC  ,SDARCH,BASE  )
C
C --- CONSTRUCTION CHAMPS EXCLUS DE L'ARCHIVAGE
C
      CALL NMAREX(MOTFAC,SDARCH)
C
C --- RECUPERATION DU PREMIER NUMERO A ARCHIVER
C
      CALL NMARPR(RESULT,SDDISC,MOTFAC,LREUSE,NUMDER,
     &            INSDER,NUMARC)
C
C --- NUMERO D'ARCHIVE COURANT
C
      CALL ASSERT(NUMARC.GE.0)
      CALL WKVECT(ARCINF,'V V I',1,JARINF)
      ZI(JARINF+1-1) = NUMARC
C
      CALL JEDEMA()

      END
