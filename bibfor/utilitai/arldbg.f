      SUBROUTINE ARLDBG(NOMPRO,NIV,IFM,IOCC,NI,VALI,NR,VALR,NK,VALK)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 20/07/2009   AUTEUR MEUNIER S.MEUNIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      CHARACTER*6  NOMPRO
      INTEGER      NI,NR,NK,N0
      INTEGER      NIV,IFM,IOCC,VALI(NI)
      REAL*8       VALR(NR)
      CHARACTER*24 VALK(NK)
      PARAMETER    (N0=0)
C
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C AFFICHAGE DEBOGAGE (NIV = 2)
C
C ----------------------------------------------------------------------
C
C
C IN NOMPRO : K6   : NOM DE LA ROUTINE
C IN NIV    : I    : NIVEAU D'INFORMATION
C IN IFM    : I    : NIVEAU D'INFORMATION
C IN IOCC   : I    : OCCURENCE DANS LA ROUTINE
C IN NI     : I    : NOMBRE DE VALEURS ENTIERES DANS LE TABLEAU
C IN VALI   : I(*) : TABLEAU DE VALEURS ENTIERES
C IN NR     : I    : NOMBRE DE VALEURS REELLES DANS LE TABLEAU
C IN VALR   : R(*) : TABLEAU DE VALEURS REELLES
C IN NK     : I    : NOMBRE DE K24 DANS LE TABLEAU
C IN VALK   : K(*) : TABLEAU DE K24
C
C ----------------------------------------------------------------------
C
      IF (NIV.LT.2) THEN
        GOTO 999
      ENDIF
C
      IF (NIV.GE.2) THEN
C
        IF (NOMPRO.EQ.'ARLPAR') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESG('I','ARLEQUINDEBG_1',N0,VALK,NI,VALI,NR,VALR)
          ENDIF
C
        ELSEIF(NOMPRO.EQ.'ARLAPF') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_2')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_3')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_4')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_5')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLCHI') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_6')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_7')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLFG') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_8')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLLCC') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_9')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_10')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_11')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_12')
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESI('I','ARLEQUINDEBG_13',NI,VALI)
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESI('I','ARLEQUINDEBG_14',NI,VALI)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLMED') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESI('I','ARLEQUINDEBG_15',NI,VALI)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ECHMCO') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESK('I','ARLEQUINDEBG_16',NK,VALK)
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESI('I','ARLEQUINDEBG_17',NI,VALI)
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESI('I','ARLEQUINDEBG_18',NI,VALI)
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_19')
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESI('I','ARLEQUINDEBG_20',NI,VALI)
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESI('I','ARLEQUINDEBG_21',NI,VALI)
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESS('I','ARLEQUINDEBG_22')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLBBS') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_30')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESR('I','ARLEQUINDEBG_31',NR,VALR)
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESR('I','ARLEQUINDEBG_32',NR,VALR)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLCLC') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_33')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_34')
          ENDIF

        ELSEIF(NOMPRO.EQ.'CAARLE') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_35')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_36')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_37')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_38')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLLEC') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_39')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_40')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESI('I','ARLEQUINDEBG_41',NI,VALI)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLMOL') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_42')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_43')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLPON') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_44')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_45')
          ENDIF

        ELSEIF(NOMPRO.EQ.'INTMAD') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESK('I','ARLEQUINDEBG_46',NK,VALK)
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_47')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_48')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_49')
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESS('I','ARLEQUINDEBG_50')
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESS('I','ARLEQUINDEBG_51')
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESS('I','ARLEQUINDEBG_52')
          ELSEIF (IOCC.EQ.8) THEN
            CALL U2MESS('I','ARLEQUINDEBG_53')
          ELSEIF (IOCC.EQ.9) THEN
            CALL U2MESR('I','ARLEQUINDEBG_54',NR,VALR)
          ELSEIF (IOCC.EQ.10) THEN
            CALL U2MESR('I','ARLEQUINDEBG_55',NR,VALR)
          ELSEIF (IOCC.EQ.11) THEN
            CALL U2MESS('I','ARLEQUINDEBG_56')
          ELSEIF (IOCC.EQ.12) THEN
            CALL U2MESS('I','ARLEQUINDEBG_57')
          ELSEIF (IOCC.EQ.13) THEN
            CALL U2MESS('I','ARLEQUINDEBG_58')
          ELSEIF (IOCC.EQ.14) THEN
            CALL U2MESR('I','ARLEQUINDEBG_59',NR,VALR)
          ELSEIF (IOCC.EQ.15) THEN
            CALL U2MESR('I','ARLEQUINDEBG_60',NR,VALR)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLBO0') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESI('I','ARLEQUINDEBG_61',NI,VALI)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLCOU') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_62')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_63')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_64')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLGDG') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_65')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_66')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_67')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_68')
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESS('I','ARLEQUINDEBG_69')
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESS('I','ARLEQUINDEBG_70')
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESI('I','ARLEQUINDEBG_71',NI,VALI)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLLPO') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESG('I','ARLEQUINDEBG_72',N0,VALK,NI,VALI,NR,VALR)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLMOM') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_73')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_74')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLVER') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESI('I','ARLEQUINDEBG_75',NI,VALI)
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESG('I','ARLEQUINDEBG_76',NK,VALK,NI,VALI,N0,VALR)
          ENDIF

        ELSEIF(NOMPRO.EQ.'INTMAM') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESK('I','ARLEQUINDEBG_77',NK,VALK)
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_78')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_79')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_80')
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESS('I','ARLEQUINDEBG_81')
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESS('I','ARLEQUINDEBG_82')
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESR('I','ARLEQUINDEBG_83',NR,VALR)
          ELSEIF (IOCC.EQ.8) THEN
            CALL U2MESR('I','ARLEQUINDEBG_84',NR,VALR)
          ELSEIF (IOCC.EQ.9) THEN
            CALL U2MESS('I','ARLEQUINDEBG_85')
          ELSEIF (IOCC.EQ.10) THEN
            CALL U2MESS('I','ARLEQUINDEBG_86')
          ELSEIF (IOCC.EQ.11) THEN
            CALL U2MESS('I','ARLEQUINDEBG_87')
          ELSEIF (IOCC.EQ.12) THEN
            CALL U2MESS('I','ARLEQUINDEBG_88')
          ELSEIF (IOCC.EQ.13) THEN
            CALL U2MESG('I','ARLEQUINDEBG_89',NK,VALK,NI,VALI,N0,VALR)
          ELSEIF (IOCC.EQ.14) THEN
            CALL U2MESS('I','ARLEQUINDEBG_90')
          ELSEIF (IOCC.EQ.15) THEN
            CALL U2MESS('I','ARLEQUINDEBG_91')
          ELSEIF (IOCC.EQ.16) THEN
            CALL U2MESI('I','ARLEQUINDEBG_92',NI,VALI)
          ELSEIF (IOCC.EQ.17) THEN
            CALL U2MESS('I','ARLEQUINDEBG_93')
          ELSEIF (IOCC.EQ.18) THEN
            CALL U2MESI('I','ARLEQUINDEBG_94',NI,VALI)
          ELSEIF (IOCC.EQ.19) THEN
            CALL U2MESK('I','ARLEQUINDEBG_95',NK,VALK)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLBOI') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_96')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_97')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_98')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG_99')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLMAI') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_1')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_2',NI,VALI)
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_3',NI,VALI)
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_4',NI,VALI)
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_5',NI,VALI)
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_6',NI,VALI)
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_7',NI,VALI)
          ELSEIF (IOCC.EQ.8) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_8')
          ELSEIF (IOCC.EQ.9) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_9',NI,VALI)
          ELSEIF (IOCC.EQ.10) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_10',NI,VALI)
          ELSEIF (IOCC.EQ.11) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_11',NI,VALI)
          ELSEIF (IOCC.EQ.12) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_12',NI,VALI)
          ELSEIF (IOCC.EQ.13) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_13')
          ELSEIF (IOCC.EQ.14) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_14')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLNOR') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_15')
          ENDIF

        ELSEIF(NOMPRO.EQ.'ECHMAP') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESG('I','ARLEQUINDEBG2_16',NK,VALK,NI,VALI,N0,VALR)
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_17',NI,VALI)
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_18',NI,VALI)
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_19')
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESG('I','ARLEQUINDEBG2_20',N0,VALK,NI,VALI,NR,VALR)
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESG('I','ARLEQUINDEBG2_21',N0,VALK,NI,VALI,NR,VALR)
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_22')
          ENDIF

        ELSEIF(NOMPRO.EQ.'PLINT2') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_23')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_24')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_25')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_26',NI,VALI)
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_27')
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESS('I','ARLEQUINDEBG2_28')
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESI('I','ARLEQUINDEBG2_29',NI,VALI)
          ELSEIF (IOCC.EQ.8) THEN
            CALL U2MESG('I','ARLEQUINDEBG2_30',N0,VALK,NI,VALI,NR,VALR)
          ENDIF

        ELSEIF(NOMPRO.EQ.'PLINT3') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESS('I','ARLEQUINDEBG_23')
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESS('I','ARLEQUINDEBG_24')
          ELSEIF (IOCC.EQ.3) THEN
            CALL U2MESS('I','ARLEQUINDEBG_25')
          ELSEIF (IOCC.EQ.4) THEN
            CALL U2MESI('I','ARLEQUINDEBG_26',NI,VALI)
          ELSEIF (IOCC.EQ.5) THEN
            CALL U2MESS('I','ARLEQUINDEBG_27')
          ELSEIF (IOCC.EQ.6) THEN
            CALL U2MESS('I','ARLEQUINDEBG_28')
          ELSEIF (IOCC.EQ.7) THEN
            CALL U2MESI('I','ARLEQUINDEBG_29',NI,VALI)
          ELSEIF (IOCC.EQ.8) THEN
            CALL U2MESG('I','ARLEQUINDEBG2_31',N0,VALK,NI,VALI,NR,VALR)
          ENDIF

        ELSEIF(NOMPRO.EQ.'ARLAP1') THEN

          IF (IOCC.EQ.1) THEN
            CALL U2MESG('I','ARLEQUINDEBG2_32',NK,VALK,NI,VALI,N0,VALR)
          ELSEIF (IOCC.EQ.2) THEN
            CALL U2MESK('I','ARLEQUINDEBG2_33',NK,VALK)
          ENDIF

        ENDIF
C
      ENDIF
C
 999  CONTINUE
C
      END
