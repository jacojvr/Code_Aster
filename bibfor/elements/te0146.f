      SUBROUTINE TE0146(OPTION,NOMTE)
      IMPLICIT NONE
      CHARACTER*16 OPTION, NOMTE
C.......................................................................
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 11/10/2010   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C  BUT: CALCUL DE L'OPTION CALC_FERRAILLAGE POUR LES ELEMENTS DE COQUE
C.......................................................................
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C------------FIN  COMMUNS NORMALISES  JEVEUX  -----------------------
C_____________________________________________________________________
C
C CALCUL DES ARMATURES DE BETON ARME (METHODE DE CAPRA ET MAURY).
C
C VERSION 1.2 DU 31/03/2010
C_____________________________________________________________________


C PARAMETRES D'ECHANGE ENTRE CODE_ASTER ET CLCPLQ (POINT D'ENTREE DU
C CALCUL DE FERRAILLAGE PAR CAPRA ET MAURY
C
C   PARAMETRES D'ENTREE (FOURNIS PAR CODE_ASTER)
C
C     HT     (DP)  EPAISSEUR DE LA COQUE
C     ENROBG (DP)  ENROBAGE
C     TYPCMB (I)   TYPE DE COMBINAISON
C               0 = ELU, 1 = ELS
C     CEQUI  (DP)  COEFFICIENT D'EQUIVALENCE ACIER/BETON
C     PIVA   (DP)  VALEUR DU PIVOT A
C     PIVB   (DP)  VALEUR DU PIVOT B
C     SIGACI (DP)  CONTRAINTE ADMISSIBLE DANS L'ACIER
C     SIGBET (DP)  CONTRAINTE ADMISSIBLE DANS LE BETON
C     EFFRTS (DP-DIM 8) TORSEUR DES EFFORTS
C
C   PARAMETRES DE SORTIE (RENVOYES A CODE_ASTER)
C     DNSITS  (DP-DIM 5) DENSITES
C                      1 A 4 : SURFACES D'ACIER LONGITUDINAL EN CM2/M,
C                      5 TRANSVERSAL: EN CM2/M2
C     SIGMBE (DP)  CONTRAINTE BETON
C     EPSIBE (DP)  DEFORMATION BETON
C     IERR        CODE RETOUR (0 = OK)
C----------------------------------------------------------------------
        REAL*8 CEQUI,PIVA,PIVB,SIGACI,SIGBET,EFFRTS(8),DNSITS(5)
        REAL*8 SIGMBE, EPSIBE,HT,ENROBG
        INTEGER IERR,JEPAIS,JEFGE,JFER1,JFER2,ITAB(7),NNO
        INTEGER TYPCMB,INO,ICMP,IRET,K
        INTEGER IADZI,IAZK24
        CHARACTER*8 NOMAIL



        CALL TECAEL(IADZI,IAZK24)

        CALL JEVECH('PCACOQU','L',JEPAIS)
        CALL JEVECH('PFERRA1','L',JFER1)
        CALL JEVECH('PFERRA2','E',JFER2)
        HT=ZR(JEPAIS)

        CALL JEVECH('PEFFORR','L',JEFGE)
        CALL TECACH('OOO','PEFFORR',7,ITAB,IRET)
        CALL ASSERT(IRET.EQ.0)
        NNO=ITAB(3)
        CALL ASSERT(NNO.GT.0.AND.NNO.LE.9)
        CALL ASSERT(ITAB(2).EQ.8*NNO)

C       -- CALCUL DE LA CONTRAINTE MOYENNE :
C       ----------------------------------------------
        DO 1, ICMP=1,8
          EFFRTS(ICMP) = 0.D0
          DO 2, INO=1,NNO
            EFFRTS(ICMP) = EFFRTS(ICMP) + ZR(JEFGE-1+(INO-1)*8+ICMP)/NNO
  2       CONTINUE
  1     CONTINUE


C       -- RECUPERATION DES DONNEES DE L'UTILISATEUR :
C       ----------------------------------------------
C       FER1_R=TYPCOMB  ENROBG  CEQUI  SIGACI  SIGBET  PIVA  PIVB
C                  1        2      3       4       5       6    7
         TYPCMB=NINT(ZR(JFER1-1+1))
         ENROBG=ZR(JFER1-1+2)
         CEQUI =ZR(JFER1-1+3)
         SIGACI=ZR(JFER1-1+4)
         SIGBET=ZR(JFER1-1+5)
         PIVA  =ZR(JFER1-1+6)
         PIVB  =ZR(JFER1-1+7)


C       -- CALCUL PROPREMENT DIT :
C       --------------------------
        SIGMBE=0.D0
        EPSIBE=0.D0
        DO 10, K=1,5
          DNSITS(K)=0.D0
 10     CONTINUE
        CALL CLCPLQ ( HT, ENROBG, TYPCMB,
     &              PIVA,PIVB,CEQUI,
     &              SIGACI, SIGBET, EFFRTS,
     &              DNSITS, SIGMBE,EPSIBE,
     &              IERR )
        IF (IERR.GT.0) CALL U2MESI('F','CALCULEL_72',1,IERR)


C       -- stockage des resultats :
C       --------------------------
C     FER2_R=  DNSXI     DNSXS   DNSYI   DNSYS   DNST    SIGMBE   EPSIBE
C               1          2       3       4       5       6        7
        ZR(JFER2-1+1)= DNSITS(1)
        ZR(JFER2-1+2)= DNSITS(3)
        ZR(JFER2-1+3)= DNSITS(2)
        ZR(JFER2-1+4)= DNSITS(4)
        ZR(JFER2-1+5)= DNSITS(5)
        ZR(JFER2-1+6)= SIGMBE
        ZR(JFER2-1+7)= EPSIBE

      END
