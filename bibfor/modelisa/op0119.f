      SUBROUTINE OP0119(IER)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 13/02/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C ----------------------------------------------------------------------
C TOLE CRP_20

C                O P E R A T E U R    DEFI_GEOM_FIBRE

C ----------------------------------------------------------------------
C     NBMCF  : NOMBRE DE MOTS CLES FACTEUR DE L'OPERATEUR
C ----------------------------------------------------------------------
      IMPLICIT NONE
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNUM,JEXNOM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER IER,IRET,IFM,NIV
      INTEGER NBOCCS,NBOCCP
      INTEGER NBFIB,NMAILS,NTTRI3,NTSEG2,NTQUA4
      INTEGER NBV,JDTM,JMS,NUMMAI,NUTYMA
      INTEGER NBVAL,ITROIS,NCARFI
      PARAMETER (NBVAL=999,NCARFI=3)
      REAL*8 VAL(NBVAL),PI4,DTROIS,ZERO
      PARAMETER (PI4=0.785398163397D+0,DTROIS=3.D+0,ITROIS=3,ZERO=0.D+0)
      CHARACTER*1 K1BID
      CHARACTER*8 SDGF,NOMGF,NOMAS,KTYMA,KSUDI
      CHARACTER*6 KNBV,KIOC,KNUMAI
      CHARACTER*16 CONCEP,CMD,LIMCLS(3),LTYMCL(3)
      CHARACTER*24 MLGTMS,MLGCNX,MLGCOO
      CHARACTER*24 VPOINT,VNBFIG,VCAFIG,VPOCFG,RNOMGF,VALK(3)
      INTEGER NBGF,JPO
      INTEGER IOC,I,J,IPOS,IN,NNO,NO,JCF,JDNO,JDCO,JNFG,IBID,IPOINT,IG
      REAL*8 X(4),Y(4),CENTRE(2),AXEP(2),SURF

      DATA LIMCLS/'MAILLE_SECT','GROUP_MA_SECT','TOUT_SECT'/
      DATA LTYMCL/'MAILLE','GROUP_MA','TOUT'/
C     ------------------------------------------------------------------

      CALL JEMARQ()

      IRET=0

C --- RECUPERATION DES ARGUMENTS  DE LA COMMANDE
      CALL GETRES(SDGF,CONCEP,CMD)

C --- ON COMPTE LE NOMBRE DES GROUPES DE FIBRES POUR DIMENSIONNER
C     LES OBJETS
      CALL GETFAC('SECTION',NBOCCS)
      CALL GETFAC('FIBRE',NBOCCP)
      NBGF=NBOCCS+NBOCCP
C --- SD GEOM_FIBRE
C NOMS DES GROUPES DE FIBRES (REPERTOIRE DE NOMS)
C NOMBRE DE FIBRES PAR GROUPE
C PLUS BAS IL Y AURA LES CARACTERISTIQUES DE FIBRES
C (TOUT A LA SUITE EN 1 SEUL VECTEUR)
C ON FAIT UN POINTEUR POUR LES CARACTERISTIQUES POUR  
C FACILITER LES ACCES
      VNBFIG = SDGF//'.NB_FIBRE_GROUPE'
      VCAFIG = SDGF//'.CARFI'
      VPOCFG = SDGF//'.POINTEUR'
      RNOMGF = SDGF//'.NOMS_GROUPES'

      CALL JECREO(RNOMGF,'G N K8')
      CALL JEECRA(RNOMGF,'NOMMAX',NBGF,' ')

      CALL WKVECT(VNBFIG, 'G V I',NBGF,JNFG)
      CALL WKVECT(VPOCFG, 'G V I',NBGF,JPO)


C     RECUPERATION DU NIVEAU D'IMPRESSION
C     -----------------------------------
      CALL INFMAJ
      CALL INFNIV(IFM,NIV)

C --- RECUPERATION DES NUMEROS DES TYPES MAILLES TRI3,QUA4
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','TRIA3'),NTTRI3)
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','QUAD4'),NTQUA4)
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM','SEG2'),NTSEG2)

C --- COMPTAGE DU NOMBRE DE FIBRES TOTAL
      NBFIB = 0
      DO 40 IOC = 1,NBOCCS
C ---   LES SECTIONS MAINTENANT
        CALL GETVID('SECTION','MAILLAGE_SECT',IOC,1,1,NOMAS,NBV)
        MLGTMS = NOMAS//'.TYPMAIL'

C ---   VERIFICATION MAILLES TRIA3 ET QUAD4 UNIQUEMENT
        CALL JEVEUO(MLGTMS,'L',JDTM)
C ---   NOMBRE DE FIBRES = NOMBRE DE MAILLES CONCERNEES
        CALL RELIEM(' ',NOMAS,'NU_MAILLE','SECTION',IOC,3,LIMCLS,
     &              LTYMCL,'&&PMFD00.MAILLSEC',NMAILS)
        NBFIB = NBFIB + NMAILS
        CALL JEVEUO('&&PMFD00.MAILLSEC','L',JMS)
        DO 30 J = 1,NMAILS
          NUMMAI = ZI(JMS+J-1)
          NUTYMA = ZI(JDTM+NUMMAI-1)
          IF (NUTYMA.NE.NTSEG2) THEN
            IF (NUTYMA.NE.NTTRI3 .AND. NUTYMA.NE.NTQUA4) THEN
              CALL CODENT(NUMMAI,'G',KNUMAI)
              CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',NUTYMA),KTYMA)
C              CALL UTMESS('F',CMD,'DANS LE MAILLAGE "'//NOMAS//
C     &                    '" LA MAILLE "'//KNUMAI//'" EST DE TYPE "'//
C     &                    KTYMA//'" (NI TRIA3 NI QUAD4)')
              VALK(1)=NOMAS
              VALK(2)=KNUMAI
              VALK(3)=KTYMA
              CALL U2MESK('F','MODELISA6_27', 3 ,VALK)
            END IF
          ELSE
C ---        ON DEDUIT LES SEG2 DU NB DE FIBRES
            NBFIB = NBFIB - 1
          END IF
   30   CONTINUE
   40 CONTINUE

      DO 50 IOC = 1,NBOCCP
C ---   NOMBRE DE FIBRES PONCTUELLES
        CALL GETVR8('FIBRE','VALE',IOC,1,NBVAL,VAL,NBV)
C ---   VERIF MULTIPLE DE 3 POUR 'VALE' DANS 'FIBRE'
        IF (DBLE(NBV)/DTROIS.NE.NBV/ITROIS) THEN
          CALL GETVTX('FIBRE','GROUP_FIBRE',IOC,1,1,NOMGF,IBID)
          CALL CODENT(IOC,'G',KIOC)
          CALL CODENT(NBV,'G',KNBV)
C          CALL UTMESS('F',CMD,'OCCURENCE '//KIOC//'DE FIBRE POUR'//
C     & ' LE GROUPE DE FIBRE '//NOMGF//': IL Y A '//KNBV//
C     & ' VALEURS POUR "VALE", CE DEVRAIT ETRE UN MULTIPLE DE 3')
          VALK(1)=NOMGF
          VALK(2)=KNBV
          CALL U2MESK('F','MODELISA6_26', 2 ,VALK)

        ELSE
          NBFIB = NBFIB + NBV/ITROIS
        ENDIF
   50 CONTINUE


C --- ENCORE UN VECTEUR DE LA SD GEOM FIBRES (CARFI)
      CALL WKVECT(VCAFIG,'G V R',NBFIB*NCARFI,JCF)

      IPOINT = 1
      IG=0
C -----------------------------------------------------------------
C --- TRAITEMENT DES SECTION
C -----------------------------------------------------------------
      DO 90 IOC = 1,NBOCCS
        IG=IG+1
        CALL GETVTX('SECTION','GROUP_FIBRE',IOC,1,1,NOMGF,IBID)
        IF(NIV.EQ.2)WRITE(IFM,1000)NOMGF
C ---   ON RECUPERE LE MAILLAGE
        CALL GETVID('SECTION','MAILLAGE_SECT',IOC,1,1,NOMAS,NBV)
C ---   RECUPERATION DES COORDONNEES DE L'AXE DE LA POUTRE
        CALL GETVR8('SECTION','COOR_AXE_POUTRE',IOC,1,2,AXEP,IRET)
        IF (IRET.NE.2) THEN
          AXEP(1) = ZERO
          AXEP(2) = ZERO
        END IF
C ---   RECONSTRUCTION DES NOMS JEVEUX DU CONCEPT MAILLAGE ASSOCIE
        MLGTMS = NOMAS//'.TYPMAIL'
        MLGCNX = NOMAS//'.CONNEX'
        MLGCOO = NOMAS//'.COORDO    .VALE'

C --- RECUPERATION DES ADRESSES JEVEUX UTILES
        CALL JEVEUO(MLGTMS,'L',JDTM)
        CALL JEVEUO(MLGCOO,'L',JDCO)

C ---  ON RECUPERE LES MAILLES DE LA SECTION CONCERNEES
        CALL RELIEM(' ',NOMAS,'NU_MAILLE','SECTION',IOC,3,LIMCLS,
     &              LTYMCL,'&&OP0119.MAILLSEC',NMAILS)
        CALL JEVEUO('&&OP0119.MAILLSEC','L',JMS)
        NBFIB = 0
        DO 70 J = 1,NMAILS
          NUMMAI = ZI(JMS+J-1)
C ---     COORDONNEES NOEUDS
          NUTYMA = ZI(JDTM+NUMMAI-1)
          IF (NUTYMA.EQ.NTSEG2) GO TO 70
          NBFIB = NBFIB + 1
          CALL JEVEUO(JEXNUM(MLGCNX,NUMMAI),'L',JDNO)
          NNO = 3
          IF (NUTYMA.EQ.NTQUA4) NNO = 4
          DO 60 IN = 1,NNO
            NO = ZI(JDNO-1+IN)
            X(IN) = ZR(JDCO+ (NO-1)*3) - AXEP(1)
            Y(IN) = ZR(JDCO+ (NO-1)*3+1) - AXEP(2)
   60     CONTINUE
C ---     SURFACE ET CENTRE
          CALL PMFSCE(NNO,X,Y,SURF,CENTRE)
C --- STOCKAGE DES CARACTERISTIQUES DE FIBRES DANS
          IPOS = JCF + IPOINT - 1 + NCARFI* (NBFIB-1)
          ZR(IPOS) = CENTRE(1)
          ZR(IPOS+1) = CENTRE(2)
          ZR(IPOS+2) = SURF
          IF (NIV.EQ.2) WRITE (IFM,1001) NBFIB,CENTRE,SURF
   70   CONTINUE
        CALL JECROC(JEXNOM(RNOMGF,NOMGF))
        ZI(JNFG+IG-1)=NBFIB
        ZI(JPO+IG-1)=IPOINT
        IPOINT = IPOINT + NBFIB*NCARFI
   90 CONTINUE

C -----------------------------------------------------------------
C --- TRAITEMENT DES FIBRE
C -----------------------------------------------------------------
C
      DO 120 IOC = 1,NBOCCP
        IG=IG+1
        CALL GETVTX('FIBRE','GROUP_FIBRE',IOC,1,1,NOMGF,IBID)
        IF (NIV.EQ.2) WRITE (IFM,2000) NOMGF
C ---   SURFACE OU DIAMETRE
        CALL GETVTX('FIBRE','CARA',IOC,1,1,KSUDI,IRET)
        IF (IRET.EQ.0) KSUDI = 'SURFACE '
        CALL GETVR8('FIBRE','VALE',IOC,1,NBVAL,VAL,NBV)
C ---   RECUPERATION DES COORDONNEES DE L'AXE DE LA POUTRE
        CALL GETVR8('FIBRE','COOR_AXE_POUTRE',IOC,1,2,AXEP,IRET)
        IF (IRET.NE.2) THEN
          AXEP(1) = ZERO
          AXEP(2) = ZERO
        END IF
C ---   CHANGER DIAMETRE EN SURFACE LE CAS ECHEANT
        NBFIB = 0
        DO 100 I = 1,NBV/3
          IF (KSUDI.EQ.'DIAMETRE') THEN
            SURF = VAL(3*I)*VAL(3*I)*PI4
          ELSE
            SURF = VAL(3*I)
          END IF
          IF (IRET.EQ.2) THEN
            CENTRE(1) = VAL(3*I-2) - AXEP(1)
            CENTRE(2) = VAL(3*I-1) - AXEP(2)
          ELSE
            CENTRE(1) = VAL(3*I-2)
            CENTRE(2) = VAL(3*I-1)
          END IF
C ---     STOCKAGE DES CARACTERISTIQUES DE FIBRES DANS
          IPOS = JCF + IPOINT - 1 + NCARFI* (I-1)
          ZR(IPOS) = CENTRE(1)
          ZR(IPOS+1) = CENTRE(2)
          ZR(IPOS+2) = SURF
          NBFIB = NBFIB + 1
          IF (NIV.EQ.2) WRITE (IFM,1001) NBFIB,CENTRE,SURF
 100    CONTINUE
        CALL JECROC(JEXNOM(RNOMGF,NOMGF))
        ZI(JNFG+IG-1)=NBFIB
        ZI(JPO+IG-1)=IPOINT
        IPOINT = IPOINT + NBFIB*NCARFI
 120  CONTINUE

 1000 FORMAT(//,'DETAIL DES FIBRES SURFACIQUES DU GROUPE "',A8,
     &     '"',/,'NUMF       Y           Z         SURF')
 1001 FORMAT(I4,3(2X,D10.4))
 2000 FORMAT(//,'DETAIL DES FIBRES PONCTUELLES DU GROUPE "',A8,
     &     '"',/,'NUMF       Y           Z         SURF')

      CALL JEDEMA()

      END
