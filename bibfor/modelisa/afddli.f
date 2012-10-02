      SUBROUTINE AFDDLI(VALR,VALK,VALC,PRNM,NDDLA,FONREE,NOMN,INO,
     &                  DDLIMP,VALIMR,VALIMF,VALIMC,MOTCLE,DIRECT,
     &                  DIMENS,MOD,LISREL,NOMCMP,NBCMP,ICOMPT,LXFEM,
     &                  JNOXFL,JNOXFV,CH1,CH2,CH3,CNXINV)
      IMPLICIT NONE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 02/10/2012   AUTEUR COURTOIS M.COURTOIS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C TOLE CRP_21
      INCLUDE 'jeveux.h'
      INTEGER      PRNM(*),NDDLA,INO,DDLIMP(NDDLA),DIMENS
      INTEGER      NBCMP,ICOMPT(NDDLA)
      REAL*8       VALR(*),VALIMR(NDDLA),DIRECT(3)
      LOGICAL      EXISDG
      COMPLEX*16   VALC(*),VALIMC(NDDLA)
      CHARACTER*4  FONREE
      CHARACTER*8  VALK(*),NOMN,VALIMF(NDDLA),NOMCMP(*),MOD
      CHARACTER*16 MOTCLE(NDDLA)
      CHARACTER*19 CNXINV,LISREL
      LOGICAL      LXFEM
      INTEGER      JNOXFL,JNOXFV
      CHARACTER*19 CH1,CH2,CH3

C  BUT : * EFFECTUER LE BLOCAGE DES DDLS DONNES PAR MOTCLE(*)
C          SUR LE NOEUD NOMN DANS LA LISTE DE RELATIONS LISREL.

C          DANS LE CAS DE RELATIONS REDONDANTES LA REGLE DE LA SURCHAGE
C          EST APPLIQUEE ET C'EST LE DERNIER BLOCAGE SUR LE NOEUD
C          QUI EST APPLIQUE .

C ARGUMENTS D'ENTREE:

C   PRNM   : DESCRIPTEUR GRANDEUR SUR LE NOEUD INO
C   NDDLA  : NOMBRE DE DDLS DANS DDL_IMPO/FACE_IMPO
C   FONREE : AFFE_CHAR_XXXX OU AFFE_CHAR_XXXX_F
C   NOMN   : NOM DU NOEUD INO OU EST EFFECTUE LE BLOCAGE
C   INO    : NUMERO DU NOEUD OU EST EFFECTUE LE BLOCAGE
C   DDLIMP : INDICATEUR DE PRESENCE OU ABSENCE DE BLOCAGE SUR CHAQUE DDL
C   VALIMR : VALEURS DE BLOCAGE SUR CHAQUE DDL (FONREE = 'REEL')
C   VALIMF : VALEURS DE BLOCAGE SUR CHAQUE DDL (FONREE = 'FONC')
C   VALIMC : VALEURS DE BLOCAGE SUR CHAQUE DDL (FONREE = 'COMP')
C   MOTCLE : TABLEAU DES NOMS DES DDLS DANS DDL_IMPO/FACE_IMPO
C   DIRECT : DIRECTION DE LA COMPOSANTE QUE L'ON VEUT CONTRAINDRE
C            N'EST UTILISEE QUE SI DIMENS DIFFERENT DE 0
C   DIMENS :  SI = 0 ON IMPOSE UN DDL SELON UNE DIRECTION DU REPERE
C             GLOBAL
C             SI =2 OU 3 C'EST LA DIMENSION DE LA GEOMETRIE DU
C             PROBLEME ET LA DIRECTION DE LA COMPOSANTE A CONTRAINDRE
C             EST DONNEE PAR DIRECT(3)
C  MOD     :  NOM DE L'OBJET MODELE ASSOCIE AU LIGREL DE CHARGE

C ARGUMENTS D'ENTREE MODIFIES:

C      VALR  : VALEURS DE BLOCAGE DES DDLS (FONREE = 'REEL')
C      VALK  : VALEURS DE BLOCAGE DES DDLS (FONREE = 'FONC')
C      VALC  : VALEURS DE BLOCAGE DES DDLS (FONREE = 'COMP')
C     LISREL : LISTE DE RELATIONS AFFECTEE PAR LA ROUTINE
C     ICOMPT(*) : "COMPTEUR" DES DDLS AFFECTES REELLEMENT



      INTEGER      J,IBID,ICMP,IITYP,INDIK8
      CHARACTER*16 OPER
      CHARACTER*8  K8B
      CHARACTER*4  FONRE1,FONRE2,TYPCOE
      CHARACTER*2  TYPLAG
      REAL*8       COEF,RBID(3)
      COMPLEX*16   CUN

C-----------------------------------------------------------------------

      CALL JEMARQ()
      CALL GETRES(K8B,K8B,OPER)
      IITYP = 0
      IF (OPER.EQ.'AFFE_CHAR_MECA_C') IITYP = 1
      TYPLAG = '12'
      TYPCOE = 'REEL'
      IF (FONREE.EQ.'COMP')  TYPCOE = 'COMP'
      IF (IITYP.EQ.1)  TYPCOE = 'COMP'
C
C --- AFFECTATION DU BLOCAGE A LA LISTE DE RELATIONS LISREL :
C     -----------------------------------------------------
      DO 30 J = 1,NDDLA

C       -- SI LA CMP N'EXISTE PAS SUR LE NOEUD, ON SAUTE :
        ICMP = INDIK8(NOMCMP,MOTCLE(J)(1:8),1,NBCMP)
        CALL ASSERT(ICMP.GT.0)
        IF (.NOT.EXISDG(PRNM,ICMP)) GOTO 30

        IF (LXFEM) THEN
          IF (ZL(JNOXFL-1+2*INO).AND.MOTCLE(J)(1:1).EQ.'D') THEN
            CALL XDDLIM(MOD,MOTCLE(J)(1:8),NOMN,INO,
     &                   VALIMR(J),VALIMC(J),VALIMF(J),FONREE,
     &                   ICOMPT(J),LISREL,IBID,RBID,JNOXFV,
     &                   CH1, CH2, CH3, CNXINV)
            GOTO 30
          ENDIF
        ENDIF

C       -- SI LA CMP N'EXISTE PAS SUR LE NOEUD, ON SAUTE :
        ICMP = INDIK8(NOMCMP,MOTCLE(J)(1:8),1,NBCMP)
        CALL ASSERT(ICMP.GT.0)
        IF (.NOT.EXISDG(PRNM,ICMP)) GOTO 30

        ICOMPT(J) = ICOMPT(J) + 1

        IF (DDLIMP(J).NE.0) THEN

C ---   CAS D'UN BLOCAGE D'UNE GRANDEUR COMPLEXE :
C       ----------------------------------------
          IF (IITYP.EQ.1) THEN
            FONRE1 = 'REEL'
            FONRE2 = 'COMP'
            COEF = 1.0D0
            CUN = DCMPLX(1.0D0,0.0D0)
            CALL AFRELA(COEF,CUN,MOTCLE(J) (1:8),NOMN,DIMENS,DIRECT,1,
     &                  VALIMR(J),VALIMC(J),VALIMF(J),FONRE1,FONRE2,
     &                  TYPLAG,0.D0,LISREL)

C ---   CAS D'UN BLOCAGE D'UNE GRANDEUR REELLE :
C       --------------------------------------
          ELSE
            COEF = 1.0D0
            CUN = DCMPLX(1.0D0,0.0D0)
            CALL AFRELA(COEF,CUN,MOTCLE(J) (1:8),NOMN,DIMENS,DIRECT,1,
     &                  VALIMR(J),VALIMC(J),VALIMF(J),TYPCOE,FONREE,
     &                  TYPLAG,0.D0,LISREL)
          END IF

          IF (FONREE.EQ.'REEL') THEN
            VALR(NDDLA* (INO-1)+J) = VALIMR(J)
          ELSE IF (FONREE.EQ.'COMP') THEN
            VALC(NDDLA* (INO-1)+J) = VALIMC(J)
          ELSE
            VALK(NDDLA* (INO-1)+J) = VALIMF(J)
          END IF
        END IF
   30 CONTINUE

      CALL JEDEMA()
      END
