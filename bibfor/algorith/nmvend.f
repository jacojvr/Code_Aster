      SUBROUTINE NMVEND(MATERD,MATERF,NMAT,DT1,TM,TP,TREF,EPSM,DEPS,
     &         SIGM,VIM,NDIM,CRIT,DAMMAX,ETATF,P,NP,BETA,NB,IER)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 04/09/2006   AUTEUR JMBHH01 J.M.PROIX 
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
C TOLE CRP_7
C-----------------------------------------------------------------------
      IMPLICIT NONE
C
      INTEGER       NMAT, NP , NB, IER, NDIM
      REAL*8        MATERD(NMAT,2), MATERF(NMAT,2)
      REAL*8        P(NP), BETA(NB), VIM(3), DT1,CRIT(*)
      REAL*8        EPSM(6),DEPS(6),TP,TM,TREF,SIGM(6)
      CHARACTER*7   ETATF(3)
C-----------------------------------------------------------------------
C     INTEGRATION DE LA LOI DE COMPORTEMENT VISCO PLASTIQUE DE
C     CHABOCHE AVEC ENDOMAGEMENT. INTEGRATION EULER IMPLICITE
C     CAS OU ON SE RAMENE A UNE SEULE EQUATION
C-----------------------------------------------------------------------
C-- ARGUMENTS
C------------
C
C IN   MATE    : PARAMETRE MATERIAU A L'INSTANT T
C      IMATE   : ADRESSE DU MATERIAU CODE
C      NMAT    : DIMENSION DE MATE
C      MATCST  : 'OUI' SI MATERIAU CST ENTRE T- ET T
C                'NAP' SI LE PARAMETRE K_D EST UNE NAPPE
C                'NON' SINON
C      HOOK    : OPERATEUR DE HOOK
C      DT      : INCREMENT DE TEMPS
C      TP      : TEMPERATURE A T+
C      NP      : NOMBRE D'INCONNUES ASSOCIEES AUX VARIABLES D'ETAT
C      NB      : NOMBRE D'INCONNUES ASSOCIEES AUX CONTRAINTES
C      RM      : VARIABLES INTERNES A T-
C      DM      : VARIABLES INTERNES A T-
C      EP      : DEFORMATIONS TOTALES ET THERMIQUE A T ET 
C                VISCOPLASTIQUE A T-      
C OUT  P       : INCONNUES ASSOCIEES AUX VARIABLES D'ETAT
C      BETA    : INCONNUES ASSOCIEES AUX CONTRAINTES
C      IER     : CODE DE RETOUR D'ERREUR
C                0=OK
C                1=NOOK
C
C INFO P(1)=RPOINT,  P(2)=DFOINT
C-----------------------------------------------------------------------
      INTEGER     I,NDT,NDI,NITER,IR
      REAL*8      DAMMAX, EPSI, R8PREM, PREC,PRECR,VAL0,DEVSE(6),SIGE(6)
C
      REAL*8  EPST(6),DEPSTH(6), EPSED(6),E,NU,ALPHAP,ALPHAM,DD,DR
      COMMON /TDIM/   NDT  , NDI
      REAL*8   NMFEND,DKOOH(6,6),HOOKF(6,6),XAP,EPSEF(6),DEPSE(6)
      REAL*8   H1SIGF(6),LCNRTS,SEQ1MD,SEQE,TROISK,TROIKM,SIGMMO
      EXTERNAL NMFEND
      COMMON /FVENDO/MU,SYVP,KVP,RM,DM,SEQE,AD,DT,NVP,MVP,RD,IR
      REAL*8 MU,SYVP,KVP,SEQ,AD,DT,NVP,UNSURN,MVP,UNSURM,RM,DM,RD
      REAL*8 EM,NUM,DEVSIG(6),DEPSMO,COEF,SIGPMO,DF,VAL1,DEVSM(6),MUM
      REAL*8 DEVEP(6),VALX,DENO,    DFDS(6), D2FDS(6,6)
C
C-----------------------------------------------------------------------
C-- 1. INITIALISATIONS
C   ===================
      NITER =  INT(CRIT(1))
      PREC =  CRIT(3)
      IER = 0
      DT=DT1
      
      RM=VIM(NB+2)
      DM=VIM(NB+3)
      E =MATERF(1,1)
      NU =MATERF(2,1)
      MU=E/2.D0/(1.D0+NU)
      TROISK = E/(1.D0-2.D0*NU)
      EM =MATERD(1,1)
      NUM =MATERD(2,1)
      TROIKM = EM/(1.D0-2.D0*NUM)
      MUM=EM/2.D0/(1.D0+NUM)
      
        IF (NDIM.EQ.2) THEN
           SIGM(5)=0.D0
           SIGM(6)=0.D0
           DEPS(5)=0.D0
           DEPS(6)=0.D0
        ENDIF   
      ALPHAP=MATERF(3,1)
      ALPHAM=MATERD(3,1)
      SYVP = MATERF(1,2)
      NVP  = MATERF(4,2)
      MVP  = MATERF(5,2)
      KVP  = MATERF(6,2)
      RD   = MATERF(7,2)
      AD   = MATERF(8,2)
      UNSURN=1.D0/NVP
      UNSURM=1.D0/MVP
      
      CALL LCDEVI(SIGM,DEVSM)
      CALL LCDEVI(DEPS,DEVEP)
        IF (NDIM.EQ.2) THEN
           DEVSM(5)=0.D0
           DEVSM(6)=0.D0
           DEVEP(5)=0.D0
           DEVEP(6)=0.D0
        ENDIF   

      IF (DM.GE.1.D0) DM=DAMMAX
      DO 15 I = 1,6          
          EPSEF(I)=DEVSM(I)/(1.D0-DM)/2.D0/MUM+DEVEP(I)
 15   CONTINUE
      CALL LCPRSV(2.D0*MU,EPSEF,DEVSE)
      
      SEQE= LCNRTS(DEVSE)
      IF (SEQE.GT.SYVP)THEN
C RESOLUTION DE L'EQUATION EN DR
         VAL0 = NMFEND(0.D0)
         IF (VAL0.GT.0.D0) CALL UTMESS('F','NMVEND','VALO >0')
         
C        CALCUL D'UNE APPROXILATION INITIALE DE LA SOLUTION
         XAP = SEQE/MU/3.D0
         
         VAL1 = NMFEND(XAP)
         IF (VAL1.LT.0.D0) THEN
C EXPLORATION DE L'INTERVALLE (0,XAP)        
            DO 22 I=1,NITER
               XAP=XAP/10.D0
               IF (NMFEND(XAP).GE.0.D0) THEN
                  GOTO 21   
               ENDIF               
22          CONTINUE 
C EXPLORATION DE L'INTERVALLE (XAP,1)        
            DO 20 I=1,NITER
               XAP=XAP*10.D0
               IF (XAP.GT.1.D0) THEN
                  IER=1
                  GOTO 9999
               ELSE
                  VALX=NMFEND(XAP)
                  IF (VALX.GE.0.D0)  GOTO 21   
               ENDIF               
20          CONTINUE 
            IER=1
            GOTO 9999           
         ELSE
C RECHERCHE DU PLUS PETIT X TEL QUE F(X) >0 DANS L'INTERVALLE(0,XAP)
            DO 23 I=1,NITER
               XAP=XAP/10.D0
               VALX=NMFEND(XAP)
               IF (VALX.LT.0.D0) THEN   
                  XAP=XAP*10.D0
                  GOTO 21   
               ENDIF               
23          CONTINUE 
         ENDIF
21       CONTINUE            

         PRECR = PREC * ABS(VAL0)
         CALL ZEROFO(NMFEND,VAL0,XAP,PRECR,NITER,DR,IER)
         IF (IER.NE.0) THEN
            GOTO 9999
         ENDIF
         IF (DR.LE.0.D0) THEN
            CALL UTMESS('F','NMVEND','DR NEGATIF')
         ENDIF
      
         SEQ1MD=KVP*((DR/DT)**UNSURN)*((RM+DR)**UNSURM)+SYVP
         DD=DT*(SEQ1MD/AD)**RD
         DF=DM+DD
      
         IF (DF.GE.DAMMAX) THEN
            DD = 0.D0
            DF = DAMMAX
            DR=0.D0
            ETATF(3)='DAMMAXO'
         ENDIF
      
         SEQ=(1.D0-DF)*SEQE-3.D0*MU*DR
         DENO=1.D0+3.D0*MU*DR/SEQ
         DO 16 I=1,6
            DEVSIG(I)=(1.D0-DF)*DEVSE(I)/DENO
 16      CONTINUE

        VALX= LCNRTS(DEVSIG)
        IF (ABS(VALX-SEQ).GT.(PREC*VALX)) THEN
           CALL UTMESS('F','NMVEND','PB2 SEQ')
        ENDIF
        VALX= LCNRTS(DEVSE)
        IF (ABS(VALX-SEQE).GT.(PREC*VALX)) THEN
           CALL UTMESS('F','NMVEND','PB4 SEQ')
        ENDIF
         
        CALL LCDVMI(DEVSE,0.D0,VAL0,DFDS,D2FDS,VAL0)
        IF (ABS(VAL0-SEQE).GT.(PREC*SEQE)) THEN
           CALL UTMESS('F','NMVEND','PB1 SEQ')
        ENDIF
        CALL LCDVMI(DEVSIG,0.D0,VALX,DFDS,D2FDS,VAL0)
        IF (ABS(VALX-SEQ).GT.(PREC*SEQ)) THEN
           CALL UTMESS('F','NMVEND','PB1 SEQ')
        ENDIF
        IF (ABS(VAL0-SEQ).GT.(PREC*SEQ)) THEN
           CALL UTMESS('F','NMVEND','PB3 SEQ')
        ENDIF
         
         

      ELSE
      
         DR=0.D0
         DD=0.D0
         SEQ1MD=SYVP
         DF=DM
         CALL R8INIR(6,0.D0,DEVSIG,1)
      ENDIF
 
      COEF = ALPHAP*(TP-TREF)- ALPHAM*(TM-TREF)
      DEPSMO = 0.D0
      DO 13 I=1,3
        DEPSMO = DEPSMO + DEPS(I) -COEF
 13   CONTINUE
      DEPSMO = DEPSMO/3.D0
 
      SIGMMO = 0.D0
      DO 17 I =1,3
        SIGMMO = SIGMMO + SIGM(I)
 17   CONTINUE
      SIGMMO = SIGMMO /3.D0
      SIGPMO=(SIGMMO/TROIKM/(1.D0-DM)+DEPSMO)*(1.D0-DF)*TROISK
      DO 18 I=1,3
        BETA(I)=DEVSIG(I)+SIGPMO
 18   CONTINUE
      DO 19 I=4,6
        BETA(I)=DEVSIG(I)
 19   CONTINUE
 
      P(1)=DR/DT
      P(2)=DD/DT
      
 9999 CONTINUE
      END
