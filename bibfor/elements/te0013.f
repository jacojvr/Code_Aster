      SUBROUTINE TE0013(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 04/05/2004   AUTEUR SMICHEL S.MICHEL-PONNELLE 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C.......................................................................
      IMPLICIT REAL*8 (A-H,O-Z)

C     BUT: CALCUL DES VECTEURS ELEMENTAIRES EN MECANIQUE
C          ELEMENTS ISOPARAMETRIQUES 3D

C          OPTION : 'CHAR_MECA_TEMP_R  '

C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................

      CHARACTER*16 NOMTE,OPTION
      CHARACTER*8 MODELI
      REAL*8 BSIGMA(81),SIGTH(162),REPERE(7),INSTAN
      REAL*8 NHARM
      REAL*8 HYDRG,SECHG,RBID
      INTEGER NBSIGM, ISECH
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------

       RBID=0
C EN PRESENCE DE METALLURGIE -> METAU2
      CALL TECACH('NNN','PPHASRR',1,META,IRET)
      IF (META.NE.0) THEN
        CALL METAU2(OPTION,NOMTE)
        GO TO 40
      END IF


C ---- CARACTERISTIQUES DU TYPE D'ELEMENT :
C ---- GEOMETRIE ET INTEGRATION
C      ------------------------
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)

C --- INITIALISATIONS :
C     -----------------
      ZERO = 0.0D0
      INSTAN = ZERO
      NHARM = ZERO
      MODELI(1:2) = NOMTE(3:4)

C ---- NOMBRE DE CONTRAINTES ASSOCIE A L'ELEMENT
C      -----------------------------------------
      NBSIG = NBSIGM(MODELI)

      DO 10 I = 1,NBSIG*NPG1
        SIGTH(I) = ZERO
   10 CONTINUE

      DO 20 I = 1,NDIM*NNO
        BSIGMA(I) = ZERO
   20 CONTINUE

C ---- RECUPERATION DES COORDONNEES DES CONNECTIVITES
C      ----------------------------------------------
      CALL JEVECH('PGEOMER','L',IGEOM)

C ---- RECUPERATION DU MATERIAU
C      ------------------------
      CALL JEVECH('PMATERC','L',IMATE)

C ---- RECUPERATION  DES DONNEEES RELATIVES AU REPERE D'ORTHOTROPIE
C      ------------------------------------------------------------
      CALL ORTREP(ZI(IMATE),NDIM,REPERE)

C ---- RECUPERATION DU CHAMP DE TEMPERATURE SUR L'ELEMENT
C      --------------------------------------------------
      CALL JEVECH('PTEMPER','L',ITEMPE)

C ---- RECUPERATION DE LA TEMPERATURE DE REFERENCE
C      -------------------------------------------
      CALL JEVECH('PTEREF','L',ITREF)

C ---- RECUPERATION DU CHAMP DE L'HDRATATION SUR L'ELEMENT
C      --------------------------------------------------
      CALL JEVECH('PHYDRER','L',IHYDR)

C ---- RECUPERATION DU CHAMP DU SECHAGE SUR L'ELEMENT
C      --------------------------------------------------
      CALL JEVECH('PSECHER','L',ISECH)
       
C ---- RECUPERATION DE L'INSTANT
C      -------------------------
      CALL TECACH('ONN','PTEMPSR',1,ITEMPS,IRET)
      IF (ITEMPS.NE.0) INSTAN = ZR(ITEMPS)

C ---- CALCUL DES CONTRAINTES THERMIQUES AUX POINTS D'INTEGRATION
C ---- DE L'ELEMENT :
C      ------------
      CALL SIGTMC(MODELI,NNO,NDIM,NBSIG,NPG1,ZR(IVF),ZR(IGEOM),
     &           ZR(ITEMPE),ZR(ITREF),ZR(IHYDR),ZR(ISECH),RBID,
     &           INSTAN,ZI(IMATE),REPERE,OPTION,SIGTH)
C ---- CALCUL DU VECTEUR DES FORCES D'ORIGINE THERMIQUE/HYDRIQUE
C ---- OU DE SECHAGE (BT*SIGTH)
C      ----------------------------------------------------------
      CALL BSIGMC(MODELI,NNO,NDIM,NBSIG,NPG1,IPOIDS,IVF,IDFDE, 
     +              ZR(IGEOM), NHARM,SIGTH, BSIGMA )

C ---- RECUPERATION ET AFFECTATION DU VECTEUR EN SORTIE AVEC LE
C ---- VECTEUR DES FORCES D'ORIGINE THERMIQUE
C      -------------------------------------
      CALL JEVECH('PVECTUR','E',IVECTU)

      DO 30 I = 1,NDIM*NNO
        ZR(IVECTU+I-1) = BSIGMA(I)
   30 CONTINUE

   40 CONTINUE
      END
