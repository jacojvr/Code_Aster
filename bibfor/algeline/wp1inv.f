      SUBROUTINE WP1INV(LMASSE,LAMOR,LRAIDE,TOLF,NITF,MXRESF,NBFREQ,NEQ,
     &                  RESUFI,RESUFR,RESUFK,VECPRO,SOLVEU)
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER           LMASSE,LAMOR,LRAIDE,NITF,NBFREQ,NEQ
      INTEGER           RESUFI(MXRESF,*)
      COMPLEX*16        VECPRO(NEQ,*)
      REAL*8            TOLF,RESUFR(MXRESF,*)
      CHARACTER*(*)     RESUFK(MXRESF,*)
      CHARACTER*19      SOLVEU
C     ------------------------------------------------------------------
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
C     CALCUL DES VECTEURS PROPRES COMPLEXES DU SYSTEME QUADRATIQUE
C                         2
C                        L (M) Y + L (C) Y + (K) Y = 0
C     PAR LA METHODE D'ITERATION INVERSE
C     -----------------------------------------------------------------
C
C     -----------------------------------------------------------------
      INTEGER       LMAT(3),IBID
      CHARACTER*1   TYPCST(3),KBID
      CHARACTER*8   NOMDDL
      CHARACTER*19  MATDYN,K19BID,MATASS,CHCINE,CRITER,MATPRE
      CHARACTER*24  NDYNAM,NMAT(3)
      COMPLEX*16    RP1,RP,RNORM,RPP
      COMPLEX*16    CZERO, CUN
      COMPLEX*16    RMASSE, RAMOR, RRAIDE
      REAL*8        CONST(6),FREQOM,RBID
C     -----------------------------------------------------------------
C-----------------------------------------------------------------------
      INTEGER ICOMB ,IEQ ,IMODE ,ITER ,JTER ,LACC1 ,LACC2 
      INTEGER LDYNAM ,LYN ,MXRESF 
      REAL*8 DSEED ,ERR ,ERR2 
      INTEGER IRET
C-----------------------------------------------------------------------
      DATA          NOMDDL /'        '/
C     -----------------------------------------------------------------
      CALL JEMARQ()
      CZERO =  DCMPLX(0.D0 , 0.D0)
      CUN   =  DCMPLX(1.D0 , 0.D0)

C     INIT. OBJETS ASTER
      CHCINE=' '
      CRITER=' '
      MATPRE=' '
      K19BID=' '
C
C     --- CREATION DES VECTEURS DE TRAVAIL ---
      CALL WKVECT('&&WP1INV.YN_ASSOCIE_A_XN','V V C',NEQ,LYN)
      CALL WKVECT('&&WP1INV.XN_MOINS_1     ','V V C',NEQ,LACC1)
      CALL WKVECT('&&WP1INV.YN_MOINS_1     ','V V C',NEQ,LACC2)
CCC   CALL WKVECT('&&WP1INV.M_ORTHOGONALISE','V V C',NEQ*NBFREQ,LMORTH)
C
C     --- CREATION DE LA MATRICE DYNAMIQUE A VALEUR COMPLEXE ---
      NEQ = ZI(LMASSE+2)
      MATDYN =  '&&WP1INV.MATR_DYNA'
      CALL MTDEFS(MATDYN,ZK24(ZI(LMASSE+1)),'V','C')
      CALL MTDSCR(MATDYN)
      NDYNAM=MATDYN(1:19)//'.&INT'
      CALL JEVEUO(NDYNAM,'E',LDYNAM)
      MATASS=ZK24(ZI(LDYNAM+1))
C
C      --- DEFINITION DES TYPES DE CONSTANTES ET DES MATRICES ---
      LMAT(1) = LMASSE
      LMAT(2) = LAMOR
      LMAT(3) = LRAIDE
      NMAT(1) = ZK24(ZI(LMAT(1)+1))
      NMAT(2) = ZK24(ZI(LMAT(2)+1))
      NMAT(3) = ZK24(ZI(LMAT(3)+1))
      DO 10 ICOMB = 1, 3
         TYPCST(ICOMB) = 'C'
 10   CONTINUE
      CONST(5) = - 1.D0
      CONST(6) = - 0.D0
C
C
      DO 100 IMODE = 1,NBFREQ
C
         RP    = DCMPLX( RESUFR(IMODE,3), RESUFR(IMODE,2) )
C
C        --- FACTORISATION DE LA MATRICE DYNAMIQUE ---
         CONST(1) = DBLE(- RP*RP)
         CONST(2) = DIMAG(- RP*RP)
         CONST(3) = DBLE(- RP)
         CONST(4) = DIMAG(- RP)
         CALL MTCMBL(3,TYPCST,CONST,NMAT,NDYNAM,NOMDDL,' ','ELIM=')
         CALL PRERES(SOLVEU,'V',IBID,MATPRE,MATASS,IBID,2)
C
C        --- CHOIX D'UN VECTEUR INITIAL POUR LA METHODE ---
         DSEED = 123457.D0
         CALL GGUBSC(DSEED,NEQ,VECPRO(1,IMODE))
CCC      CALL WP1ORT(NEQ,VECPRO,VECPRO(1,IMODE),ZC(LMORTH),IMODE)
         DO 110 IEQ = 1, NEQ
            ZC(LYN+IEQ-1) = RP * VECPRO(IEQ,IMODE)
  110    CONTINUE
C
C        --- METHODE D'ITERATION INVERSE ---
         RPP = RP
         DO 200 JTER = 1 , NITF
            ITER = JTER
C
C           --- M-NORMALISATION DES VECTEURS XN-1 ET YN-1 ---
            CALL MCMULT('ZERO',LMASSE,VECPRO(1,IMODE),ZC(LACC2),1,
     &.FALSE.)
C
C           --- RENORMALISATION ---
            RNORM = CZERO
            DO 210 IEQ = 1, NEQ
               RNORM = RNORM + DCONJG(VECPRO(IEQ,IMODE))*ZC(LACC2+IEQ-1)
  210       CONTINUE
            RNORM = SIGN(1.D0,DBLE(RNORM)) * CUN /SQRT(ABS(DBLE(RNORM)))
            DO 215 IEQ = 1, NEQ
               VECPRO(IEQ,IMODE) = VECPRO(IEQ,IMODE) * RNORM
               ZC(LYN+IEQ-1)     = ZC(LYN+IEQ-1)     * RNORM
  215       CONTINUE
C
C           --- CONSTITUTION DU SECOND MEMBRE POUR CALCULER XN ---
            CALL MCMULT('ZERO',LAMOR,VECPRO(1,IMODE),ZC(LACC2),1,
     &.FALSE.)
            DO 220 IEQ = 1, NEQ
               ZC(LACC1+IEQ-1) = RP * VECPRO(IEQ,IMODE)
  220       CONTINUE
            CALL MCMULT('CUMU',LMASSE,ZC(LACC1),ZC(LACC2),1,.FALSE.)
            CALL MCMULT('CUMU',LMASSE,ZC(LYN),ZC(LACC2),1,.FALSE.)
C
C           --- RESOLUTION ---
            CALL RESOUD(MATASS,K19BID ,SOLVEU,CHCINE,1        ,
     &                  K19BID,K19BID ,KBID  ,RBID  ,ZC(LACC2),
     &                  CRITER,.FALSE.,0     ,IRET  )
C
CCC         --- ORTHOGONALISATION DU VECTEUR AVEC LES PRECEDENTS ---
CCC         CALL WP1ORT(NEQ,VECPRO,ZC(LACC2),ZC(LMORTH),IMODE)
C
C           --- CALCUL DE YN ---
            DO 225 IEQ = 1, NEQ
               ZC(LYN+IEQ-1) =  RP*ZC(LACC2+IEQ-1)+VECPRO(IEQ,IMODE)
  225       CONTINUE
C
C           --- CALCUL DE LA VALEUR PROPRE ---
            CALL MCMULT('ZERO',LMASSE,ZC(LACC2),ZC(LACC1),1,.FALSE.)
            RMASSE = CZERO
            DO 230 IEQ = 0, NEQ-1
               RMASSE = RMASSE + DCONJG(ZC(LACC2+IEQ))*ZC(LACC1+IEQ)
  230       CONTINUE
            CALL MCMULT('ZERO',LRAIDE,ZC(LACC2),ZC(LACC1),1,.FALSE.)
            RRAIDE = CZERO
            DO 235 IEQ = 0, NEQ-1
               RRAIDE = RRAIDE + DCONJG(ZC(LACC2+IEQ))*ZC(LACC1+IEQ)
  235       CONTINUE
            CALL MCMULT('ZERO',LAMOR,ZC(LACC2),ZC(LACC1),1,.FALSE.)
            RAMOR = CZERO
            DO 240 IEQ = 0, NEQ-1
               RAMOR = RAMOR + DCONJG(ZC(LACC2+IEQ))*ZC(LACC1+IEQ)
  240       CONTINUE
C
            RP1 = -RAMOR + SQRT( RAMOR*RAMOR - 4.D0*RMASSE*RRAIDE)
            RP1 = RP1 / (2.D0*RMASSE)
            RP1 = DCMPLX( DBLE(RP1) , ABS(DIMAG(RP1)) )
C
C           --- CONVERGENCE GLOBALE EN VALEUR RELATIVE ---
            ERR = ABS(RPP-RP1)/ABS(RP1)
C
C           --- ON ARCHIVE XN  ---
            DO 245 IEQ = 1, NEQ
               VECPRO(IEQ,IMODE) = ZC(LACC2+IEQ-1)
  245       CONTINUE
            RPP = RP1
C
            IF(ERR.LT.TOLF)  THEN
C             --- ERREUR SUR CHAQUE PARTIE EN ABSOLU ---
              ERR2 = MAX( ABS(DBLE(RPP-RP1)),ABS(DIMAG(RPP-RP1)) )
              IF(ERR2 .LT.TOLF)  GO TO 300
            ENDIF
  200    CONTINUE
C
         ITER = -NITF
C
  300    CONTINUE
C
C        --- ARCHIVAGE DES VALEURS ----
         RESUFR(IMODE,2)  =  DIMAG(RP1)*DIMAG(RP1)
         RESUFR(IMODE,1)  = FREQOM(RESUFR(IMODE,2))
         RESUFR(IMODE,3)  = -DBLE(RP1)/ABS(RP1)
         RESUFR(IMODE,15) =  ERR
         RESUFI(IMODE,4)  =  ITER
         RESUFK(IMODE,2) = 'INVERSE_C'
C
C        --- M-NORMALISATION DES VECTEURS TROUVEE ---
         CALL MCMULT('ZERO',LMASSE,VECPRO(1,IMODE),ZC(LACC2),1,
     &.FALSE.)
C
C        --- RENORMALISATION ---
         RNORM = CZERO
         DO 310 IEQ = 1, NEQ
            RNORM = RNORM + DCONJG(VECPRO(IEQ,IMODE))*ZC(LACC2+IEQ-1)
  310    CONTINUE
         RNORM = SIGN(1.D0,DBLE(RNORM)) * CUN /SQRT(ABS(DBLE(RNORM)))
         DO 315 IEQ = 1, NEQ
            VECPRO(IEQ,IMODE) = VECPRO(IEQ,IMODE) * RNORM
  315    CONTINUE
CCC      LMORT = LMORTH + (IMODE-1)*NEQ
CCC      CALL MCMULT('ZERO',LMASSE,VECPRO(1,IMODE),'C',ZC(LMORT),1)
C
  100 CONTINUE
C
C     --- MENAGE ---
      CALL JEDETR('&&WP1INV.YN_ASSOCIE_A_XN')
      CALL JEDETR('&&WP1INV.XN_MOINS_1     ')
      CALL JEDETR('&&WP1INV.YN_MOINS_1     ')
      CALL DETRSD('MATR_ASSE','&&WP1INV.MATR_DYNA')
C
      CALL JEDEMA()
      END
