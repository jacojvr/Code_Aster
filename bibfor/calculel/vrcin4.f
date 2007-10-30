      SUBROUTINE VRCIN4(MODELE,CARELE,CHTEMP,CHVARC)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 29/10/2007   AUTEUR PELLET J.PELLET 
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
      IMPLICIT   NONE
      CHARACTER*8 MODELE,CARELE
      CHARACTER*19 CHVARC,CHTEMP
C ======================================================================
C   BUT : CREER LE CHAM_ELEM DE VARIABLES DE COMMANDE (CHCVARC)
C         CORRESPONDANT AU CHAMP DE TEMPERATURE (CHTEMP)
C
C   IN :
C     MODELE (K8)  IN/JXIN : SD MODELE
C     CARELE (K8)  IN/JXIN : SD CARA_ELEM (SOUS-POINTS)
C     CHTEMP (K19) IN/JXIN : SD CHAMP DE TEMP_R

C   OUT :
C     CHVARC (K19) IN/JXOUT: SD CHAM_ELEM ELGA (VARI_R) CONTENANT
C                  LA SEULE VARC 'TEMP'
C
C ----------------------------------------------------------------------
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------

      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8,CMP1,CMP2
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      INTEGER N1,IRET,NNCP,IBID
      INTEGER JDCLD,JDCLL,JDCLV
      CHARACTER*19 CHS,CES1,DCELI,MNOGA,CELMOD,CESMOD,LIGRMO
      CHARACTER*4 TYCH
C     -- VARIABLES DE SAUVEGARDE POUR GAGNER DU TEMPS
      CHARACTER*8 MODELS,CARELS
      CHARACTER*19 CHVARS
      DATA CHVARS,MODELS,CARELS /3*' '/
C ----------------------------------------------------------------------

      CALL JEMARQ()


C     0. ON REGARDE SI LE TRAVAIL N'EST PAS DEJA FAIT (POUR VRCREF) :
C     ---------------------------------------------------------------
      IF (CHTEMP(9:18).EQ.'.TEMPE_REF') THEN
        IF (  MODELS.EQ.MODELE .AND. CARELS.EQ.CARELE
     &                       .AND. CHVARS.EQ.CHVARC) THEN
          CALL JEEXIN(CHVARC//'.CELD',IRET)
          IF (IRET.GT.0) THEN
             GOTO 9999
          ENDIF
        ELSE
          MODELS=MODELE
          CARELS=CARELE
          CHVARS=CHVARC
        ENDIF
      ENDIF


      LIGRMO = MODELE//'.MODELE'

C     1. TRANSFORMATION DU CHAMP EN CHAM_ELEM_S (CES1):
C     --------------------------------------------------
      CES1 = '&&VRCIN4.CES1'
      MNOGA = MODELE//'.VRC.MNOGA'
      CALL JEEXIN(MNOGA,IRET)
      IF (IRET.EQ.0) CALL MANOPG(LIGRMO,'INIT_VARC','PVARCPR',MNOGA)

      CESMOD = MODELE//'.VRC.CESMOD'
      CALL JEEXIN(CESMOD,IRET)
      IF (IRET.EQ.0) THEN
        CELMOD = '&&VRCIN4.CELMOD'
        DCELI = '&&VRCIN4.DCELI'
        CALL CESVAR(CARELE,' ',LIGRMO,DCELI)
        CALL ALCHML(LIGRMO,'INIT_VARC','PVARCPR','V',CELMOD,IRET,DCELI)
        CALL ASSERT(IRET.EQ.0)
        CALL DETRSD('CHAMP',DCELI)
        CALL CELCES(CELMOD,'V',CESMOD)
        CALL DETRSD('CHAMP',CELMOD)
      ENDIF

      CALL DISMOI('F','TYPE_CHAMP',CHTEMP,'CHAMP',IBID,TYCH,IBID)
      CALL ASSERT(TYCH.EQ.'NOEU' .OR. TYCH.EQ.'CART')

      IF (TYCH.EQ.'NOEU') THEN
        CHS = '&&VRCIN4.CHS'
        CALL CNOCNS(CHTEMP,'V',CHS)
        CALL CNSCES(CHS,'ELGA',CESMOD,MNOGA,'V',CES1)
        CALL DETRSD('CHAM_NO_S',CHS)

      ELSE IF (TYCH.EQ.'CART') THEN
        CALL CARCES(CHTEMP,'ELGA',CESMOD,'V',CES1,IRET)
        CALL ASSERT(IRET.EQ.0)
      ENDIF



C     2. TRANSFORMATION DU CHAM_ELEM_S/TEMP_R EN CHAM_ELEM/VARI_R
C     ------------------------------------------------------------
C     2.1 : ON TRANSFORME TEMP_R -> VARI_R
      CMP1='TEMP'
      CMP2='V1'
      CALL CHSUT1(CES1,'VARI_R',1,CMP1,CMP2,'V',CES1)

C     2.2 : LE CHAMP DE TEMP_REF PEUT CONTENIR DES VALEURS "VIDES"
C           ON LES TRANSFORME EN "NAN"
      CALL JUVINN(CES1//'.CESV')

C     2.3 : CHAM_ELEM_S -> CHAM_ELEM
      CALL CESCEL(CES1,LIGRMO,'INIT_VARC','PVARCPR','NAN',NNCP,'V',
     &            CHVARC,'F',IBID)
      CALL DETRSD('CHAM_ELEM_S',CES1)

9999  CONTINUE
      CALL JEDEMA()
      END
