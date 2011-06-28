      SUBROUTINE TE0534(OPTION,NOMTE)
      IMPLICIT   NONE
      CHARACTER*16 OPTION,NOMTE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 27/06/2011   AUTEUR MASSIN P.MASSIN 
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
C RESPONSABLE GENIAUT S.GENIAUT
C TOLE CRP_20

C.......................................................................
C
C               CALCUL DES SECONDS MEMBRES DE CONTACT FROTTEMENT
C                   POUR X-FEM  (METHODE CONTINUE)
C
C
C  OPTION : 'CHAR_MECA_CONT' (CALCUL DU SECOND MEMBRE DE CONTACT)
C  OPTION : 'CHAR_MECA_FROT' (CALCUL DU SECOND MEMBRE DE FROTTEMENT)
C
C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
C
C.......................................................................
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------

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

      INTEGER      I,J,K,IFA,IPGF,ISSPG,NI,NLI,PLI
      INTEGER      JINDCO,JDONCO,JLST,IPOIDS,IVF,IDFDE,JGANO,IGEOM
      INTEGER      IDEPM,IDEPL,JPTINT,JAINT,JCFACE,JLONCH
      INTEGER      IPOIDF,IVFF,IDFDEF,IADZI,IAZK24,IBID,IVECT,JBASEC
      INTEGER      NDIM,NFH,DDLC,DDLS,NDDL,NNO,NNOS,NNOM,NNOF,DDLM
      INTEGER      NPG,NPGF,XOULA,FAC(6,4),NBF,JSEUIL
      INTEGER      INDCO(60),NINTER,NFACE,CFACE(5,3),IBID2(12,3)
      INTEGER      NINTEG,NFE,SINGU,JSTNO,NVIT
      INTEGER      NNOL,PLA(27),LACT(8),NLACT,NVEC
      INTEGER      JCOHES,IMATE,NPTF,NFISS,JFISNO,IER,CONTAC
      INTEGER      ZXAIN,XXMMVD,JHEANO,IFISS,JSTNC,NCOMPH
      INTEGER      JTAB(2),IRET,NCOMPD,NCOMPP,NCOMPA,NCOMPB,NCOMPC
      INTEGER      IBASEC,IPTINT,IAINT,JHEAFA
      REAL*8       VTMP(400),REAC,REAC12(3),FFI,JAC
      REAL*8       ND(3),FFP(27),FFC(8),SEUIL(60)
      REAL*8       RHON,MU,RHOTK,P(3,3),TAU1(3),TAU2(3),PB(3)
      REAL*8       LST,R,RR,E,G(3),RBID,FFPC(27),DFBID(27,3)
      REAL*8       CSTACO,CSTAFR,CPENCO,CPENFR,X(4)
      REAL*8       COHES(60),SAUT(3)
      REAL*8       ALPHA,DTANG(3),DNOR(3),RELA,CZMFE
      REAL*8       PP(3,3),AM(3),DSIDEP(6,6),SIGMA(6)
      REAL*8       COEFEC,COEFEF
      LOGICAL      LPENAF,NOEUD,LPENAC,LBID,LELIM
      CHARACTER*8  ELREF,TYPMA,FPG,ELC,LAG,ELREFC,NOMRES(3),JOB
      CHARACTER*16 ENR

C.......................................................................

      CALL JEMARQ()

C --- INITIALISATIONS
C
      ZXAIN=XXMMVD('ZXAIN')
      LELIM = .FALSE.
      CALL ELREF1(ELREF)
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
C
C     INITIALISATION DES DIMENSIONS DES DDLS X-FEM
      CALL XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,
     &            DDLM,NFISS,CONTAC)
C
      CALL TECAEL(IADZI,IAZK24)
      TYPMA=ZK24(IAZK24-1+3+ZI(IADZI-1+2)+3)

      IF (NDIM .EQ. 3) THEN
         CALL CONFAC(TYPMA,IBID2,IBID,FAC,NBF)
      ENDIF

      DO 40 J=1,NDDL
        VTMP(J)=0.D0
40    CONTINUE
C
C --- RECUPERATION DU TYPE DE CONTACT
C
      NOEUD=.FALSE.
      CALL TEATTR (NOMTE,'C','XLAG',LAG,IER)
      CALL ASSERT(IER.EQ.0)
      IF (LAG(1:5).EQ.'NOEUD') NOEUD=.TRUE.
      CALL ELELIN(CONTAC,ELREF,ELREFC,IBID,IBID)
C
C --- RECUPERATION DES ENTR�ES / SORTIE
C
      CALL JEVECH('PGEOMER','E',IGEOM)
C     DEPLACEMENT A L'EQUILIBRE PRECEDENT  (DEPMOI)       : 'PDEPL_M'
      CALL JEVECH('PDEPL_M','L',IDEPM)
C     INCREMENT DE DEP DEPUIS L'EQUILIBRE PRECEDENT (DEPDEL) : 'PDEPL_P'
      CALL JEVECH('PDEPL_P','L',IDEPL)
      CALL JEVECH('PINDCOI','L',JINDCO)
      CALL JEVECH('PDONCO','L',JDONCO)
      CALL TECACH('OOO','PDONCO',2,JTAB,IBID)
      NCOMPD = JTAB(2)
      CALL JEVECH('PSEUIL','L',JSEUIL)
      CALL JEVECH('PLST','L',JLST)
      CALL JEVECH('PPINTER','L',JPTINT)
      CALL JEVECH('PAINTER','L',JAINT)
      CALL JEVECH('PCFACE','L',JCFACE)
      CALL JEVECH('PLONCHA','L',JLONCH)
      CALL JEVECH('PBASECO','L',JBASEC)
      CALL JEVECH('PVECTUR','E',IVECT)
      IF (NFISS.GT.1) THEN
        CALL JEVECH('PFISNO','L',JFISNO)
        CALL JEVECH('PHEAVNO','L',JHEANO)
        CALL JEVECH('PHEAVFA','L',JHEAFA)
        CALL TECACH('OOO','PHEAVFA',2,JTAB,IRET)
        NCOMPH = JTAB(2)
      ENDIF
C     DIMENSSION DES GRANDEURS DANS LA CARTE
      CALL TECACH('OOO','PDONCO',2,JTAB,IRET)
      NCOMPD = JTAB(2)
      CALL TECACH('OOO','PPINTER',2,JTAB,IRET)
      NCOMPP = JTAB(2)
      CALL TECACH('OOO','PAINTER',2,JTAB,IRET)
      NCOMPA = JTAB(2)
      CALL TECACH('OOO','PBASECO',2,JTAB,IRET)
      NCOMPB = JTAB(2)
      CALL TECACH('OOO','PCFACE',2,JTAB,IRET)
      NCOMPC = JTAB(2)

C     STATUT POUR L'�LIMINATION DES DDLS DE CONTACT
      CALL WKVECT('&&TE0534.STNC','V V I',MAX(1,NFH)*NNOS,JSTNC)
      DO 30 I=1,MAX(1,NFH)*NNOS
        ZI(JSTNC-1+I) = 1
  30  CONTINUE
      CALL TEATTR(NOMTE,'S','XFEM',ENR,IBID)

C
C --- BOUCLE SUR LES FISSURES
C
      DO 90 IFISS = 1,NFISS

        IF (ENR.EQ.'XHC') THEN
          RELA  = ZR(JDONCO-1+(IFISS-1)*NCOMPD+10)
          CZMFE = ZR(JDONCO-1+(IFISS-1)*NCOMPD+11)
        ELSE
          RELA  = 0.D0
          CZMFE = 0.D0
        ENDIF
         
        IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
          CALL JEVECH('PMATERC','L',IMATE)
          IMATE = IMATE +60*(IFISS-1)
          CALL JEVECH('PCOHES' ,'L',JCOHES)
        ENDIF
C
C --- R�CUP�RATIONS DES DONN�ES SUR LE CONTACT ET
C     SUR LA TOPOLOGIE DES FACETTES
        NINTER=ZI(JLONCH+3*(IFISS-1)-1+1)
        IF (NINTER.EQ.0) GOTO 90
        NFACE=ZI(JLONCH+3*(IFISS-1)-1+2)
        NPTF=ZI(JLONCH+3*(IFISS-1)-1+3)
        DO 11 I=1,NFACE
          DO 12 J=1,NPTF
            CFACE(I,J)=ZI(JCFACE-1+NCOMPC*(IFISS-1)+NPTF*(I-1)+J)
 12       CONTINUE
 11     CONTINUE
        IBASEC = JBASEC + NCOMPB*(IFISS-1)
        IPTINT = JPTINT + NCOMPP*(IFISS-1)
        IAINT  = JAINT + NCOMPA*(IFISS-1)
C
        DO 10 I=1,60
          INDCO(I) = ZI(JINDCO-1+60*(IFISS-1)+I)
          SEUIL(I) = ZR(JSEUIL-1+60*(IFISS-1)+I)
          IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
             COHES(I) = ZR(JCOHES-1+60*(IFISS-1)+I)
          ENDIF
 10     CONTINUE
        RHON  = ZR(JDONCO-1+(IFISS-1)*NCOMPD+1)
        MU    = ZR(JDONCO-1+(IFISS-1)*NCOMPD+2)
        RHOTK = ZR(JDONCO-1+(IFISS-1)*NCOMPD+3)

C --- SCHEMA D'INTEGRATION NUMERIQUE ET ELEMENT DE REFERENCE DE CONTACT
        NINTEG = NINT(ZR(JDONCO-1+(IFISS-1)*NCOMPD+4))
        CALL XMINTE(NDIM,NINTEG,FPG)
C
        IF (NDIM .EQ. 3) THEN
          ELC='TR3'
        ELSEIF (NDIM.EQ.2) THEN
          IF(CONTAC.LE.2) THEN
            ELC='SE2'
          ELSE
            ELC='SE3'
          ENDIF
        ENDIF
C
        CALL ELREF4(ELC,FPG,IBID,NNOF,IBID,NPGF,IPOIDF,IVFF,IDFDEF,IBID)

C --- COEFFICIENTS DE STABILISATION
        CSTACO = ZR(JDONCO-1+(IFISS-1)*NCOMPD+6)
        CSTAFR = ZR(JDONCO-1+(IFISS-1)*NCOMPD+7)

C --- COEFFICIENTS DE PENALISATION
        CPENCO = ZR(JDONCO-1+(IFISS-1)*NCOMPD+8)
        CPENFR = ZR(JDONCO-1+(IFISS-1)*NCOMPD+9)

        IF (CSTACO.EQ.0.D0) CSTACO=RHON
        IF (CSTAFR.EQ.0.D0) CSTAFR=RHOTK

        IF (CPENCO.EQ.0.D0) CPENCO=RHON
        IF (CPENFR.EQ.0.D0) CPENFR=RHOTK

C     PENALISATION PURE
C     PENALISATION DU CONTACT
        LPENAC=.FALSE.
        IF (CSTACO.EQ.0.D0) THEN
          CSTACO=CPENCO
        IF(CPENCO.NE.0.0D0)LPENAC=.TRUE.
        ENDIF
C     PENALISATION DU FROTTEMENT
        LPENAF=.FALSE.
        IF (CSTAFR.EQ.0.D0) THEN
        IF(CPENFR.NE.0.0D0)LPENAF=.TRUE.
        ENDIF
C
C     COEFFICIENT DE MISE A L ECHELLE CONTACT
C
      IF(LPENAC) COEFEC = CPENCO
      IF(.NOT.LPENAC) COEFEC = ZR(JDONCO-1+5)
      IF(LPENAF) COEFEF = CPENFR
      IF(.NOT.LPENAF) COEFEF = 1.D0
C
        IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
          IF(CZMFE.EQ.1.D0) THEN
          CSTACO=COEFEC
            LPENAC=.FALSE.
          ENDIF
        ENDIF
C
C --- LISTE DES LAMBDAS ACTIFS
C
        IF(NOEUD) THEN
          CALL XLACTI(TYPMA,NINTER,IAINT,LACT,NLACT)
          IF (NLACT.LT.NNO) LELIM = .TRUE.
        ENDIF
        IF (NFISS.EQ.1) THEN
          DO 50 I=1,NNOS
            IF (LACT(I).EQ.0) ZI(JSTNC-1+I)=0
  50      CONTINUE
        ELSE
          DO 60 I=1,NNOS
            IF (LACT(I).EQ.0) ZI(JSTNC-1+(I-1)*NFH+
     &                       ZI(JHEANO-1+(I-1)*NFISS+IFISS))=0
  60      CONTINUE
        ENDIF
C
C --- BOUCLE SUR LES FACETTES
C
        DO 100 IFA=1,NFACE
C         NOMBRE DE LAMBDAS ET LEUR PLACE DANS LA MATRICE
          IF (NOEUD) THEN
            IF (CONTAC.EQ.1 .OR. CONTAC.EQ.4) NNOL=NNO
            IF (CONTAC.EQ.3) NNOL=NNOS
            DO 15 I=1,NNOL
              CALL XPLMAT(NDIM,NFH,NFE,DDLC,DDLM,NNO,NNOM,I,PLI)
              IF (NFISS.EQ.1) THEN
                PLA(I) = PLI
              ELSE
                PLA(I) = PLI+NDIM*(ZI(JHEANO-1+(I-1)*NFISS+IFISS)-1)
              ENDIF
 15         CONTINUE
          ELSE
            NNOL=NNOF
            DO 16 I=1,NNOF
C             XOULA  : RENVOIE LE NUMERO DU NOEUD PORTANT CE LAMBDA
              NI=XOULA(CFACE,IFA,I,JAINT,TYPMA,CONTAC)
C             PLACE DU LAMBDA DANS LA MATRICE
              CALL XPLMAT(NDIM,NFH,NFE,DDLC,DDLM,NNO,NNOM,NI,PLI)
              PLA(I)=PLI
 16         CONTINUE
          ENDIF
C
C --- BOUCLE SUR LES POINTS DE GAUSS DES FACETTES
C
          DO 110 IPGF=1,NPGF
C
C --- INDICE DE CE POINT DE GAUSS DANS INDCO
          ISSPG=NPGF*(IFA-1)+IPGF

C --- CALCUL DE JAC (PRODUIT DU JACOBIEN ET DU POIDS)
C --- ET DES FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C --- ET LA NORMALE ND ORIENT�E DE ESCL -> MAIT
            IF (NDIM.EQ.3) THEN
            CALL XJACFF(ELREF,ELREFC,ELC,NDIM,FPG,IPTINT,IFA,CFACE,IPGF,
     &       NNO,IGEOM,IBASEC,G,'NON',JAC,FFP,FFPC,DFBID,ND,TAU1,TAU2)
            ELSEIF (NDIM.EQ.2) THEN
            CALL XJACF2(ELREF,ELREFC,ELC,NDIM,FPG,IPTINT,IFA,CFACE,NPTF,
     &      IPGF,NNO,IGEOM,IBASEC,G,'NON',JAC,FFP,FFPC,DFBID,ND,TAU1)
            ENDIF

C --- CALCUL DES FONCTIONS DE FORMES DE CONTACT DANS LE CAS LAG NOEUD
            IF (CONTAC.EQ.1) THEN
              CALL XMOFFC(LACT,NLACT,NNO,FFP,FFC)
            ELSEIF (CONTAC.EQ.3) THEN
              CALL XMOFFC(LACT,NLACT,NNOS,FFPC,FFC)
            ELSEIF (CONTAC.EQ.4) THEN
              CALL XMOFFC(LACT,NLACT,NNO,FFP,FFC)
            ENDIF

C --- CE POINT DE GAUSS EST-IL SUR UNE ARETE?
            K=0
            DO 17 I=1,NINTER
              IF (K.EQ.0) THEN
                X(4)=0.D0
                DO 20 J=1,NDIM
                  X(J)=ZR(IPTINT-1+NDIM*(I-1)+J)
 20             CONTINUE
                DO 21 J=1,NDIM
                  X(4) = X(4) + (X(J)-G(J))*(X(J)-G(J))
 21             CONTINUE
                X(4) = SQRT(X(4))
                IF (X(4).LT.1.D-12) THEN
                  K=I
                  GOTO 17
                ENDIF
              ENDIF
 17         CONTINUE
C           SI OUI, L'ARETE EST-ELLE VITALE?
            IF (K.NE.0) THEN
              NVIT = NINT(ZR(IAINT-1+ZXAIN*(K-1)+5))
            ELSE
              NVIT = 0
            ENDIF
C           IL NE FAUT PAS UTILISER NVIT SI LE SCHEMA D'INTEGRATION
C           NE CONTIENT PAS DE NOEUDS
            IF ((FPG(1:3).EQ.'FPG').OR.(FPG.EQ.'GAUSS')
     &             .OR.(FPG.EQ.'XCON')) NVIT=1
C
C
C --- R�ACTION CONTACT = SOMME DES FF(I).LAMBDA(I) POUR I=1,NNOL
C --- R�ACTION FROTT = SOMME DES FF(I).(LAMB1(I).TAU1+LAMB2(I).TAU2)
C --- (DEPDEL+DEPMOI)
            REAC=0.D0
            CALL VECINI(3,0.D0,REAC12)
            DO 120 I = 1,NNOL
              PLI=PLA(I)
              IF (NOEUD) THEN
                FFI=FFC(I)
                NLI=LACT(I)
                IF (NLI.EQ.0) GOTO 120
              ELSE
                FFI=ZR(IVFF-1+NNOF*(IPGF-1)+I)
                NLI=CFACE(IFA,I)
              ENDIF
            REAC = REAC + 
     &         FFI * (ZR(IDEPL-1+PLI)+ZR(IDEPM-1+PLI))

              DO 121 J=1,NDIM
                IF (NDIM .EQ.3) THEN
                  REAC12(J)=REAC12(J)+FFI*(ZR(IDEPL-1+PLI+1)*TAU1(J)
     &                                    +ZR(IDEPM-1+PLI+1)*TAU1(J)
     &                                    +ZR(IDEPM-1+PLI+2)*TAU2(J)
     &                                    +ZR(IDEPL-1+PLI+2)*TAU2(J))
                ELSEIF (NDIM.EQ.2) THEN
                  REAC12(J)=REAC12(J)+FFI*(ZR(IDEPL-1+PLI+1)*TAU1(J)
     &                                    +ZR(IDEPM-1+PLI+1)*TAU1(J))
                ENDIF
 121          CONTINUE
 120        CONTINUE
C
C --- CALCUL DE RR = SQRT(DISTANCE AU FOND DE FISSURE)
C
            IF (SINGU.EQ.1) THEN
              LST=0.D0
              DO 112 I=1,NNO
                LST=LST+ZR(JLST-1+I)*FFP(I)
 112          CONTINUE
              R=ABS(LST)
              RR=SQRT(R)
            ENDIF
C
C --- CALCUL DES SECONDS MEMBRES DE CONTACT
C     .....................................

            IF (OPTION.EQ.'CHAR_MECA_CONT') THEN

              IF (INDCO(ISSPG).EQ.0) THEN
                IF (NVIT.NE.0) THEN
C
C --- CALCUL DU VECTEUR LN2
C
                  CALL XMVEC3(NNOL,NNOF,PLA,IPGF,IVFF,
     &                        FFC,REAC,JAC,NOEUD,COEFEC,CSTACO,
     &                        VTMP)
                ENDIF
C
              ELSE IF (INDCO(ISSPG).EQ.1) THEN
C
C --- CALCUL DU SAUT ET DE DN EN CE PG (DEPMOI + DEPDEL)
                NVEC=2
                CALL XMMSA3(NDIM,NNO,NNOS,FFP,NDDL,NVEC,ZR(IDEPL),
     &                    ZR(IDEPM),ZR(IDEPM),NFH,SINGU,RR,DDLS,DDLM,
     &                    JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                    SAUT)
C
C --- CALCUL DU VECTEUR LN1 & LN2
C
                CALL XMVEC2(NDIM,NNO,NNOS,NNOL,NNOF,PLA,IPGF,IVFF,
     &                    FFC,FFP,REAC,JAC,NFH,NOEUD,SAUT,
     &                    SINGU,ND,RR,COEFEC,CPENCO,LPENAC,DDLS,DDLM,
     &                    JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                    VTMP)

              ELSE
                CALL ASSERT(INDCO(ISSPG).EQ.0 .OR. INDCO(ISSPG).EQ.1)
              END IF
C
C --- CALCUL DES SECONDS MEMBRES DE FROTTEMENT
C     ........................................

            ELSEIF (OPTION.EQ.'CHAR_MECA_FROT') THEN

              IF (MU.EQ.0.D0.OR.SEUIL(ISSPG).EQ.0.D0)
     &          INDCO(ISSPG) = 0
              IF (NFISS.GT.1) INDCO(ISSPG) = 0
C
              IF (INDCO(ISSPG).EQ.0) THEN
                IF (NVIT.NE.0) THEN
                  NVEC=2
                  CALL XMMSA3(NDIM,NNO,NNOS,FFP,NDDL,NVEC,ZR(IDEPL),
     &                      ZR(IDEPM),ZR(IDEPM),NFH,SINGU,RR,DDLS,DDLM,
     &                      JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                      SAUT)
C
C --- CALCUL DU VECTEUR LN3
C
                  CALL XMVEF4(NDIM,NNOL,NNOF,PLA,IPGF,IVFF,
     &                      FFC,REAC12,JAC,NOEUD,
     &                      TAU1,TAU2,CFACE,IFA,LACT,
     &                      VTMP)
C
C --- ACTIVATION DE LA LOI COHESIVE & RECUPERATION DES
C --- PARAMETRES MATERIAUX
C
                ENDIF
                IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
C
C --- CALCUL DU SAUT DE DEPLACEMENT EQUIVALENT [[UEG]]
C
                  NVEC=2
                  CALL XMMSA3(NDIM,NNO,NNOS,FFP,NDDL,NVEC,ZR(IDEPL),
     &                       ZR(IDEPM),ZR(IDEPM),NFH,SINGU,RR,DDLS,DDLM,
     &                       JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &                       SAUT)
C
                  JOB='VECTEUR'
                  CALL XMMSA2(NDIM ,IPGF  ,ZI(IMATE)   ,SAUT ,ND  ,
     &                       TAU1 ,TAU2  ,COHES(ISSPG),JOB  ,RELA,
     &                       ALPHA,DSIDEP,SIGMA       ,PP   ,DNOR,
     &                       DTANG,P     ,AM)     
C
C --- CALCUL DES SECONDS MEMBRES DE COHESION
C
                  CALL XMVCO1(NDIM,NNO,NNOL,NNOF,
     &                 SIGMA,PLA,IPGF,IVFF,IFA,CFACE,LACT ,
     &                 DTANG,NFH,DDLS,JAC,FFC,FFP,
     &                 SINGU,COEFEC,RR,NOEUD,CSTACO,ND,TAU1,TAU2,
     &                 VTMP)

                ENDIF


              ELSE IF (INDCO(ISSPG).EQ.1) THEN
C
C --- CALCUL DU VECTEUR LN1
C
                CALL XMVEF2(NDIM,NNO,NNOS,FFP,JAC,SEUIL(ISSPG),
     &                    REAC12,SINGU,NFH,RR,CPENFR,CSTAFR,
     &                    MU,LPENAF,ND,DDLS,DDLM,IDEPL,RHOTK,
     &                    PB,VTMP )

C
C --- CALCUL DU VECTEUR LN3
C
                CALL XMVEF3(NDIM,NNOL,NNOF,PLA,IPGF,IVFF,
     &                    FFC,REAC12,PB,JAC,NOEUD,SEUIL(ISSPG),
     &                    TAU1,TAU2,IFA,CFACE,LACT,COEFEF,CPENFR,
     &                    CSTAFR,MU,LPENAF,
     &                    VTMP )

              ELSE
                CALL ASSERT(INDCO(ISSPG).EQ.0 .OR. INDCO(ISSPG).EQ.1)
              END IF

            ELSE
              CALL ASSERT(OPTION.EQ.'CHAR_MECA_FROT' .OR.
     &                  OPTION.EQ.'CHAR_MECA_CONT')
            ENDIF

C --- FIN DE BOUCLE SUR LES POINTS DE GAUSS
 110      CONTINUE

C --- FIN DE BOUCLE SUR LES FACETTES
 100    CONTINUE
C --- FIN BOUCLE SUR LES FISSURES
  90  CONTINUE
C
C-----------------------------------------------------------------------
C     COPIE DES CHAMPS DE SORTIES ET FIN
C-----------------------------------------------------------------------
C
      DO 900 I=1,NDDL
        ZR(IVECT-1+I)=VTMP(I)
 900  CONTINUE

      CALL TEATTR (NOMTE,'C','XLAG',LAG,IBID)
      IF (IBID.EQ.0.AND.LAG.EQ.'ARETE') THEN
        NNO = NNOS
      ENDIF
C     SUPPRESSION DES DDLS DE DEPLACEMENT SEULEMENT POUR LES XHTC
      IF (NFH.NE.0) THEN
        CALL JEVECH('PSTANO' ,'L',JSTNO)
        CALL XTEDDL(NDIM,NFH,NFE,DDLS,NDDL,NNO,NNOS,ZI(JSTNO),
     &              .FALSE.,LBID,OPTION,NOMTE,RBID,ZR(IVECT),DDLM,
     &              NFISS,JFISNO)
      ENDIF
C     SUPPRESSION DES DDLS DE CONTACT
      IF (LELIM) THEN
        CALL XTEDDL(NDIM,NFH,NFE,DDLS,NDDL,NNO,NNOS,ZI(JSTNC),
     &              .TRUE.,.TRUE.,OPTION,NOMTE,RBID,ZR(IVECT),DDLM,
     &              NFISS,JFISNO)
      ENDIF
C
      CALL JEDETR('&&TE0534.STNC')
C
      CALL JEDEMA()
      END
