      SUBROUTINE MMCHML(NOMA  ,DEFICO,RESOCO,SDDISC,SDDYNA,
     &                  NUMINS)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 30/01/2012   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      CHARACTER*8  NOMA
      CHARACTER*24 DEFICO,RESOCO
      CHARACTER*19 SDDISC,SDDYNA
      INTEGER      NUMINS
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE CONTINUE - CREATION OBJETS - CHAM_ELEM)
C
C CREATION DU CHAM_ELEM CONTENANT LES INFOS DE CONTACT
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  RESOCO : SD POUR LA RESOLUTION DE CONTACT
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  INST   : PARAMETRES D'INSTANT POUR LA DYNAMIQUE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
      CHARACTER*32 JEXNUM
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER      NCMP
      PARAMETER   (NCMP=27)
      INTEGER      CFMMVD,ZTABF
      INTEGER      IPTC,IZONE,NTPC
      CHARACTER*24 JEUSUP
      INTEGER      JJSUP
      CHARACTER*24 TABFIN,NOSDCO
      INTEGER      JTABF,JNOSDC
      INTEGER      JVALV
      CHARACTER*19 LIGRCF,CHMLCF,CRNUDD
      INTEGER      IFM,NIV      ,JCRNUD
      REAL*8       DIINST,INSTAM,INSTAP,DELTAT
      LOGICAL      NDYNLO,LDYNA ,LTHETA,LAPPAR
      REAL*8       NDYNRE,THETA
      REAL*8       MMINFR
      INTEGER      MMINFI,IFORM
      INTEGER      IUSURE
      REAL*8       COEFFF,KWEAR,HWEAR
      REAL*8       COEFAC,COEFAF
      INTEGER      IALGOC,IALGOF
      INTEGER      CFDISI,IRESOF
      INTEGER      IRET,NTLIEL,DECAL
      INTEGER      NBGREL,NBLIEL
      INTEGER      IGR  ,   IEL
      CHARACTER*24 CELD, CELV
      INTEGER      JCELD,JCELV,JLIEL
      INTEGER      NCELD1  ,NCELD2  ,NCELD3
      PARAMETER   (NCELD1=4,NCELD2=4,NCELD3=4)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('CONTACT',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<CONTACT> CREATION DU CHAM_ELEM POUR LES'//
     &        ' ELEMENTS DE CONTACT'
      ENDIF
C
C --- ACCES OBJETS
C
      JEUSUP = RESOCO(1:14)//'.JSUPCO'
      TABFIN = RESOCO(1:14)//'.TABFIN'
      NOSDCO = RESOCO(1:14)//'.NOSDCO'
      CALL JEVEUO(NOSDCO,'L',JNOSDC)
      CALL JEVEUO(JEUSUP,'L',JJSUP)
      CALL JEVEUO(TABFIN,'L',JTABF)
      CRNUDD = RESOCO(1:14)//'.NUDD'
      CALL JEVEUO(CRNUDD,'L',JCRNUD)
C
      ZTABF = CFMMVD('ZTABF')
C
C --- FONCTIONNALITES ACTIVEES
C
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      LTHETA = NDYNLO(SDDYNA,'THETA_METHODE')
      IRESOF = CFDISI(DEFICO,'ALGO_RESO_FROT')
C
C --- LIGREL DES ELEMENTS TARDIFS DE CONTACT/FROTTEMENT
C
      LIGRCF = ZK24(JNOSDC+2-1)(1:19)
C
C --- CHAM_ELEM POUR ELEMENTS TARDIFS DE CONTACT/FROTTEMENT
C
      CHMLCF = RESOCO(1:14)//'.CHML'
C
C --- INITIALISATIONS
C
      NTPC   = NINT(ZR(JTABF-1+1))
      INSTAM = DIINST(SDDISC,NUMINS-1)
      INSTAP = DIINST(SDDISC,NUMINS)
      DELTAT = INSTAP-INSTAM
      THETA  = 0.D0
      IFORM  = 0
      IF (LDYNA) THEN
        IF (LTHETA) THEN
          THETA  = NDYNRE(SDDYNA,'THETA')
          IFORM  = 2
        ELSE
          IFORM  = 1
        ENDIF
      ENDIF
C
C --- DESTRUCTION/CREATION DU CHAM_ELEM SI NECESSAIRE
C
      LAPPAR = ZL(JCRNUD)
      IF (LAPPAR) THEN
        CALL DETRSD('CHAM_ELEM',CHMLCF)
        CALL ALCHML(LIGRCF,'RIGI_CONT','PCONFR','V',CHMLCF,IRET,' ')
        CALL ASSERT(IRET.EQ.0)
      ENDIF
C
C --- RECUPERATION DU DESCRIPTEUR DU CHAM_ELEM
C
      CELD   = CHMLCF//'.CELD'
      CALL JEVEUO(CELD,'L',JCELD)
      NBGREL = ZI(JCELD-1+2)
C
C --- ACCES AUX VALEURS DU CHAM_ELEM
C
      CELV   = CHMLCF//'.CELV'
      CALL JEVEUO(CELV,'E',JCELV)
C
C --- REMPLISSAGE DU CHAM_ELEM
C
      NTLIEL = 0
      DO 200 IGR = 1,NBGREL
C       ADRESSE DANS CELD DES INFORMATIONS DU GREL IGR
        DECAL  = ZI(JCELD-1+NCELD1+IGR)
C       NOMBRE D'ELEMENTS DU GREL IGR
        NBLIEL = ZI(JCELD-1+DECAL+1)
C       VERIF TAILLE CHAM_ELEM
        CALL ASSERT(ZI(JCELD-1+DECAL+3).EQ.NCMP)
C       RECUPERATION DES MAILLES DU GREL IGR
        CALL JEVEUO(JEXNUM(LIGRCF//'.LIEL',IGR),'L',JLIEL)
        DO 300 IEL = 1,NBLIEL
C         MAILLE TARDIVE ZI(JLIEL-1+IEL) < 0
          IPTC   = -ZI(JLIEL-1+IEL)
          IZONE  = NINT(ZR(JTABF+ZTABF*(IPTC-1)+13))
          COEFFF = MMINFR(DEFICO,'COEF_COULOMB'     ,IZONE )
          IUSURE = MMINFI(DEFICO,'USURE'            ,IZONE )
          KWEAR  = MMINFR(DEFICO,'USURE_K'          ,IZONE )
          HWEAR  = MMINFR(DEFICO,'USURE_H'          ,IZONE )
          IALGOC = MMINFI(DEFICO,'ALGO_CONT'        ,IZONE )
          IALGOF = MMINFI(DEFICO,'ALGO_FROT'        ,IZONE )
          CALL CFMMCO(DEFICO,RESOCO,IZONE,'COEF_AUGM_CONT','L',
     &                COEFAC)
          CALL CFMMCO(DEFICO,RESOCO,IZONE,'COEF_AUGM_FROT','L',
     &                COEFAF)
C         ADRESSE DANS CELV DE L'ELEMENT IEL DU GREL IGR
          JVALV = JCELV-1+ZI(JCELD-1+DECAL+NCELD2+NCELD3*(IEL-1)+4)
C ------- DONNNES DE PROJECTION
          ZR(JVALV-1+1)  = ZR(JTABF+ZTABF*(IPTC-1)+3 )
          ZR(JVALV-1+2)  = ZR(JTABF+ZTABF*(IPTC-1)+4 )
          ZR(JVALV-1+3)  = ZR(JTABF+ZTABF*(IPTC-1)+5 )
          ZR(JVALV-1+4)  = ZR(JTABF+ZTABF*(IPTC-1)+6 )
          ZR(JVALV-1+5)  = ZR(JTABF+ZTABF*(IPTC-1)+7 )
          ZR(JVALV-1+6)  = ZR(JTABF+ZTABF*(IPTC-1)+8 )
          ZR(JVALV-1+7)  = ZR(JTABF+ZTABF*(IPTC-1)+9 )
          ZR(JVALV-1+8)  = ZR(JTABF+ZTABF*(IPTC-1)+10)
          ZR(JVALV-1+9)  = ZR(JTABF+ZTABF*(IPTC-1)+11)
          ZR(JVALV-1+10) = ZR(JTABF+ZTABF*(IPTC-1)+12)
          ZR(JVALV-1+11) = ZR(JTABF+ZTABF*(IPTC-1)+14)
C ------- STATUT DE CONTACT
          ZR(JVALV-1+12) = ZR(JTABF+ZTABF*(IPTC-1)+22)
C ------- SEUIL DE FROTTEMENT
          ZR(JVALV-1+13) = ZR(JTABF+ZTABF*(IPTC-1)+16)
C ------- JEU SUPPLEMENTAIRE
          ZR(JVALV-1+14) = ZR(JJSUP-1+IPTC)
C ------- ALGO/COEF DU CONTACT
          ZR(JVALV-1+15) = IALGOC
          ZR(JVALV-1+16) = COEFAC
C ------- ALGO/COEF DU FROTTEMENT
          ZR(JVALV-1+17) = IRESOF
          ZR(JVALV-1+18) = IALGOF
          ZR(JVALV-1+19) = COEFAF
          ZR(JVALV-1+20) = COEFFF
C ------- USURE
          ZR(JVALV-1+21) = IUSURE
          ZR(JVALV-1+22) = KWEAR
          ZR(JVALV-1+23) = HWEAR
C ------- EXCLUSION
          ZR(JVALV-1+24) = ZR(JTABF+ZTABF*(IPTC-1)+19)
C ------- DYNAMIQUE
          ZR(JVALV-1+25) = IFORM
          ZR(JVALV-1+26) = DELTAT
          ZR(JVALV-1+27) = THETA
C
          IF (NIV.GE.2) THEN
            CALL MMIMP3(IFM,NOMA,IPTC,JVALV,JTABF)
          ENDIF
  300   CONTINUE
        NTLIEL = NTLIEL + NBLIEL
  200 CONTINUE
      CALL ASSERT(NTLIEL.EQ.NTPC)

      CALL JEDEMA()
      END
