      SUBROUTINE LRMMFA ( FID, NOMAMD,
     &                    NBNOEU, NBMAIL,
     &                    GRPNOE, GRPMAI, NBGRNO, NBGRMA,
     &                    TYPGEO, NOMTYP, NMATYP,
     &                    PREFIX,
     &                    INFMED,
     &                    VECGRM, NBCGRM )
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 21/11/2006   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GNICOLAS G.NICOLAS
C TOLE CRP_20
C-----------------------------------------------------------------------
C     LECTURE DU MAILLAGE - FORMAT MED - LES FAMILLES
C     -    -     -                 -         --
C-----------------------------------------------------------------------
C
C ENTREES :
C  FID    : IDENTIFIANT DU FICHIER MED
C  NOMAMD : NOM DU MAILLAGE MED
C  NBNOEU : NOMBRE DE NOEUDS DU MAILLAGE
C  NBMAIL : NOMBRE DE MAILLES DU MAILLAGE
C  TYPGEO : TYPE MED POUR CHAQUE MAILLE
C  NOMTYP : NOM DES TYPES POUR CHAQUE MAILLE
C  NMATYP : NOMBRE DE MAILLES PAR TYPE
C  PREFIX : PREFIXE POUR LES TABLEAUX DES RENUMEROTATIONS
C SORTIES :
C  GRPNOE : OBJETS DES GROUPES DE NOEUDS
C  GRPMAI : OBJETS DES GROUPES DE MAILLES
C  NBGRNO : NOMBRE DE GROUPES DE NOEUDS
C  NBGRMA : NOMBRE DE GROUPES DE MAILLES
C DIVERS
C INFMED : NIVEAU DES INFORMATIONS A IMPRIMER
C-----------------------------------------------------------------------
C
      IMPLICIT NONE
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 48)
C
C 0.1. ==> ARGUMENTS
C
      INTEGER FID
      INTEGER NBNOEU, NBMAIL, NBGRNO, NBGRMA, NBCGRM
      INTEGER TYPGEO(NTYMAX), NMATYP(NTYMAX)
      INTEGER INFMED
C
      CHARACTER*6 PREFIX
      CHARACTER*8 NOMTYP(NTYMAX)
      CHARACTER*(*) NOMAMD
C
      CHARACTER*24 GRPNOE, GRPMAI, VECGRM
C
C 0.2. ==> COMMUNS
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRMMFA' )
C
      INTEGER EDNOEU
      PARAMETER (EDNOEU=3)
      INTEGER EDMAIL
      PARAMETER (EDMAIL=0)
      INTEGER TYPNOE
      PARAMETER (TYPNOE=0)
C
      INTEGER CODRET
      INTEGER IAUX
      INTEGER ITYP
      INTEGER NBRFAM
      INTEGER ADCARF, ADFANO, ADTABA
      INTEGER IFM, NIVINF
      INTEGER JNUMTY(NTYMAX), JFAMMA(NTYMAX)
C
      CHARACTER*8 SAUX08
      CHARACTER*24 FAMNOE, CARAFA, TABAUX
      CHARACTER*24 NOMGRO, NUMGRO, NUMENT
C
CGN      REAL*8 TPS1(4), TPS2(4)
CGN      CALL UTTCPU(1,'INIT',4,TPS1)
CGN      CALL UTTCPU(2,'INIT',4,TPS2)
CGN      CALL UTTCPU(1,'DEBUT',4,TPS1)
C
C====
C 1. PREALABLES
C====
C
      CALL JEMARQ ( )
C
      CALL INFNIV ( IFM, NIVINF )
C
      IF ( NIVINF.GE.2 ) THEN
C
        WRITE (IFM,1001) NOMPRO
 1001 FORMAT( 60('='),/,'DEBUT DU PROGRAMME ',A)
C
      ENDIF
C
C====
C 2. LECTURES DE DIMENSIONNEMENT
C====
C
      NBGRNO = 0
      NBGRMA = 0
C
C 2.1. ==> RECHERCHE DU NOMBRE DE FAMILLES ENREGISTREES
C
      CALL EFNFAM ( FID, NOMAMD, NBRFAM, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL U2MESK('F','MODELISA5_24',1,SAUX08)
      ENDIF
C
      IF ( INFMED.GE.2 ) THEN
C
        WRITE (IFM,2101) NBRFAM
 2101 FORMAT('NOMBRE DE FAMILLES DANS LE FICHIER A LIRE :',I5)
C
      ENDIF
C
C 2.2. ==> SI PAS DE FAMILLE, PAS DE GROUPE ! DONC, ON S'EN VA.
C          C'EST QUAND MEME BIZARRE, ALORS ON EMET UNE ALARME
C
      IF ( NBRFAM.EQ.0 ) THEN
        CALL U2MESS('A','MODELISA5_25')
      ELSE
C
C====
C 3. ON LIT LES TABLES DES NUMEROS DE FAMILLES POUR NOEUDS ET MAILLES
C====
C
C 3.1. ==> LA FAMILLE D'APPARTENANCE DE CHAQUE NOEUD
C
C               12   345678   9012345678901234
      FAMNOE = '&&'//NOMPRO//'.FAMILLE_NO     '
      CALL WKVECT ( FAMNOE, 'V V I', NBNOEU, ADFANO )
C
      CALL EFFAML ( FID, NOMAMD, ZI(ADFANO), NBNOEU,
     &              EDNOEU, TYPNOE, CODRET )
      IF ( CODRET.NE.0 ) THEN
        CALL CODENT ( CODRET,'G',SAUX08 )
        CALL U2MESK('F','MODELISA5_26',1,SAUX08)
      ENDIF
C
C 3.2. ==> LA FAMILLE D'APPARTENANCE DE CHAQUE MAILLE
C          ON DOIT LIRE TYPE PAR TYPE
C
      DO 32 , ITYP = 1 , NTYMAX
C
        IF ( NMATYP(ITYP).NE.0) THEN
C
          CALL WKVECT ('&&'//NOMPRO//'.FAMMA.'//NOMTYP(ITYP),'V V I',
     &                   NMATYP(ITYP),JFAMMA(ITYP))
          CALL EFFAML ( FID, NOMAMD, ZI(JFAMMA(ITYP)),NMATYP(ITYP),
     &                  EDMAIL, TYPGEO(ITYP), CODRET )
          IF ( CODRET.NE.0 ) THEN
           CALL CODENT ( CODRET,'G',SAUX08 )
           CALL U2MESK('F','MODELISA5_26',1,SAUX08)
          ENDIF
C
        ENDIF
C
   32 CONTINUE
C
C====
C 4. LECTURE DES CARACTERISTIQUES DES FAMILLES
C====
C
CGN      CALL UTTCPU(2,'DEBUT',4,TPS2)
C
C 4.1. ==> ALLOCATIONS
C               12   345678   9012345678901234
      CARAFA = '&&'//NOMPRO//'.CARAC_FAM      '
      TABAUX = '&&'//NOMPRO//'.TABAUX         '
      NOMGRO = '&&'//NOMPRO//'.FANOMG         '
      NUMGRO = '&&'//NOMPRO//'.FANUMG         '
      NUMENT = '&&'//NOMPRO//'.FANUM          '
C
C     CARACTERISTIQUES DES FAMILLES
      IAUX = 3*NBRFAM
      CALL WKVECT ( CARAFA, 'V V I', IAUX, ADCARF )
C
C     COLLECTION             FAM I -> NOMGNO X , NOMGMA Y ...
      CALL JECREC ( NOMGRO, 'V V K8', 'NU', 'DISPERSE',
     &              'VARIABLE', NBRFAM )
C
C     COLLECTION             FAM I -> NUMGNO X , NUMGMA Y ...
      CALL JECREC ( NUMGRO, 'V V I', 'NU', 'DISPERSE',
     &              'VARIABLE', NBRFAM )
C
C     COLLECTION INVERSE     FAM I -> NUMNO(MA) X, NUMNO(MA) Y..
      CALL JECREC ( NUMENT, 'V V I', 'NU', 'DISPERSE',
     &              'VARIABLE', NBRFAM )
C
C     VECTEUR  TEMPO         FAM I -> NUMNO(MA)
      IAUX = MAX ( NBNOEU, NBMAIL )
      CALL WKVECT ( TABAUX, 'V V I', IAUX, ADTABA )
C
C 4.2. ==> RECUPERATION DU TABLEAU DES RENUMEROTATIONS
C
      DO 42 , ITYP = 1 , NTYMAX
        IF ( NMATYP(ITYP).NE.0 ) THEN
          CALL JEVEUO('&&'//PREFIX//'.NUM.'//NOMTYP(ITYP),'L',
     &                JNUMTY(ITYP))
        ENDIF
   42 CONTINUE
C
C 4.3. ==> APPEL DU PROGRAMME DE LECTURE
C
      CALL LRMMF1 ( FID, NOMAMD,
     &              NBRFAM, ZI(ADCARF),
     &              NBNOEU, ZI(ADFANO),
     &              NMATYP, JFAMMA, JNUMTY,
     &              ZI(ADTABA),
     &              NOMGRO, NUMGRO, NUMENT,
     &              INFMED, NIVINF, IFM,
     &              VECGRM, NBCGRM )
C
C 4.4. ==> MENAGE PARTIEL
C
      CALL JEDETR(TABAUX)
C
CGN      CALL UTTCPU(2,'FIN',4,TPS2)
CGN      WRITE (IFM,*)
CGN     >'TEMPS CPU POUR LIRE LES CARACTERISTIQUES DES FAMILLES  :',
CGN     >TPS2(4)
C
C====
C 5. CREATION DES VECTEURS DE NOMS DE GROUPNO + GROUPMA
C====
C
CGN      CALL UTTCPU(2,'DEBUT',4,TPS2)
C
      CALL LRMMF4 ( NBRFAM, ZI(ADCARF), NBNOEU, NBMAIL,
     &              NOMGRO, NUMGRO, NUMENT,
     &              GRPNOE, GRPMAI, NBGRNO, NBGRMA,
     &              INFMED, NIVINF, IFM )
C
CGN      CALL UTTCPU(2,'FIN',4,TPS2)
CGN      WRITE (IFM,*)
CGN     >'TEMPS CPU POUR CREER LES GROUPES  :',TPS2(4)
C
C====
C 6. LA FIN
C====
C
      CALL JEDETC ('V','&&'//NOMPRO,1)
C
      ENDIF
C
      CALL JEDEMA ( )
C
      IF ( NIVINF.GE.2 ) THEN
C
        WRITE (IFM,6001) NOMPRO
 6001 FORMAT(/,'FIN DU PROGRAMME ',A,/,60('='))
C
      ENDIF
C
CGN      CALL UTTCPU(1,'FIN',4,TPS1)
CGN      WRITE (IFM,*) '==> DUREE TOTALE DE ',NOMPRO,' :',TPS1(4)
C
      END
