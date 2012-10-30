      SUBROUTINE RLBFR8(NOMMAT,NEQ,XSOL,NBSM,TYPSYM)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 30/10/2012   AUTEUR BERRO H.BERRO 
C     TOLE CRP_4
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      INTEGER NEQ,NBSM,TYPSYM
C
      CHARACTER*(*) NOMMAT
      REAL*8 XSOL(NEQ,*)
C     ------------------------------------------------------------------
C     RESOLUTION DU SYSTEME A COEFFICIENTS REELS:  A * X = B
C     LA MATRICE EST SYMETRIQUE ET A ETE FACTORISEE SOUS FORME L*D*LT
C     LA RESOLUTION EST EN PLACE
C
C     ON PEUT RESOUDRE SUR UNE SOUS-MATRICE DE A :
C     ON PREND LES NEQ PREMIERES LIGNES ET COLONNES (NEQ PEUT ETRE
C     INFERIEUR A LA DIMENSION DE LA MATRICE).
C
C     ON PEUT RESOUDRE NBSM SYSTEMES D'UN COUP A CONDITION
C     QUE LES VECETURS SOIENT CONSECUTIFS EN MEMOIRE :
C     XSOL EST UN VECTEUR DE NBSM*NEQ REELS
C     ------------------------------------------------------------------
C
C IN  NOMMAT  :    : NOM UTILISATEUR DE LA MATRICE A FACTORISER
C IN  NEQ     : IS : NOMBRE D'EQUATIONS PRISES EN COMPTE
C                    C'EST AUSSI LA DIMENSION DES VECTEURS XSOL.
C VAR XSOL    : R8 : EN ENTREE LES SECONDS MEMBRES
C                    EN ENTREE LES SOLUTIONS
C IN  NBSM   : IS : NOMBRE DE SOLUTIONS / SECONDS MEMBRES
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C     ------------------------------------------------------------------
      CHARACTER*24 FACTOL,FACTOU
      CHARACTER*24 NOMP01,NOMP02,NOMP03,NOMP04,NOMP05,
     %NOMP06,NOMP07,NOMP08,NOMP09,NOMP10,NOMP11,NOMP12,NOMP13,NOMP14,
     %NOMP15,NOMP16,NOMP17,NOMP18,NOMP19,NOMP20
C     -------------------------------------------------- POINTEURS
      INTEGER POINTR,DESC
      INTEGER NOUV,ANC,SUPND
      INTEGER SEQ,ADRESS,LGSN
      INTEGER DECAL,GLOBAL
      INTEGER NCBLOC,LGBLOC,NBLOC,NBSN,AD,TRAV,SOM
      INTEGER IBID,IERD,I
      CHARACTER*14 NU
      INTEGER IFM,NIV
C
C     ------------------------------------------------------------------
      DATA FACTOL/'                   .VALF'/
      DATA FACTOU/'                   .WALF'/
C     ------------------------------------------------------------------
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
      CALL DISMOI('F','NOM_NUME_DDL',NOMMAT,'MATR_ASSE',IBID,NU,IERD)
      FACTOL(1:19) = NOMMAT
      FACTOU(1:19) = NOMMAT
      CALL MLNMIN(NU,NOMP01,NOMP02,NOMP03,NOMP04,NOMP05,
     %NOMP06,NOMP07,NOMP08,NOMP09,NOMP10,NOMP11,NOMP12,NOMP13,NOMP14,
     %NOMP15,NOMP16,NOMP17,NOMP18,NOMP19,NOMP20)
C                                ALLOCATION DES POINTEURS ENTIERS
      CALL JEVEUO(NOMP01,'L',DESC)
      CALL JEVEUO(NOMP03 ,'L',ADRESS)
      CALL JEVEUO(NOMP04 ,'L',SUPND)
      CALL JEVEUO(NOMP20 ,'L',SEQ)
      CALL JEVEUO(NOMP16 ,'L',LGBLOC)
      CALL JEVEUO(NOMP17 ,'L',NCBLOC)
      CALL JEVEUO(NOMP18 ,'L',DECAL)
      CALL JEVEUO(NOMP08 ,'L',LGSN)
      CALL JEVEUO(NOMP14,'L',ANC)
      CALL JEVEUO(NOMP19,'L',NOUV)
      CALL JEVEUO(NU//'.MLTF.GLOB','L',GLOBAL)
      NBSN = ZI(DESC+1)
      NBLOC= ZI(DESC+2)
C
C                                ALLOCATION TABLEAU REEL PROVISOIRE
      CALL WKVECT('&&RLBFR8.POINTER.REELS  ','V V R',NEQ,POINTR)
      CALL WKVECT('&&RLBFR8.POINTER.ADRESSE','V V I',NEQ,AD)
      CALL WKVECT('&&RLBFR8.POINTER.TRAVAIL','V V R',NEQ*NBSM,TRAV)
      CALL WKVECT('&&RLBFR8.POINTER.SOMMES ','V V R',NBSM,SOM)
C
      CALL MLTDRB(NBLOC,ZI(NCBLOC),ZI(DECAL),ZI(SEQ),
     +              NBSN,NEQ,ZI(SUPND),ZI(ADRESS),ZI4(GLOBAL),ZI(LGSN),
     +                FACTOL,FACTOU,XSOL,ZR(POINTR),
     +                ZI(NOUV),ZI(ANC),ZI(AD),ZR(TRAV),TYPSYM,NBSM,
     +                ZR(SOM))
C
      CALL JEDETR('&&RLBFR8.POINTER.REELS  ')
      CALL JEDETR('&&RLBFR8.POINTER.ADRESSE')
      CALL JEDETR('&&RLBFR8.POINTER.TRAVAIL')
      CALL JEDETR('&&RLBFR8.POINTER.SOMMES ')
      CALL JEDEMA()
      END
