      SUBROUTINE TE0321(OPTION,NOMTE)
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE
C ......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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

C    - FONCTION REALISEE:  INITIALISATION DU CALCUL DE Z EN 3D
C                          OPTION : 'META_INIT','META_INIT_ELNO'

C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................
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

      CHARACTER*24 NOMRES
      CHARACTER*16 COMPOR(3)

      INTEGER ICODRE
      REAL*8 TNO0,MS0,ZALPHA,ZBETA
      REAL*8 METAPG(189),R8VIDE
      INTEGER JGANO,NNO,KN,J,ITEMPE,NNOS,NPG1
      INTEGER IPHASI,IPHASN,IDFDE,NVAL
      INTEGER IPOIDS,IVF,IMATE,NDIM,ICOMPO
C     -----------------------------------------------------------------
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG1,IPOIDS,IVF,IDFDE,JGANO)
C
C     PARAMETRES EN ENTREE
C    ---------------------
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PTEMPER','L',ITEMPE)
      CALL JEVECH('PPHASIN','L',IPHASI)
      CALL JEVECH('PCOMPOR','L',ICOMPO)

      COMPOR(1) = ZK16(ICOMPO)

C     PARAMETRES EN SORTIE
C    ----------------------
      CALL JEVECH('PPHASNOU','E',IPHASN)

C     -- ON VERIFIE QUE LES VALEURS INITIALES SONT BIEN INITIALISEES:
      IF (COMPOR(1).EQ.'ACIER') THEN
        NVAL=5
        DO 10, J=1,NVAL
          IF (ZR(IPHASI-1+J).EQ.R8VIDE())
     &        CALL U2MESS('F','ELEMENTS5_44')
 10     CONTINUE
      ELSEIF(COMPOR(1).EQ.'ZIRC') THEN
         IF (ZR(IPHASI-1+1).EQ.R8VIDE()) CALL U2MESS('F','ELEMENTS5_44')
         IF (ZR(IPHASI-1+2).EQ.R8VIDE()) CALL U2MESS('F','ELEMENTS5_44')
         IF (ZR(IPHASI-1+4).EQ.R8VIDE()) CALL U2MESS('F','ELEMENTS5_44')
      ENDIF


      IF (COMPOR(1).EQ.'ACIER') THEN
C        MATERIAU FERRITIQUE
C        ---------------------
C     ON RECALCULE DIRECTEMENT A PARTIR DES TEMPERATURES AUX NOEUDS
        NOMRES = 'MS0'
        CALL RCVALA(ZI(IMATE),' ','META_ACIER',1,'INST',0.D0,1,NOMRES,
     &            MS0,  ICODRE,1)

        DO 50 KN = 1,NNO
          TNO0 = ZR(ITEMPE+KN-1)

          DO 30 J = 0,4
            METAPG(1+7* (KN-1)+J) = ZR(IPHASI+J)
   30     CONTINUE

          METAPG(1+7* (KN-1)+6) = MS0
          METAPG(1+7* (KN-1)+5) = TNO0

          DO 40 J = 1,7
            ZR(IPHASN+7* (KN-1)+J-1) = METAPG(1+7* (KN-1)+J-1)
   40     CONTINUE
   50   CONTINUE

      ELSE IF (COMPOR(1) (1:4).EQ.'ZIRC') THEN

        DO 80 KN = 1,NNO

          TNO0 = ZR(ITEMPE+KN-1)

C ----------PROPORTION TOTALE DE LA PHASE ALPHA

          METAPG(1+4* (KN-1))   = ZR(IPHASI-1+1)
          METAPG(1+4* (KN-1)+1) = ZR(IPHASI-1+2)
          METAPG(1+4* (KN-1)+2) = TNO0
          METAPG(1+4* (KN-1)+3) = ZR(IPHASI-1+4)

          ZALPHA = METAPG(1+4* (KN-1)+1) + METAPG(1+4* (KN-1))

C-----------DECOMPOSITION DE LA PHASE ALPHA POUR LA MECANIQUE

          ZBETA = 1 - ZALPHA
          IF (ZBETA.GT.0.1D0) THEN
            METAPG(1+4* (KN-1)) = 0.D0
          ELSE
            METAPG(1+4* (KN-1)) = 10.D0* (ZALPHA-0.9D0)*ZALPHA
          END IF
          METAPG(1+4* (KN-1)+1) = ZALPHA - METAPG(1+4* (KN-1))

          DO 70 J = 1,4
            ZR(IPHASN+4* (KN-1)+J-1) = METAPG(1+4* (KN-1)+J-1)
   70     CONTINUE


   80   CONTINUE
      END IF



      END
