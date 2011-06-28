       SUBROUTINE TE0363(OPTION,NOMTE)
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE
C
C ----------------------------------------------------------------------
C  CONTACT XFEM GRANDS GLISSEMENTS
C  REACTUALISATION DU STATUT DE CONTACT
C
C  OPTION : 'XCVBCA' (X-FEM MISE └ JOUR DU STATUT DE CONTACT)
C
C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
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
C
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      CHARACTER*8  TYPMAI,TYPMAE,TYPMAM,TYPMAC,TYPMEC
      INTEGER      NDIM,NDDL,NNE(3),NNM(3),NNC
      INTEGER      NSINGE,NSINGM,LACT(8),NLACT,NINTER
      INTEGER      JPCPO,JPCAI,JHEAFA,JHEANO
      INTEGER      JGEOM,JDEPDE
      INTEGER      INDCO,MEMCO,INDNOR,IGLISS,NFAES
      INTEGER      JOUT
      INTEGER      INCOCA,NFHE,NFHM
      REAL*8       JEUCA,TAU1(3),TAU2(3),NORM(3)
      REAL*8       COORE(3),COORM(3),COORC(2)
      REAL*8       DLAGRC
      REAL*8       FFC(9),FFE(9),FFM(9),DFFC(3,9)
      REAL*8       PREC,NOOR,R8PREM
      REAL*8       RRE,RRM,FFEC(8)
      PARAMETER    (PREC=1.D-16)
      INTEGER      CFACE(5,3),CONTAC,DDLE(2),DDLM(2),IBID,NDEPLE
      LOGICAL      LMULTI
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INFOS SUR LA MAILLE DE CONTACT
C
      CALL XMELET(NOMTE , TYPMAI , TYPMAE ,TYPMAM ,TYPMAC  ,
     &                  NDIM  , NDDL   , NNE   , NNM  ,
     &                  NNC   , DDLE  , DDLM  ,
     &                  CONTAC, NDEPLE , NSINGE, NSINGM,NFHE,NFHM)

      CALL ASSERT(NDDL.LE.336)
      LMULTI = .FALSE.
      IF (NFHE.GT.1.OR.NFHM.GT.1) LMULTI = .TRUE.
C
C --- INITIALISATIONS
C
      DLAGRC = 0.D0
C --- INITIALISATION DE LA VARIABLE DE TRAVAIL
      INCOCA = 0
      CALL ASSERT(OPTION.EQ.'XCVBCA')
C
C --- RECUPERATION DES DONNEES DE LA CARTE CONTACT 'POINT' (VOIR XMCART)
C
      CALL JEVECH('PCAR_PT','L',JPCPO)
C --- LES COORDONNEES ESCLAVE DANS L'ELEMENT DE CONTACT
      COORC(1) = ZR(JPCPO-1+1)
      COORC(2) = ZR(JPCPO-1+10)
      TAU1(1)  = ZR(JPCPO-1+4)
      TAU1(2)  = ZR(JPCPO-1+5)
      TAU1(3)  = ZR(JPCPO-1+6)
      TAU2(1)  = ZR(JPCPO-1+7)
      TAU2(2)  = ZR(JPCPO-1+8)
      TAU2(3)  = ZR(JPCPO-1+9)
      INDCO    = NINT(ZR(JPCPO-1+11))
      NINTER   = NINT(ZR(JPCPO-1+31))
      INDNOR   = NINT(ZR(JPCPO-1+17))
      IGLISS   = NINT(ZR(JPCPO-1+20))
      MEMCO    = NINT(ZR(JPCPO-1+21))
      NFAES    = NINT(ZR(JPCPO-1+22))
C --- LES COORDONNEES ESCLAVE ET MAITRES DANS L'ELEMENT PARENT
      COORE(1) = ZR(JPCPO-1+24)
      COORE(2) = ZR(JPCPO-1+25)
      COORE(3) = ZR(JPCPO-1+26)
      COORM(1) = ZR(JPCPO-1+27)
      COORM(2) = ZR(JPCPO-1+28)
      COORM(3) = ZR(JPCPO-1+29)
C --- SQRT LSN PT MAITRE, ESCLAVE
      RRE     = ZR(JPCPO-1+18)
      RRM     = ZR(JPCPO-1+23)
      IF (NNM(1).EQ.0) RRE = 2*RRE
C
C --- RECUPERATION DES DONNEES DE LA CARTE CONTACT AINTER (VOIR XMCART)
C
      CALL JEVECH('PCAR_AI','L',JPCAI)
C
C --- RECUPERATION DE LA GEOMETRIE ET DES CHAMPS DE DEPLACEMENT
C
      CALL JEVECH('PGEOMER','E',JGEOM )
      CALL JEVECH('PDEPL_P','E',JDEPDE)
C
      IF (LMULTI) THEN
C
C --- RECUPERATION DES FONCTION HEAVISIDES SUR LES FACETTES
C
        CALL JEVECH('PHEAVFA','L',JHEAFA )
C
C --- RECUPERATION DE LA PLACE DES LAGRANGES
C
        CALL JEVECH('PHEAVNO','L',JHEANO )
      ENDIF
C
C --- RECUPERATION DES CHAMPS DE SORTIE
C
      CALL JEVECH('PINDCOO','E',JOUT)
C
C --- FONCTIONS DE FORMES
C
      CALL XTFORM(NDIM  ,TYPMAE,TYPMAM,TYPMAC,NDEPLE ,
     &            NNM(1)   ,NNC   ,COORE ,COORM ,COORC ,
     &            FFE   ,FFM   ,DFFC  )
C
C --- ON CONSTRUIT LA MATRICE DE CONNECTIVIT╔ CFACE (MAILLE ESCLAVE), CE
C --- QUI SUIT N'EST VALABLE QU'EN 2D POUR LA FORMULATION QUADRATIQUE,
C --- EN 3D ON UTILISE SEULEMENT LA FORMULATION AUX NOEUDS SOMMETS,
C --- CETTE MATRICE EST DONC INUTILE, ON NE LA CONSTRUIT PAS !!!
C
      CFACE(1,1) = 1
      CFACE(1,2) = 2
      CFACE(1,3) = 3
C
C --- FONCTION DE FORMES POUR LES LAGRANGIENS
C --- SI ON EST EN LINEAIRE, ON IMPOSE QUE LE NB DE NOEUDS DE CONTACTS
C --- ET LES FFS LAGRANGES DE CONTACT SONT IDENTIQUES A CEUX
C --- DES DEPLACEMENTS DANS LA MAILLE ESCLAVE POUR LE CALCUL DES CONTRIB
C
      IF (CONTAC.EQ.1) THEN
        NNC   = NNE(2)
        CALL XLACTI(TYPMAI,NINTER,JPCAI,LACT,NLACT)
        CALL XMOFFC(LACT,NLACT,NNC,FFE,FFC)
      ELSEIF (CONTAC.EQ.3) THEN
        NNC   = NNE(2)
        CALL ELELIN(CONTAC,TYPMAE,TYPMEC,IBID,IBID)
        CALL ELRFVF(TYPMEC,COORE,NNC,FFEC,IBID)
        CALL XLACTI(TYPMAI,NINTER,JPCAI,LACT,NLACT)
        CALL XMOFFC(LACT,NLACT,NNC,FFEC,FFC)
      ELSE
        CALL ELRFVF(TYPMAC,COORC,NNC,FFC,NNC)
      ENDIF
C
C --- CALCUL DE LA NORMALE
C
      IF (NDIM.EQ.2) THEN
        CALL MMNORM(NDIM,TAU1,TAU2,NORM,NOOR)
      ELSEIF (NDIM.EQ.3) THEN
        CALL PROVEC(TAU1,TAU2,NORM)
        CALL NORMEV(NORM,NOOR)
      ENDIF
      IF (NOOR.LE.R8PREM()) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- CALCUL DE L'INCREMENT DE REACTION DE CONTACT
C
      CALL XTLAGC(TYPMAI,NDIM  ,NNC   ,NNE    ,
     &              DDLE(1),NFAES ,CFACE ,JDEPDE,JPCAI  ,
     &              FFC   ,CONTAC,
     &              NFHE  ,LMULTI,ZI(JHEANO),DLAGRC)
C
C --- EVALUATION DES JEUX - CAS DU CONTACT
C
      CALL XMMJEC(NDIM  ,NNM ,NNE ,NDEPLE,
     &                  NSINGE,NSINGM,FFE   ,FFM   ,NORM  ,
     &                  JGEOM ,JDEPDE,RRE   ,RRM ,
     &                  DDLE  ,DDLM  ,NFHE  ,NFHM  ,LMULTI,
     &                  ZI(JHEAFA),JEUCA )
C
C
C --- NOEUDS EXCLUS PAR PROJECTION HORS ZONE
C
      IF (INDNOR .EQ. 1) THEN
        IF ((IGLISS.EQ.0).OR.(MEMCO.EQ.0)) THEN
          ZI(JOUT-1+2)= 0.D0
          GO TO 999
        ENDIF
      ENDIF
C
C --- SI LE CONTACT A ETE POSTULE, ON TESTE LA VALEUR DE LA PRESSION
C --- DE CONTACT
C
      IF (INDCO.EQ.1) THEN
        IF (DLAGRC.GT.-1.D-3) THEN
          IF ((IGLISS.EQ.1).AND.(MEMCO.EQ.1)) THEN
            ZI(JOUT-1+2) = 1
            ZI(JOUT-1+3) = 1
          ELSE IF (IGLISS.EQ.0) THEN
            ZI(JOUT-1+2) = 0
            INCOCA = 1
          ENDIF
        ELSE
          ZI(JOUT-1+2) = 1
          ZI(JOUT-1+3) = 1
        END IF
C
C --- SI LE NON-CONTACT A ETE POSTUL╔, ON TESTE LA VALEUR DU JEU
C
      ELSE IF (INDCO .EQ. 0) THEN
        IF (JEUCA.GT.PREC) THEN
          ZI(JOUT-1+2) = 1
          ZI(JOUT-1+3) = 1
          INCOCA = 1
        ELSE
          ZI(JOUT-1+2) = 0.D0
        END IF
C
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
 999  CONTINUE
C
C --- ENREGISTREMENT DU CHAMP DE SORTIE
C
      ZI(JOUT-1+1)=INCOCA
C
      CALL JEDEMA()
      END
