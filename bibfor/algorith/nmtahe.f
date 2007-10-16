      SUBROUTINE NMTAHE (FAMI,KPG,KSP,NDIM,IMATE,COMPOR,CRIT,
     &                   INSTAM,INSTAP,EPSM,DEPS,SIGM,VIM,
     &                   OPTION,SIGP,VIP,DSIDEP,IRET)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/10/2007   AUTEUR SALMONA L.SALMONA 
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
      IMPLICIT NONE
      INTEGER            KPG,KSP,NDIM,IMATE
      CHARACTER*(*)      FAMI
      CHARACTER*16       COMPOR(*),OPTION
      REAL*8             CRIT(*),INSTAM,INSTAP
      REAL*8             EPSM(6),DEPS(6)
      REAL*8             SIGM(6),VIM(9),SIGP(6),VIP(9),DSIDEP(6,6)
C ----------------------------------------------------------------------
C     REALISE LA LOI DE TAHERI POUR LES
C     ELEMENTS ISOPARAMETRIQUES EN PETITES DEFORMATIONS
C
C
C
C IN  NDIM    : DIMENSION DE L'ESPACE
C IN  IMATE   : ADRESSE DU MATERIAU CODE
C IN  COMPOR  : COMPORTEMENT : RELCOM ET DEFORM
C IN  CRIT    : CRITERES DE CONVERGENCE LOCAUX
C IN  INSTAM  : INSTANT DU CALCUL PRECEDENT
C IN  INSTAP  : INSTANT DU CALCUL
C IN  EPSM    : DEFORMATIONS A L'INSTANT DU CALCUL PRECEDENT
C IN  DEPS    : INCREMENT DE DEFORMATION
C IN  SIGM    : CONTRAINTES A L'INSTANT DU CALCUL PRECEDENT
C IN  VIM     : VARIABLES INTERNES A L'INSTANT DU CALCUL PRECEDENT
C IN  OPTION  : OPTION DEMANDEE : RIGI_MECA_TANG , FULL_MECA , RAPH_MECA
C OUT SIGP    : CONTRAINTES A L'INSTANT ACTUEL
C OUT VIP     : VARIABLES INTERNES A L'INSTANT ACTUEL
C OUT DSIDEP  : MATRICE TANGENTE
C
C OUT IRET    : CODE RETOUR DE L'INTEGRATION DE LA LOI DE TAHERI
C                              IRET=0 => PAS DE PROBLEME
C                              IRET=1 => ABSENCE DE CONVERGENCE
C
C               ATTENTION LES TENSEURS ET MATRICES SONT RANGES DANS
C               L'ORDRE :  XX YY ZZ XY XZ YZ
C ----------------------------------------------------------------------

      INTEGER     NDIMSI,NITER,K,IRET
      INTEGER     IND

      REAL*8      RAC2
      REAL*8      MATM(3),MAT(14)
      REAL*8      SIGEL(6),EPM(6)
      REAL*8      DP,SP,XI
      REAL*8      F,G,FDP,FDS,GDP,GDS,FDX,GDX,DPMAX,SIG(6),TANG(6,6)
      REAL*8      DET,DIRDP,DIRSP,DIRXI,ENER,MIN,RHO,RHOMAX,INTERI

      PARAMETER (RHOMAX = 2.D0, INTERI = 0.99999D0)



C - INITIALISATION

C    DIMENSION DES TENSEURS ET MISE AUX NORMES
      NDIMSI = NDIM*2
      RAC2 = SQRT(2.D0)
      DO 10 K = 4,NDIMSI
        VIM(2+K) = VIM(2+K) * RAC2
 10   CONTINUE

C    LECTURE DES CARACTERISTIQUES
      CALL NMTAMA(FAMI,KPG,KSP,IMATE,INSTAM,INSTAP,MATM,MAT)


C    CALCUL DES CONTRAINTES ELASTIQUES
      CALL NMTAEL(FAMI,KPG,KSP,IMATE,NDIMSI,MATM,MAT,SIGM,EPSM,DEPS,
     &            EPM,SIGEL,SIGP)


C - CALCUL DES CONTRAINTES REELLES ET DES VARIABLES INTERNES
      IF (OPTION(1:9).EQ.'RAPH_MECA'.OR.OPTION(1:9).EQ.'FULL_MECA') THEN

C      PREDICTION ELASTIQUE
        DP = 0.D0
        XI = 1.D0
        CALL NMTASP(NDIMSI,CRIT,MAT,SIGEL,VIM,EPM,DP,SP,XI,F,IRET)

C      CHARGE
        IF (F.GT.0.D0) THEN

C        CALCUL DE DP : EQUATION SCALAIRE F=0 AVEC  0 < DP < DPMAX
          CALL NMTADP(NDIMSI,CRIT,MAT,SIGEL,VIM,EPM,DP,SP,XI,G,IRET)

C        PLASTICITE CLASSIQUE (G<0)
          IF (G.LE.0.D0) THEN
            CALL NMTAAC(2,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,SIGP,VIP)

C        PLASTICITE A DEUX SURFACES (G>0) -> NEWTON
          ELSE

C          ITERATIONS DE NEWTON
            SP = VIM(2)
            XI = 1.D0
            DO 200 NITER = 1,INT(CRIT(1))

C            DIRECTION DE DESCENTE
              CALL NMTACR(2,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,
     &                    F,G,FDS,GDS,FDP,GDP,FDX,GDX,DPMAX,SIG,TANG)
              DET = FDP*GDS - FDS*GDP
              DIRDP = (G*FDS - F*GDS) / DET
              DIRSP = (F*GDP - G*FDP) / DET
              DIRXI = 0.D0

C            CORRECTION DE LA DIRECTION POUR RESTER DS P>P- ET S>SP>SP-
              IF (DP+RHOMAX*DIRDP.LT.0.D0)    DIRDP= (       -DP)/RHOMAX
              IF (SP+RHOMAX*DIRSP.LT.VIM(2))  DIRSP= (VIM(2) -SP)/RHOMAX
              IF (SP+RHOMAX*DIRSP.GT.MAT(11)) DIRSP= (MAT(11)-SP)/RHOMAX

C            RECHERCHE LINEAIRE
              ENER = (F**2+G**2)/2.D0
              MIN  = (F*FDP+G*GDP)*DIRDP + (F*FDS+G*GDS)*DIRSP
              RHO  = RHOMAX*INTERI
              CALL NMTARL(2,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,
     &                    DIRDP,DIRSP,DIRXI,MIN,RHO,ENER)

C            ACTUALISATION
              DP = DP + RHO*DIRDP
              SP = SP + RHO*DIRSP

            IF (ENER/MAT(4)**2 .LT. CRIT(3)**2) GOTO 210
 200        CONTINUE
            IRET = 1
            GOTO 9999
 210        CONTINUE

            CALL NMTAAC(3,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,SIGP,VIP)
          END IF


C      DECHARGE
        ELSE

C        EXAMEN DE LA SOLUTION ELASTIQUE (XI=0)
          DP = 0.D0
          XI = 0.D0
          IF (VIM(9).NE.0.D0) THEN
            CALL NMTASP(NDIMSI,CRIT,MAT,SIGEL,VIM,EPM,DP,SP,XI,F,IRET)
          END IF

C        DECHARGE CLASSIQUE
          IF (VIM(9).EQ.0.D0 .OR. F.LE.0.D0) THEN
            CALL NMTAAC(0,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,SIGP,VIP)



C        PSEUDO DECHARGE  -> EQUATION SCALAIRE F=0 AVEC  0<T<1
          ELSE

C          CALCUL DE XI : EQUATION SCALAIRE F=0 AVEC  0 < XI < 1
            CALL NMTAXI(NDIMSI,CRIT,MAT,SIGEL,VIM,EPM,DP,SP,XI,G,IRET)

C          ITERATIONS DE NEWTON
            IF (G.GT.0.D0) THEN

              DP = 0.D0
              SP = VIM(2)
              DO 300 NITER = 1,INT(CRIT(1))

C              DIRECTION DE DESCENTE
                CALL NMTACR(3,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,
     &                      F,G,FDS,GDS,FDP,GDP,FDX,GDX,DPMAX,SIG,TANG)
                DET   = FDX*GDS - FDS*GDX
                DIRXI = (G*FDS - F*GDS) / DET
                DIRSP = (F*GDX - G*FDX) / DET
                DIRDP = 0.D0

C              CORRECTION DIRECTION POUR RESTER DANS 0<XI<1 ET SP-<SP<S
                IF (XI+RHOMAX*DIRXI.LT.0.D0)   DIRXI=(-XI) /RHOMAX
                IF (XI+RHOMAX*DIRXI.GT.1.D0)   DIRXI=(1.D0-XI)/RHOMAX
                IF (SP+RHOMAX*DIRSP.LT.VIM(2)) DIRSP=(VIM(2)-SP)/RHOMAX
                IF (SP+RHOMAX*DIRSP.GT.MAT(11))DIRSP=(MAT(11)-SP)/RHOMAX

C              RECHERCHE LINEAIRE
                ENER = (F**2+G**2)/2.D0
                MIN  = (F*FDX+G*GDX)*DIRXI + (F*FDS+G*GDS)*DIRSP
                RHO  = RHOMAX*INTERI
                CALL NMTARL(3,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,
     &                    DIRDP,DIRSP,DIRXI,MIN,RHO,ENER)

C              ACTUALISATION
                XI = XI + RHO*DIRXI
                SP = SP + RHO*DIRSP

              IF (ENER/MAT(4)**2 .LT. CRIT(3)**2) GOTO 310
 300          CONTINUE
              IRET = 1
              GOTO 9999
 310          CONTINUE
            END IF

          CALL NMTAAC(1,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,SIGP,VIP)


          END IF

        END IF

      END IF


C -- RIGIDITE TANGENTE (FULL_MECA)

      IF (OPTION(1:9).EQ.'FULL_MECA') THEN
        IND = INT(VIP(9)+0.5D0)
        CALL NMTARI(IND,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,DSIDEP)
      END IF


C -- RIGIDITE TANGENTE (RIGI_MECA_TANG) -> MATRICE ELASTIQUE

      IF (OPTION(1:14).EQ.'RIGI_MECA_TANG') THEN
        IND = 0
        DP  = 0.D0
        SP  = VIM(2)
        XI  = 1.D0
        CALL NMTARI(IND,NDIMSI,MAT,SIGEL,VIM,EPM,DP,SP,XI,DSIDEP)
      END IF


C REMISE AUX NORMES
      IF (OPTION(1:14).EQ.'RIGI_MECA_TANG') THEN
        DO 400 K = 4,NDIMSI
          VIM(2+K) = VIM(2+K) / RAC2
 400    CONTINUE
      ELSE
        DO 410 K = 4,NDIMSI
          VIM(2+K) = VIM(2+K) / RAC2
          VIP(2+K) = VIP(2+K) / RAC2
 410    CONTINUE
      END IF


 9999 CONTINUE
C FIN ------------------------------------------------------------------
      END
