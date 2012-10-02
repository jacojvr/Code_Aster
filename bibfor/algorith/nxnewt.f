      SUBROUTINE NXNEWT (MODELE,MATE,CARELE,CHARGE,INFCHA,
     &                   INFOCH,NUMEDD,SOLVEU,
     &                   TIME,LONCH,MATASS,MAPREC,
     &                   CNCHCI,VTEMP,VTEMPM,VTEMPP,VEC2ND,
     &                   MEDIRI,CONVER,VHYDR,VHYDRP,TMPCHI,TMPCHF,
     &                   COMPOR,CNVABT,CNRESI,PARCRI,PARCRR,REASMA,
     &                   TESTR,TESTM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 02/10/2012   AUTEUR DESOZA T.DESOZA 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE                            DURAND C.DURAND
C TOLE CRP_21
C
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER      LONCH
      LOGICAL      CONVER,REASMA
      CHARACTER*19 INFCHA,SOLVEU,MAPREC
      CHARACTER*24 MODELE,MATE,CARELE,CHARGE,INFOCH,NUMEDD,TIME
      CHARACTER*24 MATASS,CNCHCI,CNRESI,VTEMP,VTEMPM,VTEMPP,VEC2ND
      CHARACTER*24 VHYDR,VHYDRP,COMPOR,TMPCHI,TMPCHF
      INTEGER      PARCRI(3)
      REAL*8       PARCRR(2)
C
C ----------------------------------------------------------------------
C
C COMMANDE THER_NON_LINE : ITERATION DE NEWTON
C
C ----------------------------------------------------------------------
C
C     VAR VTEMPM : ITERE PRECEDENT DU CHAMP DE TEMPERATURE
C     OUT VTEMPP : ITERE COURANT   DU CHAMP DE TEMPERATURE
C     OUT VHYDRP : ITERE COURANT   DU CHAMP D HYDRATATION
C
C
      COMPLEX*16         CBID
C
C
      INTEGER      K,JVARE,J2ND,JTEMPP,IBID
      INTEGER      JBTLA,JMED,JMER,NBMAT,IERR
      REAL*8       R8BID
      CHARACTER*1  TYPRES
      CHARACTER*19 CHSOL
      CHARACTER*24 BIDON,VERESI,VARESI,VABTLA,VEBTLA,CRITER
      CHARACTER*24 TLIMAT(2),MEDIRI,MERIGI,CNVABT
      REAL*8       TESTR,TESTM,VNORM,RBID
      INTEGER      IRET
C
      DATA TYPRES        /'R'/
      DATA CHSOL         /'&&NXNEWT.SOLUTION'/
      DATA BIDON         /'&&FOMULT.BIDON'/
      DATA VERESI        /'&&VERESI           .RELR'/
      DATA VEBTLA        /'&&VETBTL           .RELR'/
      DATA MERIGI        /'&&METRIG           .RELR'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      VARESI = '&&VARESI'
      VABTLA = '&&VATBTL'
      CNRESI = ' '
      CNVABT = ' '
      CRITER = '&&RESGRA_GCPC'
C
C --- RECUPERATION D'ADRESSES
C
      CALL JEVEUO (VEC2ND(1:19)//'.VALE','L',J2ND)
C
C --- VECTEURS RESIDUS ELEMENTAIRES - CALCUL ET ASSEMBLAGE
C
      CALL VERSTP (MODELE,CHARGE,INFOCH,CARELE,MATE,TIME,COMPOR,
     &             VTEMP,VTEMPM,VHYDR,VHYDRP,TMPCHI,TMPCHF,VERESI)
      CALL ASASVE (VERESI,NUMEDD,TYPRES,VARESI)
      CALL ASCOVA('D',VARESI,BIDON,'INST',R8BID,TYPRES,CNRESI)
      CALL JEVEUO (CNRESI(1:19)//'.VALE','L',JVARE)
C
C --- BT LAMBDA - CALCUL ET ASSEMBLAGE
C
      CALL VETHBT (MODELE,CHARGE,INFOCH,CARELE,MATE,VTEMPM,VEBTLA)
      CALL ASASVE (VEBTLA,NUMEDD,TYPRES,VABTLA)
      CALL ASCOVA('D',VABTLA,BIDON,'INST',R8BID,TYPRES,CNVABT)
      CALL JEVEUO (CNVABT(1:19)//'.VALE','L',JBTLA)
C
C==========================================================
C --- CALCUL DU RESIDU ET
C     DU CRITERE DE CONVERGENCE DES ITERATIONS (NORME SUP)
C==========================================================
C
      CALL JEVEUO (VTEMPP(1:19)//'.VALE','E',JTEMPP )
      TESTR = 0.D0
      TESTM = 0.D0
      VNORM = 0.D0
      DO 100 K = 1,LONCH
        ZR(JTEMPP+K-1) = ZR(J2ND+K-1) - ZR(JVARE+K-1)
     &                 - ZR(JBTLA+K-1)
        TESTR = TESTR + ( ZR(JTEMPP+K-1) )**2
        VNORM = VNORM + ( ZR(J2ND+K-1) - ZR(JBTLA+K-1) )**2
        TESTM = MAX( TESTM,ABS( ZR(JTEMPP+K-1) ) )
 100  CONTINUE
      IF (VNORM.GT.0D0) THEN
          TESTR = SQRT( TESTR / VNORM )
      ENDIF
C
      IF(PARCRI(1).NE.0) THEN
         IF (TESTM.LT.PARCRR(1)) THEN
             CONVER=.TRUE.
             CALL COPISD('CHAMP_GD','V',VTEMPM(1:19),VTEMPP(1:19))
             GOTO 999
         ELSE
             CONVER=.FALSE.
         ENDIF
      ELSE
         IF (TESTR.LT.PARCRR(2)) THEN
             CONVER=.TRUE.
             CALL COPISD('CHAMP_GD','V',VTEMPM(1:19),VTEMPP(1:19))
             GOTO 999
         ELSE
             CONVER=.FALSE.
         ENDIF
      ENDIF
C
      IF (REASMA) THEN
C
C==========================================================
C --- (RE)CALCUL DE LA MATRICE TANGENTE
C==========================================================
C
        CALL MERXTH (MODELE,CHARGE,INFOCH,CARELE,MATE,TIME,
     &               VTEMPM,MERIGI,COMPOR,TMPCHI,TMPCHF)
        CALL JEVEUO (MERIGI,'L',JMER)
        CALL JEVEUO (MEDIRI,'L',JMED)
C
        NBMAT = 0
        IF (ZK24(JMER)(1:8).NE.'        ') THEN
          NBMAT = NBMAT + 1
          TLIMAT(NBMAT) =MERIGI(1:19)
        END IF
        IF (ZK24(JMED)(1:8).NE.'        ') THEN
          NBMAT = NBMAT + 1
          TLIMAT(NBMAT) =MEDIRI(1:19)
        END IF
C
C --- ASSEMBLAGE DE LA MATRICE
C
        CALL ASMATR (NBMAT,TLIMAT,' ',NUMEDD,SOLVEU,
     &               INFCHA,'ZERO','V',1,MATASS)
C
C --- DECOMPOSITION OU CALCUL DE LA MATRICE DE PRECONDITIONNEMENT
C
        CALL PRERES(SOLVEU,'V',IERR,MAPREC,MATASS,IBID,-9999)
C
      END IF
C
C==========================================================
C --- RESOLUTION (VTEMPP CONTIENT LE SECOND MEMBRE, CHSOL LA SOLUTION)
C
      CALL RESOUD(MATASS,MAPREC,SOLVEU,CNCHCI,0     ,
     &            VTEMPP,CHSOL ,'V'   ,RBID  ,CBID  ,
     &            CRITER,.TRUE.,0     ,IRET  )
C
C --- RECOPIE DANS VTEMPP DU CHAMP SOLUTION CHSOL,
C     INCREMENT DE TEMPERATURE
C
      CALL COPISD('CHAMP_GD','V',CHSOL,VTEMPP(1:19))
C
999   CONTINUE
      CALL JEDEMA()
      END
