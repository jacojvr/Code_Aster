      SUBROUTINE XMMAB3(NDIM  ,NNO   ,NNOS  ,NNOL ,NNOF, PLA,
     &                    IPGF,IVFF  ,FFC   ,FFP ,JAC   ,KNP,
     &                    NFH   ,NOEUD ,SEUIL,COEFEF,TAU1,TAU2,MU,
     &                    SINGU ,RR    ,IFA,CFACE,LACT,DDLS  ,DDLM  ,
     &                    LPENAF,MMAT )
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/06/2011   AUTEUR MASSIN P.MASSIN 
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
C
C TOLE CRP_21
      IMPLICIT NONE
      INTEGER     NDIM,NNO,NNOS,NNOL,NNOF,IVFF,IPGF
      INTEGER     NFH,DDLS,DDLM,CFACE(5,3),IFA
      INTEGER     SINGU,PLA(27),LACT(8)
      REAL*8      MMAT(216,216)
      REAL*8      FFC(8),FFP(27),JAC,TAU1(3),TAU2(3)
      REAL*8      RR,SEUIL,KNP(3,3),MU,COEFEF
      LOGICAL     NOEUD,LPENAF
C ROUTINE CONTACT (METHODE XFEM HPP - CALCUL ELEM.)
C
C --- CALCUL DE B, BT
C
C ----------------------------------------------------------------------
C
C IN  NDIM   : DIMENSION DE L'ESPACE
C IN  NNO    : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C IN  NNOS   : NOMBRE DE NOEUDS SOMMET DE L'ELEMENT DE REF PARENT
C IN  NNOL   : NOMBRE DE NOEUDS PORTEURS DE DDLC
C IN  NNOF   : NOMBRE DE NOEUDS DE LA FACETTE DE CONTACT
C IN  PLA    : PLACE DES LAMBDAS DANS LA MATRICE
C IN  IPGF   : NUM�RO DU POINTS DE GAUSS
C IN  IVFF   : ADRESSE DANS ZR DU TABLEAU FF(INO,IPG)
C IN  FFC    : FONCTIONS DE FORME DE L'ELEMENT DE CONTACT
C IN  FFP    : FONCTIONS DE FORME DE L'ELEMENT PARENT
C IN  JAC    : PRODUIT DU JACOBIEN ET DU POIDS
C IN  KNP    : PRODUIT KN.P
C IN  NFH    : NOMBRE DE FONCTIONS HEAVYSIDE
C IN  NOEUD  : INDICATEUR FORMULATION (T=NOEUDS , F=ARETE)
C IN  SEUIL  : SEUIL
C IN  TAU1   : TANGENTE A LA FACETTE AU POINT DE GAUSS
C IN  TAU2   : TANGENTE A LA FACETTE AU POINT DE GAUSS
C IN  MU     : COEFFICIENT DE COULOMB
C IN  SINGU  : 1 SI ELEMENT SINGULIER, 0 SINON
C IN  RR     : DISTANCE AU FOND DE FISSURE
C IN  IFA    : INDICE DE LA FACETTE COURANTE
C IN  CFACE  : CONNECTIVIT� DES NOEUDS DES FACETTES
C IN  LACT   : LISTE DES LAGRANGES ACTIFS
C IN  DDLS   : NOMBRE DE DDL (DEPL+CONTACT) � CHAQUE NOEUD SOMMET
C IN  DDLM   : NOMBRE DE DDL A CHAQUE NOEUD MILIEU
C IN  LPENAF : INDICATEUR DE PENALISATION DU FROTTEMENT
C I/O MMAT   : MATRICE ELEMENTAITRE DE CONTACT/FROTTEMENT
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
C
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

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      INTEGER I,J,K,L,JN,NLI,PLI
      REAL*8  FFI,TAUKNP(2,3)
C
C ----------------------------------------------------------------------


C     INITIALISATION
      CALL MATINI(2,3,0.D0,TAUKNP)

C     II.3.1. CALCUL DE B ET DE BT

      DO 160 I = 1,NNOL
        PLI=PLA(I)
        IF (NOEUD) THEN
          FFI=FFC(I)
          NLI=LACT(I)
          IF (NLI.EQ.0) GOTO 160
        ELSE
          FFI=ZR(IVFF-1+NNOF*(IPGF-1)+I)
          NLI=CFACE(IFA,I)
        ENDIF

C     CALCUL DE TAU.KN.P
      DO 161 J = 1,NDIM
        TAUKNP(1,J) = 0.D0
        DO 162 K = 1,NDIM
          TAUKNP(1,J) = TAUKNP(1,J) + TAU1(K) * KNP(K,J)
 162    CONTINUE
 161  CONTINUE

      IF (NDIM.EQ.3) THEN
        DO 163 J = 1,NDIM
          TAUKNP(2,J) = 0.D0
          DO 164 K = 1,NDIM
            TAUKNP(2,J) = TAUKNP(2,J) + TAU2(K) * KNP(K,J)
 164      CONTINUE
 163    CONTINUE
      ENDIF

      DO 165 J = 1,NNO
        CALL INDENT(J,DDLS,DDLM,NNOS,JN)
        DO 166 K = 1,NDIM-1
          DO 167 L = 1,NFH*NDIM
            MMAT(PLI+K,JN+NDIM+L) =
     &      MMAT(PLI+K,JN+NDIM+L) +
     &      2.D0*MU*SEUIL*FFI*FFP(J)*TAUKNP(K,L)*JAC*COEFEF

            IF(.NOT.LPENAF)THEN
              MMAT(JN+NDIM+L,PLI+K) =
     &        MMAT(JN+NDIM+L,PLI+K) +
     &        2.D0*MU*SEUIL*FFI*FFP(J)*TAUKNP(K,L)*JAC*COEFEF
            ENDIF
C
 167      CONTINUE
C
          DO 168 L = 1,SINGU*NDIM
C
            MMAT(PLI+K,JN+NDIM*(1+NFH)+L) =
     &      MMAT(PLI+K,JN+NDIM*(1+NFH)+L) +
     &      2.D0*RR*MU*SEUIL*FFI*FFP(J)*TAUKNP(K,L)*JAC*COEFEF
C
            IF(.NOT.LPENAF)THEN
              MMAT(JN+NDIM*(1+NFH)+L,PLI+K) =
     &        MMAT(JN+NDIM*(1+NFH)+L,PLI+K) +
     &        2.D0*RR*MU*SEUIL*FFI*FFP(J)*TAUKNP(K,L)*JAC*COEFEF
            ENDIF
C
 168      CONTINUE
 166    CONTINUE
 165  CONTINUE
 160  CONTINUE

      END
