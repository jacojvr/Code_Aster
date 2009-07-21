      SUBROUTINE TE0544(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 21/07/2009   AUTEUR LEBOUVIER F.LEBOUVIER 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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

      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C    - FONCTION REALISEE:  CALCUL DES COEFFICIENTS A0 ET A1
C                          POUR LE PILOTAGE PAR CRITERE ELASTIQUE
C                          POUR LES ELEMENTS A VARIABLES DELOCALISEES
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................

      CHARACTER*8 TYPMOD(2),LIELRF(10)
      CHARACTER*16 COMPOR
      INTEGER JGANO,NDIM,NNO,NNOS,NPG,LGPG,JTAB(7),NTROU
      INTEGER IPOIDS,IVF,IDFDE,IGEOM,IMATE
      INTEGER ICONTM,IVARIM,ICOPIL,IBORNE,ICTAU,IRET
      INTEGER IDEPLM,IDDEPL,IDEPL0,IDEPL1,ICOMPO,ITYPE
      REAL*8 DFDI(2187),ELGEOM(10,27)
      LOGICAL LTEATT

C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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


C - TYPE DE MODELISATION
      TYPMOD(2) = 'GRADEPSI'

      IF (NOMTE(1:5).EQ.'MGCA_') THEN
        TYPMOD(1) = '3D'
      ELSE IF (LTEATT(' ','C_PLAN','OUI')) THEN
        TYPMOD(1) = 'C_PLAN'
      ELSE IF (LTEATT(' ','D_PLAN','OUI')) THEN
        TYPMOD(1) = 'D_PLAN'
      ELSE
C       NOM D'ELEMENT ILLICITE
        CALL ASSERT(NOMTE(1:5).EQ.'MGCA_')
      END IF

C - FONCTIONS DE FORMES ET POINTS DE GAUSS POUR LES DEFO GENERALISEES
      CALL ELREF2(NOMTE,10,LIELRF,NTROU)
      CALL ASSERT(NTROU.GE.2)
      CALL ELREF4(LIELRF(2),'RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,
     &            IDFDE,JGANO)

      IF (NNO.GT.27) CALL U2MESS('F','ELEMENTS4_31')
      IF (NPG.GT.27) CALL U2MESS('F','ELEMENTS4_31')


C - PARAMETRES EN ENTREE

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PDEPLMR','L',IDEPLM)
      CALL JEVECH('PCONTMR','L',ICONTM)
      CALL JEVECH('PVARIMR','L',IVARIM)
      CALL JEVECH('PDDEPLR','L',IDDEPL)
      CALL JEVECH('PDEPL0R','L',IDEPL0)
      CALL JEVECH('PDEPL1R','L',IDEPL1)
      CALL JEVECH('PTYPEPI','L',ITYPE)

      COMPOR = ZK16(ICOMPO)
      CALL JEVECH('PCDTAU','L',ICTAU)
      CALL JEVECH('PBORNPI','L',IBORNE)


C -- NOMBRE DE VARIABLES INTERNES

      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      LGPG = MAX(JTAB(6),1)*JTAB(7)

C - CALCUL DES ELEMENTS GEOMETRIQUES SPECIFIQUES LOIS DE COMPORTEMENT

      IF (COMPOR.EQ.'BETON_DOUBLE_DP') THEN
        CALL LCEGEO(NNO,NPG,IPOIDS,IVF,IDFDE,
     &              ZR(IGEOM),TYPMOD,OPTION,ZI(IMATE),
     &              ZK16(ICOMPO),LGPG,ELGEOM)
      END IF

C PARAMETRES EN SORTIE

      CALL JEVECH('PCOPILO','E',ICOPIL)


      CALL PIPEPE(ZK16(ITYPE),NDIM,NNO,NPG,IPOIDS,IVF,IDFDE,
     &            ZR(IGEOM),TYPMOD,
     &            ZI(IMATE),ZK16(ICOMPO),LGPG,ZR(IDEPLM),ZR(ICONTM),
     &            ZR(IVARIM),ZR(IDDEPL),ZR(IDEPL0),ZR(IDEPL1),
     &            ZR(ICOPIL),DFDI,ELGEOM,IBORNE,ICTAU)

      END
