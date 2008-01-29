      SUBROUTINE VRCIN1(MODELE,CHMAT,CARELE,INST)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 28/01/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT   NONE
      CHARACTER*8 MODELE,CHMAT,CARELE
      REAL*8 INST
C ======================================================================
C   BUT : FAIRE L'INTERPOLATION AU TEMPS INST DES DIFFERENTS CHAMPS
C         DE VARIABLES DE COMMANDE.
C         CES CHAMPS SONT PASSES AUX POINTS DE GAUSS MECANIQUE.
C         (INIT_VARC/PVARCPR)
C
C   IN :
C     MODELE (K8)  IN/JXIN : SD MODELE
C     CHMAT  (K8)  IN/JXIN : SD CHAM_MATER
C     CARELE  (K8)  IN/JXIN : SD CARA_ELEM
C     INST   (R)   IN      : VALEUR DE L'INSTANT

C   OUT :
C       - CREATION DE CHMAT//'.LISTE_CH' V V K24  LONG=NBCHS
C          .LISTE_CH(I) : IEME CHAM_ELEM_S / ELGA PARTICIPANT A
C                         LA CREATION DU CHAMP DE CVRC
C       - CREATION DE CHMAT//'.LISTE_SD' V V K16  LONG=7*NBCHS
C          .LISTE_SD(7*(I-1)+1) : /'EVOL' /'CHAMP' :
C               TYPE DE LA SD DONT EST ISSU .LISTE_CHS(I)
C          .LISTE_SD(7*(I-1)+2) : NOMSD
C               NOM DE L'EVOL (OU DU CHAMP) DONT EST ISSU .LISTE_CHS(I)
C          .LISTE_SD(7*(I-1)+3) : NOMSYM / ' '
C               SI 'EVOL' : NOM SYMBOLIQUE DU CHAMP DONT EST
C               ISSU .LISTE_CHS(I). SINON : ' '
C          .LISTE_SD(7*(I-1)+4) : VARC
C               VARC ASSOCIE A .LISTE_CHS(I).
C          .LISTE_SD(7*(I-1)+5) : PROLGA
C               (SI EVOL : TYPE DE PROLONGEMENT A GAUCHE)
C          .LISTE_SD(7*(I-1)+6) : PROLDR
C               (SI EVOL : TYPE DE PROLONGEMENT A DROITE)
C          .LISTE_SD(7*(I-1)+7) : FINST (OU ' ')
C               (SI EVOL : FONCTION DE TRANSFORMATION DU TEMPS)
C
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR,INSTEV
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER N1,IBID,NBMA,JCESD1,JCESL1,JCESV1,IAD,LONK80,JCVVAR
      INTEGER ITROU,INDK80,NBK80,K,IMA,JLK80,IRET,NBCHS,JLISSD,ICHS
      INTEGER NBCVRC,JCVGD,JLISCH,INDIK8
      CHARACTER*8 VARC,MAILLA,KBID,TYSD,PROLDR,PROLGA,NOMEVO,FINST
      CHARACTER*8 NOMGD,NOMGD2,TYCH,NOMSD
      CHARACTER*16 NOMSYM,NOMCH
      CHARACTER*19 CART2,CHS,CESMOD,CELMOD,LIGRMO,MNOGA,DCELI
      CHARACTER*19 CES1,CNS1
      CHARACTER*24 VALK(3)
      CHARACTER*80 K80, K80PRE
C ----------------------------------------------------------------------

      CALL JEMARQ()
      CALL INFMAJ()

      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,MAILLA,IBID)
      CALL DISMOI('F','NB_MA_MAILLA',MAILLA,'MAILLAGE',NBMA,KBID,IBID)
      LIGRMO=MODELE//'.MODELE'
      CALL JELIRA(CHMAT//'.CVRCVARC','LONMAX',NBCVRC,KBID)
      CALL JEVEUO(CHMAT//'.CVRCVARC','L',JCVVAR)
      CALL JEVEUO(CHMAT//'.CVRCGD','L',JCVGD)


C     1. CREATION DE CHMAT.LISTE_SD :
C     -------------------------------
      CALL JEEXIN(CHMAT//'.LISTE_SD',IRET)
      IF (IRET.EQ.0) THEN
      VARC=' '
      K80PRE=' '
      NBK80=0
      LONK80=5
      CALL WKVECT('&&VRCIN1.LK80','V V K80',LONK80,JLK80)
      DO 1, K=1,NBCVRC
        IF (ZK8(JCVVAR-1+K).EQ.VARC) GO TO 1
        VARC=ZK8(JCVVAR-1+K)
        CART2 = CHMAT//'.'//VARC//'.2'
        CES1='&&VRCIN1.CES1'
        CALL CARCES(CART2,'ELEM',' ','V',CES1,IRET)
        CALL ASSERT(IRET.EQ.0)
        CALL JEVEUO(CES1//'.CESD','L',JCESD1)
        CALL JEVEUO(CES1//'.CESL','L',JCESL1)
        CALL JEVEUO(CES1//'.CESV','L',JCESV1)
        DO 2,IMA=1,NBMA
          CALL CESEXI('C',JCESD1,JCESL1,IMA,1,1,1,IAD)
          IF ( IAD .LE. 0 ) GOTO 2
          IAD=IAD-1
          TYSD=ZK16(JCESV1-1+IAD+2)(1:8)
          NOMSD =ZK16(JCESV1-1+IAD+3)(1:8)
          NOMSYM=ZK16(JCESV1-1+IAD+4)
          PROLGA=ZK16(JCESV1-1+IAD+5)
          PROLDR=ZK16(JCESV1-1+IAD+6)
          FINST =ZK16(JCESV1-1+IAD+7)
          CALL ASSERT((TYSD.EQ.'EVOL').OR.
     &                (TYSD.EQ.'CHAMP').OR.(TYSD.EQ.'VIDE'))
          IF (TYSD.EQ.'VIDE') GOTO 2

          K80=' '
          K80(1:8)  =TYSD
          K80(9:16) =NOMSD
          K80(17:32)=NOMSYM
          K80(33:40)=VARC
          K80(41:48)=PROLGA
          K80(49:56)=PROLDR
          K80(57:64)=FINST
          IF (K80.EQ.K80PRE) GO TO 2
          K80PRE=K80
          ITROU=INDK80(ZK80(JLK80),K80,1,NBK80)
          IF (ITROU.GT.0) GO TO 2
          NBK80=NBK80+1
          IF (NBK80.GT.LONK80) THEN
             LONK80=2*LONK80
             CALL JUVECA('&&VRCIN1.LK80',LONK80)
             CALL JEVEUO('&&VRCIN1.LK80','E',JLK80)
          END IF
          ZK80(JLK80-1+NBK80)=K80
2       CONTINUE
        CALL DETRSD('CHAM_ELEM_S',CES1)
1     CONTINUE

      NBCHS=NBK80
      IF (NBCHS.EQ.0) THEN
        CALL JEDETR('&&VRCIN1.LK80')
        GOTO 9999
      ENDIF
      CALL WKVECT(CHMAT//'.LISTE_SD','V V K16',7*NBCHS,JLISSD)
      DO 3,ICHS=1,NBCHS
          K80=ZK80(JLK80-1+ICHS)
          ZK16(JLISSD-1+7*(ICHS-1)+1)=K80(1:8)
          ZK16(JLISSD-1+7*(ICHS-1)+2)=K80(9:16)
          ZK16(JLISSD-1+7*(ICHS-1)+3)=K80(17:32)
          ZK16(JLISSD-1+7*(ICHS-1)+4)=K80(33:40)
          ZK16(JLISSD-1+7*(ICHS-1)+5)=K80(41:48)
          ZK16(JLISSD-1+7*(ICHS-1)+6)=K80(49:56)
          ZK16(JLISSD-1+7*(ICHS-1)+7)=K80(57:64)
3     CONTINUE
      CALL JEDETR('&&VRCIN1.LK80')
      END IF


C     2. CREATION DE CHMAT.LISTE_CH :
C     -------------------------------
      CALL JEVEUO(CHMAT//'.LISTE_SD','L',JLISSD)
      CALL JELIRA(CHMAT//'.LISTE_SD','LONMAX',N1,KBID)
      NBCHS=N1/7
      CALL ASSERT(N1.EQ.7*NBCHS)
      CALL JEDETR(CHMAT//'.LISTE_CH')
      CALL WKVECT(CHMAT//'.LISTE_CH','V V K24',NBCHS,JLISCH)
      CHS=CHMAT//'.CHS000'

C     2.0.1  CREATION DE CESMOD :
C     ---------------------------
      CESMOD=MODELE//'.VRC.CESMOD'
      CALL JEEXIN(CESMOD,IRET)
      IF (IRET.EQ.0) THEN
        CELMOD='&&VRCIN1.CELMOD'
        DCELI='&&VRCIN1.DCELI'
        CALL CESVAR(CARELE,' ',LIGRMO,DCELI)
        CALL ALCHML(LIGRMO,'INIT_VARC','PVARCPR','V',CELMOD,IRET,DCELI)
        CALL ASSERT(IRET.EQ.0)
        CALL DETRSD('CHAMP',DCELI)
        CALL CELCES(CELMOD,'V',CESMOD)
        CALL DETRSD('CHAMP',CELMOD)
      END IF


C     2.0.2  CREATION DE MNOGA :
C     ---------------------------
      MNOGA = MODELE//'.VRC.MNOGA'
      CALL JEEXIN(MNOGA,IRET)
      IF (IRET.EQ.0)  CALL MANOPG(LIGRMO,'INIT_VARC','PVARCPR',MNOGA)


      DO 5,ICHS=1,NBCHS
          CALL CODENT(ICHS,'D0',CHS(13:15))
          ZK24(JLISCH-1+ICHS)=CHS
          TYSD=ZK16(JLISSD-1+7*(ICHS-1)+1)(1:8)
          VARC=ZK16(JLISSD-1+7*(ICHS-1)+4)(1:8)

C         2.1 INTERPOLATION EN TEMPS => NOMCH
C         ------------------------------------
          IF (TYSD.EQ.'EVOL') THEN
C           -- SI TYSD='EVOL', ON INTERPOLE AU TEMPS INST
            NOMEVO=ZK16(JLISSD-1+7*(ICHS-1)+2)(1:8)
            NOMSYM=ZK16(JLISSD-1+7*(ICHS-1)+3)
            PROLGA=ZK16(JLISSD-1+7*(ICHS-1)+5)
            PROLDR=ZK16(JLISSD-1+7*(ICHS-1)+6)
            FINST =ZK16(JLISSD-1+7*(ICHS-1)+7)
            NOMCH='&&VRCIN1.NOMCH'

C           -- PRISE EN COMPTE DE L'EVENTUELLE TRANSFORMATION DU TEMPS
C              (AFFE_VARC/FONC_INST):
            IF (FINST .NE. ' ') THEN
               CALL FOINTE('F',FINST,1,'INST',INST,INSTEV,IBID)
            ELSE
               INSTEV=INST
            ENDIF
            CALL RSINCH(NOMEVO,NOMSYM,'INST',INSTEV,NOMCH,PROLDR,PROLGA,
     &                  2,'V',IRET)
            CALL ASSERT(IRET.LE.2)
          ELSE
            CALL ASSERT(TYSD.EQ.'CHAMP')
C           -- SI TYSD='CHAMP', C'EST UN CHAMP INDEPENDANT DU TEMPS :
            NOMCH=ZK16(JLISSD-1+7*(ICHS-1)+2)
          END IF

C         2.2 PASSAGE AUX POINTS DE GAUSS => CHS
C         --------------------------------------
C         -- VERIFICATION DE NOMCH :
          ITROU=INDIK8(ZK8(JCVVAR),VARC,1,NBCVRC)
          CALL ASSERT(ITROU.GT.0)
          NOMGD=ZK8(JCVGD-1+ITROU)
          CALL DISMOI('F','NOM_GD',NOMCH,'CHAMP',IBID,NOMGD2,IRET)
          IF (NOMGD.NE.NOMGD2) THEN
             VALK(1) = VARC
             VALK(2) = NOMGD
             VALK(3) = NOMGD2
             CALL U2MESK('F','CALCULEL5_39', 3 ,VALK)
          ENDIF
          CALL DISMOI('F','TYPE_CHAMP',NOMCH,'CHAMP',IBID,TYCH,IRET)


          IF (TYCH.EQ.'CART') THEN
             CALL CARCES(NOMCH,'ELGA',CESMOD,'V',CHS,IRET)
             CALL ASSERT(IRET.EQ.0)

          ELSE IF (TYCH.EQ.'NOEU') THEN
             CNS1='&&VRCIN1.CNS1'
             CALL CNOCNS(NOMCH,'V',CNS1)
             CALL CNSCES(CNS1,'ELGA',CESMOD,MNOGA,'V',CHS)
             CALL DETRSD('CHAM_NO_S',CNS1)

          ELSE IF ((TYCH.EQ.'ELNO').OR.(TYCH.EQ.'ELEM')) THEN
             CES1='&&VRCIN1.CES1'
             CALL CELCES(NOMCH,'V',CES1)
             CALL CESCES(CES1,'ELGA',CESMOD,MNOGA,' ','V',CHS)
             CALL DETRSD('CHAM_ELEM_S',CES1)

          ELSE IF (TYCH.EQ.'ELGA') THEN
             CALL ASSERT(.FALSE.)

          ELSE
             CALL ASSERT(.FALSE.)
          END IF



          IF (TYSD.EQ.'EVOL') CALL DETRSD('CHAMP',NOMCH)
5     CONTINUE

9999  CONTINUE
      CALL JEDEMA()
      END
