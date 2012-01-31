      SUBROUTINE XJACF2(ELREFP,ELREFC,ELC,NDIM,FPG,JINTER,IFA,CFACE,
     &           NPTF,IPG,NNO,IGEOM,JBASEC,G,CINEM,JAC,FFP,FFPC,DFDI,
     &           ND,TAU1)
      IMPLICIT NONE

      INTEGER       JINTER,IFA,CFACE(5,3),IPG,NNO,IGEOM,JBASEC,NPTF,NDIM
      REAL*8        JAC,FFP(27),FFPC(27),DFDI(27,3)
      REAL*8        ND(3),TAU1(3),G(3)
      CHARACTER*3   CINEM
      CHARACTER*8   ELREFP,FPG,ELC,ELREFC


C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 31/01/2012   AUTEUR REZETTE C.REZETTE 
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
C TOLE CRP_21
C
C                   CALCUL DU JACOBIEN DE LA TRANSFORMATION FACETTE
C                       R�ELLE EN 2D � FACETTE DE R�F�RENCE 1D
C                   ET DES FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C               ET DE LA NORMALE � LA FACETTE ORIENT�E DE ESCL -> MAIT
C     ENTREE
C       ELREFP  : TYPE DE L'ELEMENT DE REF PARENT
C       FPG     : FAMILLE DE POINTS DE GAUSS (SCHEMA D'INTEGRATION)
C       PINTER  : COORDONN�ES DES POINTS D'INTERSECTION
C       IFA     : INDINCE DE LA FACETTE COURANTE
C       CFACE   : CONNECTIVIT� DES NOEUDS DES FACETTES
C       IPG     : NUM�RO DU POINTS DE GAUSS
C       NNO     : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C       IGEOM   : COORDONNEES DES NOEUDS DE L'ELEMENT DE REF PARENT
C       CINEM   : CALCUL DES QUANTIT�S CIN�MATIQUES
C                'NON' : ON S'ARRETE APRES LE CALCUL DES FF
C                'DFF' : ON S'ARRETE APRES LE CALCUL DES DERIVEES DES FF
C                'OUI' : ON VA JUSQU'AU BOUT

C
C     SORTIE
C       G       : COORDONN�ES R�ELLES 2D DU POINT DE GAUSS
C       JAC     : PRODUIT DU JACOBIEN ET DU POIDS
C       FF      : FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C       ND      : NORMALE � LA FACETTE ORIENT�E DE ESCL -> MAIT
C                 AU POINT DE GAUSS
C       TAU1    : TANGENTE A LA FACETTE AU POINT DE GAUSS
C
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR ,DDOT
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
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      REAL*8          XG,A(3),B(3),AB(3),KSIG1,KSIG2(3),KSIB
      REAL*8          FF(27),SEG(3)
      REAL*8          GRLT(3),NORMAB,NORME,NORM2,PS
      INTEGER         NDIMF,NBNOMX,NNOC,NNOS,NN
      INTEGER         I,J,K,NNOF,IPOIDF,IVFF,IDFDEF
      LOGICAL         ISMALI,AXI,LTEATT
      CHARACTER*8     K8BID
      INTEGER         DDLH,NFE,DDLS,DDLM
      REAL*8          HE,FE(4),DGDGL(4,3)
      REAL*8          XE(3),F(3,3),DFDIC(27,3)
      REAL*8          EPS(6),GRAD(3,3)
      INTEGER         IBID,IBID2,IBID3,NPTFMX
      REAL*8          RBID,RBID2,RBID3,RBID4

      PARAMETER       (NBNOMX = 27, NPTFMX=4)
      REAL*8          COOR2D(NPTFMX*3),COOR1D(6)
C ----------------------------------------------------------------------

      CALL JEMARQ()

      CALL ELREF4(ELC,FPG,NDIMF,NNOF,IBID,IBID2,IPOIDF,IVFF,
     &               IDFDEF,IBID3)

      AXI = LTEATT(' ','AXIS','OUI')

      CALL ASSERT(NDIM.EQ.2)
      CALL ASSERT(NPTF.LE.NPTFMX)

C --- INITIALISATION
      CALL VECINI(3,0.D0,ND)
      CALL VECINI(3,0.D0,GRLT)
      CALL VECINI(3,0.D0,A)
      CALL VECINI(3,0.D0,B)
      CALL VECINI(3,0.D0,AB)
      CALL VECINI(3,0.D0,TAU1)
      CALL VECINI(3,0.D0,SEG)

C --- COORDONN�ES DES SOMMETS DE LA FACETTE DANS LE REPERE GLOBAL NDIM
      NN=3*NPTFMX
      DO 9 I=1,NN
         COOR2D(I)=0.D0
  9   CONTINUE
      DO 10 I=1,NPTF
        DO 11 J=1,NDIM
          COOR2D((I-1)*NDIM+J)=ZR(JINTER-1+NDIM*(CFACE(IFA,I)-1)+J)
 11     CONTINUE
 10   CONTINUE

      DO 20 J=1,NDIM
        A(J)=ZR(JINTER-1+NDIM*(CFACE(IFA,1)-1)+J)
        B(J)=ZR(JINTER-1+NDIM*(CFACE(IFA,2)-1)+J)
        AB(J)=B(J)-A(J)
 20   CONTINUE

C --- COORDONN�ES DES SOMMETS DE LA FACETTE DANS LE REP�RE
C     LIE A LA FACETTE
      IF (ISMALI(ELC)) THEN
C     EN LINEAIRE 2D
        CALL NORMEV(AB,NORMAB)
        COOR1D(1)=0.D0
        COOR1D(2)=0.D0
        COOR1D(3)=NORMAB
        COOR1D(4)=0.D0
        COOR1D(5)=0.D0
        COOR1D(6)=0.D0
        SEG(1)=0.D0
        SEG(2)=NORMAB
      ELSEIF (.NOT.ISMALI(ELC)) THEN
C     EN QUADRATIQUE 2D
        KSIB=1.D0
        CALL ABSCVF(NDIM,COOR2D,KSIB,NORMAB)
        COOR1D(1)=0.D0
        COOR1D(2)=0.D0
        COOR1D(3)=NORMAB
        COOR1D(4)=0.D0
        COOR1D(5)=NORMAB/2
        COOR1D(6)=0.D0
        SEG(1)=0.D0
        SEG(2)=NORMAB
        SEG(3)=NORMAB/2
      ENDIF

C --- CALCUL DE JAC EN 1D
      K = (IPG-1)*NNOF
      CALL DFDM1D(NNOF,ZR(IPOIDF-1+IPG),ZR(IDFDEF+K),COOR1D,RBID,
     &            RBID2,JAC,RBID3,RBID4)

C --- COORDONNEES REELLES 1D DU POINT DE GAUSS IPG (ABS CUR DE G)
      XG=0.D0
      DO 30 J=1,NNOF
         XG=XG+ZR(IVFF-1+NNOF*(IPG-1)+J)*COOR1D(2*J-1)
 30   CONTINUE

C --- COORDONNEES DE REFERENCE 1D DU POINT DE GAUSS
      CALL REEREG('S',ELC,NNOF,SEG,XG,NDIMF,KSIG1,IBID)

C --- COORDONNEES REELLES 2D DU POINT DE GAUSS
      KSIG2(1)=KSIG1
      KSIG2(2)=0.D0
      CALL REEREL(ELC,NNOF,NDIM,COOR2D,KSIG2,G)

C --- CONSTRUCTION DE LA BASE AU POINT DE GAUSS
C     CALCUL DES FF DE LA FACETTE EN CE POINT DE GAUSS
      CALL ELRFVF(ELC,KSIG1,NBNOMX,FF,IBID)

      DO 40 J=1,NDIM
        DO 41 K=1,NNOF
          ND(J)  = ND(J) + FF(K)*ZR(JBASEC-1+NDIM*NDIM*(K-1)+J)
          GRLT(J)= GRLT(J) + FF(K)*ZR(JBASEC-1+NDIM*NDIM*(K-1)+J+NDIM)
 41     CONTINUE
 40   CONTINUE

      CALL NORMEV(ND,NORME)
      PS=DDOT(NDIM,GRLT,1,ND,1)
      DO 50 J=1,NDIM
        TAU1(J)=GRLT(J)-PS*ND(J)
 50   CONTINUE
      CALL NORMEV(TAU1,NORME)

      IF (NORME.LT.1.D-12) THEN
C       ESSAI AVEC LE PROJETE DE OX
        TAU1(1)=1.D0-ND(1)*ND(1)
        TAU1(2)=0.D0-ND(1)*ND(2)
        CALL NORMEV(TAU1,NORM2)
        IF (NORM2.LT.1.D-12) THEN
C         ESSAI AVEC LE PROJETE DE OY
          TAU1(1)=0.D0-ND(2)*ND(1)
          TAU1(2)=1.D0-ND(2)*ND(2)
          CALL NORMEV(TAU1,NORM2)
        ENDIF
        CALL ASSERT(NORM2.GT.1.D-12)
      ENDIF

C     CALCUL DES FF DE L'�L�MENT PARENT EN CE POINT DE GAUSS
      CALL ELELIN(3,ELREFP,K8BID,IBID,NNOS)
      CALL REEREF(ELREFP,AXI,NNO,NNOS,ZR(IGEOM),G,IBID,.FALSE.,NDIM,
     &             HE,RBID, RBID,
     &             IBID,IBID,DDLH,NFE,DDLS,DDLM,FE,DGDGL,CINEM,
     &             XE,FFP,DFDI,F,EPS,GRAD)

      IF (ELREFC.EQ.ELREFP) GO TO 999
      IF (ELREFC(1:3).EQ.'NON') GO TO 999

C     CALCUL DES FF DE L'�L�MENT DE CONTACT EN CE POINT DE GAUSS
      CALL ELELIN(3,ELREFC,K8BID,NNOC,IBID)

      CALL REEREF(ELREFC,AXI,NNOC,NNOC,ZR(IGEOM),G,IBID,.FALSE.,NDIM,
     &             HE,RBID, RBID,
     &             IBID,IBID,DDLH,NFE,DDLS,DDLM,FE,DGDGL,CINEM,
     &             XE,FFPC,DFDIC,F,EPS,GRAD)

 999  CONTINUE

      CALL JEDEMA()
      END
