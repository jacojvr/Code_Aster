      SUBROUTINE DELAPR(MODELE, NUMEDE, SOLVDE, MATE, COMREF, COMPOR,
     &           PENCST, PARCRI, CARCRI, ITEPRM, VALMOI, DEPDEL, VALPLU,
     &                  VARDEP, LAGDEP, GRADIA, ENEREL, CONVDE, CONVPR,
     &                  DIFIMP, DIFEFF, LICCVG)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/12/2004   AUTEUR VABHHTS J.PELLET 
C RESPONSABLE PBADEL P.BADEL

C TOLE CRP_21

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
      LOGICAL CONVPR
      INTEGER ITEPRM, LICCVG
      REAL*8 CONVDE(*),PARCRI(*),DIFIMP, DIFEFF
      CHARACTER*(*) MATE
      CHARACTER*8 MODELE
      CHARACTER*19 SOLVDE,PENCST
      CHARACTER*24 VALMOI,VALPLU,COMREF,NUMEDE
      CHARACTER*24 DEPDEL,COMPOR
      CHARACTER*24 CARCRI,VARDEP,LAGDEP,GRADIA, ENEREL

C ----------------------------------------------------------------------
C  LAGRANGIEN PRIMAL :  PROBLEME SANS CONTRAINTES (NEWTON + WOLFE)
C ----------------------------------------------------------------------
C IN        MODELE  NOM DU MODELE DELOCALISE
C IN        NUMEDE  NUME_DDL
C IN        SOLVDE  SOLVEUR
C IN        MATE    CHAMP MATERIAU
C IN        COMREF  VALEURS DE REFERENCE DES VAR. COM.
C IN        COMPOR  COMPORTEMENT MECANIQUE
C IN        PENCST  CARTE DE PENALISATION DU LAGRANGIEN AUGMENTE
C IN        PARCRI  CRITERES DE CONVERGENCE GLOBAUX
C IN        CARCRI  CRITERES POUR LOIS DE COMPORTEMENT
C IN        ITEPRM  NOMBRE MAXIMUM D'ITERATIONS PRIMALES
C IN        VALMOI  VARIABLES EN T-
C IN        DEPDEL  CHAM_NO INCREMENT DE DEPLACEMENT
C IN/JXVAR  VALPLU  VARIABLES EN T+
C                     JXOUT POUR VARPLU (INCLUS DANS VALPLU)
C IN        VARDEP  CHAMP    NON LOCAL EN T+
C IN        LAGDEP  LAGRANGE NON LOCAL (/LC SUR GRAD) EN T+
C IN/JXOUT  GRADIA  - GRADIENT DE L'ENERGIE ( /LC SUR GRAD )
C                     SIGNE OPPOSE AFIN DE MINIMISER ET NON MAXIMISER
C IN/JXOUT  ENEREL  CHAM_ELEM ENERGIE (OPPOSE DU LAGRANGIEN AUGMENTE)
C OUT       CONVDE  VALEURS DE CONVERGENCE
C OUT       CONVPR  VRAI SI CONVERGENCE PRIMAL
C IN        DIFIMP  VARIATION E(N+1)-E(N) MAXIMALE IMPOSEE
C OUT       DIFEFF  VARIATION E(N+1)-E(N) REALISEE
C OUT LICCVG  I   RESULTAT DE L'INTEGRATION
C                  0 - OK
C                  1 - ECHEC DANS L'INTEGRATION (LOCALE OU RELAXEE)
C ----------------------------------------------------------------------
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      CHARACTER*32       JEXNUM
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------


      LOGICAL WOLFE
      INTEGER ITEPRI, NDDL, ITERHO, I
      INTEGER JMON, JVARDE, JRES
      REAL*8  T, TOLD, Q(2), CONTEX(9), DDOT, QOLD, Q0, DIFNRJ
      REAL*8  QREF, QINF, QSUP, TINF, TSUP, TMAX, PREC, X(4), Y(4)
      REAL*8  R8MAEM
      CHARACTER*8  PROELE, K8BID
      CHARACTER*24 RESASS, MONTEE, ENERE0


      CALL JEMARQ()

C -- INITIALISATION

      LICCVG = 0
      PROELE = '&&PRDEEL'
      RESASS = '&&DELAPR.REDEAS'
      MONTEE = '&&DELAPR.MONTEE'
      ENERE0 = '&&DELAPR.ENERE0'
      CALL JELIRA(VARDEP(1:19) // '.VALE','LONMAX',NDDL,K8BID)


C -- RESOLUTION DU PROBLEME LOCAL POUR LA PREMIERE ITERATION

        CALL DELALO(MODELE, NUMEDE, MATE, COMREF, COMPOR,
     &          PENCST, CARCRI, VALMOI, DEPDEL, VALPLU, VARDEP,
     &          LAGDEP, PROELE, RESASS, GRADIA, ENEREL)


C -- ITERATIONS NEWTON

      DO 10 ITEPRI = 0, ITEPRM


C   -- DIRECTION DE MONTEE PAR NEWTON

        CALL DELAGL(NUMEDE, SOLVDE, PROELE, RESASS, MONTEE)


C   -- VARIATION D'ENERGIE ATTENDUE

        CALL JEVEUO(RESASS(1:19) // '.VALE', 'L', JRES)
        CALL JEVEUO(MONTEE(1:19) // '.VALE', 'L', JMON)
        DIFEFF = ABS(DDOT(NDDL, ZR(JRES),1, ZR(JMON),1))


C   -- RECHERCHE LINEAIRE

        WOLFE = .TRUE.
        T     = 0.D0
        TINF  = 0
        TSUP  = R8MAEM()
        TMAX  = 0.D0

        CALL COPISD('CHAMP_GD','V', ENEREL, ENERE0)


        DO 20 ITERHO = 1, 20

C        TEST DE CONVERGENCE DE LA SOLUTION COURANTE
          CALL DEPRCV(PARCRI, RESASS, CONVPR, CONVDE)
          IF (CONVPR .AND. DIFEFF.LT.DIFIMP) GOTO 9000


          CALL JEVEUO(RESASS(1:19) // '.VALE', 'L', JRES)
          CALL JEVEUO(MONTEE(1:19) // '.VALE', 'L', JMON)

          CALL DELANR(ENERE0, ENEREL, DIFNRJ)

          Q(1) =  - DIFNRJ
          Q(2) =  - DDOT(NDDL, ZR(JRES),1, ZR(JMON),1)

          IF (ITERHO.EQ.1) THEN
            QREF = Q(2)
            IF (QREF.GT.0)
     &        CALL UTMESS('F','DELAPR','MAUVAISE DIRECTION DE DESCENTE')
          END IF


C        STOCKAGE DE BORNES OPTIMALES EN CAS D'ECHEC DE LA RL
          IF (Q(2).GE.0 .AND. T.LT.TSUP) THEN
            TSUP = T
            QSUP = Q(2)
          ELSE IF (Q(2).LE.0 .AND. T.GT.TINF) THEN
            TINF = T
            QINF = Q(2)
          END IF
          TMAX = MAX(TMAX, T)


          TOLD = T
          CALL ALWOLF(CONTEX, Q, WOLFE, T)
          IF (WOLFE) GOTO 100

C        REACTUALISATION DES INCONNUE
          CALL JEVEUO(VARDEP(1:19) // '.VALE', 'E', JVARDE)
          CALL DAXPY(NDDL, TOLD-T, ZR(JMON),1, ZR(JVARDE),1)

C        RESOLUTION DU PROBLEME LOCAL
          CALL DELALO(MODELE, NUMEDE, MATE, COMREF, COMPOR,
     &          PENCST, CARCRI, VALMOI, DEPDEL, VALPLU, VARDEP,
     &          LAGDEP, PROELE, RESASS, GRADIA, ENEREL)

 20     CONTINUE


C      ECHEC DANS LA RECHERCHE LINEAIRE : RESOLUTION Q(2)=0

C      RECHERCHE D'UNE BORNE POSITIVE
        IF (TSUP .EQ. R8MAEM()) THEN

          DO 30 I = 1,100
            TMAX = TMAX*10
            TOLD = T
            T    = TMAX
            CALL JEVEUO(VARDEP(1:19) // '.VALE', 'E', JVARDE)
            CALL DAXPY(NDDL, TOLD-T, ZR(JMON),1, ZR(JVARDE),1)
            CALL DELALO(MODELE, NUMEDE, MATE, COMREF, COMPOR,
     &          PENCST, CARCRI, VALMOI, DEPDEL, VALPLU, VARDEP,
     &          LAGDEP, PROELE, RESASS, GRADIA, ENEREL)
            CALL JEVEUO(RESASS(1:19) // '.VALE', 'L', JRES)
            CALL JEVEUO(MONTEE(1:19) // '.VALE', 'L', JMON)
            Q(2) =  - DDOT(NDDL, ZR(JRES),1, ZR(JMON),1)
            IF (Q(2).GT.0) GOTO 35
 30       CONTINUE
          LICCVG = 1
          CALL UTMESS('I','DELAPR','PAS DE BORNE SUP')
          GOTO 9000

 35       CONTINUE
          TSUP = T
          QSUP = Q(2)
        END IF


C      RECHERCHE DU MINIMUM PAR RESOLUTION Q2(T) = 0
        PREC = ABS(QREF/10)
        X(1) = TINF
        Y(1) = QINF
        X(2) = TSUP
        Y(2) = QSUP
        X(3) = X(1)
        Y(3) = Y(1)
        X(4) = X(2)
        Y(4) = Y(2)

        DO 50 ITERHO = 1, 100
          IF (MOD(ITERHO,3) .EQ. 0) THEN
            CALL ZERODI(X,Y)
          ELSE
            CALL ZEROCO(X,Y)
          END IF

          TOLD = T
          T    = X(4)
          CALL JEVEUO(VARDEP(1:19) // '.VALE', 'E', JVARDE)
          CALL DAXPY(NDDL, TOLD-T, ZR(JMON),1, ZR(JVARDE),1)
          CALL DELALO(MODELE, NUMEDE, MATE, COMREF, COMPOR,
     &          PENCST, CARCRI, VALMOI, DEPDEL, VALPLU, VARDEP,
     &          LAGDEP, PROELE, RESASS, GRADIA, ENEREL)
          CALL JEVEUO(RESASS(1:19) // '.VALE', 'L', JRES)
          CALL JEVEUO(MONTEE(1:19) // '.VALE', 'L', JMON)
          Q(2) =  - DDOT(NDDL, ZR(JRES),1, ZR(JMON),1)

          IF (ABS(Q(2))      .LE. PREC ) GOTO 100
          IF (ABS(X(3)-X(4)) .LE. 1.D-3) GOTO 100
          Y(4) = Q(2)
 50     CONTINUE
 55     CONTINUE
        CALL UTMESS('I','DELAPR','PROBLEME RECHERCHE LINEAIRE PRIMAL')
        LICCVG = 1
        GOTO 9000


 100    CONTINUE
 10   CONTINUE


      CALL UTMESS ('I','DELAPR','ITERATIONS PRIMALES INSUFFISANTES')
      LICCVG = 1

 9000 CONTINUE
      CALL JEDEMA()
      END
