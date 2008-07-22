      SUBROUTINE XDNOR(MODELE,MOTCLE,NOMCMP,NBCMP,NDIM,DIRECT,PRNM,
     &                 NOMN,INO,VALIMR,FONREE,LISREL)
      IMPLICIT NONE

      INTEGER      INO,ICOMPT,NBCMP,PRNM(*),NDIM
      REAL*8       VALIMR,DIRECT(3)
      CHARACTER*4  FONREE
      CHARACTER*8  MODELE,MOTCLE,VALIMF,NOMCMP(*),NOMN
      CHARACTER*19 LISREL

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 21/07/2008   AUTEUR GENIAUT S.GENIAUT 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C      TRAITEMENT DE DNOR SUR UN NOEUD X-FEM

C          POMP� SUR XDDLIM, IL FAUDRA UNE SEULE ROUTINE POUR LA RESTIT 
C
C IN  MODELE : NOM DE L'OBJET MODELE ASSOCIE AU LIGREL DE CHARGE
C IN  MOTCLE : NOM DE LA COMPOSANTE DU DEPLACEMENT A IMPOSER
C IN  NOMN   : NOM DU NOEUD INO OU EST EFFECTUE LE BLOCAGE
C IN  INO    : NUMERO DU NOEUD OU EST EFFECTUE LE BLOCAGE
C IN  VALIMR : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'REEL')
C IN  VALIMC : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'COMP')
C IN  VALIMF : VALEUR DE BLOCAGE SUR CE DDL (FONREE = 'FONC')
C IN  PRNM   : DESCRIPTEUR GRANDEUR SUR LE NOEUD INO
C IN  FONREE : AFFE_CHAR_XXXX OU AFFE_CHAR_XXXX_F
C IN  NDIM

C IN/OUT     
C     ICOMPT : "COMPTEUR" DES DDLS AFFECTES REELLEMENT
C     LISREL : LISTE DE RELATIONS AFFECTEE PAR LA ROUTINE
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      INTEGER     NBXCMP
      PARAMETER  (NBXCMP=18)
      INTEGER     IER,STANO,JSTANO,JLSN,JLST,NREL,I,NTERM,IREL
      INTEGER     ICMP,INDIK8,J,DIMENS(NBXCMP)
      REAL*8      LSN,LST,R,THETA(2),R8PI,HE(2),T,COEF(NBXCMP),SIGN
      REAL*8      RBID
      CHARACTER*8  DDL(NBXCMP),NOEUD(NBXCMP),VALK(2),AXES(3)
      CHARACTER*19 CH1,CH2,CH3
      COMPLEX*16  CBID,VALIMC
      LOGICAL     EXISDG
      DATA        AXES /'X','Y','Z'/

C ----------------------------------------------------------------------
C
      CALL JEMARQ()

C     ON NE TRAITE QUE LE MOT CLE DEPL
      CALL ASSERT(MOTCLE.EQ.'DEPL')

C     ON NE TRAITE QUE LES NOEUDS X-FEM 
      ICMP = INDIK8(NOMCMP,'DCX',1,NBCMP)
      IF (.NOT.EXISDG(PRNM,ICMP)) GOTO 999

C     STATUT D'ENRICHISSMENT DU NOEUD
      CH1 = '&&XDNOR.CHS1'
      CALL CNOCNS(MODELE//'.STNO','V',CH1)
      CALL JEVEUO(CH1//'.CNSV','L',JSTANO)
      STANO=ZI(JSTANO-1+INO)

C     SI LE NOEUD N'EST PAS ENRICHI, ON SORT
      IF (STANO.EQ.0) THEN 
        CALL JEDETR('&&XDDLIM.CHS1')
        GOTO 999
      ENDIF

C     LEVEL SETS AU NOEUD
      CH2 = '&&XDNOR.CHS2'
      CH3 = '&&XDNOR.CHS3'
      CALL CNOCNS(MODELE//'.LNNO','V',CH2)
      CALL CNOCNS(MODELE//'.LTNO','V',CH3)
      CALL JEVEUO(CH2//'.CNSV','L',JLSN)
      CALL JEVEUO(CH3//'.CNSV','L',JLST)
      LSN = ZR(JLSN-1+INO)
      LST = ZR(JLST-1+INO)

C     IDENTIFICATIOND DES CAS A TRAITER :
C     SI NOEUD SUR LES LEVRES : 2 RELATIONS (UNE POUR CHAQUE LEVRE)
C     SINON                   : 1 RELATION
      IF (LSN.EQ.0.D0.AND.LST.LT.0.D0) THEN
        NREL = 2
        THETA(1) =  R8PI()
        THETA(2) = -R8PI()
        HE(1)    =  1.D0
        HE(2)    = -1.D0
      ELSE
        NREL = 1
        HE(1)    = SIGN(1.D0,LSN)
        THETA(1) = HE(1)*ABS(ATAN2(LSN,LST))
      ENDIF

      CALL ASSERT(FONREE.EQ.'REEL')

      DO 5 I=1,NBXCMP
        DIMENS(I)=0.D0
        NOEUD(I)=NOMN
 5    CONTINUE

C     BOUCLE SUR LES RELATIONS
      DO 10 IREL=1,NREL

C       CALCUL DES COORDONN�ES POLAIRES DU NOEUD (R,T)
        R = SQRT(LSN**2+LST**2)
        T = THETA(IREL)

        I = 0

        DO 20 J = 1, NDIM

C         COEFFICIENTS ET DDLS DE LA RELATION
          I = I+1
          DDL(I) = 'DC'//AXES(J)
          COEF(I)=DIRECT(J)

          IF (STANO.EQ.1.OR.STANO.EQ.3) THEN 
            I = I+1
            DDL(I) = 'H1'//AXES(J)
            COEF(I)=HE(IREL)*DIRECT(J)
          ENDIF

          IF (STANO.EQ.2.OR.STANO.EQ.3) THEN 
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
          
 20     CONTINUE

        NTERM = I

        CALL AFRELA(COEF,CBID,DDL,NOEUD,DIMENS,RBID,NTERM,VALIMR,VALIMC,
     &              VALIMF,'REEL',FONREE,'12',0.D0,LISREL)

 10   CONTINUE

      CALL JEDETR('&&XDNOR.CHS1')
      CALL JEDETR('&&XDNOR.CHS2')
      CALL JEDETR('&&XDNOR.CHS3')

 999  CONTINUE

      CALL JEDEMA()
      END
