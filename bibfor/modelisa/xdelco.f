      SUBROUTINE XDELCO(GRMA,MOD,LISREL,NREL)


C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 14/03/2005   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

      IMPLICIT NONE

      INTEGER NREL
      CHARACTER*8 MOD
      CHARACTER*19 LISREL
      CHARACTER*24 GRMA

C     BUT: SUPPRIMER LES DDLS DE CONTACT SUR LES MAILLES
C                   HEAVYSIDE
C                (VOIR  BOOK IV  18/08/04 ET 14/12/04)

C ARGUMENTS D'ENTR�E:
C      GRMA       : GROUPE DE MAILLES HEAVYSIDE
C      MOD        : NOM DU MODELE

C ARGUMENTS DE SORTIE:
C      LISREL    : LISTE DES RELATIONS � IMPOSER
C      NREL      : NOMBRE DE RELATIONS � IMPOSER


C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C-----------------------------------------------------------------------
C---------------- DECLARATION DES VARIABLES LOCALES  -------------------

      REAL*8 BETAR,RBID
      INTEGER JFISS,JCESD1,JCESD2,JCESV1,JCESV2,JCESL1,JCESL2
      INTEGER JCESK1,JCONX1,JCONX2,IAD,JMA,ITYPMA,JSTANO
      INTEGER I,IMA,INO,IA,IER
      INTEGER NOMIL,NA,NB,N,IN,NBMAIL,NBNOMA,AR(12,2)
      INTEGER NBAR,NINTER,NUNO
      CHARACTER*8 FISS,MA,TYPMA,NOMNO,DDLC(3),K8BID
      CHARACTER*19 CHS,CHS1,CHS2,MAI
      COMPLEX*16 CBID(2)
      LOGICAL LINACT(27)
      DATA BETAR/0.D0/
      DATA DDLC/'LAGS_C','LAGS_F1','LAGS_F2'/
C-------------------------------------------------------------

      CALL JEMARQ()

      CALL JEEXIN(GRMA,IER)
      IF (IER.EQ.0) GO TO 60

      WRITE (6,*) 'XDELCO'

      CALL JEVEUO(MOD//'.FISS','L',JFISS)
      FISS = ZK8(JFISS)

      CHS = '&&XDELCO.CHS'
      CHS1 = '&&XDELCO.LONCHA'
      CHS2 = '&&XDELCO.AINTER'

      CALL CNOCNS(FISS//'.STNO','V',CHS)
      CALL CELCES(FISS//'.TOPOFAC.LONCHAM','V',CHS1)
      CALL CELCES(FISS//'.TOPOFAC.AINTER','V',CHS2)

      CALL JEVEUO(CHS//'.CNSV','L',JSTANO)
      CALL JEVEUO(CHS1//'.CESD','L',JCESD1)
      CALL JEVEUO(CHS2//'.CESD','L',JCESD2)

      CALL ASSERT(ZI(JCESD1).EQ.ZI(JCESD2))

      CALL JEVEUO(CHS1//'.CESV','L',JCESV1)
      CALL JEVEUO(CHS2//'.CESV','L',JCESV2)

      CALL JEVEUO(CHS1//'.CESL','L',JCESL1)
      CALL JEVEUO(CHS2//'.CESL','L',JCESL2)

C     DONN�ES RELATIVES AU MAILLAGE
      CALL JEVEUO(CHS1//'.CESK','L',JCESK1)
      MA = ZK8(JCESK1-1+1)
      MAI = MA//'.TYPMAIL'
      CALL JEVEUO(MAI,'L',JMA)

      CALL JEVEUO(MA//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(MA//'.CONNEX','LONCUM'),'L',JCONX2)
      NBMAIL = ZI(JCESD1-1+1)

C     BOUCLE SUR LES MAILLES

      WRITE (6,*) 'NBMAIL ',NBMAIL

      DO 50 IMA = 1,NBMAIL

        NBNOMA = ZI(JCONX2+IMA) - ZI(JCONX2+IMA-1)
        ITYPMA = ZI(JMA-1+IMA)
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ITYPMA),TYPMA)
        IF (TYPMA(1:4).NE.'HEXA' .AND. TYPMA(1:5).NE.'PENTA' .AND.
     &      TYPMA(1:5).NE.'TETRA') GO TO 50
        CALL CONARE(TYPMA,AR,NBAR)

        CALL CESEXI('C',JCESD1,JCESL1,IMA,1,1,1,IAD)
        IF (IAD.LE.0) GO TO 50
        NINTER = ZI(JCESV1-1+IAD)

C       INITIALISATION : LAMBDA INACTIF SUR TOUS LES NOEUDS
        DO 10 INO = 1,NBNOMA
          LINACT(INO) = .TRUE.
   10   CONTINUE

        IF (NINTER.NE.0) THEN
C         BOUCLE SUR LES POINTS D'INTERSECTION
          DO 20 I = 1,NINTER
            CALL CESEXI('S',JCESD2,JCESL2,IMA,1,1,4* (I-1)+1,IAD)
            CALL ASSERT(IAD.GT.0)
            IA = NINT(ZR(JCESV2-1+IAD))
            CALL CESEXI('S',JCESD2,JCESL2,IMA,1,1,4* (I-1)+2,IAD)
            CALL ASSERT(IAD.GT.0)
            IN = NINT(ZR(JCESV2-1+IAD))

            IF (IA.EQ.0) THEN
C             INTERSECTION SUR UN NOEUD SOMMET
              LINACT(IN) = .FALSE.
            ELSE
C             INTERSECTION SUR UNE ARETE
              CALL ASSERT(IN.EQ.0)
              N = NOMIL(TYPMA,IA)
              LINACT(N) = .FALSE.
            END IF

   20     CONTINUE
        END IF

C       ON SUPPRIME LES LAMBDAS INACTIFS
        DO 40 INO = 1,NBNOMA
          NUNO = ZI(JCONX1-1+ZI(JCONX2+IMA-1)+INO-1)
          CALL JENUNO(JEXNUM(MA//'.NOMNOE',NUNO),NOMNO)
          IF (LINACT(INO)) THEN

            DO 30 I = 1,3
              CALL AFRELA(1.D0,CBID,DDLC(I),NOMNO,0,RBID,1,BETAR,CBID,
     &                    K8BID,'REEL','REEL','12',0.D0,LISREL)
              NREL = NREL + 1
   30       CONTINUE

          END IF
   40   CONTINUE

   50 CONTINUE

      CALL JEDETR('&&XDELCO.CHS')
      CALL JEDETR('&&XDELCO.LONCHA')
      CALL JEDETR('&&XDELCO.AINTER')

   60 CONTINUE
      CALL JEDEMA()
      END
