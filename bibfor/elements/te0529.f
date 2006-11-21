      SUBROUTINE TE0529(OPTION,NOMTE)
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 21/11/2006   AUTEUR SALMONA L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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

C     BUT: CALCUL DES DEFORMATIONS LIES AUX VARIABLES DE COMMANDE
C          AUX POINTS D'INTEGRATION
C          OU AUX NOEUDS DES ELEMENTS ISOPARAMETRIQUES 3D

C          OPTIONS : 'EPVC_ELNO'
C                    'EPVC_ELGA'
C    CINQ COMPOSANTES :
C    EPTHER_L = DILATATION THERMIQUE (LONGI)   : ALPHA_L*(T-TREF)
C    EPTHER_T = DILATATION THERMIQUE (TRANSV)   : ALPHA_T*(T-TREF)
C    EPTHER_N = DILATATION THERMIQUE (NORMLALE)   : ALPHA_N*(T-TREF) 
C    EPSECH = RETRAIT DE DESSICCATION : -K_DESSIC(SREF-SECH)
C    EPHYDR = RETRAIT ENDOGENE        : -B_ENDOGE*HYDR
C
C     ENTREES  ---> OPTION : OPTION DE CALCUL
C              ---> NOMTE  : NOM DU TYPE ELEMENT
C.......................................................................
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

      INTEGER JGANO,NDIM,NNO,I,NNOS,NPG,JVAL,IPOIDS,IVF,IDFDE,
     &        IGAU,ISIG,INO,IGEOM,ITEMPE,ITREF,IER,
     &        ITEMPS,IDEFO,IMATE,IRET,NBCMP,IDIM
      REAL*8 EPVC(135),EPSNO(135),REPERE(7),TEMPE(27),HYDR(27),SECH(27)
      REAL*8 INSTAN,TREF,SREF,TEMPG,EPSSE(6),EPSTH(6),EPSHY(6)
      REAL*8 HYDRG, SECHG,XYZGAU(3),XYZ(3)
      CHARACTER*8 MODELI
      CHARACTER*16 OPTIO2
C DEB ------------------------------------------------------------------

      MODELI(1:2) = NOMTE(3:4)
C    NOMBRE DE COMPOSANTES  A  CALCULER  
      NBCMP=5 

C ---- CARACTERISTIQUES DU TYPE D'ELEMENT :
C ---- GEOMETRIE ET INTEGRATION
C      ------------------------
      IF (OPTION(6:9).EQ.'ELGA') THEN
        CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      ELSE IF (OPTION(6:9).EQ.'ELNO') THEN
C       -- ON AURAIT AIME PRENDRE 'NOGA' MAIS SI IL EXISTE DE
C          L'HYDRATATION, IL FAUT SE SOUMETTRE ...
        CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
      ELSE
        CALL ASSERT(.FALSE.)
      END IF

C ---- RECUPERATION DES COORDONNEES DES CONNECTIVITES :
C      ----------------------------------------------
      CALL JEVECH('PGEOMER','L',IGEOM)


C ---- RECUPERATION DU MATERIAU :
C      ----------------------------------------------
      CALL TECACH('NNN','PMATERC',1,IMATE,IRET)

C --- RECUPERATION  DES DONNEEES RELATIVES AU REPERE D'ORTHOTROPIE :
C     ------------------------------------------------------------
C     COORDONNEES DU BARYCENTRE ( POUR LE REPERE CYLINDRIQUE )
      XYZ(1) = 0.D0
      XYZ(2) = 0.D0
      XYZ(3) = 0.D0
      DO 300 I = 1,NNO
        DO 310 IDIM = 1,NDIM
          XYZ(IDIM) = XYZ(IDIM)+ZR(IGEOM+IDIM+NDIM*(I-1)-1)/NNO
 310    CONTINUE
 300  CONTINUE
      CALL ORTREP(ZI(IMATE),NDIM,XYZ,REPERE)

C ---- RECUPERATION DE L'INSTANT DE CALCUL :
C      -----------------------------------
      CALL TECACH('NNN','PTEMPSR',1,ITEMPS,IRET)
      IF (ITEMPS.NE.0) THEN
        INSTAN = ZR(ITEMPS)
      END IF

C     -----------------
C ---- RECUPERATION DU VECTEUR DES DEFORMATIONS EN SORTIE :
C      --------------------------------------------------
      CALL JEVECH('PDEFOVC','E',IDEFO)
      CALL R8INIR(135,0.D0,EPVC,1)

C ---- RECUPERATION DU CHAMP DE TEMPERATURE SUR L'ELEMENT :
C      --------------------------------------------------
      CALL R8INIR(27,0.D0,TEMPE,1)
      CALL TECACH('NNN','PTEMPER',1,ITEMPE,IRET)
      IF (ITEMPE.NE.0) THEN
        DO 40 I = 1,NNO
          TEMPE(I) = ZR(ITEMPE+I-1)
   40   CONTINUE
      END IF

C ---- RECUPERATION DE LA TEMPERATURE DE REFERENCE :
C      -------------------------------------------
      CALL TECACH('NNN','PTEREF',1,ITREF,IRET)
      IF (ITREF.NE.0) THEN
        TREF = ZR(ITREF)
      ELSE
        TREF=0.D0  
      END IF

C    RECUPERATION DU SECHAGE DE REFERENCE
C      -------------------------------------------
      CALL RCVARC(' ','SECH','REF','RIGI',1,1,SREF,IRET)
      IF (IRET.EQ.1) SREF=0.D0
      
      CALL R8INIR(27,0.D0,HYDR,1)
      CALL R8INIR(27,0.D0,SECH,1)      

      DO 200 IGAU = 1 , NPG

C       RECUPERATION DU SECHAGE ET DE L'HYDRATATION 
C      -------------------------------------------         
          CALL RCVARC(' ','HYDR','+','RIGI',IGAU,1,HYDRG,IER)
          IF (IER.EQ.1) HYDRG=0.D0
          CALL RCVARC(' ','SECH','+','RIGI',IGAU,1,SECHG,IER)
          IF (IER.EQ.1) SECHG=0.D0        

C      CALCUL AU POINT DE GAUSS DE LA TEMPERATURE ET 
C       DU REPERE D'ORTHOTROPIE
C ------------------------------------------
           TEMPG = 0.D0
           XYZGAU(1) = 0.D0
           XYZGAU(2) = 0.D0
           XYZGAU(3) = 0.D0
         DO 50 I = 1,NNO
           TEMPG = TEMPG + ZR(IVF+I-1+NNO*(IGAU-1))*TEMPE(I)
  50     CONTINUE            
             DO 55 IDIM = 1, NDIM
               XYZGAU(IDIM) = XYZGAU(IDIM) +
     +          ZR(IVF+IDIM-1+NNO*(IGAU-1))*
     +                 ZR(IGEOM+IDIM-1+NDIM*(IDIM-1))
  55         CONTINUE
  
 
        OPTIO2 = 'EPVC_' //OPTION(6:9) // '_TEMP'        
         
         CALL EPSTMC(MODELI,NDIM,TEMPG,TREF,HYDRG,SECHG,SREF,
     &    INSTAN,XYZGAU,REPERE,ZI(IMATE),OPTIO2,EPSTH)
        OPTIO2 = 'EPVC_' //OPTION(6:9) // '_SECH'        
        CALL EPSTMC(MODELI,NDIM,TEMPG,TREF,HYDRG,SECHG,SREF,
     &    INSTAN,XYZGAU,REPERE,ZI(IMATE),OPTIO2,EPSSE)
        OPTIO2 = 'EPVC_' //OPTION(6:9) // '_HYDR'        
        CALL EPSTMC(MODELI,NDIM,TEMPG,TREF,HYDRG,SECHG,SREF,
     &    INSTAN,XYZGAU,REPERE,ZI(IMATE),OPTIO2,EPSHY)
        DO 60 I=1,3
         EPVC(I+NBCMP*(IGAU-1)) = EPSTH(I)
 60     CONTINUE     
         EPVC(4+NBCMP*(IGAU-1) )= EPSSE(1)
         EPVC(5+NBCMP*(IGAU-1) )= EPSHY(1)
     
  200  CONTINUE

      IF (OPTION(6:9).EQ.'ELGA') THEN
C         --------------------
C ---- AFFECTATION DU VECTEUR EN SORTIE AVEC LES DEFORMATIONS AUX
C ---- POINTS D'INTEGRATION :
C      --------------------
        DO 80 IGAU = 1,NPG
          DO 70 ISIG = 1,NBCMP
            ZR(IDEFO+NBCMP* (IGAU-1)+ISIG-1) = EPVC(NBCMP* (IGAU-1)+
     &        ISIG)
   70     CONTINUE
   80   CONTINUE

      ELSE IF (OPTION(6:9).EQ.'ELNO') THEN

C ---- DEFORMATIONS AUX NOEUDS :
C      -----------------------

        CALL PPGAN2(JGANO,NBCMP,EPVC,EPSNO)

C ---- AFFECTATION DU VECTEUR EN SORTIE AVEC LES DEFORMATIONS AUX
C ---- NOEUDS :
C      ------
        DO 100 INO = 1,NNO
          DO 90 ISIG = 1,NBCMP
            ZR(IDEFO+NBCMP* (INO-1)+ISIG-1) = EPSNO(NBCMP* (INO-1)+ISIG)
   90     CONTINUE
  100   CONTINUE

      ELSE
        CALL ASSERT(.FALSE.)
      END IF

      END
