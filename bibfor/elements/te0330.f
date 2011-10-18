      SUBROUTINE TE0330(OPTION,NOMTE)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 17/10/2011   AUTEUR PELLET J.PELLET 
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
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)

C     BUT:
C       POUR TOUS LES ELEMENTS, CALCUL AUX NOEUDS DES
C       DES CONTRAINTES EQUIVALENTES SUIVANTES :
C           . VON MISES            (= 1 VALEUR)
C           . TRESCA               (= 1 VALEUR)
C           . CONTRAINTES PRINCIPALES      (= 3 VALEURS)
C           . VON-MISES * SIGNE (PRESSION) (= 1 VALEUR)
C           . DIRECTION DES CONTRAINTES PRINCIPALES
C                              (=3*3 VALEURS)
C           . TRACE                        (= 1 VALEUR)
C           . TAUX DE TRIAXIALITE          (= 1 VALEUR)
C     OPTIONS :  'SIEQ_ELNO'

C     ENTREES :  OPTION : OPTION DE CALCUL
C                NOMTE  : NOM DU TYPE ELEMENT
C ----------------------------------------------------------------------
      PARAMETER (NPGMAX=27,NNOMAX=27,NEQMAX=17)
C ----------------------------------------------------------------------
      INTEGER ICONT,IEQUIF
      INTEGER IDCP,KP,J,I,INO
      INTEGER NNO,NCEQ,NPG,NNOS,NCMP
      INTEGER NDIM1,NBVA
      REAL*8 EQPG(NEQMAX*NPGMAX),EQNO(NEQMAX*NNOMAX)
      REAL*8 SIGMA(30), HYD
      CHARACTER*6  TYPMOD
      CHARACTER*16 NOMTE,OPTION

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
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

C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------

      CALL EQCARA(NOMTE,TYPMOD,NDIM1,NCEQ,NCMP,NBVA)

      IF (NOMTE.EQ.'MEC3QU9H' .OR. NOMTE.EQ.'MEC3TR7H') THEN
         CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESI','L',JIN)
         NNO   = ZI(JIN)
         NPG   = NNO
      ELSE
         CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,
     &               IVF,IDFDX,JGANO)
      ENDIF

      IF(TYPMOD.EQ.'COQUE') THEN
         CALL JEVECH('PCONCOR','L',ICONT)
      ELSE
         CALL JEVECH('PCONTRR','L',ICONT)
      ENDIF
      CALL JEVECH('PCONTEQ','E',IEQUIF)

      DO 10 I = 1,NCEQ*NPG
        EQPG(I) = 0.0D0
   10 CONTINUE
      DO 20 I = 1,NCMP*NNO
        EQNO(I) = 0.0D0
   20 CONTINUE

C -   CONTRAINTES EQUIVALENTES AUX POINTS DE GAUSS

      IF(TYPMOD.EQ.'2D') THEN
         DO 103 KP = 1,NPG
            IDCP = (KP-1) * NCMP
            DO 109 I = 1,4
                SIGMA(I) = ZR(ICONT+(KP-1)*NBVA+I-1)
 109        CONTINUE
            SIGMA(5) = 0.D0
            SIGMA(6) = 0.D0
            CALL FGEQUI(SIGMA,'SIGM',NDIM1,EQPG(IDCP+1))
 103     CONTINUE


      ELSEIF(TYPMOD.EQ.'3D'.OR. TYPMOD.EQ.'COQUE') THEN
         DO 100 KP = 1,NPG
           IDCP = (KP-1)*NCMP
           IF(TYPMOD.EQ.'COQUE') THEN
              CALL FGEQUI(ZR(ICONT+(KP-1)*NBVA),'SIGM_DIR',NDIM1,
     &                    EQNO(IDCP+1))
           ELSE
              CALL FGEQUI(ZR(ICONT+(KP-1)*NBVA),'SIGM',NDIM1,
     &                    EQPG(IDCP+1))
           ENDIF
  100        CONTINUE
      ENDIF
C -       EXTRAPOLATION AUX NOEUDS

          IF(TYPMOD.NE.'COQUE') THEN
             CALL PPGAN2(JGANO,1,NCMP,EQPG,ZR(IEQUIF))
          ENDIF

C         CORRECTION NECESSAIRE POUR VMIS_SG
C         IL NE FAUT PAS CALCULER VMIS_SG EXTRAPOLE AUX NOEUDS
C         MAIS PLUTOT  ELNO(VMIS)*SIGNE(ELNO(TRACE))
          DO 130 I = 1,NNO
C           RECALCUL DE LA TRACE, MAL CALCULEE PAR PPGAN2
            HYD=ZR(IEQUIF-1+NCMP*(I-1)+3)+ZR(IEQUIF-1+NCMP*(I-1)+4)+
     &          ZR(IEQUIF-1+NCMP*(I-1)+5)
            ZR(IEQUIF-1+NCMP*(I-1)+NCMP)=HYD
C ------    EQUIVALENT FATIGUE = SECOND INVARIANT * SIGNE(PREMIER INV)
            IF ( HYD .GE. 0.D0 ) THEN
               ZR(IEQUIF-1+NCMP*(I-1)+6)=  ZR(IEQUIF-1+NCMP*(I-1)+1)
            ELSE
               ZR(IEQUIF-1+NCMP*(I-1)+6)= -ZR(IEQUIF-1+NCMP*(I-1)+1)
            ENDIF
  130    CONTINUE


C -       STOCKAGE

        IF (TYPMOD.EQ.'COQUE') THEN
          DO 120 INO = 1,NNO
            DO 110 J = 1,NCMP
              ZR(IEQUIF-1+ (INO-1)*NCMP+J) = EQNO((INO-1)*NCMP+J)
  110       CONTINUE
  120     CONTINUE
        END IF

      END
