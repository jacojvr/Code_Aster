      SUBROUTINE RC3601(IG,IOCS,SEISME,NPASS,IMA,IPT,NBM,ADRM,C,K,CARA,
     &                  NOMMAT,SNMAX,SAMAX,UTOT,SM)
      IMPLICIT   NONE
      INTEGER IG,IOCS,NPASS,IMA,IPT,NBM,ADRM(*)
      REAL*8 C(*),K(*),CARA(*),SNMAX,SAMAX,UTOT,SM
      LOGICAL SEISME
      CHARACTER*8 NOMMAT
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF POSTRELE  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     ------------------------------------------------------------------

C     OPERATEUR POST_RCCM, TRAITEMENT DE FATIGUE_B3600

C     CALCUL DES AMPLITUDES DE CONTRAINTES
C     CALCUL DU FACTEUR D'USAGE
C     ON TRAITE LES SITUATIONS COMBINABLES DANS LEUR GROUPE

C     Soit 2 �tats stabilis�s I et J appartenant aux situations P et Q

C     on calcule le SALT(I,J) = 0,5*(EC/E)*Ke*Sn(P,Q)*Sp(I,J)

C     avec Sn(P,Q) = Max( Sn(I,J) )
C          Sn(I,J) = Max( Max(Sn(I,J,ThP)), Max(Sn(I,J,ThQ)) )

C     avec Sp(I,J) = Max( Max(Sp(I,J,ThP)), Max(Sp(I,J,ThQ)) )

C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------

      INTEGER NBSIGR,JNSG,IS1,IOC1,IS2,IOC2,INDS,IFM,NIV,JCOMBI,JPRESA,
     &        JPRESB,JMOMEA,JMOMEB,JNBOCC,NBTH1,JTH1,NBTH2,JTH2,JCHMAT,
     &        JMSA,NDIM,JNOC,NSCY,NS,JMSN,NBSIG2,I1,I2,INDI,JIST
      REAL*8 PPI,PPJ,PQI,PQJ,SALTIJ,UG,SN,SP,SMM,MPI(3),MPJ(3),MQI(3),
     &       MQJ(3),MSE(3),MATPI(14),MATPJ(14),MATQI(14),MATQJ(14),
     &       MATSE(14)
      CHARACTER*8 K8B
      CHARACTER*24 MOMEPI,MOMEPJ,MOMEQI,MOMEQJ,MATEPI,MATEPJ,MATEQI,
     &             MATEQJ
      REAL*8 TYPEKE,SPMECA,SPTHER
C DEB ------------------------------------------------------------------
      CALL JEMARQ()

      CALL INFNIV(IFM,NIV)

      CALL JEVEUO('&&RC3600.SITU_COMBINABLE','L',JCOMBI)
      CALL JEVEUO('&&RC3600.SITU_PRES_A','L',JPRESA)
      CALL JEVEUO('&&RC3600.SITU_PRES_B','L',JPRESB)
      CALL JEVEUO('&&RC3600.SITU_MOMENT_A','L',JMOMEA)
      CALL JEVEUO('&&RC3600.SITU_MOMENT_B','L',JMOMEB)
      CALL JEVEUO('&&RC3600.SITU_NB_OCCUR','L',JNBOCC)

      CALL JEVEUO('&&RC3600.MATERIAU','L',JCHMAT)

      CALL JELIRA(JEXNUM('&&RC3600.LES_GROUPES',IG),'LONMAX',NBSIGR,K8B)
      CALL JEVEUO(JEXNUM('&&RC3600.LES_GROUPES',IG),'L',JNSG)
      IF (NIV.GE.2) THEN
        WRITE (IFM,1000) IG,NBSIGR
        WRITE (IFM,1002) (ZI(JNSG+I1-1),I1=1,NBSIGR)
      END IF

      IF (IOCS.EQ.0) THEN
        NBSIG2 = NBSIGR
      ELSE
        NBSIG2 = NBSIGR - 1
      END IF
      NDIM = 2*NBSIG2
      CALL WKVECT('&&RC3601.NB_OCCURR','V V I',NDIM,JNOC)
      CALL WKVECT('&&RC3601.IMPR_SITU','V V I',NDIM,JIST)
      NDIM = NBSIG2*NBSIG2
      CALL WKVECT('&&RC3601.MATRICE_SN','V V R',NDIM,JMSN)
      NDIM = 4*NBSIG2*NBSIG2
      CALL WKVECT('&&RC3601.MATRICE_SALT','V V R',NDIM,JMSA)

      NS = 0
      IF (SEISME) THEN
        MOMEPI = ZK24(JMOMEA+IOCS-1)
        CALL RCMO01(MOMEPI,IMA,IPT,MSE)
        MSE(1) = 2*MSE(1)
        MSE(2) = 2*MSE(2)
        MSE(3) = 2*MSE(3)
        MATEPI = ZK24(JCHMAT+2*IOCS-1)
        CALL RCMA01(MATEPI,IMA,IPT,NBM,ADRM,MATSE)
        NS = ZI(JNBOCC+2*IOCS-2)
        NSCY = ZI(JNBOCC+2*IOCS-1)
      ELSE
        MSE(1) = 0.D0
        MSE(2) = 0.D0
        MSE(3) = 0.D0
      END IF


C --- SITUATION P :
C     -------------

      I1 = 0
      DO 20 IS1 = 1,NBSIGR
        IOC1 = ZI(JNSG+IS1-1)
        IF (.NOT.ZL(JCOMBI+IOC1-1)) GO TO 20
        IF (IOC1.EQ.IOCS) GO TO 20

        I1 = I1 + 1
        ZI(JNOC-1+2* (I1-1)+1) = ZI(JNBOCC+2*IOC1-2)
        ZI(JNOC-1+2* (I1-1)+2) = ZI(JNBOCC+2*IOC1-2)
        ZI(JIST-1+2* (I1-1)+1) = IOC1
        ZI(JIST-1+2* (I1-1)+2) = IOC1

        PPI = ZR(JPRESA+IOC1-1)
        MOMEPI = ZK24(JMOMEA+IOC1-1)
        CALL RCMO01(MOMEPI,IMA,IPT,MPI)
        MATEPI = ZK24(JCHMAT+2*IOC1-1)
        CALL RCMA01(MATEPI,IMA,IPT,NBM,ADRM,MATPI)
        TYPEKE = MATPI(14)

        PPJ = ZR(JPRESB+IOC1-1)
        MOMEPJ = ZK24(JMOMEB+IOC1-1)
        CALL RCMO01(MOMEPJ,IMA,IPT,MPJ)
        MATEPJ = ZK24(JCHMAT+2*IOC1-2)
        CALL RCMA01(MATEPJ,IMA,IPT,NBM,ADRM,MATPJ)

        CALL JELIRA(JEXNUM('&&RC3600.SITU_THERMIQUE',IOC1),'LONUTI',
     &              NBTH1,K8B)
        IF (NBTH1.NE.0) THEN
          CALL JEVEUO(JEXNUM('&&RC3600.SITU_THERMIQUE',IOC1),'L',JTH1)
        ELSE
          JTH1 = 1
        END IF

        NBTH2 = 0
        JTH2 = 1
        IOC2 = 0

        SN = 0.D0
        CALL RC36SN(NBM,ADRM,IPT,C,CARA,MATPI,PPI,MPI,MATPJ,PPJ,MPJ,MSE,
     &              NBTH1,NBTH2,IOC1,IOC2,SN)
        ZR(JMSN-1+NBSIG2* (I1-1)+I1) = SN
        SNMAX = MAX(SNMAX,SN)

        IF (NIV.GE.2) WRITE (IFM,1010) IOC1,SN
        INDS = 4*NBSIG2* (I1-1) + 4* (I1-1)


C ----- 1/ CALCUL DU SALT(I,I) A PARTIR DU SN(P,Q) ET SP(I,I)

        SALTIJ = 0.D0
        ZR(JMSA-1+INDS+1) = SALTIJ

C ----- 2/ CALCUL DU SALT(I,J) A PARTIR DU SN(P,Q) ET SP(I,J)

        SP = 0.D0
        SPMECA = 0.D0
        SPTHER = 0.D0
        CALL RC36SP(NBM,ADRM,IPT,C,K,CARA,MATPI,PPI,MPI,MATPJ,PPJ,MPJ,
     &              MSE,NBTH1,NBTH2,IOC1,IOC2,SP,TYPEKE,SPMECA,SPTHER)

        IF (NIV.GE.2) WRITE (IFM,1032) SP
          IF (TYPEKE.GT.0.D0) THEN
             IF (NIV.GE.2) THEN
                WRITE (IFM,1132) SPMECA,SPTHER
             END IF
          END IF

        CALL RC36SA(NOMMAT,MATPI,MATPJ,SN,SP,TYPEKE,SPMECA,SPTHER,
     &              SALTIJ,SMM)

        ZR(JMSA-1+INDS+2) = SALTIJ
        ZR(JMSA-1+INDS+3) = SALTIJ
        IF (SALTIJ.GT.SAMAX) THEN
          SAMAX = SALTIJ
          SM = SMM
        END IF

C ----- 3/ CALCUL DU SALT(J,J) A PARTIR DU SN(P,Q) ET SP(J,J)

        SALTIJ = 0.D0
        ZR(JMSA-1+INDS+4) = SALTIJ

C ----- SITUATION Q :
C       -------------

        I2 = I1
        DO 10 IS2 = IS1 + 1,NBSIGR
          IOC2 = ZI(JNSG+IS2-1)
          IF (.NOT.ZL(JCOMBI+IOC2-1)) GO TO 10
          IF (IOC2.EQ.IOCS) GO TO 10
          I2 = I2 + 1

          PQI = ZR(JPRESA+IOC2-1)
          MOMEQI = ZK24(JMOMEA+IOC2-1)
          CALL RCMO01(MOMEQI,IMA,IPT,MQI)
          MATEQI = ZK24(JCHMAT+2*IOC2-1)
          CALL RCMA01(MATEQI,IMA,IPT,NBM,ADRM,MATQI)

          PQJ = ZR(JPRESB+IOC2-1)
          MOMEQJ = ZK24(JMOMEB+IOC2-1)
          CALL RCMO01(MOMEQJ,IMA,IPT,MQJ)
          MATEQJ = ZK24(JCHMAT+2*IOC2-2)
          CALL RCMA01(MATEQJ,IMA,IPT,NBM,ADRM,MATQJ)

          CALL JELIRA(JEXNUM('&&RC3600.SITU_THERMIQUE',IOC2),'LONUTI',
     &                NBTH2,K8B)
          IF (NBTH2.NE.0) THEN
            CALL JEVEUO(JEXNUM('&&RC3600.SITU_THERMIQUE',IOC2),'L',JTH2)
          ELSE
            JTH2 = 1
          END IF

C ------- CALCUL DU SN(P,Q), ON A 4 COMBINAISONS

          SN = 0.D0

          CALL RC36SN(NBM,ADRM,IPT,C,CARA,MATPI,PPI,MPI,MATQI,PQI,MQI,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SN)

          CALL RC36SN(NBM,ADRM,IPT,C,CARA,MATPI,PPI,MPI,MATQJ,PQJ,MQJ,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SN)

          CALL RC36SN(NBM,ADRM,IPT,C,CARA,MATPJ,PPJ,MPJ,MATQJ,PQJ,MQJ,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SN)

          CALL RC36SN(NBM,ADRM,IPT,C,CARA,MATPJ,PPJ,MPJ,MATQI,PQI,MQI,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SN)

          ZR(JMSN-1+NBSIG2* (I1-1)+I2) = SN
          ZR(JMSN-1+NBSIG2* (I2-1)+I1) = SN
          IF (NIV.GE.2) WRITE (IFM,1020) IOC1,IOC2,SN

          SNMAX = MAX(SNMAX,SN)
          INDS = 4*NBSIG2* (I1-1) + 4* (I2-1)
          INDI = 4*NBSIG2* (I2-1) + 4* (I1-1)

C ------- 1/ CALCUL DU SALT(I,I) A PARTIR DU SN(P,Q) ET SP(I,I)

          SP = 0.D0
          SPMECA = 0.D0
          SPTHER = 0.D0

          CALL RC36SP(NBM,ADRM,IPT,C,K,CARA,MATPI,PPI,MPI,MATQI,PQI,MQI,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SP,TYPEKE,SPMECA,SPTHER)

          IF (NIV.GE.2) WRITE (IFM,1031) SP
          IF (TYPEKE.GT.0.D0) THEN
             IF (NIV.GE.2) THEN
                WRITE (IFM,1131) SPMECA,SPTHER
             END IF
          END IF

          CALL RC36SA(NOMMAT,MATPI,MATQI,SN,SP,TYPEKE,SPMECA,SPTHER,
     &                SALTIJ,SMM)

          ZR(JMSA-1+INDS+1) = SALTIJ
          ZR(JMSA-1+INDI+1) = SALTIJ
          IF (SALTIJ.GT.SAMAX) THEN
            SAMAX = SALTIJ
            SM = SMM
          END IF

C ------- 2/ CALCUL DU SALT(I,J) A PARTIR DU SN(P,Q) ET SP(I,J)

          SP = 0.D0
          SPMECA = 0.D0
          SPTHER = 0.D0

          CALL RC36SP(NBM,ADRM,IPT,C,K,CARA,MATPI,PPI,MPI,MATQJ,PQJ,MQJ,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SP,TYPEKE,SPMECA,SPTHER)

          IF (NIV.GE.2) WRITE (IFM,1032) SP
          IF (TYPEKE.GT.0.D0) THEN
             IF (NIV.GE.2) THEN
                WRITE (IFM,1132) SPMECA,SPTHER
             END IF
          END IF

          CALL RC36SA(NOMMAT,MATPI,MATQJ,SN,SP,TYPEKE,SPMECA,SPTHER,
     &                SALTIJ,SMM)

          ZR(JMSA-1+INDS+3) = SALTIJ
          ZR(JMSA-1+INDI+2) = SALTIJ
          IF (SALTIJ.GT.SAMAX) THEN
            SAMAX = SALTIJ
            SM = SMM
          END IF

C ------- 3/ CALCUL DU SALT(J,I) A PARTIR DU SN(P,Q) ET SP(J,I)

          SP = 0.D0
          SPMECA = 0.D0
          SPTHER = 0.D0

          CALL RC36SP(NBM,ADRM,IPT,C,K,CARA,MATPJ,PPJ,MPJ,MATQI,PQI,MQI,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SP,TYPEKE,SPMECA,SPTHER)

          IF (NIV.GE.2) WRITE (IFM,1034) SP
          IF (TYPEKE.GT.0.D0) THEN
             IF (NIV.GE.2) THEN
                WRITE (IFM,1134) SPMECA,SPTHER
             END IF
          END IF

          CALL RC36SA(NOMMAT,MATPJ,MATQI,SN,SP,TYPEKE,SPMECA,SPTHER,
     &                SALTIJ,SMM)

          ZR(JMSA-1+INDS+2) = SALTIJ
          ZR(JMSA-1+INDI+3) = SALTIJ
          IF (SALTIJ.GT.SAMAX) THEN
            SAMAX = SALTIJ
            SM = SMM
          END IF

C ------- 4/ CALCUL DU SALT(J,J) A PARTIR DU SN(P,Q) ET SP(J,J)

          SP = 0.D0
          SPMECA = 0.D0
          SPTHER = 0.D0

          CALL RC36SP(NBM,ADRM,IPT,C,K,CARA,MATPJ,PPJ,MPJ,MATQJ,PQJ,MQJ,
     &                MSE,NBTH1,NBTH2,IOC1,IOC2,SP,TYPEKE,SPMECA,SPTHER)

          IF (NIV.GE.2) WRITE (IFM,1033) SP
          IF (TYPEKE.GT.0.D0) THEN
             IF (NIV.GE.2) THEN
                WRITE (IFM,1133) SPMECA,SPTHER
             END IF
          END IF

          CALL RC36SA(NOMMAT,MATPJ,MATQJ,SN,SP,TYPEKE,SPMECA,SPTHER,
     &                SALTIJ,SMM)

          ZR(JMSA-1+INDS+4) = SALTIJ
          ZR(JMSA-1+INDI+4) = SALTIJ
          IF (SALTIJ.GT.SAMAX) THEN
            SAMAX = SALTIJ
            SM = SMM
          END IF

   10   CONTINUE

   20 CONTINUE

C --- CALCUL DU FACTEUR D'USAGE

      IF (SEISME) THEN
        CALL RC36FS(NBSIG2,ZI(JNOC),ZI(JIST),NBSIG2,ZI(JNOC),ZI(JIST),
     &              ZR(JMSA),NS,NSCY,MATSE,MSE,ZR(JMSN),NOMMAT,C,K,CARA,
     &              UG)
      ELSE
        CALL RC36FU(NBSIG2,ZI(JNOC),ZI(JIST),NBSIG2,ZI(JNOC),ZI(JIST),
     &              ZR(JMSA),NPASS,NOMMAT,UG)
      END IF

      UTOT = UTOT + UG

      CALL JEDETR('&&RC3601.MATRICE_SALT')
      CALL JEDETR('&&RC3601.MATRICE_SN')
      CALL JEDETR('&&RC3601.NB_OCCURR')
      CALL JEDETR('&&RC3601.IMPR_SITU')

 1000 FORMAT ('=> GROUPE: ',I4,' , NOMBRE DE SITUATIONS: ',I4)
 1002 FORMAT ('=> LISTE DES SITUATIONS: ',100 (I4,1X))
 1010 FORMAT (1P,' SITUATION ',I4,' SN =',E12.5)
 1020 FORMAT (1P,' COMBINAISON DES SITUATIONS ',I4,3X,I4,'  SN =',E12.5)
 1031 FORMAT (1P,26X,'ETAT_A ETAT_A ',' SP =',E12.5)
 1032 FORMAT (1P,26X,'ETAT_B ETAT_A ',' SP =',E12.5)
 1033 FORMAT (1P,26X,'ETAT_B ETAT_B ',' SP =',E12.5)
 1034 FORMAT (1P,26X,'ETAT_A ETAT_B ',' SP =',E12.5)
 
 1131 FORMAT (1P,26X,'ETAT_A ETAT_A ',' SPMECA=',E12.5,' SPTHER=',E12.5)
 1132 FORMAT (1P,26X,'ETAT_B ETAT_A ',' SPMECA=',E12.5,' SPTHER=',E12.5)
 1133 FORMAT (1P,26X,'ETAT_B ETAT_B ',' SPMECA=',E12.5,' SPTHER=',E12.5)
 1134 FORMAT (1P,26X,'ETAT_A ETAT_B ',' SPMECA=',E12.5,' SPTHER=',E12.5)

      CALL JEDEMA()
      END
