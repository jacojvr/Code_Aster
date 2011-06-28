      SUBROUTINE XTEDDL(NDIM,NFH,NFE,DDLS,NDDL,NNO,NNOS,STANO,
     &                  LCONTX,MATSYM,OPTION,NOMTE,
     &                  MAT,VECT,DDLM,NFISS,JFISNO)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 27/06/2011   AUTEUR MASSIN P.MASSIN 
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
C TOLE CRS_1404

      IMPLICIT NONE
      INTEGER      NDIM,NFH,NFE,DDLS,NDDL,NNO,NNOS,STANO(*)
      LOGICAL      MATSYM,LCONTX
      CHARACTER*16 OPTION,NOMTE
      REAL*8       MAT(*),VECT(*)
      INTEGER      DDLM,NFISS,JFISNO
C     BUT: SUPPRIMER LES DDLS "EN TROP" (VOIR BOOK III 09/06/04
C                                         ET  BOOK IV  30/07/07)

C IN   NDIM   : DIMENSION DE L'ESPACE
C OUT  NFH    : NOMBRE DE FONCTIONS HEAVYSIDE
C OUT  NFE    : NOMBRE DE FONCTIONS SINGULI�RES D'ENRICHISSEMENT
C IN   DDLS   : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C IN   NDDL   : NOMBRE DE DDL TOTAL DE L'�L�MENT
C IN   NNO    : NOMBRE DE NOEUDS DE L'ELEMENT PORTANT DES DDLS DE DEPL
C IN   NNOS   : NOMBRE DE NOEUDS SOMMENT DE L'ELEMENT
C IN   STANO  : STATUT DES NOEUDS
C IN   LCONTX : ON S'OCCUPE DES DDLS DE CONTACT
C IN   MATSYM : STOCKAGE DE LA MATRICE SYM�TRIQUE ?
C IN   OPTION : OPTION DE CALCUL DU TE
C IN   NOMTE  : NOM DU TYPE ELEMENT
C IN   NFISS  : NOMBRE DE FISSURES "VUES" PAR L'�L�MENT
C IN   JFISNO : POINTEUR DE CONNECTIVIT� FISSURE/HEAVISIDE

C IN/OUT :   MAT   : MATRICE DE RIGIDIT�
C IN/OUT :   VECT  : VECTEUR SECOND MEMBRE
C
C IN   DDLM   : NOMBRE DE DDL (DEPL+CONTACT) A CHAQUE NOEUD MILIEU

C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
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
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------
C-----------------------------------------------------------------------
C---------------- DECLARATION DES VARIABLES LOCALES  -------------------

       INTEGER      JPOS,IER,ISTATU,INO,K,I,J,IELIM,IN
       INTEGER      IFH,FISNO(NNO,NFISS)
       CHARACTER*8  TYENEL
       CHARACTER*19 POSDDL
       LOGICAL      LELIM,LMULTC
       REAL*8       R8MAEM,DMAX,DMIN,CODIA
C
C-------------------------------------------------------------

      CALL JEMARQ()
C
C --- CONECTIVIT� DES FISSURE ET DES DDL HEAVISIDES
C
      IF (NFISS.EQ.1) THEN
        DO 300 INO = 1, NNO
          FISNO(INO,1) = 1
 300    CONTINUE
      ELSE
        DO 310 IFH = 1, NFH
          DO 320 INO = 1, NNO
            FISNO(INO,IFH) = ZI(JFISNO-1+(INO-1)*NFH+IFH)
 320      CONTINUE
 310    CONTINUE
      ENDIF
C     TYPE D'ENRICHISSEMENT DE L'ELEMENT ET TYPE D'ELIMINATION
      CALL TEATTR (NOMTE,'S','XFEM',TYENEL,IER)
       IF (TYENEL(1:2).EQ.'XH') IELIM=1
       IF (TYENEL(1:2).EQ.'XT') IELIM=2
       IF (TYENEL(1:3).EQ.'XHT') IELIM=3
      IF (LCONTX) IELIM=4
C     APPROCHE (HIX, HIY, HIZ) <-> (LAGI_C,LAGI_F1,LAGI_F2) POUR MULTI-H
      IF (NFISS.GT.1.AND.TYENEL(4:4).EQ.'C') THEN
        LMULTC = .TRUE.
      ELSE
        LMULTC = .FALSE.
      ENDIF

C     REMPLISSAGE DU VECTEUR POS : POSITION DES DDLS A SUPPRIMER
      POSDDL = '&&XTEDDL.POSDDL'
      CALL WKVECT(POSDDL,'V V I',NDDL,JPOS)

C     VRAI SI ON ELIMINE LES DDLS D'AU MOINS UN NOEUD
      LELIM=.FALSE.

      DO 100 INO = 1,NNO
        CALL INDENT(INO,DDLS,DDLM,NNOS,IN)
C       ENRICHISSEMENT DU NOEUD
        IF (IELIM.EQ.1) THEN

C         1) CAS DES MAILLES 'ROND'
C         -------------------------

C         PB DE STATUT DES NOEUDS ENRICHIS
          DO 330 IFH = 1,NFH
            ISTATU = STANO((INO-1)*NFISS+FISNO(INO,IFH))
            CALL ASSERT(ISTATU.LE.1)
            IF (ISTATU.EQ.0) THEN
C           ON SUPPRIME LES DDL H
              DO 10 K = 1,NDIM
                ZI(JPOS-1+IN+NDIM*IFH+K)=1
C           ON SUPPRIME LES DDL C SI MULTI-HEAVISIDE AVEC CONTACT
                IF (LMULTC) ZI(JPOS-1+IN+NDIM*(NFH+IFH)+K)=1
   10         CONTINUE
              LELIM=.TRUE.
            ENDIF
 330      CONTINUE
        ELSEIF (IELIM.EQ.2) THEN

C         2) CAS DES MAILLES 'CARR�'
C         --------------------------

C         PB DE STATUT DES NOEUDS ENRICHIS
          ISTATU = STANO(INO)
          CALL ASSERT(ISTATU.LE.2 .AND. ISTATU.NE.1)
          IF (ISTATU.EQ.2) THEN
C           ON NE SUPPRIME AUCUN DDL
          ELSE IF (ISTATU.EQ.0) THEN
C           ON SUPPRIME LES DDL E
            DO 20 K = 1,NFE*NDIM
              ZI(JPOS-1+IN+NDIM*(1+NFH)+K)=1
   20       CONTINUE
            LELIM=.TRUE.
          END IF

        ELSEIF (IELIM.EQ.3) THEN

C         3) CAS DES MAILLES 'ROND-CARR�'
C         ------------------------------

C         PB DE STATUT DES NOEUDS ENRICHIS
          ISTATU = STANO(INO)
          CALL ASSERT(ISTATU.LE.3)
          IF (ISTATU.EQ.3) THEN
C           ON NE SUPPRIME AUCUN DDL
          ELSE IF (ISTATU.EQ.2) THEN
C           ON SUPPRIME LES DDL H
            DO 30 K = 1,NDIM
              ZI(JPOS-1+IN+NDIM+K)=1
   30       CONTINUE
            LELIM=.TRUE.
          ELSE IF (ISTATU.EQ.1) THEN
C           ON SUPPRIME LES DDL E
            DO 40 K = 1,NFE*NDIM
              ZI(JPOS-1+IN+NDIM*(1+NFH)+K)=1
   40       CONTINUE
            LELIM=.TRUE.
          ELSE IF (ISTATU.EQ.0) THEN
C           ON SUPPRIME LES DDLS H ET E
            DO 50 K = 1,NDIM
              ZI(JPOS-1+IN+NDIM+K)=1
   50       CONTINUE
            DO 60 K = 1,NFE*NDIM
              ZI(JPOS-1+IN+NDIM*(1+NFH)+K)=1
   60       CONTINUE
            LELIM=.TRUE.
          END IF

        ELSEIF (IELIM.EQ.4) THEN
C         4) CAS DU CONTACT
C         ------------------------------
          IF (INO.LE.NNOS) THEN

            DO 80 IFH = 1,MAX(1,NFH)
              ISTATU = STANO((INO-1)*MAX(1,NFH)+IFH)
              IF (ISTATU.EQ.0) THEN
C             ON SUPPRIME LES DDLS LAGS_C, LAGS_F1 ET LAGS_F2
                DO 70 K = 1,NDIM
                  ZI(JPOS-1+IN+NDIM*(NFH+NFE+IFH)+K)=1
   70           CONTINUE
                LELIM=.TRUE.
              ENDIF
  80        CONTINUE
          ENDIF
        ENDIF

 100  CONTINUE

      IF (LELIM) THEN

C     POUR LES OPTIONS CONCERNANT DES MATRICES :
C        CALCUL DU COEFFICIENT DIAGONAL POUR
C        L'ELIMINATION DES DDLS HEAVISIDE
        IF (OPTION(1:10).EQ.'RIGI_MECA_' .OR.
     &           OPTION.EQ.'RIGI_MECA'   .OR.
     &           OPTION.EQ.'FULL_MECA'   .OR.
     &           OPTION.EQ.'RIGI_CONT'   .OR.
     &           OPTION.EQ.'RIGI_FROT'   .OR.
     &           OPTION.EQ.'MASS_MECA') THEN
          DMIN=R8MAEM()
          DMAX=-R8MAEM()
          DO 110 I = 1,NDDL
            IF(MATSYM) THEN
               CODIA=MAT((I-1)*I/2+I)
            ELSE
               CODIA=MAT((I-1)*NDDL+I)
            ENDIF
            IF (CODIA.GT.DMAX) THEN
              DMAX=CODIA
            ELSE IF (CODIA.LT.DMIN) THEN
              DMIN=CODIA
            ENDIF
 110      CONTINUE
          CODIA=(DMAX+DMIN)/2.0D0
          IF (CODIA.EQ.0) CODIA = 1
        ENDIF

C     POUR LES OPTIONS CONCERNANT DES MATRICES :
C        MISE A ZERO DES TERMES HORS DIAGONAUX (I,J)
C        ET MISE A UN DES TERMES DIAGONAUX (I,I)
C        (ATTENTION AU STOCKAGE SYMETRIQUE)
C     POUR LES OPTIONS CONCERNANT DES VECTEURS :
C        MISE A ZERO DES TERMES I

        DO 200 I = 1,NDDL
          IF (ZI(JPOS-1+I).EQ.0) GOTO 200
          IF (OPTION(1:10).EQ.'RIGI_MECA_' .OR.
     &             OPTION.EQ.'RIGI_MECA'   .OR.
     &             OPTION.EQ.'FULL_MECA'   .OR.
     &             OPTION.EQ.'RIGI_CONT'   .OR.
     &             OPTION.EQ.'RIGI_FROT'   .OR.
     &             OPTION.EQ.'MASS_MECA') THEN
            DO 210 J = 1,NDDL
             IF(MATSYM) THEN
              IF (J.LT.I)  MAT((I-1)*I/2+J) = 0.D0
              IF (J.EQ.I)  MAT((I-1)*I/2+J) = CODIA
              IF (J.GT.I)  MAT((J-1)*J/2+I) = 0.D0
             ELSE
              IF (J.NE.I)  MAT((I-1)*NDDL+J) = 0.D0
              IF (J.NE.I)  MAT((J-1)*NDDL+I) = 0.D0
              IF (J.EQ.I)  MAT((I-1)*NDDL+J) = CODIA
             ENDIF
 210        CONTINUE
          ENDIF
          IF (OPTION.EQ.'RAPH_MECA' .OR.
     &        OPTION.EQ.'FULL_MECA' .OR.
     &        OPTION.EQ.'FORC_NODA' .OR.
     &        OPTION.EQ.'CHAR_MECA_PRES_R' .OR.
     &        OPTION.EQ.'CHAR_MECA_PRES_F' .OR.
     &        OPTION.EQ.'CHAR_MECA_FR2D3D' .OR.
     &        OPTION.EQ.'CHAR_MECA_FR1D2D' .OR.
     &        OPTION.EQ.'CHAR_MECA_FF2D3D' .OR.
     &        OPTION.EQ.'CHAR_MECA_FF1D2D' .OR.
     &        OPTION.EQ.'CHAR_MECA_CONT' .OR.
     &        OPTION.EQ.'CHAR_MECA_FROT' .OR.
     &        OPTION.EQ.'CHAR_MECA_FR3D3D' .OR.
     &        OPTION.EQ.'CHAR_MECA_FR2D2D' .OR.
     &        OPTION.EQ.'CHAR_MECA_FF3D3D' .OR.
     &        OPTION.EQ.'CHAR_MECA_FF2D2D' .OR.
     &        OPTION.EQ.'CHAR_MECA_PESA_R' .OR.
     &        OPTION.EQ.'CHAR_MECA_ROTA_R'     ) VECT(I) = 0.D0
 200    CONTINUE

      ENDIF

      CALL JEDETR(POSDDL)

      CALL JEDEMA()
      END
