      SUBROUTINE POSVAR (COMPOR,NDIM,VARI,NUME)
      IMPLICIT NONE
      CHARACTER*16 COMPOR(*)
      CHARACTER*24 VARI
      CHARACTER*24 VALK(2)
      INTEGER NDIM, NUME
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C ======================================================================
C MODIF ALGORITH  DATE 11/03/2008   AUTEUR MAHFOUZ D.MAHFOUZ 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C --- RECUPERATION DE L ADRESSE DE LA VARIABLE INTERNE NOMMEE
C   COMPOR  IN   K16 : COMPORTEMENT
C   NDIM    IN    I  : DIMENSION DU PROBLEME
C   VARI    IN   K16 : NOM DE LA VARIABLE INTERNE CHERCHE
C   NUME   OUT    I  : ADRESSE DE LA VARIABLE INTERNE

      INTEGER NVIM,NVIT,NVIH,NVIC,DECAL
      INTEGER ADVIME,ADVITH,ADVIHY,ADVICO
      INTEGER VIHRHO,VICPHI,VICPVP,VICSAT
      CHARACTER*16 MECA,THMC,THER,HYDR

      CALL NVITHM(COMPOR, MECA, THMC, THER, HYDR, NVIM, NVIT,
     &            NVIH, NVIC, ADVIME, ADVITH, ADVIHY, ADVICO,
     &            VIHRHO, VICPHI, VICPVP, VICSAT)

      IF ( ( THMC .EQ. 'LIQU_GAZ' )           .OR.
     &     ( THMC .EQ. 'LIQU_GAZ_ATM' ) )  THEN

         IF (VARI(1:6).EQ.'DPORO') THEN
            NUME=ADVICO
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'DRHOLQ') THEN
            NUME=ADVIHY
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'DPVP') THEN
            NUME=ADVICO+1
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'SATLIQ') THEN
            NUME=0
            CALL U2MESK('A','ALGORITH9_96',1,THMC)
            GOTO 9999
         ENDIF
      ELSE IF ( ( THMC .EQ. 'LIQU_VAPE' ) .OR.
     &          ( THMC .EQ. 'LIQU_VAPE_GAZ' ) .OR.
     &          ( THMC .EQ. 'LIQU_AD_GAZ_VAPE') ) THEN

         IF (VARI(1:6).EQ.'DPORO') THEN
            NUME=ADVICO
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'DRHOLQ') THEN
            NUME=ADVIHY
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'DPVP') THEN
            NUME=ADVICO+1
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'SATLIQ') THEN
            NUME=ADVICO+2
            GOTO 9999
         ENDIF
      ELSE

         IF (VARI(1:6).EQ.'DPORO') THEN
            NUME=ADVICO
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'DRHOLQ') THEN
            NUME=ADVIHY
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'DPVP') THEN
            CALL U2MESK('A','ALGORITH9_97',1,THMC)
            NUME=0
            GOTO 9999
         ELSE IF (VARI(1:6).EQ.'SATLIQ') THEN
            CALL U2MESK('A','ALGORITH9_96',1,THMC)
            NUME=0
            GOTO 9999
         ENDIF
      ENDIF

C-----LA LOI MECANIQUE EST CAM_CLAY

      IF (MECA(1:8).EQ.'CAM_CLAY') THEN
C----- DEFORMATION VOLUMIQUE PLASTIQUE CUMULEE
         IF (VARI(1:3).EQ.'PCR') THEN
            NUME=ADVIME
C----- INDICATEUR D ETAT
            GOTO 9999
         ELSE IF (VARI(1:7).EQ.'IND_ETA') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- contrainte volumique
         ELSE IF (VARI(1:5).EQ.'SIGMO') THEN
            NUME=ADVIME+2
            GOTO 9999
C----- contrainte deviatorique
         ELSE IF (VARI(1:5).EQ.'SIGDV') THEN
            NUME=ADVIME+3
            GOTO 9999
C----- deformation plastique volumique
         ELSE IF (VARI(1:5).EQ.'EPSVO') THEN
            NUME=ADVIME+4
            GOTO 9999
C----- deformation plastique equivalente
         ELSE IF (VARI(1:5).EQ.'EPSEQ') THEN
            NUME=ADVIME+5
            GOTO 9999
C----- indice des vides
         ELSE IF (VARI(1:7).EQ.'IND_VID') THEN
            NUME=ADVIME+6
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE EST MAZARS

      ELSE IF (MECA(1:6).EQ.'MAZARS') THEN
C----- ENDOMMAGEMENT
         IF (VARI(1:1).EQ.'D') THEN
            NUME=ADVIME
            GOTO 9999
C----- INDICATEUR D ENDOMMAGEMENT
         ELSE IF (VARI(1:7).EQ.'IND_END') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- TEMPERATURE MAXIMALE AU POINT DE GAUSS
         ELSE IF (VARI(1:8).EQ.'TEMP_MAX') THEN
            NUME=ADVIME+2
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE EST DRUCKER-PRAGER

      ELSE IF (MECA(1:14).EQ.'DRUCK_PRAGER') THEN
C----- DEFORMATION DEVIATOIRE PLASTIQUE CUMULEE
         IF (VARI(1:4).EQ.'GAMP') THEN
            NUME=ADVIME
            GOTO 9999
C----- DEFORMATION VOLUMIQUE PLASTIQUE CUMULEE
         ELSE IF (VARI(1:3).EQ.'EVP') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- INDICATEUR D ETAT
         ELSE IF (VARI(1:7).EQ.'IND_ETA') THEN
            NUME=ADVIME+2
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE EST ENDO_ISOT_BETON

      ELSE IF (MECA(1:10).EQ.'ENDO_ISOT_') THEN
C----- ENDOMMAGEMENT
         IF (VARI(1:1).EQ.'D') THEN
            NUME=ADVIME
            GOTO 9999
C----- INDICATEUR D ENDOMMAGEMENT
         ELSE IF (VARI(1:7).EQ.'IND_END') THEN
            NUME=ADVIME+1
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE EST BARCELONE

      ELSE IF (MECA(1:9).EQ.'BARCELONE') THEN
C----- PRESSION CRITIQUE
         IF (VARI(1:3).EQ.'PCR') THEN
            NUME=ADVIME
            GOTO 9999
C----- INDICATEUR DE PLASTICITE MECANIQUE
         ELSE IF (VARI(1:7).EQ.'IND_ETA') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- SEUIL HYDRIQUE
         ELSE IF (VARI(1:9).EQ.'SEUIL_HYD') THEN
            NUME=ADVIME+2
            GOTO 9999
C----- INDICATEUR D IRREVERSIBILITE HYDRIQUE
         ELSE IF (VARI(1:7).EQ.'IND_HYD') THEN
            NUME=ADVIME+3
            GOTO 9999
C----- PRESSION DE COHESION
         ELSE IF (VARI(1:5).EQ.'PCOHE') THEN
            NUME=ADVIME+4
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE EST LAIGLE

      ELSE IF (MECA(1:6).EQ.'LAIGLE') THEN

C----- DEFORMATION DEVIATOIRE PLASTIQUE CUMULEE
         IF (VARI(1:4).EQ.'GAMP') THEN
            NUME=ADVIME
            GOTO 9999
C----- DEFORMATION VOLUMIQUE PLASTIQUE CUMULEE
         ELSE IF (VARI(1:3).EQ.'EVP') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- COMPORTEMENT DE LA ROCHE
         ELSE IF (VARI(1:8).EQ.'COMP_ROC') THEN
            NUME=ADVIME+2
            GOTO 9999
C----- INDICATEUR D ETAT
         ELSE IF (VARI(1:7).EQ.'IND_ETA') THEN
            NUME=ADVIME+3
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE VISCOPLASTIQUE DU CIH : LETK

      ELSE IF (MECA(1:6).EQ.'LETK') THEN

C----- VARIABLE D ECROUISSAGE ELASTOPLASTIQUE
         IF (VARI(1:3).EQ.'XIP') THEN
            NUME=ADVIME
            GOTO 9999
C----- DEFORMATION  DEVIATORIQUE PLASTIQUE
         ELSE IF (VARI(1:6).EQ.'GAMMAP') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- VARIABLE D ECROUISSAGE VISCOPLASTIQUE
         ELSE IF (VARI(1:3).EQ.'XIV') THEN
            NUME=ADVIME+2
            GOTO 9999
C----- DEFORMATION  DEVIATORIQUE VISCOPLASTIQUE
         ELSE IF (VARI(1:6).EQ.'GAMMAV') THEN
            NUME=ADVIME+3
            GOTO 9999
C----- INDICATEUR DU DOMAINE DE CONTRACTANCE/DILATANCE
         ELSE IF (VARI(1:5).EQ.'VARV') THEN
            NUME=ADVIME+4
            GOTO 9999
C----- INDICATEUR DE LA VISCOSITE
         ELSE IF (VARI(1:8).EQ.'IND_VISC') THEN
            NUME=ADVIME+5
            GOTO 9999
C----- INDICATEUR DE LA PLASTICITE
         ELSE IF (VARI(1:8).EQ.'IND_PLAS') THEN
            NUME=ADVIME+6
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

C-----LA LOI MECANIQUE EST CJS

      ELSE IF (MECA(1:3).EQ.'CJS') THEN

         IF (NDIM.EQ.3) THEN
            DECAL=2
         ELSE
            DECAL=0
         ENDIF

C----- SEUIL ISOTROPE
         IF (VARI(1:9).EQ.'SEUIL_ISO') THEN
            NUME=ADVIME
            GOTO 9999
C----- ANGLE DU SEUIL DEVIATOIRE
         ELSE IF (VARI(1:7).EQ.'ANG_DEV') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- TENSEUR D ECROUISSAGE CINEMATIQUE
         ELSE IF (VARI(1:3).EQ.'X11') THEN
            NUME=ADVIME+2
            GOTO 9999
         ELSE IF (VARI(1:3).EQ.'X22') THEN
            NUME=ADVIME+3
            GOTO 9999
         ELSE IF (VARI(1:3).EQ.'X33') THEN
            NUME=ADVIME+4
            GOTO 9999
         ELSE IF (VARI(1:3).EQ.'X12') THEN
            NUME=ADVIME+5
            GOTO 9999
         ELSE IF (VARI(1:3).EQ.'X13') THEN
            IF (NDIM.EQ.3) THEN
               NUME=ADVIME+6
               GOTO 9999
            ELSE
               CALL U2MESK('A','ALGORITH9_99',1,VARI)
               NUME=0
            ENDIF
         ELSE IF (VARI(1:3).EQ.'X23') THEN
            IF (NDIM.EQ.3) THEN
               NUME=ADVIME+7
               GOTO 9999
            ELSE
               NUME=0
               CALL U2MESK('A','ALGORITH9_99',1,VARI)
            ENDIF
C----- DISTANCE NORMALISEE AU SEUIL DEVIATOIRE
         ELSE IF (VARI(1:8).EQ.'DIST_DEV') THEN
            NUME=ADVIME+DECAL+6
            GOTO 9999
C----- RAPPORT ENTRE LE SEUIL DEVIATOIRE
C----- ET LE SEUIL DEVIATORIQUE CRITIQUE
         ELSE IF (VARI(1:12).EQ.'DEV_SUR_CRIT') THEN
            NUME=ADVIME+DECAL+7
            GOTO 9999
C----- DISTANCE NORMALISEE AU SEUIL ISOTROPE
         ELSE IF (VARI(1:8).EQ.'DIST_ISO') THEN
            NUME=ADVIME+DECAL+8
            GOTO 9999
C----- NOMBRE D ITERATION INTERNE
         ELSE IF (VARI(1:7).EQ.'NB_ITER') THEN
            NUME=ADVIME+DECAL+9
            GOTO 9999
C----- VALEUR DU TEST LOCAL D ARRET DU PROCESSUS ITERATIF
         ELSE IF (VARI(1:5).EQ.'ARRET') THEN
            NUME=ADVIME+DECAL+10
            GOTO 9999
C----- NOMBRE DE REDECOUPAGE LOCAL DU PAS DE TEMPS
         ELSE IF (VARI(1:7).EQ.'NB_REDE') THEN
            NUME=ADVIME+DECAL+11
            GOTO 9999
C----- SIGNE DU PRODUIT CONTRACTE DE LA CONTRAINTE DEVIATORIQUE
C----- PAR LA DEFORMATION PLASTIQUE DEVIATORIQUE
         ELSE IF (VARI(1:5).EQ.'SIGNE') THEN
            NUME=ADVIME+DECAL+12
            GOTO 9999
C----- INDICATEUR D ETAT
         ELSE IF (VARI(1:7).EQ.'IND_ETA') THEN
            NUME=ADVIME+DECAL+13
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF

      ELSE
         NUME=0
      ENDIF
      
C-----LA LOI MECANIQUE EST HUJEUX

      IF (MECA(1:6).EQ.'HUJEUX') THEN
C----- ECROUISSAGE DEVIATOIRE MECANISME 1
         IF (VARI(1:6).EQ.'RDEV_1') THEN
            NUME=ADVIME
            GOTO 9999
C----- ECROUISSAGE DEVIATOIRE MECANISME 2
         ELSEIF (VARI(1:6).EQ.'RDEV_2') THEN
            NUME=ADVIME+1
            GOTO 9999
C----- ECROUISSAGE DEVIATOIRE MECANISME 3
         ELSEIF (VARI(1:6).EQ.'RDEV_3') THEN
            NUME=ADVIME+2
            GOTO 9999
C----- ECROUISSAGE ISOTROPE MECANISME 4
         ELSEIF (VARI(1:4).EQ.'RISO') THEN
            NUME=ADVIME+3
            GOTO 9999
C----- DEFORMATION PLASTIQUE VOLUMIQUE
         ELSEIF (VARI(1:8).EQ.'EPSIVPLA') THEN
            NUME=ADVIME+4
            GOTO 9999
C----- INDICATEUR D'ETAT MECANISME 1
         ELSEIF (VARI(1:5).EQ.'IND_1') THEN
            NUME=ADVIME+5
            GOTO 9999
C----- INDICATEUR D'ETAT MECANISME 2
         ELSEIF (VARI(1:5).EQ.'IND_2') THEN
            NUME=ADVIME+6
            GOTO 9999
C----- INDICATEUR D'ETAT MECANISME 3
         ELSEIF (VARI(1:5).EQ.'IND_3') THEN
            NUME=ADVIME+7
            GOTO 9999
C----- INDICATEUR D'ETAT MECANISME 4
         ELSEIF (VARI(1:5).EQ.'IND_4') THEN
            NUME=ADVIME+8
            GOTO 9999
         ELSE
            NUME=-1
            GOTO 9999
         ENDIF
         
      ELSE
         NUME=0
      ENDIF
      
9999  CONTINUE

      IF (NUME.EQ.-1) THEN
          VALK(1) = VARI
          VALK(2) = MECA
          CALL U2MESK('A','ALGORITH10_1', 2 ,VALK)
      ENDIF
      END
