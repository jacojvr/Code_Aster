      SUBROUTINE IRGMSH ( NOMCON,
     &                    PARTIE, IFI, NBCHAM, CHAM, LRESU,
     &                    NBORDR, ORDR, NBCMP, NOMCMP, NBMAT, NUMMAI,
     &                    VERSIO, LGMSH, TYCHA )
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER           IFI, NBCHAM, NBORDR, NBCMP, ORDR(*), NBMAT,
     &                  NUMMAI(*),VERSIO
      LOGICAL           LRESU,LGMSH
      CHARACTER*(*)     NOMCON
      CHARACTER*(*)     CHAM(*),NOMCMP(*),PARTIE
      CHARACTER*8       TYCHA
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 25/06/2012   AUTEUR ABBAS M.ABBAS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
C     BUT: ECRITURE D'UN CHAMP OU D'UN CONCEPT RESULTAT AU FORMAT GMSH
C
C     ENTREE:
C     NOMCON : K8  : NOM DU CONCEPT A IMPRIMER
C     PARTIE : K4  : IMPRESSION DE LA PARTIE COMPLEXE OU REELLE DU CHAMP
C     IFI    : I   : NUMERO D'UNITE LOGIQUE DU FICHIER GMSH
C     NBCHAM : I   : NOMBRE DE CHAMP DANS LE TABLEAU CHAM
C     CHAM   : K16 : NOM DES CHAMPS SYMBOLIQUES A IMPRIMER (EX 'DEPL',
C     LRESU  : L   : INDIQUE SI NOMCON EST UN CHAMP OU UN RESULTAT
C     NBORDR : I   : NOMBRE DE NUMEROS D'ORDRE DANS LE TABLEAU ORDR
C     ORDR   : I   : LISTE DES NUMEROS D'ORDRE A IMPRIMER
C     NBCMP  : I   : NOMBRE DE COMPOSANTES A IMPRIMER
C     NOMCMP : K*  : NOMS DES COMPOSANTES A IMPRIMER
C     NBMAT  : I   : NOMBRE DE MAILLES A IMPRIMER
C     NUMMAI : I   : NUMEROS DES MAILLES A IMPRIMER
C     VERSIO : I   : =1 SI TOUTES LES MAILLES SONT DES TRIA3 OU DES TET4
C                    =2 SINON ( LES MAILLLES SONT LINEAIRES)
C     TYCHA  : K8  : TYPE DE CHAMP A IMPRIMER (VERSION >= 1.2)
C                    = SCALAIRE/VECT_2D/VECT_3D/TENS_2D/TENS_3D
C
C     ------------------------------------------------------------------
      INTEGER       IOR, ICH, IRET, IBID, IERD, NBMA, I
      INTEGER      TYPPOI, TYPSEG, TYPTRI, TYPTET, TYPQUA,
     &             TYPPYR, TYPPRI, TYPHEX
      INTEGER       JCOOR, JCONX, JPOIN, JPARA, IAD
      CHARACTER*8   TYCH, NOMA, K8B, NOMAOU,VALK(2)
      CHARACTER*16  VALK2(2)
      CHARACTER*19  NOCH19,NOCO19
C
C     --- TABLEAU DE DECOUPAGE
      INTEGER    NTYELE
      PARAMETER (NTYELE = 28)
C     NBRE, NOM D'OBJET POUR CHAQUE TYPE D'ELEMENT
      INTEGER      NBEL(NTYELE)
      CHARACTER*24 NOBJ(NTYELE)
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- RECUPERATION DU MAILLAGE, NB_MAILLE, ...
C
      IF ( LRESU ) THEN
         DO 30 IOR = 1 , NBORDR
            DO 32 ICH = 1 , NBCHAM
               CALL RSEXCH(NOMCON,CHAM(ICH),ORDR(IOR),NOCH19,IRET)
               IF ( IRET .EQ. 0 ) GOTO 34
 32         CONTINUE
 30      CONTINUE
         CALL U2MESS('A','PREPOST2_59')
         GOTO 9999
 34      CONTINUE
      ELSE
         NOCH19 = NOMCON
      ENDIF
      CALL DISMOI ('F','NOM_MAILLA'  ,NOCH19,'CHAMP',IBID,NOMA,IERD)
      CALL DISMOI ('F','NB_MA_MAILLA',NOMA,'MAILLAGE',NBMA,K8B ,IERD)
C
C --- ECRITURE DE L'ENTETE DU FICHIER AU FORMAT GMSH
C
      IF (.NOT.LGMSH) THEN
          CALL IRGMPF ( IFI, VERSIO )
          LGMSH = .TRUE.
      ENDIF
C
C --- RECUPERATION DES INSTANTS, FREQUENCES, ...
C
      CALL WKVECT ( '&&IRGMSH.PARA' , 'V V R', MAX(1,NBORDR), JPARA  )
      IF ( LRESU ) THEN
         NOCO19=NOMCON

C        -- DANS UN EVOL_NOLI, IL PEUT EXISTER INST ET FREQ.
C           ON PREFERE INST :
         CALL JENONU(JEXNOM(NOCO19//'.NOVA','INST'),IRET)
         IF ( IRET .NE. 0 ) THEN
            DO 20 IOR = 1 , NBORDR
               CALL RSADPA(NOMCON,'L',1,'INST',ORDR(IOR),0,IAD,K8B)
               ZR(JPARA+IOR-1) = ZR(IAD)
 20         CONTINUE
         ELSE
           CALL JENONU(JEXNOM(NOCO19//'.NOVA','FREQ'),IRET)
         IF ( IRET .NE. 0 ) THEN
            DO 22 IOR = 1 , NBORDR
               CALL RSADPA(NOMCON,'L',1,'FREQ',ORDR(IOR),0,IAD,K8B)
               ZR(JPARA+IOR-1) = ZR(IAD)
 22         CONTINUE
         ENDIF
         ENDIF
      ELSE
         ZR(JPARA) = 0.D0
      ENDIF
C
C --- TRANSFORMATION DU MAILLAGE EN MAILLAGE SUPPORTE PAR GMSH
C
C --- INIT
      DO 101 I=1,NTYELE
         NBEL(I) = 0
         NOBJ(I) = ' '
 101  CONTINUE
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'POI1'   ), TYPPOI )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'SEG2'   ), TYPSEG )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'TRIA3'  ), TYPTRI )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'QUAD4'  ), TYPQUA )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'TETRA4' ), TYPTET )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'PYRAM5' ), TYPPYR )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'PENTA6' ), TYPPRI )
      CALL JENONU ( JEXNOM('&CATA.TM.NOMTM', 'HEXA8' ) , TYPHEX )
      NOBJ(TYPPOI) = '&&IRGMSH_POI'
      NOBJ(TYPSEG) = '&&IRGMSH_SEG'
      NOBJ(TYPTRI) = '&&IRGMSH_TRI'
      NOBJ(TYPQUA) = '&&IRGMSH_QUA'
      NOBJ(TYPTET) = '&&IRGMSH_TET'
      NOBJ(TYPPYR) = '&&IRGMSH_PYR'
      NOBJ(TYPPRI) = '&&IRGMSH_PRI'
      NOBJ(TYPHEX) = '&&IRGMSH_HEX'
C
      NOMAOU = '&&MAILLA'
      CALL IRGMMA(NOMA, NOMAOU, NBMAT, NUMMAI, 'V', NOBJ, NBEL, VERSIO)
C
      CALL JEVEUO(NOMAOU//'.COORDO    .VALE'        ,'L',JCOOR)
      CALL JEVEUO(NOMAOU//'.CONNEX'                 ,'L',JCONX)
      CALL JEVEUO(JEXATR(NOMAOU//'.CONNEX','LONCUM'),'L',JPOIN)
C
C
C --- BOUCLE SUR LE NOMBRE DE CHAMPS A IMPRIMER
C
      DO 10 ICH = 1 , NBCHAM
C
         IF( LRESU ) THEN
C        --VERIFICATION DE L'EXISTENCE DU CHAMP CHAM(ICH) DANS LA
C          SD RESULTAT NOMCON POUR LE NO. D'ORDRE ORDR(1)
C          ET RECUPERATION DANS NOCH19 DU NOM SI LE CHAM_GD EXISTE
           CALL RSEXCH(NOMCON,CHAM(ICH),ORDR(1),NOCH19,IRET)
           IF ( IRET .NE. 0 ) GOTO 10
         ELSE
           NOCH19 = NOMCON
         ENDIF
C
C ------ RECHERCHE DU TYPE DU CHAMP (CHAM_NO OU CHAM_ELEM)
C
         CALL DISMOI('F','TYPE_CHAMP',NOCH19,'CHAMP',IBID,TYCH,IERD)
C
C ------ TRAITEMENT DU CAS CHAM_NO:
C
         IF (TYCH(1:4).EQ.'NOEU' ) THEN
            CALL IRGMCN ( CHAM(ICH), PARTIE, IFI,
     &                    NOMCON,
     &                    ORDR,NBORDR,
     &                    ZR(JCOOR), ZI(JCONX), ZI(JPOIN), NOBJ, NBEL,
     &                    NBCMP, NOMCMP, LRESU, ZR(JPARA),
     &                    VERSIO, TYCHA )
C
C ------ TRAITEMENT DU CAS CHAM_ELEM AUX NOEUDS:
C
         ELSE IF (TYCH(1:4).EQ.'ELNO' ) THEN
            IF(TYCHA(1:4).EQ.'VECT')THEN
              VALK(1)=TYCHA
              VALK(2)=TYCH(1:4)
              CALL U2MESK('A','PREPOST6_35',2,VALK)
              TYCHA='SCALAIRE'
            ENDIF
            CALL IRGMCE ( CHAM(ICH), PARTIE, IFI,
     &                    NOMCON,
     &                    ORDR,NBORDR,
     &                    ZR(JCOOR), ZI(JCONX), ZI(JPOIN), NOBJ, NBEL,
     &                    NBCMP, NOMCMP, LRESU, ZR(JPARA),
     &                    NOMAOU, NOMA,
     &                    VERSIO, TYCHA )

C
C ------ TRAITEMENT DU CAS CHAM_ELEM AUX GAUSS:
C
         ELSE IF (TYCH(1:4).EQ.'ELGA' .OR.
     &            TYCH(1:4).EQ.'ELEM' ) THEN
            IF(TYCHA(1:4).EQ.'VECT'.OR.TYCHA(1:4).EQ.'TENS')THEN
              VALK(1)=TYCHA
              VALK(2)=TYCH(1:4)
              CALL U2MESK('A','PREPOST6_35',2,VALK)
            ENDIF
            CALL IRGMCG ( CHAM(ICH), PARTIE, IFI,
     &                    NOMCON,
     &                    ORDR,NBORDR,
     &                    ZR(JCOOR), ZI(JCONX), ZI(JPOIN), NOBJ, NBEL,
     &                    NBCMP, NOMCMP, LRESU, ZR(JPARA),
     &                    NOMAOU,VERSIO )
C
C ------ AUTRE: PAS D'IMPRESSION
C
         ELSE
            VALK2(1) = CHAM(ICH)
            VALK2(2) = TYCH
            CALL U2MESK('I','PREPOST2_60',2,VALK2)
         ENDIF
 10   CONTINUE
C
      DO 102 I=1,NTYELE
         IF(NOBJ(I).NE.' ') THEN
            CALL JEDETR(NOBJ(I))
         ENDIF
 102  CONTINUE
C
      CALL JEDETC ( 'V', NOMAOU, 1 )
      CALL JEDETC ( 'V', '&&IRGMSH', 1 )
C
 9999 CONTINUE
C
      CALL JEDEMA()
C
      END
