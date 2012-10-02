      SUBROUTINE VP1ITE(LMASSE,LRAIDE,LDYNAM,X,IMODE,VALP,NEQ,MXITER,
     &                  TOL,ITER,X0,MX,ERR,IEXCL,PLACE,IQUOTI,SOLVEU)
      IMPLICIT NONE
C
      INCLUDE 'jeveux.h'
      REAL*8 X(NEQ,1),MX(NEQ,*),ERR,X0(NEQ)
      REAL*8 VALP
      INTEGER PLACE,IEXCL(*),IMODE,NEQ,MXITER,ITER
      INTEGER LMASSE,LRAIDE,LDYNAM
      CHARACTER*19 SOLVEU
C     ----------------------- ------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 02/10/2012   AUTEUR DESOZA T.DESOZA 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     CALCUL D'UN COUPLE VECTEUR ET VALEUR PROPRE PAR ITERATION INVERSE
C     ------------------------------------------------------------------
C VAR X      :    :  VECTEUR(S) PROPRE(S)
C VAR VALP : R8 :    VALEUR PROPRE, LA VALEUR INITIALE EST CORRIGEE
C     X0     :    :  VECTEUR PROPRE OBTENU A L'ITERATION PRECEDENTE
C IN  MXITER : IS : NOMBRE MAXIMUM D'ITERATION
C OUT ITER   : IS : NOMBRE D'ITERATION EFFECTUEE
C                   EN CAS DE NON CONVERGENCE ITER = -MXITER
C IN  TOL    : R8 : TOLERENCE (CRITERE DE CONVERGENCE SUR LE MODE)
C OUT ERR    : R8 : ERREUR SUR LE DERNIER ITERE
C IN  SOLVEU : K19 : SD SOLVEUR POUR PARAMETRER LE SOLVEUR LINEAIRE
C     ------------------------------------------------------------------
C     QUOTIENT DE RAYLEIGH GENERALISE
C                Y.A.Y / Y.X  = L + Y.( A.X - L.X) / Y.X
C
C     REFERENCE: F.L. BAUER - J.H. WILKINSON - C. REINSCH
C        HANDBOOK FOR AUTOMATIC COMPUTATION - LINEAR ALGEBRA - VOL.2
C        PAGE 73
C     ------------------------------------------------------------------


      REAL*8 XMX,X0MX,XXX,DET0,PVALP
      REAL*8 COEF,COEFT,RMG
      COMPLEX*16  CBID
      CHARACTER*1  KBID
      CHARACTER*19 K19BID,MATASS,CHCINE,CRITER
C     ------------------------------------------------------------------
C
C     INIT. OBJETS ASTER
C-----------------------------------------------------------------------
      INTEGER IDET0 ,IEQ ,IER ,IQUOTI ,JTER 
      REAL*8 DSEED ,TOL 
      INTEGER IRET
C-----------------------------------------------------------------------
      MATASS=ZK24(ZI(LDYNAM+1))
      CHCINE=' '
      CRITER=' '
      K19BID=' '

C     --- VECTEUR INITIAL ALEATOIRE ---
      DSEED = 526815.0D0
      CALL GGUBS(DSEED,NEQ,X0)
      CALL VPMORT(NEQ,X0,X,MX,IMODE)
      CALL MRMULT('ZERO',LMASSE,X0,MX(1,IMODE),1,.FALSE.)
      DO 20 IEQ = 1,NEQ
        MX(IEQ,IMODE) = MX(IEQ,IMODE)*IEXCL(IEQ)
   20 CONTINUE
C
      X0MX = 0.D0
      DO 30 IEQ = 1,NEQ
        X0MX = X0MX + X0(IEQ)*MX(IEQ,IMODE)
   30 CONTINUE
C
      COEF = 1.D0/SQRT(ABS(X0MX))
      COEFT = SIGN(1.D0,X0MX)*COEF
      DO 40 IEQ = 1,NEQ
        X0(IEQ) = COEF*X0(IEQ)
        MX(IEQ,IMODE) = COEFT*MX(IEQ,IMODE)
   40 CONTINUE
C
      DO 100 JTER = 1,MXITER
        ITER = JTER
C
C        --- ELIMINATION DES DDL EXTERNES ---
        DO 110 IEQ = 1,NEQ
          X(IEQ,IMODE) = MX(IEQ,IMODE)*IEXCL(IEQ)
  110   CONTINUE
C
C        --- RESOLUTION DE (K-W.M) X = (M).X ---
        CALL RESOUD(MATASS,K19BID ,SOLVEU,CHCINE    ,1     ,
     &              K19BID,K19BID ,KBID  ,X(1,IMODE),CBID  ,
     &              CRITER,.FALSE.,0     ,IRET      )
C
C        --- ORTHOGONALISATION EN CAS DE MODES MULTIPLES  ---
        CALL VPMORT(NEQ,X(1,IMODE),X,MX,IMODE)
C
C        --- CALCUL DE M.XN ---
        CALL MRMULT('ZERO',LMASSE,X(1,IMODE),MX(1,IMODE),1,.FALSE.)
        DO 120 IEQ = 1,NEQ
          MX(IEQ,IMODE) = MX(IEQ,IMODE)*IEXCL(IEQ)
  120   CONTINUE
C
C        --- CALCUL DE XN.M.XN ---
        XMX = 0.D0
        DO 130 IEQ = 1,NEQ
          XMX = XMX + X(IEQ,IMODE)*MX(IEQ,IMODE)
  130   CONTINUE
C
C        --- NORMALISATION DE XN ---
        COEF = 1.D0/SQRT(ABS(XMX))
        COEFT = SIGN(1.D0,XMX)*COEF
        DO 140 IEQ = 1,NEQ
          X0(IEQ) = COEF*X0(IEQ)
          MX(IEQ,IMODE) = COEFT*MX(IEQ,IMODE)
  140   CONTINUE
C
C        --- CALCUL DE LA NORME DE XN-1.M.XN ---
        XXX = 0.D0
        DO 150 IEQ = 1,NEQ
          XXX = XXX + X0(IEQ)*MX(IEQ,IMODE)
  150   CONTINUE
C
C        --- CALCUL DE L'ERREUR ---
        COEF = XXX/XMX/COEF
        ERR = ABS(ABS(XXX)-1.D0)
        IF (ERR.LT.TOL) GO TO 900
C
C        --- SAUVEGARDE DE XN DANS XN-1 ---
        DO 160 IEQ = 1,NEQ
          X0(IEQ) = X(IEQ,IMODE)
  160   CONTINUE
C
C        --- SHIFT ---
        IF (IQUOTI.GT.0) THEN
          PVALP = VALP + COEF
C
          IF (PVALP.GT.VALP*0.9D0 .AND. PVALP.LT.VALP*1.1D0) THEN
C --- POUR OPTIMISER ON NE CALCULE PAS LE DET
            VALP = PVALP
            CALL VPSTUR(LRAIDE,VALP,LMASSE,LDYNAM,
     &                  DET0,IDET0,PLACE,IER,SOLVEU,.FALSE.,.TRUE.)
          END IF

        END IF

  100 CONTINUE
C
C     --- SORTIE SANS CONVERGENCE ---
      ITER = -MXITER
  900 CONTINUE
C
C     --- FREQUENCE CORRIGEE ---
      VALP = VALP + COEF
C
C     --- NORMALISATION DU VECTEUR ---
      RMG = 0.D0
      DO 911 IEQ = 1,NEQ
        RMG = MAX(ABS(X(IEQ,IMODE)),RMG)
  911 CONTINUE
      DO 912 IEQ = 1,NEQ
        X(IEQ,IMODE) = X(IEQ,IMODE)/RMG
  912 CONTINUE
C
      END
