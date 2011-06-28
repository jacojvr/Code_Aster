      SUBROUTINE XTLAGF(TYPMAI,NDIM  ,NNC   ,JNN        ,
     &                  NDDLS,NFACE ,CFACE ,JDEPDE,JPCAI  ,
     &                  FFC   ,NCONTA,NFHE  ,DLAGRF)
C
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      INTEGER      NDIM,NNC,JNN(3),NCONTA,NFHE
      INTEGER      JDEPDE,JPCAI
      REAL*8       FFC(9)
      CHARACTER*8  TYPMAI
      REAL*8       DLAGRF(2)
      INTEGER      CFACE(5,3),NFACE
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEMGG - CALCUL ELEM.)
C
C CALCUL DES INCREMENTS - LAGRANGE DE FROTTEMENT
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C
C DEPDEL - INCREMENT DE DEPLACEMENT DEPUIS DEBUT DU PAS DE TEMPS
C
C IN  NDIM   : DIMENSION DU MODELE
C IN  NNC    : NOMBRE DE NOEUDS DE CONTACT
C IN  NN     : NOMBRE DE NOEUDS
C IN  NNS    : NOMBRE DE NOEUDS SOMMETS
C IN  NDDLS  : NOMBRE DE DDL SUR UN NOEUD SOMMET
C IN  JDEPDE : POINTEUR JEVEUX POUR DEPDEL
C IN  FFC    : FONCTIONS DE FORMES LAGR.
C IN  CFACE  : CONNECTIVIT� DES NOEUDS DES FACETTES
C IN  NFACE  : NUM�RO DE LA FACETTE
C IN  JAINT  : ADRESSE DES INFORMATIONS CONCERNANT LES ARETES COUP�ES
C IN  TYPMAI : TYPE DE LA MAILLE
C OUT DLAGRF : INCREMENT DEPDEL DES LAGRANGIENS DE FROTTEMENT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER IDIM,INO,NN,NNS,NDDLS
      INTEGER IN,XOULA,PL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      NN = JNN(1)
      NNS= JNN(2)
C
      DLAGRF(1) = 0.D0
      DLAGRF(2) = 0.D0
C
C --- LAGRANGES DE FROTTEMENT
C
      DO 221 IDIM=2,NDIM
        DO 231 INO = 1,NNC
          IN    = XOULA(CFACE ,NFACE ,INO   ,JPCAI ,
     &                  TYPMAI,NCONTA)
          CALL XPLMA2(NDIM  ,NN    ,NNS   ,NDDLS ,IN    ,NFHE  ,PL    )
          DLAGRF(IDIM-1) = DLAGRF(IDIM-1)+
     &          FFC(INO)*ZR(JDEPDE-1+PL+IDIM-1)
 231    CONTINUE
 221  CONTINUE
C
      CALL JEDEMA()
C
      END
