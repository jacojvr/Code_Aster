      SUBROUTINE LCRESA(FAMI,KPG,KSP,TYPMOD,IMAT,NMAT,MATERD,MATERF,
     &                  COMP,NR,NVI,TIMED,TIMEF,DEPS,EPSD,YF,DY,R,IRET)
      
      IMPLICIT   NONE
C TOLE CRP_21 CRS_1404
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/06/2012   AUTEUR PROIX J-M.PROIX 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C     ----------------------------------------------------------------
C     CALCUL DES TERMES DU SYSTEME NL A RESOUDRE = R(DY)
C     IN  FAMI   :  FAMILLE DU POINT DE GAUSS
C         KPG    :  POINT DE GAUSS
C         KSP    :  SOUS-POINT DE GAUSS
C         LOI    :  MODELE DE COMPORTEMENT
C         TYPMOD    :  TYPE DE MODELISATION
C         IMAT   :  NOM DU MATERIAU
C         NMAT   :  DIMENSION MATER
C         MATERD :  COEFFICIENTS MATERIAU A T
C         MATERF :  COEFFICIENTS MATERIAU A T+DT
C         COMP   :  COMPORTEMENT
C         NR     :  DIMENSION DU SYSTEME R(NR) NR=6+NVI
C         NVI    :  NOMBRE DE VARIABLE INTERNES
C         TIMED  :  INSTANT  T
C         TIMEF  :  INSTANT  T+DT
C         DEPS   :  INCREMENT DE DEFORMATION
C         EPSD   :  DEFORMATION A T
C         YF     :  VARIABLES A T + DT   
C         DY     :  SOLUTION     
C     OUT R      :  SYSTEME NL A T + DT
C     ----------------------------------------------------------------
C
      INTEGER IMAT,NMAT,NR,NVI,KPG,KSP,IRET,ITENS
      REAL*8 DEPS(6),EPSD(6),R(NR),YF(NR),DY(NR),X
      REAL*8 MATERD(NMAT,2),MATERF(NMAT,2),TIMED,TIMEF,EVI(6)
      REAL*8 DKOOH(6,6),FKOOH(6,6),H1SIGF(6),SIGI(6),VINI(NVI)
      REAL*8 DTIME,DVIN(NVI),EPSEF(6),SIGF(6)
      CHARACTER*8 TYPMOD
      CHARACTER*(*)   FAMI
      CHARACTER*3 MATCST
      CHARACTER*16 COMP(*)
C----------------------------------------------------------------      

      IRET=0
      DTIME=TIMEF-TIMED
      
C     INVERSE DE L'OPERATEUR D'ELASTICITE DE HOOKE
      IF (MATERF(NMAT,1).EQ.0) THEN
         CALL LCOPIL  ( 'ISOTROPE' , TYPMOD , MATERD , DKOOH )
         CALL LCOPIL  ( 'ISOTROPE' , TYPMOD , MATERF , FKOOH )
      ELSEIF (MATERF(NMAT,1).EQ.1) THEN
         CALL LCOPIL  ( 'ORTHOTRO' , TYPMOD , MATERD , DKOOH )
         CALL LCOPIL  ( 'ORTHOTRO' , TYPMOD , MATERF , FKOOH )
      ENDIF
      
      X=DTIME
      CALL DCOPY(NVI,YF(7),1,VINI,1)
      CALL DCOPY(6,YF(1),1,SIGI,1)
      MATCST='OUI'
      
      CALL LCDVIN(FAMI,KPG,KSP,COMP,TYPMOD,IMAT,MATCST,NVI,NMAT,VINI,
     &     MATERF(1,2),X,DTIME,SIGI,DVIN,IRET)
     
      CALL DSCAL(NVI,DTIME,DVIN,1)
      
      DO 5 ITENS=1,6
        EVI(ITENS) = VINI(ITENS)+DVIN(ITENS)
    5 CONTINUE
      
      CALL CALSIG(FAMI,KPG,KSP,EVI,TYPMOD,COMP,VINI,X,DTIME,EPSD,
     &              DEPS,NMAT,MATERF(1,1),SIGI)
      
      CALL DCOPY(6,YF,1,SIGF,1)      
      CALL LCPRMV ( FKOOH,   SIGI  , EPSEF )
      CALL LCPRMV ( FKOOH,   SIGF  , H1SIGF )
      CALL LCDIVE ( EPSEF,   H1SIGF  , R(1) )
      
      CALL DCOPY(NVI,DVIN,1,R(7),1)
      CALL DAXPY(NVI,-1.D0,DY(7),1,R(7),1)

      END
