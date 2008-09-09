      SUBROUTINE CAARLE ( CHARGE )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 01/09/2008   AUTEUR MEUNIER S.MEUNIER 
C ======================================================================
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
C RESPONSABLE MEUNIER S.MEUNIER
C
      IMPLICIT NONE
      CHARACTER*8   CHARGE
C
C ----------------------------------------------------------------------
C
C              CREATION D'UN CHARGEMENT DE TYPE ARLEQUIN
C
C ----------------------------------------------------------------------
C
C I/O  CHARGE : SD CHARGE
C
C SD EN ENTREE :
C ==============
C
C .CHME.MODEL.NOMO       : NOM DU MODELE ASSOCIE A LA CHARGE
C .TYPE                  : TYPE DE LA CHARGE
C
C SD EN SORTIE ENRICHIE PAR :
C ===========================
C
C .POIDS_MAILLE   : VECTEUR DE PONDERATION DES MAILLES DU MAILLAGE
C                         (P_1,P_2, ...) AVEC P_I POIDS DE LA MAILLE I
C .CHME.LIGRE     : LIGREL DE CHARGE
C .CHME.CIMPO     : CARTE COEFFICIENTS IMPOSES
C .CHME.CMULT     : CARTE COEFFICIENTS MULTIPLICATEURS
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C
      CHARACTER*32       JEXNUM
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      CHARACTER*16 TYPMAI
      CHARACTER*10 NOMA,NOMB,NOMC,NOM1,NOM2,NORM,TANG,QUADRA
      CHARACTER*8  NOMO,MAIL,MODEL(3),CINE(3),NOMARL
      CHARACTER*8  K8BID
      INTEGER      DIME,NOCC
      INTEGER      NBTYP,NBMAC,NAPP
      INTEGER      IOCC,ZOCC,IBID,I
      INTEGER      JTYPM,JLGRF
      INTEGER      DIMVAR(2),DEGRE
      REAL*8       BC(2,3),LCARA
      REAL*8       POND1,POND2
      INTEGER      GRFIN,GRMED,GRCOL
      INTEGER      IFM,NIV
      CHARACTER*16 MOTCLE
C
      DATA MOTCLE /'ARLEQUIN'/
      DATA TYPMAI /'&&CAARLE.NOMTM'/
      DATA NOMARL /'&&ARL'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
C --- IMPOSE-T-ON UNE CHARGE ARLEQUIN ?
C
      CALL GETFAC('ARLEQUIN',NOCC)
      IF (NOCC.EQ.0) GOTO 999
C
C --- LECTURE NOMS DU MODELE ET DU MAILLAGE
C
      CALL GETVID(' ','MODELE',0,1,1,NOMO,IBID)
      CALL JEVEUO(NOMO//'.MODELE    .LGRF','L',JLGRF)
      MAIL = ZK8(JLGRF)
C
C --- STRUCTURES DE DONNEES
C
      NOMA   = CHARGE(1:8)//'.A'
      NOMB   = CHARGE(1:8)//'.B'
      NOMC   = CHARGE(1:8)//'.C'
      NOM1   = CHARGE(1:8)//'.1'
      NOM2   = CHARGE(1:8)//'.2'
      NORM   = CHARGE(1:8)//'.N'
      TANG   = CHARGE(1:8)//'.T'
      QUADRA = CHARGE(1:8)//'.Q'
C
C --- CREATION D'UN VECTEUR CONTENANT LE NOM DES TYPES DE MAILLES
C
      CALL JELIRA('&CATA.TM.NOMTM','NOMMAX',NBTYP,K8BID)
      CALL WKVECT(TYPMAI, 'V V K8',NBTYP, JTYPM)
      DO 10 I = 1,NBTYP
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',I),ZK8(JTYPM-1+I))
 10   CONTINUE
C
C --- CREATION DE LA SD PRINCIPALE ARLEQUIN NOMARL
C ---
C --- 1. STOCKAGE DE PARAMETRES FIGES DE LA METHODE
C
      CALL ARLPAR(NOMARL,'V')
C
C --- 2. CREATION DE VECTEURS DE TRAVAIL TEMPORAIRES
C
      CALL ARLCAR(NOMARL,'V')
C
C --- 3. CREATION DU VECTEUR DE PONDERATION DES MAILLES
C
      CALL ARLCVP(NOMARL,CHARGE,MAIL,'G')
C
C ========================================
C BOUCLE SUR LE NOMBRE DE CHARGES ARLEQUIN
C ========================================
C
      DO 30 IOCC = 1, NOCC
C
        ZOCC = IOCC
C
C --- LECTURE ET VERIFICATION DES MAILLES DES MODELES
C
        CALL ARLLEC(MOTCLE,ZOCC  ,NOMO  ,NOMA  ,NOMB  ,
     &              MODEL ,CINE  ,DIMVAR,DIME)
C
C --- CALCUL DES NORMALES DES COQUES (SI NECESSAIRE)
C
        CALL ARLNOR(MOTCLE,ZOCC  ,CINE  ,NORM  ,TANG  ,
     &              TYPMAI,DIME  )
C
C --- MISE EN BOITE DES MAILLES DES DEUX ZONES
C
        CALL ARLBOI(MAIL  ,NOMARL,TYPMAI,DIME  ,NOMA  ,
     &              NOMB  ,NORM  )
C
C --- CALCUL DE LA BOITE DE SUPERPOSITION ET LONGUEUR CARACTERISTIQUE
C
        CALL ARLBBS(DIME  ,NOMA  ,NOMB  ,BC    ,LCARA)
C
C --- FILTRAGE DES MAILLES SITUEES DANS LA ZONE DE SUPERPOSITION
C
        CALL ARLFIL(NOMA  ,NOMB  ,BC    ,NOM1  ,NOM2)
C
C --- LECTURE ET VERIFICATION PONDERATION
C
        CALL ARLLPO(MOTCLE,ZOCC  ,NOM1  ,NOM2  ,POND1 ,
     &              POND2 ,GRFIN)
C
C --- CHOIX DU MEDIATEUR
C
        CALL ARLMED(MOTCLE,ZOCC  ,GRFIN ,GRMED)
C
C --- MAILLES DE LA ZONE DE COLLAGE
C
        CALL ARLLCC(MOTCLE,ZOCC  ,NOMARL,NOMO  ,MAIL  ,
     &              DIME  ,TYPMAI,NOM1  ,NOM2  ,NORM  ,
     &              BC    ,NOMC  ,NBMAC ,GRMED ,GRCOL ,
     &              MODEL ,CINE)
C
C --- CALCUL DU DEGRE MAXIMAL DES GRAPHES NOEUDS -> MAILLES
C
        CALL ARLGDG(MAIL  ,NOM1  ,NOM2  ,DIMVAR,DEGRE)
C
C --- APPARIEMENT DES MAILLES ET FAMILLES D'INTEGRALES
C
        CALL ARLAPF(MAIL  ,DIME  ,TYPMAI,NOM1  ,NOM2  ,
     &              NOMARL,NORM  ,GRMED ,GRCOL ,CINE  ,
     &              DEGRE ,NBMAC ,NOMC  ,NAPP  ,QUADRA)
C
C --- ELIMINATION REDONDANCE CONDITIONS LIMITES / COUPLAGE ARLEQUIN
C
        CALL ARLCLR(MOTCLE,ZOCC  ,MAIL  ,NOMARL,DIME  ,
     &              NOMC  ,TANG  )
C
C --- CALCUL DES EQUATIONS DE COUPLAGE
C
        CALL ARLCOU(ZOCC  ,
     &              MAIL  ,NOMO  ,NOMARL,TYPMAI,QUADRA,
     &              NOMC  ,NOM1  ,NOM2  ,CINE  ,NORM  ,
     &              TANG  ,GRMED ,LCARA ,DIME)
C
C --- PONDERATION DES MAILLES
C
        CALL ARLPON(MAIL  ,DIME  ,NOMARL,TYPMAI,NOMC  ,
     &              NOM1  ,NOM2  ,CINE  ,NORM  ,BC    ,
     &              GRCOL ,POND1 ,POND2 )
C
C --- DESALLOCATION GROUPES 1 ET 2
C
        CALL ARLDSD('GROUPEMA',NOM1)
        CALL ARLDSD('GRMAMA'  ,NOM1)
        CALL ARLDSD('BOITE'   ,NOM1)
        CALL ARLDSD('GROUPEMA',NOM2)
        CALL ARLDSD('GRMAMA'  ,NOM2)
        CALL ARLDSD('BOITE'   ,NOM2)
C
C --- ASSEMBLAGE EN CHARGE .CHME
C
        CALL ARLCHR(DIME  ,NOMARL,CINE  ,NOM1  ,NOM2  ,
     &              CHARGE)
C
C --- DESALLOCATION MATRICES MORSES
C
        CALL ARLDSD('MORSE',NOM1)
        CALL ARLDSD('MORSE',NOM2)
C
C --- DESALLOCATIONS GROUPE COLLAGE
C
        CALL ARLDSD('COLLAGE',NOMC)
C
C ==========
C FIN BOUCLE
C ==========
C
 30   CONTINUE
C
C --- DESALLOCATION OBJETS ARLEQUIN
C
      CALL ARLDSD('ARLEQUIN',NOMARL)
C
C --- AUTRES OBJETS
C
      CALL JEDETR(TYPMAI)
      CALL JEDETR(NORM)
      CALL JEDETR(TANG)
C

 999  CONTINUE

      CALL JEDEMA()

      END
