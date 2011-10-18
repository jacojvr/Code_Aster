      SUBROUTINE DXDMUL(LCALCT,ICOU,INIV,T1VE,T2VE,H,D1I,D2I,X3I,EPI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 18/10/2011   AUTEUR DESOZA T.DESOZA 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
      IMPLICIT NONE
      LOGICAL LCALCT
      INTEGER ICOU
      INTEGER INIV
      REAL*8 T1VE(3,3)
      REAL*8 T2VE(2,2)
      REAL*8 H(3,3)
      REAL*8 D1I(2,2),D2I(2,4)
      REAL*8 X3I,EPI
C     ------------------------------------------------------------------
C     MATRICES D1I ET D2I POUR LE CALCUL DES CONTRAINTES EN MULTICOUCHE
C     (ELLES SONT FOURNIES DANS LE REPERE DE L'ELEMENT) CF BATOZ-DHATT
C     ------------------------------------------------------------------
C     IN  ICOU   : NUMERO DE LA COUCHE
C     IN  INIV   : NIVEAU DANS LA COUCHE (-1:INF , 0:MOY , 1:SUP)
C     IN  T1VE   : MATRICE DE CHANGEMENT DE REPERE D'UNE MATRICE (3,3)
C     IN  T2VE   : MATRICE DE CHANGEMENT DE REPERE D'UNE MATRICE (2,2)
C     OUT H      : MATRICE D'ELASTICITE DE LA COUCHE, REPERE INTRINSEQUE
C     OUT D1I    : MATRICE D1I REPERE INTRINSEQUE
C     OUT D2I    : MATRICE D2I REPERE INTRINSEQUE
C     OUT X3I    : Z DE CALCUL DE LA CONTRAINTE
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
C      CHARACTER*32 JEXNUM,JEXNOM,JEXR8,JEXATR
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
      INTEGER     I,K,L,JCACO,JCOU,JMATE,ICODRE(27)
      CHARACTER*2 VAL
      CHARACTER*3 NUM
      CHARACTER*8 NOMRES(27)
      REAL*8      VALRES(27),R8BID
      REAL*8      DX1I(2,2),DX2I(2,4)
      REAL*8      DA1I(2,2),DA2I(2,4)
      REAL*8      ORDI,AI(3,3)
      REAL*8      XAB1(3,3),EXCEN
C
      CALL JEVECH('PCACOQU','L',JCACO)
      EXCEN = ZR(JCACO+5-1)
C
      CALL JEVECH('PMATERC','L',JMATE)
C     ----- RAPPEL DES CARACTERISTIQUES DU MONOCOUCHE ------------------
      CALL CODENT(ICOU,'G',NUM)
      DO 10 I = 1,27
        CALL CODENT(I,'G',VAL)
        NOMRES(I) = 'C'//NUM//'_V'//VAL
   10 CONTINUE
      CALL RCVALA(ZI(JMATE),' ','ELAS_COQMU',0,' ',R8BID,9,NOMRES,
     &           VALRES, ICODRE, 1)
      EPI = VALRES(1)
      ORDI = VALRES(3)
      H(1,1) = VALRES(4)
      H(1,2) = VALRES(5)
      H(1,3) = VALRES(6)
      H(2,2) = VALRES(7)
      H(2,3) = VALRES(8)
      H(3,3) = VALRES(9)
      H(2,1) = H(1,2)
      H(3,1) = H(1,3)
      H(3,2) = H(2,3)
C     ----- CALCUL DE Z ------------------------------------------------
      X3I = ORDI + EXCEN
      IF (INIV.LT.0) THEN
        X3I = X3I - EPI/2.D0
      ELSE IF (INIV.GT.0) THEN
        X3I = X3I + EPI/2.D0
      END IF
C     ----- CALCUL DE D1I ET D2I ---------------------------------------

      CALL MATINI(2,2,0.D0,DX1I)
      CALL MATINI(2,4,0.D0,DX2I)

      IF (.NOT.LCALCT) THEN
        GOTO 999
      ENDIF

      DO 110 JCOU = 1,ICOU
        CALL CODENT(JCOU,'G',NUM)
        DO 60 I = 1,27
          CALL CODENT(I,'G',VAL)
          NOMRES(I) = 'C'//NUM//'_V'//VAL
   60   CONTINUE
        CALL RCVALA(ZI(JMATE),' ','ELAS_COQMU',0,' ',R8BID,1,NOMRES,
     &             VALRES, ICODRE, 1)
        EPI = VALRES(1)
        CALL RCVALA(ZI(JMATE),' ','ELAS_COQMU',0,' ',R8BID,1,NOMRES(3),
     &              VALRES(3), ICODRE(3), 1)
        ORDI = VALRES(3)
        CALL RCVALA(ZI(JMATE),' ','ELAS_COQMU',0,' ',R8BID,12,
     &            NOMRES(16), VALRES(16), ICODRE(16), 1)
C
C      RECUP MATRICE AI = H(Z).HF-1
C
        AI(1,1) = VALRES(16)
        AI(2,1) = VALRES(17)
        AI(3,1) = VALRES(18)
        AI(1,2) = VALRES(19)
        AI(2,2) = VALRES(20)
        AI(3,2) = VALRES(21)
        AI(1,3) = VALRES(22)
        AI(2,3) = VALRES(23)
        AI(3,3) = VALRES(24)
C
C      PASSAGE DANS LE REPERE INTRINSEQUE A L'ELEMENT
C
        CALL UTBTAB('ZERO',3,3,AI,T1VE,XAB1,AI)

C         TERMES DE LA MATRICE INTERVENANT DANS D1(Z)
C      CF. DHAT-BATOZ VOL 2 PAGE 243
C      DAI1 MATRICE (2,2) CONSTANTE PAR COUCHE
C      TERME 1,1 : A11+A33 TERME 1,2 : A13+A32
C      TERME 2,1 : A31+A23 TERME 2,2 : A22+A33
          DA1I(1,1) = AI(1,1) + AI(3,3)
          DA1I(1,2) = AI(1,3) + AI(3,2)
          DA1I(2,1) = AI(3,1) + AI(2,3)
          DA1I(2,2) = AI(2,2) + AI(3,3)
C         TERMES DE LA MATRICE INTERVENANT DANS D2(Z)
C      CF. DHAT-BATOZ VOL 2 PAGE 243
C      DAI2 MATRICE (2,4) CONSTANTE PAR COUCHE
          DA2I(1,1) = AI(1,1) - AI(3,3)
          DA2I(1,2) = AI(1,3) - AI(3,2)
          DA2I(1,3) = AI(1,2)*2.D0
          DA2I(1,4) = AI(3,1)*2.D0
          DA2I(2,1) = AI(3,1) - AI(2,3)
          DA2I(2,2) = AI(3,3) - AI(2,2)
          DA2I(2,3) = AI(3,2)*2.D0
          DA2I(2,4) = AI(2,1)*2.D0

C
C      D1(Z)=SOMME(-T,Z)(-Z/2*DA1I DZ)
C      TOUS CALCULS FAITS : K INDICE MAX TEL QUE ZK < X3I
C      D1=SOMME(I=1,K-1)(-1/2*DA1I*EPI*ORDI)+DAIK(ZK**2-X3I**2)
C
        DO 80 K = 1,2
          DO 70 L = 1,2
            D1I(K,L) = DX1I(K,L) + ((ORDI-EPI/2.D0)**2-X3I*X3I)*
     &                 DA1I(K,L)/4.D0
            DX1I(K,L) = DX1I(K,L) - EPI*ORDI*DA1I(K,L)/2.D0
   70     CONTINUE
   80   CONTINUE
C
C      D2(Z)=SOMME(-T,Z)(-Z/2*DA2I DZ)
C      TOUS CALCULS FAITS : K INDICE MAX TEL QUE ZK < X3I
C      D2=SOMME(I=1,K-1)(-1/2*DA2I*EPI*ORDI)+DA2K(ZK**2-X3I**2)
C
        DO 100 K = 1,2
          DO 90 L = 1,4
            D2I(K,L) = DX2I(K,L) + ((ORDI-EPI/2.D0)**2-X3I*X3I)*
     &                 DA2I(K,L)/4.D0
            DX2I(K,L) = DX2I(K,L) - EPI*ORDI*DA2I(K,L)/2.D0
   90     CONTINUE
  100   CONTINUE
  110 CONTINUE
C
 999  CONTINUE
C
C     MATRICE H DANS LE REPERE INTRINSEQUE DE L'ELEMENT

      CALL UTBTAB('ZERO',3,3,H,T1VE,XAB1,H)

      END
