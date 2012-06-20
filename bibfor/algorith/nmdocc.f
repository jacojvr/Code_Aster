      SUBROUTINE NMDOCC(COMPOR,MODELE,NBMO1,MOCLEF,
     &                  NOMCMP,NCMPMA,MECA,NOMCMD)
C RESPONSABLE PROIX J-M.PROIX
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/06/2012   AUTEUR PROIX J-M.PROIX 
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
C     SAISIE ET STOCKAGE DES PARAMETRES LOCAUX DE COMPORTEMENT
C
C OUT COMPOR : CARTE DECRIVANT LES PARAMETRES K16 DU COMPORTEMENT
C IN MODELE  : LE MODELE
C IN NBMO1   : NOMBRE DE MOTS-CLES (1 OU 2) COMP_INCR / COMP_ELAS
C IN MOCLEF  : LISTE DES MOTS-CLES (COMP_INCR / COMP_ELAS)
C IN NCMPMA  : NOMBRE DE CMP DE LA GRANDEUR COMPOR
C IN NOMCMP  : NOMS DES CMP DE LA GRANDEUR COMPOR
C IN MECA    : COMMANDE MECANIQUE OU PAS
C IN NOMCMD  : NOMS DE LA COMMANDE
C ----------------------------------------------------------------------
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER ICMP,K,JMA,NBMA,IRET,I,IBID,N1,JVALV,NCMPMA,JNCMP
      INTEGER NBMO1,NBOCC,DIMAKI,DIMANV,NBKIT,NUMLC,NBVARI,ICPRI
      INTEGER NBVARZ,NUNIT,II,INV,IARG,INDIMP
C    DIMAKI = DIMENSION MAX DE LA LISTE DES RELATIONS KIT
      PARAMETER (DIMAKI=9)
C    DIMANV = DIMENSION MAX DE LA LISTE DU NOMBRE DE VAR INT EN THM
      PARAMETER (DIMANV=4)
      INTEGER NBNVI(DIMANV),NCOMEL,NVMETA,NT
      CHARACTER*8  NOMA,K8B,TYPMCL(2),NOMCMP(*),SDCOMP,TAVARI
      CHARACTER*16 TYMATG,MOCLEF(2),COMP,TXCP,DEFO,MOCLES(2)
      CHARACTER*16 TEXTE(2),COMCOD,LCOMEL(5),NOMKIT(DIMAKI)
      CHARACTER*16 NOMSUB,NOMCMD,COMCO2,CRIRUP
      CHARACTER*19 CES2,COMPOR
      CHARACTER*24 MESMAI,MODELE
      CHARACTER*128 NOMLIB
      INTEGER EXIST,GETEXM
      LOGICAL EXIPMF,MECA,ISZMAT

      SAVE INDIMP
      DATA INDIMP /1/

C ----------------------------------------------------------------------
      CALL JEMARQ()

      EXIPMF = .FALSE.
      ISZMAT = .FALSE.
      COMPOR = '&&NMDOCC.COMPOR'

      CALL DISMOI('F','NOM_MAILLA',MODELE(1:8),'MODELE',I,NOMA,IRET)

C ======================================================================
      IF (MECA) THEN
C        ON INITIALISE LA CARTE COMPOR AVEC 'ELAS' SUR TOUT LE MAILLAGE
         CES2='&&NMDOCC.CES2'
         CALL CRCMEL(NBMO1,MOCLEF,COMPOR,CES2,MODELE,NCMPMA,NOMCMP,NT)

C        SI COMP_ELAS ET COMP_INCR SONT ABSENTS (POUR CALC_G)
         IF (NT.EQ.0) THEN
            IF (NOMCMD(1:6) .EQ.'CALC_G') THEN
              GOTO 170
            ELSEIF (NOMCMD(1:9).EQ.'LIRE_RESU') THEN
C                       1234567890123456789
              COMPOR = '                   '
              GOTO 170
            ENDIF
         ENDIF
      ELSE
         CALL ALCART('V',COMPOR,NOMA,'COMPOR')
      ENDIF
C ======================================================================

      MOCLES(1) = 'GROUP_MA'
      MOCLES(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'
      MESMAI = '&&NMDOCC'//'.MES_MAILLES'
      TXCP='ANALYTIQUE'

C ======================================================================
C                       REMPLISSAGE DE LA CARTE COMPOR :
C --- ON STOCKE LE NOMBRE DE VARIABLES INTERNES PAR COMPORTEMENT
C ======================================================================

      CALL JEVEUO(COMPOR//'.NCMP','E',JNCMP)
      CALL JEVEUO(COMPOR//'.VALV','E',JVALV)
      DO 90 ICMP = 1,NCMPMA
        ZK8(JNCMP+ICMP-1) = NOMCMP(ICMP)
   90 CONTINUE

C     MOTS CLES FACTEUR
      DO 160 I = 1,NBMO1
        CALL GETFAC(MOCLEF(I),NBOCC)

C       NOMBRE D'OCCURRENCES
        DO 150 K = 1,NBOCC

          CALL GETVTX(MOCLEF(I),'RELATION',K,IARG,1,COMP,N1)
          NCOMEL=1
          LCOMEL(NCOMEL)=COMP

          CALL RELIEM(MODELE,NOMA,'NU_MAILLE',MOCLEF(I),K,2,MOCLES,
     &                TYPMCL,MESMAI,NBMA)
C         VERIFICATIONS DE LA COMPATIBILITE MODELE-COMPORTEMENT
C         AFFECTATION AUTOMATIQUE DE DEBORST LE CAS ECHEANT
          IF (MECA) THEN
            CALL LCCREE(NCOMEL, LCOMEL, COMCO2)
            CALL NMDOVM(MODELE,MESMAI,NBMA,CES2,COMCO2,COMP,TXCP)
          ENDIF

C         POUR COMPORTEMENTS KIT_
          CALL NMDOKI(MOCLEF(I),MODELE,COMP,K,DIMAKI,NBKIT,NOMKIT,
     &                NBNVI,NCOMEL,LCOMEL,NUMLC,NVMETA)

C         SAISIE ET VERIFICATION DU TYPE DE DEFORMATION UTILISEE
          CALL NMDOGD(MOCLEF(I),COMP,K,NCOMEL,LCOMEL,DEFO)

C         PRISE EN COMPTE DE DEBORST
          CALL NMDOCP(NCOMEL,LCOMEL,TXCP)
C         
C         APPEL A LCINFO POUR RECUPERER LE NOMBRE DE VARIABLES INTERNES
          CALL LCCREE(NCOMEL, LCOMEL, COMCOD)
          CALL LCINFO(COMCOD, NUMLC, NBVARI)
          
C         NOMS DES VARIABLES INTERNES
          IF (INDIMP.EQ.1) THEN
            CALL IMVARI(MOCLEF(I),K,NCOMEL, LCOMEL,COMCOD,NBVARI,TAVARI)
          ENDIF

C         CAS PARTICULIER DE META A INTEGRER DANS CATA_COMPORTEMENT.PY
          IF (COMP(1:4).EQ.'META') THEN
            IF (DEFO.EQ.'SIMO_MIEHE') NVMETA=NVMETA+1
            IF (DEFO.EQ.'GDEF_LOG') NVMETA=NVMETA+6
            NBVARI=NVMETA
          ENDIF

C         VERIF QUE DEFO EST POSSIBLE POUR COMP
          CALL LCTEST(COMCOD,'DEFORMATION',DEFO,IRET)
          IF (IRET.EQ.0) THEN
            TEXTE(1)=DEFO
            TEXTE(2)=COMP
            CALL U2MESG('F','COMPOR1_44',2,TEXTE,0,0,0,0.D0)
          ENDIF

C ======================================================================
C         CAS PARTICULIERS
          TYMATG=' '
          EXIST = GETEXM(MOCLEF(I),'TYPE_MATR_TANG')
          IF (EXIST .EQ. 1) THEN
            CALL GETVTX(MOCLEF(I),'TYPE_MATR_TANG',K,IARG,1,TYMATG,N1)
            IF (N1.GT.0) THEN
              IF (TYMATG.EQ.'TANGENTE_SECANTE') NBVARI=NBVARI+1
            ENDIF
          ENDIF
C         CAS PARTICULIER DE MONOCRISTAL
          IF (COMP(1:8).EQ.'MONOCRIS') THEN
            CALL GETVID(MOCLEF(I),'COMPOR',K,IARG,1,SDCOMP,N1)
            CALL JEVEUO(SDCOMP//'.CPRI','L',ICPRI)
            NBVARI=ZI(ICPRI-1+3)
            ZK16(JVALV-1+7) = SDCOMP
            IF (TXCP.EQ.'DEBORST') NBVARI=NBVARI+4
            IF ((DEFO.EQ.'SIMO_MIEHE').AND.(COMP.EQ.'MONOCRISTAL')) THEN
                  NBVARI=NBVARI+9+9
            ENDIF
          ELSEIF (COMP(1:8).EQ.'POLYCRIS') THEN
            CALL GETVID(MOCLEF(I),'COMPOR',K,IARG,1,SDCOMP,N1)
            CALL JEVEUO(SDCOMP//'.CPRI','L',ICPRI)
            NBVARI=ZI(ICPRI-1+3)
            ZK16(JVALV-1+7) = SDCOMP
            IF (TXCP.EQ.'DEBORST') NBVARI=NBVARI+4
          ENDIF
C
C         STOCKAGE DE VI SI POST_ITER='CRIT_RUPT' 
          IF (NOMCMD(1:6) .NE.'CALC_G') THEN
             IF (MOCLEF(I) .EQ. 'COMP_INCR') THEN
                CALL GETVTX(MOCLEF(I),'POST_ITER',K,IARG,1,CRIRUP,IRET)
                   IF (IRET.EQ.1) THEN
                       NBVARI=NBVARI+6
                   ENDIF
             ENDIF
          ENDIF 

          IF (COMP(1:8).EQ.'MULTIFIB') EXIPMF=.TRUE.
          IF (COMP(1:4).EQ.'ZMAT') THEN
            ISZMAT = .TRUE.
            CALL GETVIS(MOCLEF,'NB_VARI',K,IARG,1,NBVARZ,N1)
            NBVARI=NBVARZ+NBVARI
            CALL GETVIS(MOCLEF,'UNITE',K,IARG,1,NUNIT,N1)
            WRITE (ZK16(JVALV-1+7),'(I16)') NUNIT
          ENDIF
C         POUR COMPORTEMENT KIT_
          DO 140 II = 1,DIMAKI
            IF ((COMP(1:4).EQ.'KIT_') .OR. (COMP(1:4).EQ.'META')) THEN
              ZK16(JVALV-1+II+7) = NOMKIT(II)
            ELSE
              ZK16(JVALV-1+II+7) = '        '
            END IF
  140     CONTINUE
          IF ((COMP(1:5).EQ.'KIT_H').OR.(COMP(1:6).EQ.'KIT_TH')) THEN
            DO 180 INV = 1, DIMANV
              WRITE (ZK16(JVALV-1+7+DIMAKI+INV),'(I16)') NBNVI(INV)
 180        CONTINUE
          ENDIF
          IF (COMP.EQ.'KIT_DDI') THEN
            IF ((NOMKIT(1)(1:4).EQ.'GLRC').OR.
     &          (NOMKIT(2)(1:4).EQ.'GLRC')) THEN
              NBVARI=NBVARI+10
            ENDIF
          END IF

C         POUR LES COMPORTEMENTS UMAT
C         ON STOCKE LA LIB DANS KIT1-KIT8 (128 CARACTERES)
C         ET LA SUBROUTINE DANS KIT9
          IF (COMP(1:4).EQ.'UMAT') THEN
            CALL GETVIS(MOCLEF,'NB_VARI',K,IARG,1,NBVARZ,N1)
            NBVARI=NBVARZ+NBVARI
            CALL GETVTX(MOCLEF, 'LIBRAIRIE',K,IARG,1,NOMLIB,N1)
            CALL GETVTX(MOCLEF, 'NOM_ROUTINE',K,IARG,1,NOMSUB,N1)
            DO 30 II = 1,DIMAKI-1
              ZK16(JVALV-1+II+7) = NOMLIB(16*(II-1)+1:16*II)
  30        CONTINUE
            ZK16(JVALV-1+DIMAKI+7) = NOMSUB
          ENDIF
C         FIN DES CAS PARTICULIERS
C ======================================================================

C         REMPLISSAGE DES CMP

          ZK16(JVALV-1+1) = COMP
          WRITE (ZK16(JVALV-1+2),'(I16)') NBVARI
          ZK16(JVALV-1+3) = DEFO
          ZK16(JVALV-1+4) = MOCLEF(I)
          ZK16(JVALV-1+5) = TXCP
C         ON ECRIT NUMLC EN POSITION 6 (CMP XXX1)
          IF (COMP(1:8).NE.'MULTIFIB') THEN
            WRITE (ZK16(JVALV-1+6),'(I16)') NUMLC
          ENDIF

          IF (NBMA.NE.0) THEN
            CALL JEVEUO(MESMAI,'L',JMA)
            CALL NOCART(COMPOR,3,K8B,'NUM',NBMA,K8B,ZI(JMA),' ',NCMPMA)
            CALL JEDETR(MESMAI)
          ELSE
C -----   PAR DEFAUT C'EST TOUT='OUI'
            CALL NOCART(COMPOR,1,K8B,K8B,0,K8B,IBID,K8B,NCMPMA)
          END IF

  150   CONTINUE
  160 CONTINUE

C ======================================================================
C     SI MULTIFIBRE, ON FUSIONNE AVEC LA CARTE CREEE DANS AFFE_MATERIAU
C      / AFFE_COMPOR - RCCOMP.F
      IF (EXIPMF) THEN
        CALL NMDPMF(COMPOR)
      ENDIF
C ======================================================================
 170  CONTINUE
C
C     SI ZMAT, ON REINITIALISE LES ZASTER_HANDLER POUR FORCER
C     LA RELECTURE DES FICHIERS DECRIVANT LES COMPORTEMENTS
      IF (ISZMAT) THEN
        CALL ZASWRI()
      ENDIF

      CALL JEDETR(COMPOR//'.NCMP')
      CALL JEDETR(COMPOR//'.VALV')
C FIN ------------------------------------------------------------------
      INDIMP=1
      CALL JEDEMA()
      END
