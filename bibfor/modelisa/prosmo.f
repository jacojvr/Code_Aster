      SUBROUTINE PROSMO(MATREZ,LIMAT,NBMAT,BASEZ,NUMEDD,FACSYM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 15/02/2005   AUTEUR CIBHHPD L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C.======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)

C     PROSMO  --  LE BUT DE CETTE ROUTINE EST DE CONSTRUIRE LA MATR_ASSE
C                 DE NOM MATRES QUI VA RESULTER DE LA COMBINAISON
C                 LINEAIRE DES NBMAT MATR_ASSE DE LA LISTE LISMAT
C                 DE NOMS DE MATR_ASSE. LES MATRICES ONT UN STOCKAGE
C                 MORSE


C   ARGUMENT        E/S  TYPE         ROLE
C    MATREZ         OUT    K*     NOM DE LA MATR_ASSE RESULTANT DE LA
C                                 COMBINAISON LINEAIRE DES MATR_ASSE
C                                 DE LA LISTE LISMAT.
C    LIMAT          IN    K24     LISTE DES MATR_ASSE A COMBINER
C                                 DES MATR_ASSE A COMBINER.
C    NBMAT          IN    I       ON FAIT LA COMBINAISON LINEAIRE
C                                 DES NBMAT PREMIERS MATR_ASSE DE LA
C                                 LISTE LIMAT.
C    BASEZ          IN    K*      NOM DE LA BASE SUR LAQUELLE ON
C                                 CONSTRUIT LA MATR_ASSE.
C    NUMEDD         IN    K14    NOM DU NUME_DDL SUR LEQUEL S'APPUIERA
C                                 LA MATR_ASSE MATREZ
C        SI NUMEDD  =' ', LE NOM DU NUME_DDL SERA OBTENU PAR GCNCON
C        SI NUMEDD /=' ', ON PRENDRA NUMEDD COMME NOM DE NUME_DDL

C    FACSYM   IN    L   /.TRUE. : ON FAIT LA FACTORISATION SYMBOLIQUE
C                                 DE LA MATRICE (MLTPRE)
C                       /.FALSE. : ON NE LA FAIT PAS


C.========================= DEBUT DES DECLARATIONS ====================
C ----- COMMUNS NORMALISES  JEVEUX
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR,TMAX,JEVTBL
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL,FACSYM
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR
C -----  ARGUMENTS
      INTEGER NBMAT
      CHARACTER*(*) MATREZ,BASEZ,NUMEDD
      CHARACTER*24 LIMAT(NBMAT)
C -----  VARIABLES LOCALES
      CHARACTER*1 K1BID,BASE
      CHARACTER*8 METHOD
      CHARACTER*14 NUMDDL,NUMDD1,NUMDDI
      CHARACTER*19 MATRES,MAT1,MATI
      CHARACTER*19 PFCHNO
      CHARACTER*24 KHCOL,KADIA,KABLO,KIABL,KDESC,KREFA,KCONL,KVALE
      CHARACTER*24 KABLO1,KHCO1,KREFE,KREFI
      CHARACTER*24 KLISTE
      CHARACTER*6 KNUMI

C.========================= DEBUT DU CODE EXECUTABLE ==================

      CALL JEMARQ()

C --- INITIALISATIONS :
C     ---------------
      BASE = BASEZ
      MATRES = MATREZ


C --- NOM DU NUME_DDL A CONSTRUIRE :
C     ----------------------------
      IF (NUMEDD.EQ.' ') THEN
        CALL GCNCON('_',NUMDDL(1:8))
        NUMDDL(9:14) = '.NUDDL'
      ELSE
        NUMDDL = NUMEDD
      END IF

C --- NOM DE LA PREMIERE MATR_ASSE :
C     ----------------------------
      MAT1 = LIMAT(1) (1:19)

C --- RECUPERATION DU NUME_DDL ATTACHE A LA PREMIERE MATR_ASSE  :
C     --------------------------------------------------------
      CALL DISMOI('F','NOM_NUME_DDL',MAT1,'MATR_ASSE',IBID,NUMDD1,IER)


C --- COPIE DE LA METHODE DE NUMEROTATION DE LA PREMIERE MATR_ASSE
C --- DANS LE NUMEDDL DE LA MATRICE RESULTANTE :
C     ----------------------------------------
      CALL JEDUPO(NUMDD1//'.MLTF.RENU',BASE,NUMDDL//'.MLTF.RENU',
     &            .FALSE.)

C --- RECOPIE DU PROF_CHNO DE LA PREMIERE MATRICE SUR LA MATRICE
C --- RESULTANTE :
C     ---------
      CALL JEDUPO(NUMDD1//'.NUME.DEEQ',BASE,NUMDDL//'.NUME.DEEQ',
     &            .FALSE.)
      CALL JEDUPO(NUMDD1//'.NUME.DELG',BASE,NUMDDL//'.NUME.DELG',
     &            .FALSE.)
      CALL JEDUPO(NUMDD1//'.NUME.LILI',BASE,NUMDDL//'.NUME.LILI',
     &            .FALSE.)
      CALL JEDUPO(NUMDD1//'.NUME.LPRN',BASE,NUMDDL//'.NUME.LPRN',
     &            .FALSE.)
      CALL JEDUPO(NUMDD1//'.NUME.NUEQ',BASE,NUMDDL//'.NUME.NUEQ',
     &            .FALSE.)
      CALL JEDUPO(NUMDD1//'.NUME.PRNO',BASE,NUMDDL//'.NUME.PRNO',.TRUE.)
      CALL JEDUPO(NUMDD1//'.NUME.REFN',BASE,NUMDDL//'.NUME.REFN',
     &            .FALSE.)

C --- RECUPERATION DU NOMBRE D'EQUATIONS DE LA PREMIERE MATRICE
C --- A COMBINER (C'EST LE MEME POUR TOUTES LES MATRICES) :
C     ---------------------------------------------------
      CALL JEVEUO(NUMDD1//'.SMOS.DESC','L',IDESC1)
      NEQ = ZI(IDESC1+1-1)


C --- CREATION ET AFFECTATION DU TABLEAU .ABLO DES NUMEROS
C --- DES LIGNES DE DEBUT ET DE FIN DU BLOC :
C     ====================================

      KABLO = NUMDDL//'.SMOS.ABLO'
      CALL WKVECT(KABLO,BASE//' V I',2,IDABLO)
      ZI(IDABLO) = 0
      ZI(IDABLO+1) = NEQ


C     7) CONSTRUCTION DE L'OBJET KLISTE QUI CONTIENDRA LES DIFFERENTS
C        HCOL(MAT_I) MIS BOUT A BOUT (EQUATION PAR EQUATION) :
C        KLISTE(JEQ)=HCOL(IMAT_1)(JEQ)//HCOL(IMAT_2)(JEQ)//...
C        KLISTE EST ALLOU� PAR "BLOC" POUR EVITER D'UTILISER
C        TROP DE MEMOIRE
C     =========================================================
      KLISTE = '&&PROSMO.KLISTE'
C     RECUPERATION DE LA TAILLE DES BLOCS DONNEE DANS LA COMMANDE DEBUT:
      TMAX=JEVTBL()
      LGBL = INT(TMAX*1024)

C     7-1) HTC : HAUTEUR CUMULEE DE KLISTE(JEQ)
C     --------------------------------------------------------
      CALL WKVECT('&&PROSMO.HTC','V V I',NEQ,JHTC)
      DO 20 I = 1,NBMAT
        MATI = LIMAT(I) (1:19)
        CALL DISMOI('F','NOM_NUME_DDL',MATI,'MATR_ASSE',IBID,NUMDDI,IER)
        CALL JEVEUO(NUMDDI//'.SMOS.ADIA','L',IADI)
        DO 10,JEQ = 1,NEQ
          IF (JEQ.EQ.1) THEN
            NBTER = 1
          ELSE
            NBTER = ZI(IADI-1+JEQ) - ZI(IADI-1+JEQ-1)
          END IF
          ZI(JHTC-1+JEQ) = ZI(JHTC-1+JEQ) + NBTER
   10   CONTINUE
        CALL JELIBE(NUMDDI//'.SMOS.ADIA')
   20 CONTINUE

C     7-2) IBL : NUMERO DU BLOC DE KLISTE(JEQ) :
C          PBL : POSITION DE L'EQUATION JEQ DANS LE BLOC IBL  :
C     ------------------------------------------------------------
      CALL WKVECT('&&PROSMO.IBL','V V I',NEQ,JIBL)
      CALL WKVECT('&&PROSMO.PBL','V V I',NEQ,JPBL)
      IBL1 = 1
      LCUMU = 0
      DO 30,JEQ = 1,NEQ
        ZI(JPBL-1+JEQ) = LCUMU
        LCUMU = LCUMU + ZI(JHTC-1+JEQ)
C       -- SI ON CHANGE DE BLOC :
        IF (LCUMU.GT.LGBL) THEN
          IBL1 = IBL1 + 1
          LCUMU = 0
        END IF
        ZI(JIBL-1+JEQ) = IBL1
   30 CONTINUE

C     7-3) ALLOCATION DE KLISTE :
C     ------------------------------------------------------------
      IF (IBL1.EQ.1) LGBL=LCUMU
      CALL JECREC(KLISTE,'V V I','NU','DISPERSE','CONSTANT',IBL1)
      CALL JEECRA(KLISTE,'LONMAX',LGBL,K1BID)
      DO 40 KBL = 1,IBL1
        CALL JEVEUO(JEXNUM(KLISTE,KBL),'E',JBL1)
        CALL JELIBE(JEXNUM(KLISTE,KBL))
   40 CONTINUE

C     7-4) REMPLISSAGE DE KLISTE :
C     ------------------------------------------------------------
      CALL JEDETR('&&PROSMO.HTC')
      CALL WKVECT('&&PROSMO.HTC','V V I',NEQ,JHTC)
      IBLAV = 1
      CALL JEVEUO(JEXNUM(KLISTE,IBLAV),'E',JBL1)
      DO 70 I = 1,NBMAT
        MATI = LIMAT(I) (1:19)
        CALL DISMOI('F','NOM_NUME_DDL',MATI,'MATR_ASSE',IBID,NUMDDI,IER)
        CALL JEVEUO(NUMDDI//'.SMOS.ADIA','L',IADI)
        CALL JEVEUO(NUMDDI//'.SMOS.HCOL','L',IDHCOI)
        ICUM = 0
        DO 60,JEQ = 1,NEQ
          IF (JEQ.EQ.1) THEN
            NBTER = 1
          ELSE
            NBTER = ZI(IADI-1+JEQ) - ZI(IADI-1+JEQ-1)
          END IF

C         LE BLOC CONTENANT J DOIT-IL ETRE RAMENE EN MEMOIRE ?
          IBL1 = ZI(JIBL-1+JEQ)
          IF (IBLAV.NE.IBL1) THEN
            CALL JELIBE(JEXNUM(KLISTE,IBLAV))
            CALL JEVEUO(JEXNUM(KLISTE,IBL1),'E',JBL1)
            IBLAV = IBL1
          END IF
          DO 50,K = 1,NBTER
            ZI(JBL1+ZI(JPBL-1+JEQ)+ZI(JHTC-1+JEQ)+K-1) = ZI(IDHCOI+ICUM+
     &         (K-1))
   50     CONTINUE
          ICUM = ICUM + NBTER
          ZI(JHTC-1+JEQ) = ZI(JHTC-1+JEQ) + NBTER
   60   CONTINUE
        CALL JELIBE(NUMDDI//'.SMOS.ADIA')
        CALL JELIBE(NUMDDI//'.SMOS.HCOL')
   70 CONTINUE
      CALL JELIBE(JEXNUM(KLISTE,IBLAV))


C     7-5) COMPACTAGE DE L'OBJET KLISTE
C     8)   ET CREATION  DU TABLEAU .ADIA
C     ===================================
      KADIA = NUMDDL//'.SMOS.ADIA'
      CALL WKVECT(KADIA,BASE//' V I',NEQ,IADIA)

      LHCOL = 0
      IBLAV = 1
      CALL JEVEUO(JEXNUM(KLISTE,IBLAV),'E',JBL1)
      DO 80 JEQ = 1,NEQ
C       LE BLOC CONTENANT JEQ DOIT-IL ETRE RAMENE EN MEMOIRE ?
        IBL1 = ZI(JIBL-1+JEQ)
        IF (IBLAV.NE.IBL1) THEN
          CALL JELIBE(JEXNUM(KLISTE,IBLAV))
          CALL JEVEUO(JEXNUM(KLISTE,IBL1),'E',JBL1)
          IBLAV = IBL1
        END IF

C       ON TRIE ET ORDONNE LA COLONNE (EN PLACE)
        NTERM = ZI(JHTC-1+JEQ)
        CALL UTTRII(ZI(JBL1+ZI(JPBL-1+JEQ)),NTERM)
        ZI(JHTC-1+JEQ) = NTERM
        IF (JEQ.EQ.1) THEN
          CALL ASSERT(NTERM.EQ.1)
          ZI(IADIA+1-1) = NTERM
        ELSE
          ZI(IADIA+JEQ-1) = ZI(IADIA+ (JEQ-1)-1) + NTERM
        END IF
        LHCOL = LHCOL + NTERM
   80 CONTINUE
      CALL JELIBE(JEXNUM(KLISTE,IBLAV))


C     9) CREATION ET AFFECTATION DU TABLEAU .HCOL
C     ====================================================
      KHCOL = NUMDDL//'.SMOS.HCOL'
      CALL WKVECT(KHCOL,BASE//' V I',LHCOL,IDHCOL)
      IBLAV = 1
      CALL JEVEUO(JEXNUM(KLISTE,IBLAV),'E',JBL1)
      L = 0
      DO 100 JEQ = 1,NEQ
C       LE BLOC CONTENANT JEQ DOIT-IL ETRE RAMENE EN MEMOIRE ?
        IBL1 = ZI(JIBL-1+JEQ)
        IF (IBLAV.NE.IBL1) THEN
          CALL JELIBE(JEXNUM(KLISTE,IBLAV))
          CALL JEVEUO(JEXNUM(KLISTE,IBL1),'E',JBL1)
          IBLAV = IBL1
        END IF

        NTERM = ZI(JHTC-1+JEQ)
        DO 90 K = 1,NTERM
          L = L + 1
          ZI(IDHCOL-1+L) = ZI(JBL1+ZI(JPBL-1+JEQ)-1+K)
   90   CONTINUE
  100 CONTINUE
      CALL JELIBE(JEXNUM(KLISTE,IBLAV))
      CALL JEDETR(KLISTE)
      CALL JEDETR('&&PROSMO.HTC')
      CALL JEDETR('&&PROSMO.IBL')
      CALL JEDETR('&&PROSMO.PBL')


C     10) CREATION ET AFFECTATION DU TABLEAU .IABL
C     ========================================================
      KIABL = NUMDDL//'.SMOS.IABL'
      CALL WKVECT(KIABL,BASE//' V I',NEQ,IDIABL)
      DO 110 I = 1,NEQ
        ZI(IDIABL+I-1) = 1
  110 CONTINUE


C     11) CREATION ET AFFECTATION DU TABLEAU .DESC
C     =============================================
      KDESC = NUMDDL//'.SMOS.DESC'

      CALL WKVECT(KDESC,BASE//' V I',6,IDDESC)

C --- RECUPERATION DE LA TAILLE DU BLOC DE LA MATRICE RESULTANTE
C --- (NOMBRE DE TERMES NON NULS DE LA MATRICE)
      ITBLOC = ZI(IADIA+NEQ-1)

      ZI(IDDESC+1-1) = NEQ
      ZI(IDDESC+2-1) = ITBLOC
      ZI(IDDESC+3-1) = 1


C     12) CREATION ET AFFECTATION DE LA COLLECTION .VALE
C     ===================================================
      KVALE = MATRES//'.VALE'

      NBLOC = 1

      CALL JEEXIN(KVALE,IER)
      IF ( IER.EQ.0) THEN
         CALL JECREC(KVALE,BASE//' V R','NU','DISPERSE',
     &               'CONSTANT',NBLOC)

         CALL JEECRA(KVALE,'LONMAX',ITBLOC,' ')
         CALL JEECRA(KVALE,'DOCU',IBID,'MS')

         CALL JECROC(JEXNUM(KVALE,NBLOC))
         CALL JEVEUO(JEXNUM(KVALE,NBLOC),'E',IDKVAL)
         CALL JELIBE(JEXNUM(KVALE,NBLOC))
      ENDIF

C     13) CREATION ET AFFECTATION DU TABLEAU .REFA
C     ============================================================
      KREFA = MATRES//'.REFA'
      KCONL = MATRES//'.CONL'
      CALL JEEXIN(KREFA,IER)
      IF (IER.EQ.0) THEN
         CALL WKVECT(KREFA,BASE//' V K24',4,IDREFA)
      ELSE
         CALL JEVEUO(KREFA,'E',IDREFA)
      ENDIF
      ZK24(IDREFA+2-1) = NUMDDL//'.NUME'
      ZK24(IDREFA+3-1) = NUMDDL//'.SMOS'

      DO 120 I = 1,NBMAT
        MATI = LIMAT(I) (1:19)
        KREFI = MATI//'.REFA'
        CALL JEVEUO(KREFI,'L',IDREFI)
        IF (ZK24(IDREFI+1-1).NE.' ') THEN
          ZK24(IDREFA+1-1) = ZK24(IDREFI+1-1)
          GO TO 130
        END IF
  120 CONTINUE
  130 CONTINUE

C --- ON AFFECTE L'ETAT 'ASSEMBLE' A LA MATRICE :
C     -----------------------------------------
      CALL JEECRA(KREFA,'DOCU',IBID,'ASSE')


C     14) CREATION ET AFFECTATION DE L'OBJET .REFE DU NUME_DDL:
C     =========================================================
      KREFE = NUMDDL//'.SMOS.REFE'
      CALL WKVECT(KREFE,BASE//' V K24',1,IDREFE)

      ZK24(IDREFE+1-1) (1:14) = NUMDDL
      CALL JEECRA(KREFE,'DOCU',IBID,'SMOS')


C     15) CREATION ET AFFECTATION DU VECTEUR .CONL
C     =============================================
      CALL WKVECT(KCONL,BASE//' V R',NEQ,IDCONL)
      DO 140 IEQ = 1,NEQ
        ZR(IDCONL+IEQ-1) = 1.D0
  140 CONTINUE


C --- RECUPERATION DE LA METHODE DE RENUMEROTATION ATTACHEE
C --- A LA MATRICE RESULTANTE :
C     =======================
      CALL JEVEUO(NUMDDL//'.MLTF.RENU','L',IDRENU)
      METHOD = ZK8(IDRENU)
      LMAT = L
C --- SI LA MATRICE EST DIAGONALE ON CHOISIT LA NUMEROTATION 'MDA' :
      IF (LMAT.EQ.NEQ) METHOD = 'MDA'

C --- CREATION DES TABLEAUX .MLTF ISSUS DE LA NUMEROTATION
C --- MINIMUM DEGREE
C     ==============
      CALL DETRSD('MLTF',NUMDDL//'.MLTF')
      IF (FACSYM) CALL MLTPRE(NUMDDL,BASE,METHOD)
      CALL JEDUPO(NUMDD1//'.MLTF.RENU',BASE,NUMDDL//'.MLTF.RENU',
     &            .FALSE.)



      CALL JEDEMA()

      END
