      SUBROUTINE CFTANR(NOMA  ,NDIMG ,DEFICO,IZONE ,FFORME,
     &                  POSMAM,POSNOE,NUMENM,KSI1  ,KSI2  ,
     &                  TAU1M ,TAU2M ,TAU1  ,TAU2  )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 22/07/2008   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*8   NOMA,FFORME
      INTEGER       POSMAM,POSNOE
      INTEGER       IZONE,NUMENM
      INTEGER       NDIMG
      REAL*8        KSI1,KSI2
      CHARACTER*24  DEFICO
      REAL*8        TAU1(3),TAU2(3)
      REAL*8        TAU1M(3),TAU2M(3)
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE DISCRETE - APPARIEMENT)
C
C MODIFIE LES VECTEURS TANGENTS LOCAUX SUIVANT OPTIONS
C
C ----------------------------------------------------------------------
C
C  NB: LE REPERE EST ORTHONORME ET TEL QUE LA NORMALE POINTE VERS
C  L'INTERIEUR DE LA MAILLE
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NDIMG  : DIMENSION DU MODELE
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  IZONE  : ZONE DE CONTACT ACTIVE
C IN  POSMAM : MAILLE MAITRE OU NOEUD MAITRE QUI RECOIT LA PROJECTION
C              > 0 MAILLE MAITRE QUI RECOIT LA PROJECTION
C              < 0 NOEUD MAITRE QUI RECOIT LA PROJECTION
C IN  NUMENM : > 0 NUMERO ABSOLU MAILLE MAITRE QUI RECOIT LA PROJECTION
C              < 0 NUMERO ABSOLU NOEUD MAITRE QUI RECOIT LA PROJECTION
C IN  POSNOE : NOEUD ESCLAVE
C IN  KSI1   : COORDONNEE PARAMETRIQUE SUR MAITRE DU POINT ESCLAVE
C              PROJETE
C IN  KSI2   : COORDONNEE PARAMETRIQUE SUR MAITRE DU POINT ESCLAVE
C              PROJETE
C IN  TAU1M  : PREMIERE TANGENTE SUR LA MAILLE MAITRE AU POINT ESCLAVE
C              PROJETE
C IN  TAU2M  : SECONDE TANGENTE SUR LA MAILLE MAITRE AU POINT ESCLAVE
C              PROJETE
C OUT TAU1   : PREMIER VECTEUR TANGENT LOCAL AU POINT ESCLAVE PROJETE
C OUT TAU2   : SECOND VECTEUR TANGENT LOCAL AU POINT ESCLAVE PROJETE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*32 JEXNUM
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
      LOGICAL      LLISS,LBID,LMFIXE,LEFIXE,LMAIT,LESCL
      LOGICAL      LPOUTR,LPOINT
      CHARACTER*24 K24BID,K24BLA
      INTEGER      I,IBID,IMA
      INTEGER      POSMAE,POSNOM,NUMMAE,NUMMAM
      INTEGER      INORM,ITYPEM,ITYPEE
      CHARACTER*8  NOMENT,ALIASE,ALIASM
      REAL*8       R8BID,VECTOR(3)
      REAL*8       TAU1E(3),TAU2E(3)
      CHARACTER*24 TANINI,MANOCO,PMANO,CONTMA
      INTEGER      JTGINI,JMANO,JPOMA,JMACO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- RECUPERATION DE QUELQUES DONNEES
C
      TANINI = DEFICO(1:16)//'.TANINI'
      MANOCO = DEFICO(1:16)//'.MANOCO'
      PMANO  = DEFICO(1:16)//'.PMANOCO'
      CONTMA = DEFICO(1:16)//'.MAILCO'
      CALL JEVEUO(TANINI,'L',JTGINI)
      CALL JEVEUO(MANOCO,'L',JMANO)
      CALL JEVEUO(PMANO ,'L',JPOMA)
      CALL JEVEUO(CONTMA,'L',JMACO)
C
C --- INITIALISATIONS
C
      K24BLA = ' '
      LMFIXE = .FALSE.
      LEFIXE = .FALSE.

      IF (NUMENM.GT.0) THEN
        CALL JENUNO(JEXNUM(NOMA//'.NOMMAI',NUMENM),NOMENT)
      ELSEIF (NUMENM.LT.0) THEN
        POSNOM = ABS(POSMAM)
        CALL JENUNO(JEXNUM(NOMA//'.NOMNOE',ABS(NUMENM)),NOMENT)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

C
C --- LISSAGE OU PAS ?
C
      CALL MMINFP(IZONE ,DEFICO,K24BLA,'LISSAGE',
     &            IBID  ,R8BID ,K24BID,LLISS   )
C
C --- TYPE DE LA NORMALE A CHOISIR
C
      CALL MMINFP(IZONE ,DEFICO,K24BLA,'NORMALE',
     &            INORM ,R8BID ,K24BID,LBID     )
C
C --- NORMALES A MODIFIER
C
      LMAIT = .FALSE.
      LESCL = .FALSE.
      IF (INORM.EQ.0) THEN
        LMAIT = .TRUE.
        LESCL = .FALSE.
      ELSEIF (INORM.EQ.1) THEN
        LMAIT = .TRUE.
        LESCL = .TRUE.
      ELSEIF (INORM.EQ.2) THEN
        LMAIT = .FALSE.
        LESCL = .TRUE.
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- DIMENSION MAILLE ESCLAVE: ON PREND LA PREMIERE MAILLE ATTACHEE
C --- AU NOEUD ESCLAVE
C
      IF (LESCL) THEN
        IMA    = 1
        POSMAE = ZI(JMANO+ZI(JPOMA+POSNOE-1)+IMA-1)
        NUMMAE = ZI(JMACO+POSMAE-1)
        CALL MMELTY(NOMA  ,NUMMAE,ALIASE,IBID  ,IBID  )
      ENDIF
C
C --- DIMENSION MAILLE MAITRE
C
      IF (LMAIT) THEN
        IF (POSMAM.EQ.0) THEN
          IMA    = 1
          POSMAM = ZI(JMANO+ZI(JPOMA+POSNOM-1)+IMA-1)
          NUMMAM = ZI(JMACO+POSMAM-1)
          CALL MMELTY(NOMA  ,NUMMAM,ALIASM,IBID  ,IBID  )
        ELSE
          NUMMAM = ZI(JMACO+POSMAM-1)
          CALL MMELTY(NOMA  ,NUMMAM,ALIASM,IBID  ,IBID  )
        ENDIF
      ENDIF
C
C --- RECUPERATION TANGENTES ESCLAVES SI NECESSSAIRE
C
      IF (LESCL) THEN
        DO 10 I = 1,3
          TAU1E(I) = ZR(JTGINI+6*(POSNOE-1)+I-1)
          TAU2E(I) = ZR(JTGINI+6*(POSNOE-1)+3+I-1)
 10     CONTINUE
      ENDIF
C
C --- MODIFICATIONS DES NORMALES MAITRES
C
      IF (LMAIT) THEN
        CALL MMINFP(IZONE ,DEFICO,K24BLA,'VECT_MAIT',
     &              ITYPEM,VECTOR,K24BID,LBID)
        IF ((NDIMG.EQ.2).AND.(ITYPEM.EQ.2)) THEN
          CALL U2MESS('F','CONTACT3_43')
        ENDIF
        LPOUTR = (NDIMG.EQ.3).AND.(ALIASM(1:2).EQ.'SG')
        LPOINT = ALIASM.EQ.'POI1'
        IF (LPOINT) THEN
          CALL U2MESS('F','CONTACT_75')
        ENDIF
        CALL CFNORS(NOMA  ,DEFICO,FFORME,POSMAM,NUMENM,
     &              LPOUTR,LPOINT,KSI1  ,KSI2  ,LLISS ,
     &              ITYPEM,VECTOR,TAU1M ,TAU2M ,LMFIXE)
      ENDIF
C
C --- MODIFICATIONS DES NORMALES ESCLAVES
C
      IF (LESCL) THEN
        CALL MMINFP(IZONE ,DEFICO,K24BLA,'VECT_ESCL',
     &              ITYPEE,VECTOR,K24BID,LBID)
        IF ((NDIMG.EQ.2).AND.(ITYPEE.EQ.2)) THEN
          CALL U2MESS('F','CONTACT3_43')
        ENDIF
        LPOUTR = (NDIMG.EQ.3).AND.(ALIASE(1:2).EQ.'SG')
        LPOINT = ALIASE.EQ.'POI1'
        CALL CFNORS(NOMA  ,DEFICO,FFORME,POSMAE,NUMENM,
     &              LPOUTR,LPOINT,R8BID ,R8BID ,.FALSE.,
     &              ITYPEE,VECTOR,TAU1E ,TAU2E ,LEFIXE)
      ENDIF
C
C --- CHOIX DE LA NORMALE -> CALCUL DES TANGENTES
C
      CALL CFCHNO(NOMA  ,DEFICO,IZONE ,POSNOE,NUMENM,
     &            LMFIXE,LEFIXE,NDIMG ,TAU1M ,TAU2M ,
     &            TAU1E ,TAU2E ,TAU1  ,TAU2  )
C
      CALL JEDEMA()
C
      END
