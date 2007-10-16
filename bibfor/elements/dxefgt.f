      SUBROUTINE DXEFGT ( NOMTE, XYZL, PGL, SIGT )
      IMPLICIT  REAL*8 (A-H,O-Z)
      REAL*8        XYZL(3,1),PGL(3,1),SIGT(1)
      CHARACTER*16  NOMTE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 16/10/2007   AUTEUR SALMONA L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ------------------------------------------------------------------
C --- EFFORTS GENERALISES N, M, V D'ORIGINE THERMIQUE AUX POINTS
C --- D'INTEGRATION POUR LES ELEMENTS COQUES A FACETTES PLANES :
C --- DST, DKT, DSQ, DKQ, Q4G DUS :
C ---  .A UN CHAMP DE TEMPERATURES SUR LE PLAN MOYEN DONNANT
C ---        DES EFFORTS DE MEMBRANE
C ---  .A UN GRADIENT DE TEMPERATURES DANS L'EPAISSEUR DE LA COQUE
C     ------------------------------------------------------------------
C     IN  NOMTE        : NOM DU TYPE D'ELEMENT
C     IN  XYZL(3,NNO)  : COORDONNEES DES CONNECTIVITES DE L'ELEMENT
C                        DANS LE REPERE LOCAL DE L'ELEMENT
C     IN  PGL(3,3)     : MATRICE DE PASSAGE DU REPERE GLOBAL AU REPERE
C                        LOCAL
C     OUT SIGT(1)      : EFFORTS  GENERALISES D'ORIGINE THERMIQUE
C                        AUX POINTS D'INTEGRATION
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
      INTEGER  NDIM,NNO,NNOS,NPG,IPOIDS,ICOOPG,IVF,IDFDX,IDFD2,JGANO
      INTEGER  MULTIC,IRET,IPG,NBCOU,NPGH,SOMIRE
      REAL*8   DF(3,3),DM(3,3),DMF(3,3)
      REAL*8   TMOYPG,TSUPPG,TINFPG
      REAL*8   N(4),T2EV(4),T2VE(4),T1VE(9)
      LOGICAL GRILLE,LTEATT
      CHARACTER*2   CODRET(56)
      CHARACTER*4   FAMI
      CHARACTER*10  PHENOM
C     ------------------------------------------------------------------
C
      FAMI = 'RIGI'
      CALL ELREF5(' ',FAMI,NDIM,NNO,NNOS,NPG,IPOIDS,ICOOPG,
     &                                         IVF,IDFDX,IDFD2,JGANO)
C
      CALL R8INIR(32,0.D0,SIGT,1)
C
C --- POUR L'INSTANT PAS DE PRISE EN COMPTE DES CONTRAINTES
C --- THERMIQUES POUR LES MATERIAUX MULTICOUCHES
C     ------------------------------------------
      CALL JEVECH('PMATERC','L',JMATE)
      CALL RCCOMA(ZI(JMATE),'ELAS',PHENOM,CODRET)

C --- RECUPERATION DE LA TEMPERATURE DE REFERENCE ET
C --- DE L'EPAISSEUR DE LA COQUE
C     --------------------------

      GRILLE= LTEATT(' ','GRILLE','OUI')
C
      CALL JEVECH('PCACOQU','L',JCARA)
      EPAIS = ZR(JCARA)

      CALL RCVARC(' ','TEMP','REF',FAMI,1,1,TREF,IRET1)

C
C --- CALCUL DES COEFFICIENTS THERMOELASTIQUES DE FLEXION,
C --- MEMBRANE, MEMBRANE-FLEXION
C     ----------------------------------------------------

      CALL DXMATH('RIGI',EPAIS,DF,DM,DMF,NNO,PGL,MULTIC,INDITH,
     &                               GRILLE,T2EV,T2VE,T1VE,NPG)
      IF (INDITH.EQ.-1) GO TO 30

C SI ON EST SUR UNE GRILLE ON RECUPERE LA TEMPERATURE MOYENNE SUR LA
C PREMIERE COUCHE ( CAR ELLE EST CONSTANTE SUR L EPAISSEUR )
      IF (GRILLE) THEN
        NBCOU=1
        IPG=1
        NPGH=1
      ELSE
        CALL JEVECH('PNBSP_I','L',JCOU)
        NBCOU=ZI(JCOU)
        IPG=(3*NBCOU+1)/2
        NPGH=3
      ENDIF
C --- BOUCLE SUR LES POINTS D'INTEGRATION
C     -----------------------------------
      DO 20 IGAU = 1,NPG

C  --      TEMPERATURES SUR LES FEUILLETS MOYEN, SUPERIEUR ET INFERIEUR
C  --      AU POINT D'INTEGRATION COURANT
C          ------------------------------
        CALL RCVARC(' ','TEMP','+',FAMI,IGAU,IPG,TMOYPG,IRET2)
        CALL RCVARC(' ','TEMP','+',FAMI,IGAU,1,TINFPG,IRET3)
        CALL RCVARC(' ','TEMP','+',FAMI,IGAU,NPGH*NBCOU,TSUPPG,IRET4)
        SOMIRE = IRET2+IRET3+IRET4
        IF (SOMIRE.EQ.0) THEN
          IF (IRET1.EQ.1) THEN
            CALL U2MESS('F','CALCULEL_31')
          ELSE

C  --      LES COEFFICIENTS SUIVANTS RESULTENT DE L'HYPOTHESE SELON
C  --      LAQUELLE LA TEMPERATURE EST PARABOLIQUE DANS L'EPAISSEUR.
C  --      ON NE PREJUGE EN RIEN DE LA NATURE DU MATERIAU.
C  --      CETTE INFORMATION EST CONTENUE DANS LES MATRICES QUI
C  --      SONT LES RESULTATS DE LA ROUTINE DXMATH.
C          ----------------------------------------
            COE1 = (TSUPPG+TINFPG+4.D0*TMOYPG)/6.D0 - TREF
            COE2 = (TSUPPG-TINFPG)/EPAIS

        SIGT(1+8* (IGAU-1)) = COE1* (DM(1,1)+DM(1,2)) +
     &                        COE2* (DMF(1,1)+DMF(1,2))
        SIGT(2+8* (IGAU-1)) = COE1* (DM(2,1)+DM(2,2)) +
     &                        COE2* (DMF(2,1)+DMF(2,2))
        SIGT(3+8* (IGAU-1)) = COE1* (DM(3,1)+DM(3,2)) +
     &                        COE2* (DMF(3,1)+DMF(3,2))
        SIGT(4+8* (IGAU-1)) = COE2* (DF(1,1)+DF(1,2)) +
     &                        COE1* (DMF(1,1)+DMF(1,2))
        SIGT(5+8* (IGAU-1)) = COE2* (DF(2,1)+DF(2,2)) +
     &                        COE1* (DMF(2,1)+DMF(2,2))
        SIGT(6+8* (IGAU-1)) = COE2* (DF(3,1)+DF(3,2)) +
     &                        COE1* (DMF(3,1)+DMF(3,2))
         ENDIF    
        ENDIF      
   20 CONTINUE
C
   30 CONTINUE
C
      END
