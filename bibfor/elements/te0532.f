      SUBROUTINE TE0532(OPTION,NOMTE)
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
C.......................................................................
C
C                CONTACT X-FEM M�THODE CONTINUE :
C         CONVERGENCE DE LA BOUCLE SUR LES CONTRAINTES ACTIVES
C
C
C  OPTION : 'XCVBCA' (X-FEM CONVERGENCE BOUCLE CONTRAINTES ACTIVES )

C  ENTREES  ---> OPTION : OPTION DE CALCUL
C           ---> NOMTE  : NOM DU TYPE ELEMENT
C
C......................................................................
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
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

C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------

      INTEGER      I,J,IFA,IPGF,ISSPG,NI,PLI
      INTEGER      JINDCO,JDONCO,JLST,IPOIDS,IVF,IDFDE,JGANO,IGEOM
      INTEGER      IDEPL,JPTINT,JAINT,JCFACE,JLONCH,JGLISS
      INTEGER      IPOIDF,IVFF,IDFDEF,IADZI,IAZK24,IBID,JOUT1,JOUT2
      INTEGER      JOUT3,JMEMCO,NDIM,NFH,DDLC,DDLS,DDLM
      INTEGER      NPG,NPGF,XOULA,INCOCA,INTEG,NFE,NINTER,NNOF
      INTEGER      INDCO(60),GLISS(60),MEMCO(60),NFACE,CFACE(5,3)
      INTEGER      NNO,NNOS,NNOM,NNOL,PLA(27),LACT(8),NLACT
      INTEGER      IER,CONTAC,JBASEC,NPTF,NDDL,NVEC,NFISS,JFISNO
      INTEGER      IMATE,SINGU,JCOHES,JCOHEO,JHEANO,IFISS,JHEAFA,NCOMPH
      INTEGER      JTAB(2),IRET,NCOMPD,NCOMPP,NCOMPA,NCOMPB,NCOMPC
      INTEGER      IBASEC,IPTINT,IAINT
      INTEGER ICODRE(3)
      CHARACTER*8  ELREF,TYPMA,FPG,ELC,LAG,ELREFC,NOMRES(3),JOB
      CHARACTER*9  PHEN
      CHARACTER*16 ENR
      REAL*8       FFPC(27),DFBID(27,3),CZMFE
      REAL*8       FFI,REAC,FFP(27),FFC(8),LC
      REAL*8       PREC,ND(3),DN,SAUT(3),LAMBDA,LST,R,RR,E,G(3),RBID
      REAL*8       ALPHA0,P(3,3),PP(3,3),DSIDEP(6,6),TAU1(3)
      REAL*8       TAU2(3),ALPHA,DNOR(3),DTANG(3),AM3(3),SIGMA(6)
      REAL*8       VALRES(3),RELA,COHES(60)
      REAL*8       COEFEC,CPENCO,CSTACO
      PARAMETER    (PREC=1.D-16)
      LOGICAL      IMPRIM,NOEUD,LPENAC
      DATA         NOMRES /'GC','SIGM_C','PENA_ADH'/
C......................................................................

      CALL JEMARQ()

      IMPRIM=.FALSE.
      INCOCA=0

      CALL ELREF1(ELREF)
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDE,JGANO)
C
      CALL XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,
     &            DDLM,NFISS,CONTAC)

      CALL TECAEL(IADZI,IAZK24)
      TYPMA=ZK24(IAZK24-1+3+ZI(IADZI-1+2)+3)
C
C     RECUPERATION DU TYPE DE CONTACT
      NOEUD=.FALSE.
      CALL TEATTR (NOMTE,'C','XLAG',LAG,IER)
      CALL ASSERT(IER.EQ.0)
      IF (LAG(1:5).EQ.'NOEUD') NOEUD=.TRUE.
      CALL ELELIN(CONTAC,ELREF,ELREFC,IBID,IBID)

C     RECUPERATION DES ENTR�ES / SORTIE
      CALL JEVECH('PGEOMER','E',IGEOM)
C     DEPLACEMENT TOTAL COURANT (DEPPLU) : 'PDEPL_P'
      CALL JEVECH('PDEPL_P','L',IDEPL)
      CALL JEVECH('PINDCOI','L',JINDCO)
      CALL JEVECH('PDONCO','L',JDONCO)
      CALL TECACH('OOO','PDONCO',2,JTAB,IBID)
      NCOMPD = JTAB(2)
      CALL JEVECH('PGLISS','L',JGLISS)
      CALL JEVECH('PLST','L',JLST)
      CALL JEVECH('PPINTER','L',JPTINT)
      CALL JEVECH('PAINTER','L',JAINT)
      CALL JEVECH('PCFACE','L',JCFACE)
      CALL JEVECH('PLONCHA','L',JLONCH)
      CALL JEVECH('PMEMCON','L',JMEMCO)
      CALL JEVECH('PBASECO','L',JBASEC)
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

      CALL JEVECH('PINCOCA','E',JOUT1)
      CALL JEVECH('PINDCOO','E',JOUT2)
      CALL JEVECH('PINDMEM','E',JOUT3)

      CALL TEATTR(NOMTE,'S','XFEM',ENR,IBID)
C
C --- BOUCLE SUR LES FISSURES
C
      DO 90 IFISS = 1,NFISS
      IF (ENR.EQ.'XHC') THEN
        RELA   = ZR(JDONCO-1+(IFISS-1)*NCOMPD+10)
        CZMFE  = ZR(JDONCO-1+(IFISS-1)*NCOMPD+11)
      ELSE
        RELA  = 0.0D0
        CZMFE = 0.D0
      ENDIF
      IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
        CALL JEVECH('PMATERC','L',IMATE)
          IMATE = IMATE + 60*(IFISS-1)
          CALL JEVECH('PCOHES' ,'L',JCOHES)
          CALL JEVECH('PCOHESO' ,'E',JCOHEO)
        ENDIF
C       R�CUP�RATIONS DES DONN�ES SUR LE CONTACT ET
C       SUR LA TOPOLOGIE DES FACETTES
        NINTER=ZI(JLONCH+3*(IFISS-1)-1+1)
        IF (NINTER.EQ.0) GOTO 90
        NFACE=ZI(JLONCH+3*(IFISS-1)-1+2)
        NPTF=ZI(JLONCH+3*(IFISS-1)-1+3)

        DO 10 I=1,60
          INDCO(I) = ZI(JINDCO-1+60*(IFISS-1)+I)
          GLISS(I) = ZI(JGLISS-1+60*(IFISS-1)+I)
          MEMCO(I) = ZI(JMEMCO-1+60*(IFISS-1)+I)
          IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
             COHES(I) = ZR(JCOHES-1+60*(IFISS-1)+I)
          ENDIF
10      CONTINUE

        DO 15 I=1,NFACE
          DO 16 J=1,NPTF
            CFACE(I,J)=ZI(JCFACE-1+NCOMPC*(IFISS-1)+NPTF*(I-1)+J)
16        CONTINUE
15      CONTINUE
        IBASEC = JBASEC + NCOMPB*(IFISS-1)
        IPTINT = JPTINT + NCOMPP*(IFISS-1)
        IAINT  = JAINT + NCOMPA*(IFISS-1)
C
C       SCHEMA D'INTEGRATION NUMERIQUE ET ELEM DE REFERENCE DE CONTACT
        INTEG = NINT(ZR(JDONCO+(IFISS-1)*NCOMPD-1+4))
        CALL XMINTE(NDIM,INTEG,FPG)
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
C
C       VALEUR INITIALE DE LA VARIABLE INTERNE
C       DEFINITIONS DIFFERENTES SELON LA LOI COHESIVE
        IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
          PHEN = 'RUPT_FRAG'
          CALL RCVALA(ZI(IMATE),' ',PHEN,0,' ',0.D0,3,
     &              NOMRES,VALRES,ICODRE, 1)
          IF(RELA.EQ.1.D0) LC=VALRES(1)/VALRES(2)
          IF(RELA.EQ.2.D0) LC=2.D0*VALRES(1)/VALRES(2)
          ALPHA0=VALRES(3)*LC
        ENDIF

C       IMPRESSION (1ERE PARTIE)
        IF (IMPRIM) THEN
          WRITE(6,*)' '
          WRITE(6,697)
 697      FORMAT(4X,'I_IN',7X,'DN',11X,'REAC',7X,'I_OUT')
        ENDIF
C
C       LISTES DES LAMBDAS ACTIFS PAR FACETTE
C
        IF(NOEUD) CALL XLACTI(TYPMA,NINTER,IAINT,LACT,NLACT)

C       BOUCLE SUR LES FACETTES
        DO 100 IFA=1,NFACE

C          NOMBRE DE LAMBDAS ET LEUR PLACE DANS LA MATRICE
          IF (NOEUD) THEN
            IF (CONTAC.EQ.1 .OR. CONTAC.EQ.4) NNOL=NNO
            IF (CONTAC.EQ.3) NNOL=NNOS
            DO 13 I=1,NNO
              CALL XPLMAT(NDIM,NFH,NFE,DDLC,DDLM,NNO,NNOM,I,PLI)
              IF (NFISS.EQ.1) THEN
                PLA(I) = PLI
              ELSE
                PLA(I) = PLI+NDIM*(ZI(JHEANO-1+(I-1)*NFISS+IFISS)-1)
              ENDIF
 13         CONTINUE
          ELSE
            NNOL=NNOF
            DO 14 I=1,NNOF
C             XOULA  : RENVOIE LE NUMERO DU NOEUD PORTANT CE LAMBDA
              NI=XOULA(CFACE,IFA,I,JAINT,TYPMA,CONTAC)
C             PLACE DU LAMBDA DANS LA MATRICE
              CALL XPLMAT(NDIM,NFH,NFE,DDLC,DDLM,NNO,NNOM,NI,PLI)
              PLA(I)=PLI
 14         CONTINUE
          ENDIF

C         BOUCLE SUR LES POINTS DE GAUSS DES FACETTES
          DO 110 IPGF=1,NPGF
C
C            INDICE DE CE POINT DE GAUSS DANS INDCO
             ISSPG=NPGF*(IFA-1)+IPGF
C
C            CALCUL DE JAC (PRODUIT DU JACOBIEN ET DU POIDS)
C            ET DES FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C            ET LA NORMALE ND ORIENT�E DE ESCL -> MAIT
             IF (NDIM.EQ.3) THEN
               CALL XJACFF(ELREF,ELREFC,ELC,NDIM,FPG,IPTINT,IFA,
     &          CFACE,IPGF,NNO,IGEOM,IBASEC,G,'NON',RBID,FFP,FFPC,
     &          DFBID,ND,TAU1,TAU2)
             ELSEIF (NDIM.EQ.2) THEN
               CALL XJACF2(ELREF,ELREFC,ELC,NDIM,FPG,IPTINT,IFA,
     &               CFACE,NPTF,IPGF,NNO,IGEOM,IBASEC,G,'NON',
     &               RBID,FFP,FFPC,DFBID,ND,TAU1)
             ENDIF

C            CALCUL DES FONCTIONS DE FORMES DE CONTACT
C            DANS LE CAS LINEAIRE
             IF (CONTAC.EQ.1) THEN
               CALL XMOFFC(LACT,NLACT,NNO,FFP,FFC)
             ELSEIF (CONTAC.EQ.3) THEN
               CALL XMOFFC(LACT,NLACT,NNOS,FFPC,FFC)
             ELSEIF (CONTAC.EQ.4) THEN
               CALL XMOFFC(LACT,NLACT,NNO,FFP,FFC)
             ENDIF
C
C            CALCUL DE RR = SQRT(DISTANCE AU FOND DE FISSURE)
C
             IF (SINGU.EQ.1) THEN
               LST=0.D0
               DO 112 I=1,NNO
                 LST=LST+ZR(JLST-1+I)*FFP(I)
112            CONTINUE
               R=ABS(LST)
               RR=SQRT(R)
             ENDIF
C            CALCUL COMPOSANTE NORMALE SAUT DE DEPLACEMENT
             NVEC=1
             CALL XMMSA3(NDIM,NNO,NNOS,FFP,NDDL,NVEC,ZR(IDEPL),
     &           ZR(IDEPL),ZR(IDEPL),NFH,SINGU,RR,DDLS,DDLM,
     &                   JFISNO,NFISS,IFISS,JHEAFA,NCOMPH,IFA,
     &           SAUT)

             IF(CZMFE.EQ.1.D0) THEN
               ZI(JOUT2-1+60*(IFISS-1)+ISSPG) = 0
               ZI(JOUT3-1+60*(IFISS-1)+ISSPG) = 0
             ELSE
             
               DN = 0.D0
               DO 143 J = 1,NDIM
                 DN = DN + SAUT(J)*ND(J)
 143           CONTINUE

C              CALCUL DE LA REACTION A PARTIR DES LAMBDA DE DEPPLU
               REAC = 0.D0
               DO 150 I = 1,NNOL
                 PLI=PLA(I)
                 IF (NOEUD) THEN
                   FFI=FFC(I)
                 ELSE
                   FFI=ZR(IVFF-1+NNOF*(IPGF-1)+I)
                 ENDIF
                 LAMBDA = ZR(IDEPL-1+PLI)
                 REAC = REAC + FFI * LAMBDA
 150           CONTINUE

               IF (INDCO(ISSPG).EQ.0) THEN

C              ON REGARDE LA DISTANCE DN DES POINTS SUPPOS�S
C              NON CONTACTANTS :
C              INTERP�N�PRATION EQUIVAUT � DN > 0 (ICI DN > 1E-16 )

                 IF (DN.GT.PREC) THEN
                   ZI(JOUT2-1+60*(IFISS-1)+ISSPG) = 1
                   ZI(JOUT3-1+60*(IFISS-1)+ISSPG) = 1
                   INCOCA = 1
                 ELSE
                   ZI(JOUT2-1+60*(IFISS-1)+ISSPG) = 0
                 END IF
C
C                ON REGARDE LA REACTION POUR LES POINTS 
C                SUPPOSES CONTACTANT :
               ELSE IF (INDCO(ISSPG).EQ.1) THEN
                 IF (REAC.GT.-1.D-3) THEN
C                  SI GLISSIERE=OUI ET IL Y A EU DU CONTACT DEJA SUR CE
C                  POINT (MEMCON=1), ALORS ON FORCE LE CONTACT
                  IF ((GLISS(ISSPG).EQ.1).AND.
     &            (MEMCO(ISSPG).EQ.1)) THEN
                    ZI(JOUT2-1+60*(IFISS-1)+ISSPG) = 1
                    ZI(JOUT3-1+60*(IFISS-1)+ISSPG) = 1
                  ELSE IF (GLISS(ISSPG).EQ.0) THEN
                    ZI(JOUT2-1+60*(IFISS-1)+ISSPG) = 0
                    INCOCA = 1
                  ENDIF
                ELSE
                  ZI(JOUT2-1+60*(IFISS-1)+ISSPG) = 1
                  ZI(JOUT3-1+60*(IFISS-1)+ISSPG) = 1
                ENDIF
C
               ELSE
C                SI INDCO N'EST NI �GAL � 0 NI �GAL � 1:
C                PROBLEME DE STATUT DE CONTACT.
                 CALL ASSERT(INDCO(ISSPG).EQ.0.OR.INDCO(ISSPG).EQ.1)
               END IF
C
C           IMPRESSION (2EME PARTIE)
               IF (IMPRIM) THEN
                 WRITE(6,698)INDCO(ISSPG),DN,REAC,
     &                        ZI(JOUT2-1+60*(IFISS-1)+ISSPG)
 698             FORMAT(5X,I1,4X,E11.5,4X,E11.5,4X,I1)
               ENDIF
            
             ENDIF
                  
             IF(RELA.EQ.1.D0.OR.RELA.EQ.2.D0) THEN
C
C              CALCUL SAUT DE DEPLACEMENT EQUIVALENT
               JOB='SAUT_EQ'
               CALL XMMSA2(NDIM  ,IPGF  ,ZI(IMATE),SAUT  ,ND   ,
     &                    TAU1 ,TAU2  ,COHES(ISSPG),JOB  ,RELA,
     &                    ALPHA,DSIDEP,SIGMA       ,PP   ,DNOR,
     &                    DTANG,P   ,AM3)
C
C              ACTUALISATION VARIABLE INTERNE
               IF (ALPHA.GT.ZR(JCOHES-1+60*(IFISS-1)+ISSPG)) THEN
                 ZR(JCOHEO-1+60*(IFISS-1)+ISSPG)=ALPHA
                 IF(ALPHA.LT.ALPHA0) ZR(JCOHEO-1+60*(IFISS-1)+ISSPG)=0
               ELSE IF (ALPHA.LE.ZR(JCOHES-1+60*(IFISS-1)+ISSPG)) THEN
                 ZR(JCOHEO-1+60*(IFISS-1)+ISSPG)=
     &                                   ZR(JCOHES-1+60*(IFISS-1)+ISSPG)
               ENDIF
             ENDIF

110       CONTINUE
100     CONTINUE
 90   CONTINUE

C     ENREGISTREMENT DES CHAMPS DE SORTIE
      ZI(JOUT1)=INCOCA

      CALL JEDEMA()
      END
