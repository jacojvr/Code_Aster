      SUBROUTINE XLAGSP(NOMA  ,NOMO,  FISS  ,ALGOLA,NDIM  ,
     &                  NLISEQ,NLISRL,NLISCO,NBASCO)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/06/2011   AUTEUR MASSIN P.MASSIN 
C TOLE CRS_1404
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
C RESPONSABLE GENIAUT S.GENIAUT
C
      IMPLICIT NONE
      CHARACTER*8   NOMA,NOMO,FISS
      INTEGER       NDIM
      INTEGER       ALGOLA
      CHARACTER*19  NLISEQ,NLISRL,NLISCO,NBASCO
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (PREPARATION)
C
C CHOIX DE L'ESPACE DES LAGRANGES POUR LE CONTACT
C                   (VOIR BOOK VI 15/07/05) :
C    - DETERMINATION DES NOEUDS
C    - CREATION DES RELATIONS DE LIAISONS ENTRE LAGRANGE
C
C ----------------------------------------------------------------------
C
C
C IN  NDIM   : DIMENSION DE L'ESPACE
C IN  NOMA   : NOM DE L'OBJET MAILLAGE
C IN  ALGOLA : TYPE DE CREATION DES RELATIONS DE LIAISONS ENTRE LAGRANGE
C OUT NLISRL : LISTE REL. LIN. POUR V1 ET V2
C OUT NLISCO : LISTE REL. LIN. POUR V1 ET V2
C OUT NLISEQ : LISTE REL. LIN. POUR V2 SEULEMENT
C OUT NBASCO : CHAM_NO POUR BASE COVARIANTE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32 JEXNUM,JEXATR
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      NBCMP
      PARAMETER    (NBCMP = 12)
      CHARACTER*8  LICMPR(NBCMP)
C
      INTEGER      NBNO,NBAR,NBARTO,ITYPMA
      INTEGER      AR(12,3),NA,NB,NMIL,NUNOA,MXAR
      INTEGER      NUNOB,NUNOM,NOMIL,NUNOAA,NUNOBB
      INTEGER      IA,IIA,IA1,IA2,I,J,IRET,IMA,JMA,IBID
      INTEGER      JCONX1,JCONX2,JMAIL
      INTEGER      JCNSV,JCNSL,NPIL,GETEXM
      REAL*8       C(NDIM),CC(NDIM)
      CHARACTER*8   K8BID,TYPMA
      INTEGER      IFM,NIV
      CHARACTER*19  CNSBAS
      CHARACTER*19  TABNO,TABINT,TABCRI
      INTEGER      JTABNO,JTABIN,JTABCR
      INTEGER      XXMMVD,ZXBAS,ZXAIN
      REAL*8       LON,DIST1,DIST2,R8MAEM
      LOGICAL      MAQUA,EXILI,ISMALI,LMULTI
      CHARACTER*19  CHSOE,CHSLO,CHSBA,CHSAI
      INTEGER      JCESL2,JCESL3,JCESL4,JCESL5
      INTEGER      JCESD2,JCESD3,JCESD4,JCESD5
      INTEGER      JCESV2,JCESV3,JCESV4,JCESV5
      INTEGER      IAD2,IAD3,IAD4,IAD5,ITYELE,NINTER,PINT,IFISS
      CHARACTER*16  TYPELE,ENR
      CHARACTER*24  XINDIC,GRP(3)
      INTEGER      JINDIC,KK,NMAENR,IENR,JGRP,JXC,IER,JNBPT
C
      DATA LICMPR/ 'X1' ,'X2' ,'X3' ,
     &             'X4' ,'X5' ,'X6' ,
     &             'X7' ,'X8' ,'X9' ,
     &             'X10','X11','X12'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('XFEM',IFM,NIV)
C
C --- INITIALISATIONS
C
      CHSOE  = '&&XLAGSP.CHSOE'
      CHSLO  = '&&XLAGSP.CHSLO'
      CHSBA  = '&&XLAGSP.CHSBA'
      CHSAI  = '&&XLAGSP.CHSAI'
C
C --- ON TRANSFORME LE CHAMP TOPOFAC.LO EN CHAMP SIMPLE
C
      CALL CELCES(NOMO//'.TOPOFAC.LO','V',CHSLO)
      CALL JEVEUO(CHSLO//'.CESD','L',JCESD2)
      CALL JEVEUO(CHSLO//'.CESV','L',JCESV2)
      CALL JEVEUO(CHSLO//'.CESL','L',JCESL2)
C
C --- ON TRANSFORME LE CHAMP TOPOFAC.AI EN CHAMP SIMPLE
C
      ZXAIN = XXMMVD('ZXAIN')
      CALL CELCES(NOMO//'.TOPOFAC.AI','V',CHSAI)
      CALL JEVEUO(CHSAI//'.CESD','L',JCESD3)
      CALL JEVEUO(CHSAI//'.CESV','L',JCESV3)
      CALL JEVEUO(CHSAI//'.CESL','L',JCESL3)
C
C --- ON TRANSFORME LE CHAMP TOPOFAC.OE EN CHAMP SIMPLE
C
      CALL CELCES(NOMO//'.TOPOFAC.OE','V',CHSOE)
      CALL JEVEUO(CHSOE//'.CESD','L',JCESD4)
      CALL JEVEUO(CHSOE//'.CESV','L',JCESV4)
      CALL JEVEUO(CHSOE//'.CESL','L',JCESL4)
C
C --- ON TRANSFORME LE CHAMP TOPOFAC.BA EN CHAMP SIMPLE
C
      ZXBAS   = XXMMVD('ZXBAS')
      CALL CELCES(NOMO//'.TOPOFAC.BA','V',CHSBA)
      CALL JEVEUO(CHSBA//'.CESD','L',JCESD5)
      CALL JEVEUO(CHSBA//'.CESV','L',JCESV5)
      CALL JEVEUO(CHSBA//'.CESL','L',JCESL5)
C
C --- RECUPERATION DE DONNEES RELATIVES AU MAILLAGE
C
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNO,K8BID,IRET)
      CALL JEVEUO(NOMA(1:8)//'.TYPMAIL','L',JMA)
      CALL JEVEUO(NOMA(1:8)//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(NOMA(1:8)//'.CONNEX','LONCUM'),'L',JCONX2)
C --- RECUPERATION DES MAILLES DU MODELE
      CALL JEVEUO(NOMO//'.MAILLE','L',JMAIL)
C --- LE MULTI-HEAVISIDE EST-IL ACTIF ?
      CALL JEEXIN(NOMO//'.FISSNO    .CELD',IER)
      IF (IER.NE.0) THEN
        LMULTI = .TRUE.
      ELSE
        LMULTI = .FALSE.
        IFISS = 1
      ENDIF
C --- RECUPERATION DU COMPTAGE DES FISSURES VUES PAR LES MAILLES
      IF (LMULTI) CALL JEVEUO('&&XCONTA.NBSP','E',JNBPT)
C
C --- DIMENSIONNEMENT DU NOMBRE MAXIMUM D'ARETES COUPEES PAR LA FISSURE
C --- PAR LE NOMBRE DE NOEUDS DU MAILLAGE (AUGMENTER SI NECESSAIRE)
C
      MXAR   = NBNO
C
      NBARTO = 0
      CALL ASSERT(NBCMP.EQ.ZXBAS)
      TABNO  = '&&XLAGSP.TABNO'
      TABINT = '&&XLAGSP.TABINT'
      TABCRI = '&&XLAGSP.TABCRI'
      CNSBAS = '&&XLAGSP.CNSBAS'
C
C --- CREATION DU CHAM_NO_S DE LA BASE COVARIANTE
C
      CALL CNSCRE(NOMA,'NEUT_R',NBCMP,LICMPR,'V',CNSBAS)
C
C --- ACCES AU CHAM_NO_S DE LA BASE COVARIANTE
C
      CALL JEVEUO(CNSBAS(1:19)//'.CNSV','E',JCNSV)
      CALL JEVEUO(CNSBAS(1:19)//'.CNSL','E',JCNSL)
C
C --- CREATION OBJETS DE TRAVAIL
C --- TABNO  : COL 1,2     : NOEUDS EXTREMITE
C            : COL 3       : NOEUD MILIEU
C --- TABINT : COL 1,2(,3) : COORDONNEES DU POINT D'INTERSECTION
C
      CALL WKVECT(TABNO ,'V V I',3*MXAR   ,JTABNO)
      CALL WKVECT(TABINT,'V V R',NDIM*MXAR,JTABIN)
      CALL WKVECT(TABCRI,'V V R',1*MXAR   ,JTABCR)
C
C --- CREATION DE LA LISTE DES ARETES COUPEES
C
      EXILI=.FALSE.

      GRP(1) = FISS//'.MAILFISS  .HEAV'
      GRP(2) = FISS//'.MAILFISS  .CTIP'
      GRP(3) = FISS//'.MAILFISS  .HECT'
      XINDIC = FISS//'.MAILFISS .INDIC'
      CALL JEVEUO(XINDIC,'L',JINDIC)
C
C --- BOUCLE SUR LES GRP
C
      DO 10 KK = 1,3
        IF (ZI(JINDIC-1+2*(KK-1)+1).NE.1) GOTO 10
        CALL JEVEUO(GRP(KK),'L',JGRP)
        NMAENR = ZI(JINDIC-1+2*KK)
C
C --- BOUCLE SUR LES MAILLES DU GROUPE
C
        DO 100 IENR = 1,NMAENR
          IMA = ZI(JGRP-1+IENR)
          IF (LMULTI) THEN
            ZI(JNBPT-1+IMA) = ZI(JNBPT-1+IMA)+1
            IFISS = ZI(JNBPT-1+IMA)
          ENDIF
C
C --- SI LA MAILLE N'APPARTIENT PAS AU MODELE, ON SORT
C
          ITYELE=ZI(JMAIL-1+IMA)
C          IF (ITYELE.EQ.0) GOTO 100
C
C --- SI CE N'EST PAS UNE MAILLE DE CONTACT X-FEM, ON SORT
          CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYELE),TYPELE)
          CALL TEATTR(TYPELE,'S','XFEM',ENR,IBID)
          IF (ENR(3:3).NE.'C'.AND.ENR(4:4).NE.'C') GOTO 100
C
          ITYPMA = ZI(JMA-1+IMA)
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYPMA),TYPMA)
          MAQUA=.NOT.ISMALI(TYPMA)
          CALL JEVEUO(NOMO(1:8)//'.XFEM_CONT','L',JXC)
          IF (ZI(JXC).EQ.3) MAQUA=.FALSE.
          IF (.NOT.MAQUA) EXILI=.TRUE.
          IF(GETEXM('PILOTAGE','DIRE_PILO').EQ.1) THEN
             CALL GETVTX('PILOTAGE','DIRE_PILO',1,1,0,K8BID,NPIL)
             NPIL=-NPIL
             IF(NPIL.GE.1) THEN
                EXILI=.TRUE.
                MAQUA=.FALSE.
             ENDIF
          ENDIF
C
C --- RECUPERATION DU NOMBRE DE POINT D'INTERSECTIONS
C

          CALL CESEXI('C',JCESD2,JCESL2,IMA,1,IFISS,1,IAD2)
          NINTER = ZI(JCESV2-1+IAD2)
C --- NINTER DOIT D�PENDRE DE LA FISS QUI COUPE SI ELEMENT XH2C,3C OU 4C
C          IF (LMULTI) THEN
C            IF (ENR.EQ.'XH2C'.OR.ENR.EQ.'XH3C'.OR.ENR.EQ.'XH4C') THEN
C              CALL CESEXI('S',JCESD2,JCESL2,IMA,1,1,4,IAD2)
C              IF (ZI(JCESV2-1+IAD2).NE.ZI(JNBPT-1+IMA)) NINTER = 0
C            ENDIF
C          ENDIF

C --- RECUPERATION DE LA CONNECTIVITE DES ARETES
C
          CALL CONARE(TYPMA,AR,NBAR)
C
C --- BOUCLE SUR LES POINTS D'INTERSECTIONS
C
          DO 110 PINT=1,NINTER
C
C --- NUMERO DE L'ARETE INTERSECTEES
C
            CALL CESEXI('S',JCESD3,JCESL3,IMA,1,IFISS,
     &                                            ZXAIN*(PINT-1)+1,IAD3)
            CALL ASSERT(IAD3.GT.0)
            IA=NINT(ZR(JCESV3-1+IAD3))
C - SI PILOTAGE ET NOEUD INTERSECTE, ON L AJOUTE
            IF(GETEXM('PILOTAGE','DIRE_PILO').EQ.1) THEN
                CALL GETVTX('PILOTAGE','DIRE_PILO',1,1,0,K8BID,NPIL)
                NPIL=-NPIL
                IF(NPIL.GE.1) THEN
                   IF(IA.EQ.0) THEN
                       CALL CESEXI('S',JCESD3,JCESL3,IMA,1,IFISS,
     &                              ZXAIN*(PINT-1)+2,IAD3)
                       NA=NINT(ZR(JCESV3-1+IAD3))
                       NB=NA
                   ELSE
                       NA = AR(IA,1)
                       NB = AR(IA,2)
                   ENDIF
                ENDIF
C --- SI CE N'EST PAS UNE ARETE COUPEE, ON SORT
            ELSE 
               IF (IA.EQ.0) GOTO 110  
               NA = AR(IA,1)
               NB = AR(IA,2)
            ENDIF
C
C --- RECUPERATION DES NOEUDS
C
            NUNOA = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NA-1)
            NUNOB = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NB-1)
            IF (.NOT.MAQUA) THEN
              NUNOM=0
            ELSE
              NMIL  = NOMIL(TYPMA,IA)
              NUNOM = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+NMIL-1)
            ENDIF
C
C --- EST-CE QUE L'ARETE EST DEJA VUE ?
C
            IF (.NOT.MAQUA) THEN
              DO 120 I = 1,NBARTO
C             ARETE DEJA VUE
                IF (NUNOA.EQ.ZI(JTABNO-1+3*(I-1)+1).AND.
     &                 NUNOB.EQ.ZI(JTABNO-1+3*(I-1)+2)) GOTO 110
                IF (NUNOA.EQ.ZI(JTABNO-1+3*(I-1)+2).AND.
     &                 NUNOB.EQ.ZI(JTABNO-1+3*(I-1)+1)) GOTO 110
 120          CONTINUE
            ELSE
              DO 150 I = 1,NBARTO
C             ARETE DEJA VUE (ON A DEJA SON NOEUD MILIEU EN STOCK)
                IF (NUNOM.EQ.ZI(JTABNO-1+3*(I-1)+3)) GOTO 110
 150          CONTINUE
            ENDIF
C
C --- NOUVELLE ARETE
C
            NBARTO = NBARTO+1
            CALL ASSERT(NBARTO.LT.MXAR)
            ZI(JTABNO-1+3*(NBARTO-1)+1) = NUNOA
            ZI(JTABNO-1+3*(NBARTO-1)+2) = NUNOB
            ZI(JTABNO-1+3*(NBARTO-1)+3) = NUNOM
            DO 130 I=1,NDIM
              CALL CESEXI('S',JCESD4,JCESL4,IMA,1,IFISS,
     &                                   NDIM*(PINT-1)+I,IAD4)
              CALL ASSERT(IAD4.GT.0)
              C(I) = ZR(JCESV4-1+IAD4)
              ZR(JTABIN-1+NDIM*(NBARTO-1)+I) = C(I)
 130        CONTINUE
C
C --- REMPLISSAGE DU CHAM_NO_S DE LA BASE COVARIANTE
C --- POUR L'ANCIENNE FORMULATION
C
            IF (MAQUA) THEN

              DO 140 I=1,NDIM
                ZR(JCNSV-1+ZXBAS*(NUNOM-1)+I)=C(I)
 140          CONTINUE
              DO 145 I=1,NDIM
                DO 146 J=1,NDIM
                  CALL CESEXI('S',JCESD5,JCESL5,IMA,1,IFISS,
     &                        NDIM*NDIM*(PINT-1)+NDIM*(I-1)+J,IAD5)
                  CALL ASSERT(IAD5.GT.0)
                  ZR(JCNSV-1+ZXBAS*(NUNOM-1)+3*I+J)=
     &                        ZR(JCESV5-1+IAD5)
 146            CONTINUE
 145          CONTINUE
              DO 147 J=1,ZXBAS
                ZL(JCNSL-1+ZXBAS*(NUNOM-1)+J)=.TRUE.
 147          CONTINUE
            ENDIF
C
 110      CONTINUE
C
 100    CONTINUE
C
  10  CONTINUE
C
C --- CAS MAILLAGE LINϿ�AIRE, ON VERIFIE QUE ALGO LAG EST ACTIF
C
      IF (EXILI.AND.ALGOLA.EQ.0) THEN
        ALGOLA=2
        CALL U2MESS('A','XFEM_28')
      ENDIF
C
C --- CREATION DU CHAM_NO DE LA BASE COVARIANTE
C
        IF (.NOT.EXILI) THEN
        IF (NBARTO.GT.0) THEN
          CALL CNSCNO(CNSBAS,' ','NON','G',NBASCO,'F',IBID)
        ENDIF
      ENDIF
C
C --- CRITERE POUR DEPARTAGER LES ARETES HYPERSTATIQUES:
C     LONGUEUR DE FISSURE CONTROLϿ�E, I.E.
C     SOMME DES LONGUEURS DES ARETES DES FACETTES
C     DE CONTACT CONNECTEES A CHAQUE ARETE
C
      DO 200 IA=1,NBARTO
        NUNOA = ZI(JTABNO-1+3*(IA-1)+1)
        NUNOB = ZI(JTABNO-1+3*(IA-1)+2)
        NUNOM = ZI(JTABNO-1+3*(IA-1)+3)
        DO 210 I=1,NDIM
          C(I)=ZR(JTABIN-1+NDIM*(IA-1)+I)
 210    CONTINUE
        DIST1=R8MAEM()
        DIST2=R8MAEM()
        IA1=0
        IA2=0

        DO 220 IIA=1,NBARTO
          NUNOAA = ZI(JTABNO-1+3*(IIA-1)+1)
          NUNOBB = ZI(JTABNO-1+3*(IIA-1)+2)
          IF ((NUNOA.EQ.NUNOAA.AND.NUNOB.NE.NUNOBB)
     &             .OR.(NUNOA.EQ.NUNOBB.AND.NUNOB.NE.NUNOAA)) THEN
C           NUNOA CONNECTE LES DEUX ARETES
            DO 300 I=1,NDIM
              CC(I)=ZR(JTABIN-1+NDIM*(IIA-1)+I)
 300        CONTINUE
            LON=0.D0
            DO 310 I=1,NDIM
              LON = LON+(CC(I)-C(I))*(CC(I)-C(I))
 310        CONTINUE
            LON=SQRT(LON)
            IF (LON.LT.DIST1) THEN
              DIST1=LON
              IA1=IIA
            ENDIF
          ENDIF
          IF ((NUNOA.NE.NUNOAA.AND.NUNOB.EQ.NUNOBB)
     &             .OR.(NUNOA.NE.NUNOBB.AND.NUNOB.EQ.NUNOAA)) THEN
C           NUNOB CONNECTE LES DEUX ARETES
            DO 320 I=1,NDIM
              CC(I)=ZR(JTABIN-1+NDIM*(IIA-1)+I)
 320        CONTINUE
            LON=0.D0
            DO 330 I=1,NDIM
              LON = LON+(CC(I)-C(I))*(CC(I)-C(I))
 330        CONTINUE
            LON=SQRT(LON)
            IF (LON.LT.DIST2) THEN
              DIST2=LON
              IA2=IIA
            ENDIF
          ENDIF
 220    CONTINUE
        LON=0.D0
        IF (IA2.NE.0) THEN
          LON=LON+DIST2
        ENDIF
        IF (IA1.NE.0) THEN
          LON=LON+DIST1
        ENDIF

        ZR(JTABCR-1+1*(IA-1)+1)=LON

 200  CONTINUE
C
C --- CREATION DES LISTES DES RELATIONS DE LIAISONS ENTRE LAGRANGE
C
      CALL XLAGSC(NDIM  ,NBNO  ,NBARTO,MXAR  ,ALGOLA,
     &            JTABNO,JTABIN,JTABCR,FISS ,EXILI ,
     &            NLISEQ,NLISRL,NLISCO)
C
C --- SI LE MULTI-HEAVISIDE EST ACTIF, ON CREE UNE SD SUPPLEMENTAIRE
C --- CONTENANT LE NUM�ROS DE LAGRANGIEN CORESPONDANT.
C
      IF (LMULTI) CALL XLAG2C(NOMO  ,NLISEQ,JNBPT)
C
C --- DESTRUCTION DES OBJETS TEMPORAIRES
C
      CALL JEDETR(TABNO)
      CALL JEDETR(TABINT)
      CALL JEDETR(TABCRI)
      CALL DETRSD('CHAM_ELEM_S',CHSOE)
      CALL DETRSD('CHAM_ELEM_S',CHSLO)
      CALL DETRSD('CHAM_ELEM_S',CHSAI)
      CALL DETRSD('CHAM_ELEM_S',CHSBA)
C
C --- AFFICHAGE LISTE REL. LINEAIRES
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<XFEM  > LISTE DES RELATIONS LINEAIRES'
        CALL UTIMSD(IFM,-1,.TRUE.,.TRUE.,NLISEQ,1,' ')
        CALL UTIMSD(IFM,-1,.TRUE.,.TRUE.,NLISRL,1,' ')
        CALL UTIMSD(IFM,-1,.TRUE.,.TRUE.,NLISCO,1,' ')
      ENDIF
C
      CALL JEDEMA()
      END
