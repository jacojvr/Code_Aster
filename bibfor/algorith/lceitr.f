      SUBROUTINE LCEITR(FAMI,KPG,KSP,MAT,OPTION,MU,SU,DE,
     &                  DDEDT,VIM,VIP,R)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 23/02/2011   AUTEUR LAVERNE J.LAVERNE 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE LAVERNE J.LAVERNE

      IMPLICIT NONE
      CHARACTER*16 OPTION
      INTEGER MAT,KPG,KSP
      REAL*8  MU(3),SU(3),DE(6),DDEDT(6,6),VIM(*),VIP(*),R      
      CHARACTER*(*)  FAMI

C-----------------------------------------------------------------------
C            LOI DE COMPORTEMENT COHESIVE CZM_TRA_MIX 
C            POUR LES ELEMENTS D'INTERFACE 2D ET 3D. 
C
C IN : FAMI,KPG,KSP,MAT,OPTION
C      MU  : LAGRANGE
C      SU  : SAUT DE U
C      VIM : VARIABLES INTERNES
C      
C OUT : DE    : DELTA, SOLUTION DE LA MINIMISATION 
C       DDEDT : D(DELTA)/DT
C       VIP   : VARIABLES INTERNES MISES A JOUR
C       R     : PENALISATION DU LAGRANGE 
C-----------------------------------------------------------------------
      INTEGER NBPAR
      PARAMETER (NBPAR=6)
      LOGICAL RESI, RIGI, ELAS
      INTEGER REGIME
      REAL*8  SC,GC,C,H,KA,SK,ST,VAL(NBPAR),TMP,KAP,GAP
      REAL*8  DN,TN,T(3),DDNDTN,DELE,DELP,DELC,COEE,COEP
      CHARACTER*2 COD(NBPAR)
      CHARACTER*8 NOM(NBPAR)
      CHARACTER*1 POUM
      
      DATA NOM /'GC','SIGM_C','COEF_EXTR','COEF_PLAS',
     &          'PENA_LAGR','RIGI_GLIS'/
C-----------------------------------------------------------------------

C OPTION CALCUL DU RESIDU OU CALCUL DE LA MATRICE TANGENTE
      RESI = OPTION(1:4).EQ.'FULL' .OR. OPTION(1:4).EQ.'RAPH'
      RIGI = OPTION(1:4).EQ.'FULL' .OR. OPTION(1:4).EQ.'RIGI'
      ELAS = OPTION(11:14).EQ.'ELAS' 

C RECUPERATION DES PARAMETRES PHYSIQUES
      IF (OPTION.EQ.'RIGI_MECA_TANG') THEN
        POUM = '-'
      ELSE
        POUM = '+'
      ENDIF

      CALL RCVALB(FAMI,KPG,KSP,POUM,MAT,' ','RUPT_DUCT',0,' ',
     &            0.D0,NBPAR,NOM,VAL,COD,'F ')

      GC   = VAL(1)      
      SC   = VAL(2)
      COEE = VAL(3)
      COEP = VAL(4)
      
      IF (COEE.GT.COEP) CALL U2MESS('F','COMPOR1_67')

C EVALUATION DES SAUTS CRITIQUE, EXTRINSEQUE ET PLASTIQUE      
      DELC = 2*GC/(SC*(1-COEE+COEP))
      DELE = COEE*DELC
      DELP = COEP*DELC 
           
      H    = SC/(DELC - DELP)
      R    = H * VAL(5)
      C    = H * VAL(6)
      
C SEUIL COURANT ET CONTRAINTE CRITIQUE COURANTE
      KA   = MAX(DELE,VIM(1))
      SK   = MAX(0.D0 , MIN( SC, SC*(KA-DELC)/(DELP-DELC) ) )

C    FORCES COHESIVES AUGMENTEES       
      T(1) = MU(1) + R*SU(1)
      T(2) = MU(2) + R*SU(2)
      T(3) = MU(3) + R*SU(3)
      TN   = T(1)      
 
C -- CALCUL DE DELTA  
C ------------------
        
C     ON VA TESTER ST : VALEUR DE LA DROITE EN KA 
      ST = -R*KA + TN
      
C    SI RIGI_MECA_*      
      IF (.NOT. RESI) THEN
        REGIME = NINT(VIM(2))
        GOTO 5000
      END IF
                        
C    CONTACT   
      IF (ST .LE. -R*DELE*SK/SC) THEN
        REGIME = -1
        DN = KA - DELE*SK/SC 
        
C    DECHARGE   
      ELSEIF ((-R*DELE*SK/SC.LT.ST).AND.(ST .LE. SK)) THEN
        REGIME = 0
        DN = ( DELE*(TN-SK) + SC*KA)/(R*DELE + SC)

C    PLATEAU         
      ELSEIF ((SK.LT.ST).AND.
     &        (ST .LE. (MAX(0.D0,R*(DELP-KA)) + SK))) THEN
        REGIME = 3
        DN = (TN - SC)/R
        
C    ENDOMMAGEMENT                    
      ELSEIF (( (MAX(0.D0,R*(DELP-KA)) + SK ).LT.ST).AND.
     &        ( ST.LE.R*(DELC-KA) )) THEN
        REGIME = 1
        DN = (TN - H*DELC)/(R - H)
        
C    RUPTURE (SURFACE LIBRE)
      ELSE 
        REGIME = 2
        DN = TN/R
      ENDIF

      CALL R8INIR(6, 0.D0, DE,1)

C    COMPOSANTE DE L'OUVERTURE :        
      DE(1) = DN
C    COMPOSANTES DE CISAILLEMENT : ELASTIQUE
      DE(2) = T(2)/(C+R)
      DE(3) = T(3)/(C+R)
      
      
C -- ACTUALISATION DES VARIABLES INTERNES
C ---------------------------------------

C   V1 :  PLUS GRANDE NORME DU SAUT (SEUIL EN SAUT) 
C   V2 :  REGIME DE LA LOI
C        -1 : CONTACT
C         0 : ADHERENCE OU DECHARGE 
C         3 : PLATEAU
C         1 : ENDOMMAGEMENT   
C         2 : RUPTURE (SURFACE LIBRE)   
C   V3 :  INDICATEUR D'ENDOMMAGEMENT  
C         0 : SAIN 
C         1 : ENDOMMAGE
C         2 : CASSE   
C   V4 :  POURCENTAGE D'ENERGIE DISSIPEE
C   V5 :  VALEUR DE L'ENERGIE DISSIPEE (V4*GC)
C   V6 :  ENERGIE RESIDUELLE COURANTE 
C        (NULLE POUR CE TYPE D'IRREVERSIBILITE)
C   V7 A V9 : VALEURS DE DELTA

      KAP = MIN( MAX(KA,DN) , DELC )
      TMP = KA + DELE*(1.D0 - SK/SC)
      GAP = SC*(KA - DELE*SK/SC)  -  (TMP-DELP)*(SC-SK)/2.D0
      GAP = GAP/GC
            
      VIP(1) = KAP
      VIP(2) = REGIME

      IF (KAP.EQ.DELE) THEN
        VIP(3) = 0.D0
      ELSEIF (KAP.EQ.DELC) THEN
        VIP(3) = 2.D0
      ELSE
        VIP(3) = 1.D0        
      ENDIF
      
      VIP(4) = GAP
      VIP(5) = GC*VIP(4)
      VIP(6) = 0.D0       
      VIP(7) = DE(1)
      VIP(8) = DE(2)
      VIP(9) = DE(3)


C -- MATRICE TANGENTE
C--------------------

 5000 CONTINUE
      IF (.NOT. RIGI) GOTO 9999
      
C    AJUSTEMENT POUR PRENDRE EN COMPTE *_MECA_ELAS
      IF (ELAS) THEN
        IF (REGIME.EQ.1) REGIME = 0
      END IF

      CALL R8INIR(36, 0.D0, DDEDT,1)

      DDEDT(2,2) = 1/(C+R)
      DDEDT(3,3) = 1/(C+R)
 
      IF (REGIME .EQ. 0) THEN
        DDNDTN = DELE/(DELE*R + SC)
      ELSE IF (REGIME .EQ. 3) THEN
        DDNDTN = 1/R
      ELSE IF (REGIME .EQ. 1) THEN
        DDNDTN = 1/(R-H)
      ELSE IF (REGIME .EQ. 2) THEN
        DDNDTN = 1/R
      ELSE IF (REGIME .EQ. -1) THEN
        DDNDTN = 0
      END IF
      DDEDT(1,1) = DDNDTN
      
 9999 CONTINUE
 
      END
