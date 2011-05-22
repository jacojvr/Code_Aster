      SUBROUTINE GINISE(TABLE1,NBPASE,INPSCO,NORECG,MATE,NCHA,VCHAR,
     &                  NBPASS)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/05/2011   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE GENIAUT S.GENIAUT

      IMPLICIT NONE
      CHARACTER*8  TABLE1
      CHARACTER*13 INPSCO
      CHARACTER*19 VCHAR
      CHARACTER*24 NORECG,MATE
      INTEGER      NBPASS,NBPASE,NCHA
      
C ----------------------------------------------------------------------
C        OPERATEUR CALC_G
C                ROUTINE DE RECUPERATION DES PARAMETRES POUR UN
C                CALCUL DE SENSIBILITE                      
C
C IN TABLE1 : TABLE RESULTAT
C IN MATE   : CHAMP MATERIAU
C IN NCHA   : NOMBRE DE CHARGES 
C IN VCHAR  : NOM JEVEUX POUR STOCKER LES CHARGES 

C OUT NBPASE  : NOMBRE DE PARAMETRES DE SENSIBILITE
C OUT INPSCO  : STRUCTURE CONTENANT LA LISTE DES NOMS
C               VOIR LA DEFINITION DANS SEGICO
C OUT NORECG  : STRUCTURE QUI CONTIENT LES NBPASS COUPLES
C               (NOM COMPOSE, NOM DU PARAMETRE SENSIBLE)
C               ELLE N'EST PAS ALLOUEE EN ENTREE DE CE PROGRAMME ; ELLE
C               LE SERA EN SORTIE
C OUT NBPASS  : NOMBRE DE PASSAGES EN POST-TRAITEMENT

C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32    JEXATR
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      INTEGER   IAUX,JAUX,IRET,NRPASE,NBTYCH,ADCHSE,NEXCI,ICHAR,N1,ICHA
      INTEGER   IBID
      PARAMETER (NBTYCH=17)

      CHARACTER*5  SUFFIX
      CHARACTER*6  NOMPRO,NOMLIG(NBTYCH)
      CHARACTER*8  K8BID,MATERI,NOPASE,MATERS,TYPEPS(-2:NBTYCH),AFFCHA
      CHARACTER*24 MATES,CHARSE,NOMCHA,LIGRCH,LCHIN
      PARAMETER  ( NOMPRO = 'GINISE' )
      LOGICAL EXCHSE

      DATA NOMLIG/'.FORNO','.F3D3D','.F2D3D','.F1D3D','.F2D2D','.F1D2D',
     &     '.F1D1D','.PESAN','.ROTAT','.PRESS','.FELEC','.FCO3D',
     &     '.FCO2D','.EPSIN','.FLUX','.VEASS','.ONDPL'/
      DATA TYPEPS/'MATERIAU','CARAELEM','DIRICHLE','FORCE   ',
     &     'FORCE   ','FORCE   ','FORCE   ','FORCE   ','FORCE   ',
     &     'FORCE   ','.PESAN','.ROTAT','FORCE   ','.FELEC','FORCE   ',
     &     'FORCE   ','.EPSIN','.FLUX','.VEASS','.ONDPL'/

C
      CALL JEMARQ()

C     RECUPERATION DE NBPASE (NOMBRE DE PASSAGES)
C     POUR UN CALCUL STANDARD DE G, CE NOMBRE VAUT 1
      K8BID = '&&'//NOMPRO
      IAUX = 1
      CALL PSLECT(' ',0,K8BID,TABLE1,IAUX,NBPASE,INPSCO,IRET)
      IAUX = 1
      JAUX = 1
      CALL PSRESE(' ',0,IAUX,TABLE1,JAUX,NBPASS,NORECG,IRET)
C
C     A-T-ON UNE DEPENDANCE VIS-A-VIS D'UN MATERIAU ? (CF. NMDOME)
      DO 100 , NRPASE = 1 , NBPASE
C
        IAUX = NRPASE
        JAUX = 1
        MATERI = MATE(1:8)
        CALL PSNSLE (INPSCO,IAUX,JAUX,NOPASE)
        CALL PSGENC (MATERI,NOPASE,MATERS,IRET)
        IF (IRET.EQ.0) THEN
          CALL PSTYPA (NBPASE,INPSCO,MATERI,NOPASE,TYPEPS(-2) )
          CALL RCMFMC (MATERS,MATES)
        ENDIF
C
  100 CONTINUE
C
C     A-T-ON UNE DEPENDANCE VIS-A-VIS D'UNE CHARGE ? (CF. NMDOME)
C
      EXCHSE = .FALSE.
      IF (NCHA.NE.0.AND.NBPASE.NE.0) THEN
C
        CALL JEVEUO(VCHAR,'L',ICHA)

        CHARSE = '&&'//NOMPRO//'.CHARSE'
        IAUX = MAX(NBPASE,1)
        CALL WKVECT(CHARSE,'V V K8',IAUX,ADCHSE)
C
        CALL GETFAC('EXCIT',NEXCI)
C
        DO 200 , ICHAR = 1 , NCHA
C
C         LA CHARGE EST-ELLE CONCERNEE PAR UNE SENSIBILITE ?
C
          IF (NEXCI.GT.0) THEN
            CALL GETVID('EXCIT','CHARGE',ICHAR,1,1,NOMCHA,N1)
          ELSE
            NOMCHA = ZK8(ICHA+ICHAR-1)
          ENDIF

          DO 210 , NRPASE = 1 , NBPASE
            IAUX = NRPASE
            JAUX = 1
            CALL PSNSLE(INPSCO,IAUX,JAUX,NOPASE)
            CALL PSGENC(NOMCHA,NOPASE,K8BID,IRET)
            IF (IRET.EQ.0) THEN
              ZK8(ADCHSE+NRPASE-1) = NOPASE
              EXCHSE = .TRUE.
            ELSE
              ZK8(ADCHSE+NRPASE-1) = '        '
            ENDIF
 210      CONTINUE
C
 200    CONTINUE
C
C       SI LA CHARGE EST CONCERNEE, ON AFFINE
        IF (EXCHSE) THEN
C
          LIGRCH = NOMCHA(1:8)//'.CHME.LIGRE'
C
          DO 300 , IAUX = 1,NBTYCH
C
            IF (NOMLIG(IAUX).EQ.'.VEASS') THEN
              SUFFIX = '     '
            ELSE
              SUFFIX = '.DESC'
            ENDIF
            LCHIN = LIGRCH(1:13)//NOMLIG(IAUX)//SUFFIX
            CALL JEEXIN(LCHIN,IRET)
C
            IF (IRET.NE.0) THEN
C
              CALL DISMOI('F','TYPE_CHARGE',NOMCHA,'CHARGE',IBID,AFFCHA,
     &                    IRET)
C
              IF (AFFCHA(5:7).EQ.'_FO') THEN
                DO 310 , NRPASE = 1 , NBPASE
                  NOPASE = ZK8(ADCHSE+NRPASE-1)
                  IF (NOPASE.NE.'        ') THEN
                    CALL TELLME('F','NOM_FONCTION',LCHIN(1:19),NOPASE,
     &                                K8BID,IRET)
                    IF (K8BID.EQ.'OUI') THEN
                      CALL PSTYPA(NBPASE,INPSCO,NOMCHA,NOPASE,
     &                            TYPEPS(IAUX))
                    ENDIF
                  ENDIF
 310            CONTINUE
              ENDIF
C
            ENDIF
C
 300      CONTINUE
C
        ENDIF
C
      ENDIF

C-----------------------------------------------------------------------
C     FIN
C-----------------------------------------------------------------------

      CALL JEDEMA()
      END
