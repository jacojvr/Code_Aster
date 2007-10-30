      SUBROUTINE LRCEME ( CHANOM, NOCHMD, TYPECH, NOMAMD,
     &                    NOMAAS, NOMMOD, NOMGD,
     &                    NBCMPV, NCMPVA, NCMPVM,
     &                    IINST, NUMPT, NUMORD, INST, CRIT, PREC,
     &                    NROFIC, LIGREL, OPTION, PARAM, CODRET )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 29/10/2007   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GNICOLAS G.NICOLAS
C TOLE CRP_21
C     LECTURE D'UN CHAMP AUX ELEMENTS - FORMAT MED
C     -    -       -         -               --
C-----------------------------------------------------------------------
C     ENTREES:
C        CHANOM : NOM ASTER DU CHAMP A LIRE
C        NOCHMD : NOM MED DU CHAMP DANS LE FICHIER
C        TYPECH : TYPE DE CHAMP AUX ELEMENTS : ELEM/ELGA/ELNO
C        NOMAMD : NOM MED DU MAILLAGE LIE AU CHAMP A LIRE
C                  SI ' ' : ON SUPPOSE QUE C'EST LE PREMIER MAILLAGE
C                           DU FICHIER
C        NOMAAS : NOM ASTER DU MAILLAGE
C        NOMMOD : NOM ASTER DU MODELE NECESSAIRE POUR LIGREL
C        NOMGD  : NOM DE LA GRANDEUR ASSOCIEE AU CHAMP
C        NBCMPV : NOMBRE DE COMPOSANTES VOULUES
C                 SI NUL, ON LIT LES COMPOSANTES A NOM IDENTIQUE
C        NCMPVA : LISTE DES COMPOSANTES VOULUES POUR ASTER
C        NCMPVM : LISTE DES COMPOSANTES VOULUES DANS MED
C        IINST  : 1 SI LA DEMANDE EST FAITE SUR UN INSTANT, 0 SINON
C        NUMPT  : NUMERO DE PAS DE TEMPS EVENTUEL
C        NUMORD : NUMERO D'ORDRE EVENTUEL DU CHAMP
C        INST   : INSTANT EVENTUEL
C        CRIT   : CRITERE SUR LA RECHERCHE DU BON INSTANT
C        PREC   : PRECISION SUR LA RECHERCHE DU BON INSTANT
C        NROFIC : NUMERO NROFIC LOGIQUE DU FICHIER MED
C        LIGREL : NOM DU LIGREL
C     SORTIES:
C        CODRET : CODE DE RETOUR (0 : PAS DE PB, NON NUL SI PB)
C_____________________________________________________________________
C
      IMPLICIT NONE
C
C 0.1. ==> ARGUMENTS
C
      CHARACTER*19 CHANOM,LIGREL
      CHARACTER*(*) NCMPVA, NCMPVM
      CHARACTER*8   NOMMOD, NOMAAS, NOMGD
      CHARACTER*4   TYPECH
      CHARACTER*8 CRIT, PARAM
      CHARACTER*24 OPTION
      CHARACTER*32  NOCHMD, NOMAMD
C
      INTEGER NROFIC
      INTEGER NBCMPV
      INTEGER IINST, NUMPT, NUMORD
      INTEGER CODRET
C
      REAL*8 INST
      REAL*8 PREC
C
C 0.2. ==> COMMUNS
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNOM,JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX --------------------------
C
C 0.3. ==> VARIABLES LOCALES
C
      CHARACTER*6 NOMPRO
      PARAMETER ( NOMPRO = 'LRCEME' )
C
      INTEGER IAUX, NAUX
      INTEGER NTYPEL,NPGMAX
      PARAMETER(NTYPEL=26,NPGMAX=27)
      INTEGER VALI(2),INDPG(NTYPEL,NPGMAX)
      INTEGER NBMAI, NBVATO,NBMA, JNBPGM
      INTEGER JCESD,JCESV,JCESL,JCESC,JCESK,IBID
      INTEGER JNOCMP, NCMPRF, JCMPVA, NBCMPA, IRET, I, J,NNCP
C
      CHARACTER*1  SAUX01
      CHARACTER*8  K8B
      CHARACTER*19 CHAMES
C
      LOGICAL      TTT
C
      CALL JEMARQ ( )
C
C====
C 0. TRAITEMENT PARTICULIER POUR LES CHAMPS ELGA
C====
C
C 0.1 ==> VERIFICATION DES LOCALISATIONS DES PG
C         CREATION DU TABLEAU DEFINISSANT LE NBRE DE PG PAR MAIL
C         CREATION D'UN TABLEAU DE CORRESPONDANCE ENTRE LES PG MED/ASTER
C
      DO 5 I=1,NTYPEL
          DO 6 J=1,NPGMAX
            INDPG(I,J)=0
 6        CONTINUE
 5    CONTINUE
      IF(TYPECH(1:4).EQ.'ELGA')THEN
        CALL DISMOI('F','NB_MA_MAILLA',NOMAAS,'MAILLAGE',NBMA,K8B,IRET)
        CALL WKVECT('&&LRCEME_NBPG_MAILLE','V V I',NBMA,JNBPGM)
        CALL LRMPGA(NROFIC,LIGREL,NOCHMD,NBMA,ZI(JNBPGM),
     &              NTYPEL,NPGMAX,INDPG,IINST,NUMPT, NUMORD,
     &              INST,CRIT, PREC, OPTION, PARAM)
      ENDIF


C====
C 1. ALLOCATION D'UN CHAM_ELEM_S  (CHAMES)
C====
C
C 1.1. ==> REPERAGE DES CARACTERISTIQUES DE CETTE GRANDEUR
C
      CALL JENONU ( JEXNOM ( '&CATA.GD.NOMGD', NOMGD ) , IAUX )
      IF ( IAUX.EQ.0 ) THEN
        CALL U2MESS('F','PREPOST3_21')
      ENDIF
      CALL JEVEUO ( JEXNOM ( '&CATA.GD.NOMCMP', NOMGD ) ,
     &              'L', JNOCMP )
      CALL JELIRA ( JEXNOM ( '&CATA.GD.NOMCMP', NOMGD ) ,
     &              'LONMAX', NCMPRF, SAUX01 )
C
C 1.2. ==> ALLOCATION DU CHAM_ELEM_S
C
C               1234567890123456789
      CHAMES = '&&      .CES.MED   '
      CHAMES(3:8) = NOMPRO
      LIGREL = NOMMOD//'.MODELE'
C
      CALL JEEXIN ( NCMPVA, IRET)
      IF (IRET.GT.0) THEN
        CALL JEVEUO ( NCMPVA, 'L', JCMPVA )
        CALL JELIRA ( NCMPVA, 'LONMAX',NBCMPA,K8B)
        IF (NOMGD(1:4).EQ.'VARI') THEN
          JNOCMP=JCMPVA
          NCMPRF=NBCMPA
        ELSEIF (NBCMPA.LE.NCMPRF) THEN
          DO 20 I=1,NBCMPA
             TTT=.FALSE.
             DO 30 J=1,NCMPRF
              IF (ZK8(JCMPVA+I-1).EQ.ZK8(JNOCMP+J-1)) TTT=.TRUE.
 30          CONTINUE
             IF (.NOT.TTT) THEN
                CALL U2MESS('F','PREPOST3_22')
             ENDIF
 20       CONTINUE
        ELSE
          CALL U2MESS('F','PREPOST3_23')
        ENDIF
      ENDIF
C
      IF (TYPECH(1:4).EQ.'ELGA')THEN
        CALL CESCRE ( 'V', CHAMES, TYPECH, NOMAAS, NOMGD, NCMPRF,
     &               ZK8(JNOCMP),ZI(JNBPGM),-1,-NCMPRF)
      ELSE
        CALL CESCRE ( 'V', CHAMES, TYPECH, NOMAAS, NOMGD, NCMPRF,
     &               ZK8(JNOCMP),-1,-1,-NCMPRF)
      ENDIF

C
      CALL JEVEUO ( CHAMES//'.CESK', 'L', JCESK )
      CALL JEVEUO ( CHAMES//'.CESD', 'L', JCESD )
      CALL JEVEUO ( CHAMES//'.CESC', 'L', JCESC )
      CALL JEVEUO ( CHAMES//'.CESV', 'E', JCESV )
      CALL JEVEUO ( CHAMES//'.CESL', 'E', JCESL )
C
C NBMAI: NOMBRE DE MAILLES DU MAILLAGE
      NBMAI = ZI(JCESD-1+1)
      NBVATO = NBMAI
C
C====
C 3. LECTURE POUR CHAQUE TYPE DE SUPPORT
C====
C
      CALL LRCAME ( NROFIC, NOCHMD, NOMAMD, NOMAAS,
     &              NBVATO, TYPECH,
     &              NBMA, ZI(JNBPGM), NTYPEL, NPGMAX, INDPG,
     &              NBCMPV, NCMPVA, NCMPVM,
     &              IINST, NUMPT, NUMORD, INST, CRIT, PREC,
     &              NOMGD, NCMPRF, JNOCMP, JCESL, JCESV, JCESD,
     &              CODRET )
C
C====
C 4. TRANSFORMATION DU CHAM_ELEM_S EN CHAM_ELEM :
C====
C
C
      CALL CESCEL ( CHAMES,LIGREL,' ',' ','OUI',NNCP,'V',CHANOM,'F',
     &              IBID)
      IF(NNCP.GT.0)THEN
         IAUX=0
         CALL JELIRA(CHAMES//'.CESL', 'LONMAX', NAUX, SAUX01)
         DO 40 I=1, NAUX
            IF(ZL(JCESL+I-1)) IAUX=IAUX+1
 40      CONTINUE
         VALI (1) = IAUX
         VALI (2) = NNCP
         CALL U2MESG('A', 'PREPOST5_42',0,' ',2,VALI,0,0.D0)
      ENDIF
C
      CALL DETRSD ( 'CHAM_ELEM_S', CHAMES )
C
C====
C 5. BILAN
C====
C
      IF ( CODRET.NE.0 ) THEN
         CALL U2MESK('A','PREPOST3_24',1,CHANOM)
      ENDIF

      IF(TYPECH(1:4).EQ.'ELGA')THEN
        CALL JEDETR('&&LRCEME_NBPG_MAILLE')
      ENDIF

      CALL JEDEMA ( )
C
      END
