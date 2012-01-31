      SUBROUTINE XMVEF1(NDIM  ,JNNE   ,JNNM,NDEPLE ,
     &                  NNC,NFAES ,CFACE ,HPG   ,FFC   ,FFE   ,
     &                  FFM   ,JACOBI,JPCAI ,DLAGRC,DLAGRF,
     &                  COEFFR,LPENAF,COEFFF,TAU1  ,
     &                  TAU2  ,RESE  ,MPROJ ,
     &                  TYPMAI,NSINGE,NSINGM,RRE   ,RRM   ,NVIT  ,
     &                  NCONTA,JDDLE,JDDLM,NFHE,VTMP  )  
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 30/01/2012   AUTEUR DESOZA T.DESOZA 
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
      IMPLICIT NONE
      INTEGER  NDIM,NNC,JNNE(3),JNNM(3),NFAES,JPCAI,CFACE(5,3)
      INTEGER  NSINGE,NSINGM,NVIT,JDDLE(2),JDDLM(2),NFHE
      REAL*8   HPG,FFC(8),FFE(8),FFM(8),JACOBI
      REAL*8   DLAGRC,DLAGRF(2)
      REAL*8   COEFFF,COEFFR,RRE,RRM
      REAL*8   TAU1(3),TAU2(3),RESE(3),MPROJ(3,3),VTMP(336)
      INTEGER  NCONTA,NDEPLE
      CHARACTER*8  TYPMAI
      LOGICAL  LPENAF
C
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEMGG - CALCUL ELEM.)
C
C CALCUL DU SECOND MEMBRE POUR LE FROTTEMENT
C CAS AVEC CONTACT
C
C ----------------------------------------------------------------------
C ROUTINE SPECIFIQUE A L'APPROCHE <<GRANDS GLISSEMENTS AVEC XFEM>>,
C TRAVAIL EFFECTUE EN COLLABORATION AVEC I.F.P.
C ----------------------------------------------------------------------
C
C IN  NDIM   : DIMENSION DU PROBLEME
C IN  NNE    : NOMBRE DE NOEUDS DE LA MAILLE ESCLAVE
C IN  NNES   : NOMBRE DE NOEUDS SOMMETS DE LA MAILLE ESCLAVE
C IN  NNC    : NOMBRE DE NOEUDS DE CONTACT
C IN  NNM    : NOMBRE DE NOEUDS DE LA MAILLE MAITRE
C IN  NFAES  : NUMERO DE LA FACETTE DE CONTACT ESCLAVE
C IN  CFACE  : MATRICE DE CONECTIVITE DES FACETTES DE CONTACT
C IN  HPG    : POIDS DU POINT INTEGRATION DU POINT DE CONTACT
C IN  FFC    : FONCTIONS DE FORME DU POINT DE CONTACT DANS ELC
C IN  FFE    : FONCTIONS DE FORME DU POINT DE CONTACT DANS ESC
C IN  FFM    : FONCTIONS DE FORME DE LA PROJECTION DU PTC DANS MAIT
C IN  JACOBI : JACOBIEN DE LA MAILLE AU POINT DE CONTACT
C IN  JPCAI  : POINTEUR VERS LE VECT DES ARRETES ESCLAVES INTERSECTEES
C IN  COEFFA : COEF_REGU_FROT
C IN  COEFFF : COEFFICIENT DE FROTTEMENT DE COULOMB
C IN  TAU1   : PREMIERE TANGENTE
C IN  TAU2   : SECONDE TANGENTE
C IN  RESE   : PROJECTION DE LA BOULE UNITE POUR LE FROTTEMENT
C IN  MPROJ  : MATRICE DE L'OPERATEUR DE PROJECTION
C IN  DLAGRF : LAGRANGES DE FROTTEMENT AU POINT D'INTÉGRATION
C IN  TYPMAI : NOM DE LA MAILLE ESCLAVE D'ORIGINE (QUADRATIQUE)
C IN  NSINGE : NOMBRE DE FONCTION SINGULIERE ESCLAVE
C IN  NSINGM : NOMBRE DE FONCTION SINGULIERE MAITRE
C IN  RRE    : SQRT LST ESCLAVE
C IN  RRM    : SQRT LST MAITRE
C IN  NVIT   : POINT VITAL OU PAS
C IN  INADH  : POINT ADHERENT OU PAS
C I/O VTMP   : VECTEUR SECOND MEMBRE ELEMENTAIRE DE CONTACT/FROTTEMENT
C ----------------------------------------------------------------------
      INTEGER   I, J, K, II, INI, PLI, XOULA,IIN,NDDLE
      INTEGER   NNE,NNES,NNEM,NNM,NNMS,DDLES,DDLEM,DDLMS,DDLMM
      REAL*8    VECTT(3), TT(2), VV, T
C ----------------------------------------------------------------------
C
C --- INITIALISATIONS
C
      NNE=JNNE(1)
      NNES=JNNE(2)
      NNEM=JNNE(3)
      NNM=JNNM(1)
      NNMS=JNNM(2)
      DDLES=JDDLE(1)
      DDLEM=JDDLE(2)
      DDLMS=JDDLM(1)
      DDLMM=JDDLM(2)
      NDDLE = DDLES*NNES+DDLEM*NNEM
C
      DO 100 I = 1,3
        VECTT(I) = 0.D0
 100  CONTINUE
      DO 110 I = 1,2
        TT(I) = 0.D0
 110  CONTINUE
C
C --- CALCUL DE RESE.C(*,I)
C
      DO 120 I = 1,NDIM
        DO 130 K = 1,NDIM
          VECTT(I) = RESE(K)*MPROJ(K,I) + VECTT(I)
  130   CONTINUE
  120 CONTINUE
C
C --- CALCUL DE T.(T-P)
C
      DO 140 I = 1,NDIM
        T = DLAGRF(1)*TAU1(I)+DLAGRF(2)*TAU2(I)-RESE(I)
        TT(1)= T*TAU1(I)+TT(1)
        IF (NDIM.EQ.3) TT(2)= T*TAU2(I)+TT(2)
  140 CONTINUE
C
C --------------------- CALCUL DE [L1_FROT]-----------------------------
C
      IF (NNM.NE.0) THEN
C
      DO 10 J = 1,NDIM
        DO 20 I = 1,NDEPLE
C --- BLOCS ES,CL ; ES,EN ; (ES,SI)
          VV = JACOBI*HPG*COEFFF*DLAGRC*VECTT(J)*FFE(I)
          CALL INDENT(I,DDLES,DDLEM,NNES,IIN)
          II = IIN + J
          VTMP(II) = -VV
          II = II + NDIM
          VTMP(II) = VV
          DO 25 K = 1,NSINGE
            II = II + NDIM
            VTMP(II) = RRE * VV
   25     CONTINUE
   20   CONTINUE
        DO 30 I = 1,NNM
          VV = JACOBI*HPG*COEFFF*
     &       DLAGRC*VECTT(J)*FFM(I)
          CALL INDENT(I,DDLMS,DDLMM,NNMS,IIN)
          II = NDDLE + IIN + J
          VTMP(II) = VV
          II = II + NDIM
          VTMP(II) = VV
          DO 35 K = 1,NSINGM
            II = II + NDIM
            VTMP(II) = RRM * VV
   35     CONTINUE
   30   CONTINUE
   10 CONTINUE
      ELSE
C
      DO 60 J = 1,NDIM
        DO 70 I = 1,NDEPLE
C --- BLOCS ES,SI
          VV = JACOBI*HPG*COEFFF*
     &        DLAGRC*VECTT(J)*FFE(I)
          CALL INDENT(I,DDLES,DDLEM,NNES,IIN)
          II = IIN + J
          VTMP(II) = RRE * VV
   70   CONTINUE
   60 CONTINUE
      ENDIF
C
C --------------------- CALCUL DE [L3]----------------------------------
C
      IF (NVIT.EQ.1) THEN
      DO 40 I = 1,NNC
        INI=XOULA(CFACE,NFAES,I,JPCAI,TYPMAI,NCONTA)
        CALL XPLMA2(NDIM,NNE,NNES,DDLES,INI,NFHE,PLI)
        DO 50 J = 1,NDIM-1
          II = PLI+J
          IF(LPENAF) THEN
            VTMP(II) = JACOBI*HPG*TT(J)*FFC(I)
          ELSE
            VTMP(II) = JACOBI*HPG*TT(J)*FFC(I)*COEFFF*DLAGRC/COEFFR
          ENDIF
   50   CONTINUE
   40 CONTINUE
      ENDIF
C
      END
