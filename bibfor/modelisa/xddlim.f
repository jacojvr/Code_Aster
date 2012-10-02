      SUBROUTINE XDDLIM(MODELE, MOTCLE, NOMN  ,
     &                  INO   , VALIMR, VALIMC, VALIMF,
     &                  FONREE, ICOMPT, LISREL, NDIM  , DIRECT,
     &                  JNOXFV, CH1   , CH2   , CH3   , CNXINV )
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER      INO,ICOMPT,NDIM,JNOXFV
      REAL*8       VALIMR,DIRECT(3)
      CHARACTER*4  FONREE
      CHARACTER*8  MODELE,NOMN,VALIMF,MOTCLE
      CHARACTER*19 LISREL,CNXINV
C ---------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 02/10/2012   AUTEUR COURTOIS M.COURTOIS 
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
C RESPONSABLE GENIAUT S.GENIAUT
C
C      TRAITEMENT DE DDL_IMPO SUR UN NOEUD X-FEM
C             (POUR MOTCLE = DX, DY ,DZ)
C      TRAITEMENT DE FACE_IMPO SUR UN NOEUD X-FEM
C             (POUR DNOR OU DTAN : MOTCLE = DEPL )
C
C IN  MODELE : NOM DE L'OBJET MODELE ASSOCIE AU LIGREL DE CHARGE
C IN  MOTCLE : NOM DE LA COMPOSANTE DU DEPLACEMENT A IMPOSER
C IN  NOMN   : NOM DU NOEUD INO OU EST EFFECTUE LE BLOCAGE
C IN  INO    : NUMERO DU NOEUD OU EST EFFECTUE LE BLOCAGE
C IN  VALIMR : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'REEL')
C IN  VALIMC : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'COMP')
C IN  VALIMF : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'FONC')
C IN  FONREE : AFFE_CHAR_XXXX OU AFFE_CHAR_XXXX_F
C IN  NDIM

C IN/OUT
C     ICOMPT : "COMPTEUR" DES DDLS AFFECTES REELLEMENT
C     LISREL : LISTE DE RELATIONS AFFECTEE PAR LA ROUTINE
C
C
C
C
      INTEGER     NBXCMP
      PARAMETER  (NBXCMP=18)
      INTEGER     IER,STANO(4),JSTNOL,JSTNOV,JSTNOD,NREL
      INTEGER     JLSNV,JLSNL,JLSND,JLSTV,JLSTL,JLSTD
      INTEGER     JFISNV,JFISNL,JFISND,NFH,IFH
      INTEGER     I,J,NTERM,IREL,DIMENS(NBXCMP),IFISS,NFISS
      INTEGER     IALINO,NBNO,NBMANO,ADRMA,IMA,NUMA,NBNOMA,NUNO,NUNO2
      INTEGER     JCONX1,JCONX2,IDNOMA,IBID,IAD,FISNO(4)
      REAL*8      R,THETA(2),R8PI,HE(2,4),T,COEF(NBXCMP),SIGN
      REAL*8      LSN(4),LST(4),MINLSN,MAXLSN,RBID,R8MAEM,LSN2
      CHARACTER*8 DDL(NBXCMP),NOEUD(NBXCMP),AXES(3),K8BID,NOMA
      CHARACTER*19 CH1,CH2,CH3,CH4
      COMPLEX*16  CBID,VALIMC
      CHARACTER*1   CH
      DATA        AXES /'X','Y','Z'/

C ----------------------------------------------------------------------
C
      CALL JEMARQ()

C --- RECUP DU NUMERO LOCAL NUMO DU NOEUD INO DANS LA MAILLE X-FEM NUMA
      NUMA = ZI(JNOXFV-1+2*(INO-1)+1)
      NUNO = ZI(JNOXFV-1+2*(INO-1)+2)
C
C       REMARQUE : FAIRE DES CALL JEVEUO AU COEUR DE LA BOUCLE SUR
C      LES NOEUDS ET SUR LES DDLS BLOQUES N'EST PAS OPTIMAL DU POINT
C      DE VUE DES PERFORMANCES, MAIS A PRIORI, CA NE DEVRAIT PAS ETRE
C      POUR BEAUCOUP DE NOEUDS
      CALL JEVEUO(CH1//'.CESV','L',JSTNOV)
      CALL JEVEUO(CH1//'.CESL','L',JSTNOL)
      CALL JEVEUO(CH1//'.CESD','L',JSTNOD)
      CALL JEVEUO(CH2//'.CESV','L',JLSNV)
      CALL JEVEUO(CH2//'.CESL','L',JLSNL)
      CALL JEVEUO(CH2//'.CESD','L',JLSND)
      CALL JEVEUO(CH3//'.CESV','L',JLSTV)
      CALL JEVEUO(CH3//'.CESL','L',JLSTL)
      CALL JEVEUO(CH3//'.CESD','L',JLSTD)
C
C --- NOMBRE DE FISSURES VUES PAR LA MAILLE
      NFISS = ZI(JSTNOD-1+5+4*(NUMA-1)+2)
C
      IF (NFISS.GT.1) THEN
        CH4 = '&&XDDLIM.CHS4'
        CALL CELCES(MODELE//'.FISSNO','V',CH4)
        CALL JEVEUO(CH4//'.CESV','L',JFISNV)
        CALL JEVEUO(CH4//'.CESL','L',JFISNL)
        CALL JEVEUO(CH4//'.CESD','L',JFISND)
C --- NOMBRE DE DDLS HEAVISIDES DANS LA MAILLE
        NFH = ZI(JFISND-1+5+4*(NUMA-1)+2)
        DO 40 I = 1,NFH
          CALL CESEXI('S',JFISND,JFISNL,NUMA,NUNO,I,1,IAD)
          FISNO(I) = ZI(JFISNV-1+IAD)
 40     CONTINUE
      ENDIF
      DO 70 IFISS=1,NFISS
        CALL CESEXI('S',JSTNOD,JSTNOL,NUMA,NUNO,IFISS,1,IAD)
        STANO(IFISS)=ZI(JSTNOV-1+IAD)
        CALL CESEXI('S',JLSND,JLSNL,NUMA,NUNO,IFISS,1,IAD)
        LSN(IFISS) = ZR(JLSNV-1+IAD)
        CALL CESEXI('S',JLSTD,JLSTL,NUMA,NUNO,IFISS,1,IAD)
        LST(IFISS) = ZR(JLSTV-1+IAD)
 70   CONTINUE


C --- IDENTIFICATIOND DES CAS A TRAITER :
C --- SI NOEUD SUR LES LEVRES ET CONNECT� � DES NOEUDS (APPARTENANT AU
C --- GROUPE AFFECT�) DE PART ET D'AUTRE DE LA LEVRE : 2 RELATIONS
C --- SINON IL FAUT IMPOSER QUE D'UN SEUL COT�        : 1 RELATION
      IF (NFISS.EQ.1) THEN
        IF (LSN(1).EQ.0.D0.AND.LST(1).LT.0.D0) THEN
          MINLSN = R8MAEM()
          MAXLSN = -1*R8MAEM()
C ---     RECUPERATION DE LA LISTE DES NOEUDS AFFECT�S PAR LA CONDITION
          CALL JEEXIN('&&CADDLI.NUNOTMP',IER)
          IF (IER.NE.0) THEN
            CALL JEVEUO('&&CADDLI.NUNOTMP','L',IALINO)
            CALL JELIRA('&&CADDLI.NUNOTMP','LONMAX',NBNO,K8BID)
          ELSE
C ---       ON ZAPPE SI ON N'EST PAS EN MODE DDL_IMPO
            NBNO=0
          ENDIF
C ---     RECUPERATION DU NOM DU MAILLAGE :
          CALL JEVEUO(MODELE//'.MODELE    .LGRF','L',IDNOMA)
          NOMA = ZK8(IDNOMA)
C ---     RECUPERATION DES MAILLES CONTENANT LE NOEUD
          CALL JEVEUO(NOMA//'.CONNEX','L',JCONX1)
          CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',JCONX2)
          CALL JELIRA(JEXNUM(CNXINV,INO),'LONMAX',NBMANO,K8BID)
          CALL JEVEUO(JEXNUM(CNXINV,INO),'L',ADRMA)
C ---     BOUCLE SUR LES MAILLES CONTENANT LE NOEUD
          DO 100 IMA=1,NBMANO
            NUMA = ZI(ADRMA-1 + IMA)
            NBNOMA = ZI(JCONX2+NUMA) - ZI(JCONX2+NUMA-1)
C ---       BOUCLE SUR LES NOEUDS DE LA MAILLE
C ---       ATTENTION ON NE PREND EN COMPTE QUE LES MAILLES LINEAIRES !
            DO 110 I=1,NBNOMA
              NUNO  = ZI(JCONX1-1+ZI(JCONX2+NUMA-1)+I-1)
C ---         ON REGARDE SI LE NOEUD APPARTIENT AU GRP DE NOEUD AFFECT�
              DO 120 J=1,NBNO
                NUNO2 = ZI(IALINO-1+J)
                IF (NUNO2.EQ.NUNO) THEN
                  CALL CESEXI('C',JLSND,JLSNL,NUMA,I,1,1,IAD)
                  IF (IAD.LE.0) GOTO 110
                  LSN2 = ZR(JLSNV-1+IAD)
C                  LSN2 = ZR(JLSN-1+NUNO)
                  IF (LSN2.LT.MINLSN) MINLSN=LSN2
                  IF (LSN2.GT.MAXLSN) MAXLSN=LSN2
                  GOTO 110
                ENDIF
 120          CONTINUE
 110        CONTINUE
 100      CONTINUE

          IF ((MINLSN.EQ.0.D0).AND.(MAXLSN.GT.0.D0)) THEN
C ---       ON AFFECTE LA RELATION UNIQUEMENT SUR LA PARTIE MAITRE
            NREL = 1
            THETA(1) =  R8PI()
            HE(1,1)    =  1.D0
          ELSEIF ((MINLSN.LT.0.D0).AND.(MAXLSN.EQ.0.D0)) THEN
C ---       ON AFFECTE LA RELATION UNIQUEMENT SUR LA PARTIE ESCLAVE
            NREL = 1
            THETA(1) =  R8PI()
            HE(1,1)    =  -1.D0
          ELSEIF (((MINLSN.LT.0.D0).AND.(MAXLSN.GT.0.D0))
     &              .OR.(NBNO.EQ.0)) THEN
C ---       ON AFFECTE LA RELATION SUR LES DEUX PARTIES
            NREL = 2
            THETA(1) =  R8PI()
            THETA(2) = -R8PI()
            HE(1,1)    =  1.D0
            HE(2,1)    = -1.D0
          ELSE
C ---       SI NOEUD ISOLE, ON AFFECTE RIEN POUR L'INSTANT
            GOTO 888
          ENDIF
        ELSE
          NREL = 1
          HE(1,1)    = SIGN(1.D0,LSN(1))
          THETA(1) = HE(1,1)*ABS(ATAN2(LSN(1),LST(1)))
        ENDIF
      ELSE
        NREL = 1
        DO 50 IFH = 1,NFH
C --- ON NE PREND PAS ENCORE EN COMPTE LE CAS OU ON PASSE PAR UN NOEUD
          IF (LSN(FISNO(IFH)).EQ.0) GOTO 888
          HE(1,IFH) = SIGN(1.D0,LSN(FISNO(IFH)))
 50     CONTINUE
      ENDIF
      DO 5 I=1,NBXCMP
        DIMENS(I)= 0
        NOEUD(I) = NOMN
 5    CONTINUE

C     BOUCLE SUR LES RELATIONS
      DO 10 IREL=1,NREL

C       CALCUL DES COORDONN�ES POLAIRES DU NOEUD (R,T)
        R = SQRT(LSN(1)**2+LST(1)**2)
        T = THETA(IREL)

C       CAS FACE_IMPO DNOR OU DTAN
        IF (MOTCLE(1:8).EQ.'DEPL    ') THEN

          I = 0
          DO 20 J = 1, NDIM

C           COEFFICIENTS ET DDLS DE LA RELATION
            I = I+1
            DDL(I) = 'D'//AXES(J)
            COEF(I)=DIRECT(J)

            IF (NFISS.EQ.1) THEN
              IF (STANO(1).EQ.1.OR.STANO(1).EQ.3) THEN
                I = I+1
                DDL(I) = 'H1'//AXES(J)
                COEF(I)=HE(IREL,1)*DIRECT(J)
              ENDIF

              IF (STANO(1).EQ.2.OR.STANO(1).EQ.3) THEN
                I = I+1
                DDL(I) = 'E1'//AXES(J)
                COEF(I)=SQRT(R)*SIN(T/2.D0)*DIRECT(J)
                I = I+1
                DDL(I) = 'E2'//AXES(J)
                COEF(I)=SQRT(R)*COS(T/2.D0)*DIRECT(J)
                I = I+1
                DDL(I) = 'E3'//AXES(J)
                COEF(I)=SQRT(R)*SIN(T/2.D0)*SIN(T)*DIRECT(J)
                I = I+1
                DDL(I) = 'E4'//AXES(J)
                COEF(I)=SQRT(R)*COS(T/2.D0)*SIN(T)*DIRECT(J)
              ENDIF
            ELSE
              DO 80 IFH = 1,NFH
                IF (STANO(FISNO(IFH)).EQ.1) THEN
                  I = I+1
                  CALL CODENT(IFH,'G',CH)
                  DDL(I) = 'H'//CH//AXES(J)
                  COEF(I)=HE(IREL,IFH)*DIRECT(J)
                ENDIF
 80           CONTINUE
            ENDIF
 20       CONTINUE

C       CAS DDL_IMPO DX DY DZ
        ELSEIF (MOTCLE.EQ.'DX'.OR.MOTCLE.EQ.'DY'.OR.MOTCLE.EQ.'DZ') THEN

C         COEFFICIENTS ET DDLS DE LA RELATION
          DDL(1) = 'D'//MOTCLE(2:2)
          COEF(1)=1.D0
          I = 1
          IF (NFISS.EQ.1) THEN
            IF (STANO(1).EQ.1.OR.STANO(1).EQ.3) THEN
              I = I+1
              DDL(I) = 'H1'//MOTCLE(2:2)
              COEF(I)=HE(IREL,1)
            ENDIF
            IF (STANO(1).EQ.2.OR.STANO(1).EQ.3) THEN
              I = I+1
              DDL(I) = 'E1'//MOTCLE(2:2)
              COEF(I)=SQRT(R)*SIN(T/2.D0)
              I = I+1
              DDL(I) = 'E2'//MOTCLE(2:2)
              COEF(I)=SQRT(R)*COS(T/2.D0)
              I = I+1
              DDL(I) = 'E3'//MOTCLE(2:2)
              COEF(I)=SQRT(R)*SIN(T/2.D0)*SIN(T)
              I = I+1
              DDL(I) = 'E4'//MOTCLE(2:2)
              COEF(I)=SQRT(R)*COS(T/2.D0)*SIN(T)
            ENDIF
          ELSE
            DO 60 IFH = 1,NFH
              IF (STANO(FISNO(IFH)).EQ.1) THEN
                I = I+1
                CALL CODENT(IFH,'G',CH)
                DDL(I) = 'H'//CH//MOTCLE(2:2)
                COEF(I)=HE(IREL,IFH)
              ENDIF
 60         CONTINUE
          ENDIF
        ENDIF
        NTERM = I
        CALL AFRELA(COEF,CBID,DDL,NOEUD,DIMENS,RBID,NTERM,VALIMR,VALIMC,
     &              VALIMF,'REEL',FONREE,'12',0.D0,LISREL)

 10   CONTINUE

      ICOMPT = ICOMPT + 1

888   CONTINUE

      IF (NFISS.GT.1) CALL DETRSD('CHAM_ELEM_S',CH4)

      CALL JEDEMA()
      END
