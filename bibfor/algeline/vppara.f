      SUBROUTINE VPPARA(MODES, TYPCON, KNEGA, LRAIDE, LMASSE, LAMOR,
     &                  MXRESF, NEQ, NFREQ, OMECOR, DLAGR,
     &                  DBLOQ, VECTR, VECTC, 
     +                  NBPARI, NBPARR, NBPARK, NOPARA,
     +                  RESUI, RESUR, RESUK ,KTYP)
      IMPLICIT NONE
      CHARACTER*8   MODES, KNEGA
      CHARACTER*1   KTYP
      CHARACTER*16  TYPCON
      CHARACTER*(*) RESUK(*), NOPARA(*)
      INTEGER       LRAIDE, LMASSE, LAMOR, MXRESF, NEQ, NFREQ,
     &              DLAGR(*), DBLOQ(*), RESUI(*)
      INTEGER       NBPARI, NBPARR, NBPARK
      REAL *8       VECTR(*), RESUR(*), OMECOR
      COMPLEX *16   VECTC(*)
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 24/02/2003   AUTEUR NICOLAS O.NICOLAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C TOLE CRP_21
C
C     CALCUL DES PARAMETRES MODAUX, DES NORMES D'ERREUR ET STOCKAGE DES
C     INFORMATIONS
C     ------------------------------------------------------------------
C IN  MODES    : K8  : NOM UTILISATEUR DU CONCEPT MODAL PRODUIT
C IN  KTYP     : K1  : TYPE DE LA MATRICE DE RAIDEUR
C IN  TYPCON   : K16 : TYPE DE LA STRUCTURE DE DONNEES PRODUITE
C IN  KNEGA    : K8  : VALEUR DU MOT-CLE NUME_MODE_NEGA
C IN  LRAIDEUR : IS  : DESCRIPTEUR DE LA MATRICE DE "RAIDEUR"
C IN  LMASSE   : IS  : DESCRIPTEUR DE LA MATRICE DE "MASSE"
C IN  LAMOR    : IS  : DESCRIPTEUR DE LA MATRICE DE "AMORTISSEMENT"
C IN  MXRESF   : IS  : PARAMETRE DE DIMENSIONNEMENT DE RESUR
C IN  NEQ      : IS  : NPMBRE DE DDL
C IN  NFREQ    : IS  : NOMBRE DE FREQUENCES
C IN  FCORIG   : IS  : VALEUR SEUIL EN FREQUNCE
C IN DLAGR     : IS  : POSITION DES DDL DE LAGRANGE
C IN DBLOQ     : IS  : POSITION DES DDL BLOQUES
C IN/OUT VECTR : R   : VECTEURS PROPRES REELS
C IN/OUT VECTC : C   : VECTEURS PROPRES COMPLEXES
C OUT RESUR    : R   : STRUTURE DE DONNEES RESULTAT CONTENANT TOUS LES
C                      PARAMETRES MODAUX
C     ------------------------------------------------------------------
      INTEGER    INEG, LXLGUT, IPREC, IRET, ILGCON
      REAL*8     RBID
      COMPLEX*16 ZBID
C     ------------------------------------------------------------------
C     ------------------------------------------------------------------
C
C     --- PRISE EN COMPTE DES MODES NEGATIFS ?
      INEG = +1
      IF (KNEGA.EQ.'OUI') INEG = -1
C
C     --- PREPARATION AU STOCKAGE DANS LA STRUCTURE DE DONNEES ---
      ILGCON = LXLGUT(TYPCON)
      IF ( TYPCON(ILGCON-1:ILGCON) .EQ. '_C' ) ILGCON = ILGCON -2
      CALL RSEXIS(MODES,IRET)
      IF ( IRET .EQ. 0 ) CALL RSCRSD(MODES,TYPCON(:ILGCON),NFREQ)
      IPREC = 0
C
C     --- NORMALISATION ET CALCUL DES PARAMETRES MODAUX ---
C     -----------------------------------------------------
C
      IF (( LAMOR .EQ. 0 ).AND.(KTYP.EQ.'R')) THEN
C
C        - NORMALISATION A LA + GRANDE DES COMPOSANTES /= LAGRANGE --
         CALL VPNORX(NFREQ,NEQ,DLAGR,VECTR,RESUK)
C
C        - CALCUL DES PARAMETRES GENERALISES ---
         CALL VPPGEN(LMASSE,LAMOR,LRAIDE,RESUR(4*MXRESF+1),
     &               RESUR(6*MXRESF+1),RESUR(5*MXRESF+1),
     &               VECTR,NEQ,NFREQ,DBLOQ)
C
C        CALCUL DES FACTEURS DE PARTICIPATIONS ET DES MASSES EFFECTIVES
         CALL VPPFAC(LMASSE,RESUR(4*MXRESF+1),VECTR,NEQ,NFREQ,MXRESF,
     &               RESUR(7*MXRESF+1),RESUR(10*MXRESF+1))
C
C        - CALCUL DE LA NORME D'ERREUR SUR LE MODE ---
         CALL VPERMO(LMASSE,LRAIDE,NFREQ,VECTR,RESUR(MXRESF+1),
     &               DBLOQ,OMECOR,RESUR(3*MXRESF+1))
C
C        - STOCKAGE DES VECTEURS PROPRES ---
         CALL VPSTOR ( INEG, 'R', MODES, NFREQ, NEQ, VECTR, ZBID,
     +                 MXRESF, NBPARI, NBPARR, NBPARK, NOPARA,
     +                 RESUI, RESUR, RESUK, IPREC )
C
      ELSE IF (( LAMOR .EQ. 0 ).AND.(KTYP.EQ.'C')) THEN
C
C        - NORMALISATION A LA + GRANDE DES COMPOSANTES /= LAGRANGE --
         CALL WPNORX(NFREQ,NEQ,DLAGR,VECTC,RESUK)

C        - CALCUL DES PARAMETRES GENERALISES ---
         CALL VPPGEC(LMASSE,LAMOR,LRAIDE,RESUR(4*MXRESF+1),
     &               RESUR(6*MXRESF+1),RESUR(5*MXRESF+1),
     &               VECTC,NEQ,NFREQ,DBLOQ)
C
C        CALCUL DES FACTEURS DE PARTICIPATIONS ET DES MASSES EFFECTIVES
C         CALL VPPFAC(LMASSE,RESUR(4*MXRESF+1),VECTR,NEQ,NFREQ,MXRESF,
C     &               RESUR(7*MXRESF+1),RESUR(10*MXRESF+1))
C
C        - CALCUL DE LA NORME D'ERREUR SUR LE MODE ---
         CALL VPERMC(LMASSE,LRAIDE,NFREQ,VECTC,
     &               RESUR(MXRESF+1),RESUR(2*MXRESF+1),DBLOQ,
     &               OMECOR,RESUR(3*MXRESF+1))
C
C        - STOCKAGE DES VECTEURS PROPRES ---
         CALL VPSTOR ( INEG, 'C', MODES, NFREQ, NEQ, RBID, VECTC,
     +                 MXRESF, NBPARI, NBPARR, NBPARK, NOPARA,
     +                 RESUI, RESUR, RESUK, IPREC )
C
      ELSE IF (( LAMOR .NE. 0 ).AND.(KTYP.EQ.'R')) THEN
C
C        - NORMALISATION A LA + GRANDE DES COMPOSANTES /= LAGRANGE --
         CALL WPNORX(NFREQ,NEQ,DLAGR,VECTC,RESUK)
C
C        - CALCUL DES PARAMETRES GENERALISES ---
         CALL WPPGEN(LMASSE,LAMOR,LRAIDE,RESUR(4*MXRESF+1),
     &               RESUR(6*MXRESF+1),RESUR(5*MXRESF+1),
     &               VECTC,NEQ,NFREQ,DBLOQ)
C
C        - CALCUL DE LA NORME D'ERREUR SUR LE MODE ---
         CALL WPERMO(LMASSE,LRAIDE,LAMOR,NFREQ,VECTC,
     &               RESUR(MXRESF+1),RESUR(2*MXRESF+1),DBLOQ,
     &               OMECOR,RESUR(3*MXRESF+1))
C
C        - STOCKAGE DES VECTEURS PROPRES ---
         CALL VPSTOR ( INEG, 'C', MODES, NFREQ, NEQ, RBID, VECTC,
     +                 MXRESF, NBPARI, NBPARR, NBPARK, NOPARA,
     +                 RESUI, RESUR, RESUK, IPREC )
      ELSE IF (( LAMOR .NE. 0 ).AND.(KTYP.EQ.'C')) THEN
C
C        - NORMALISATION A LA + GRANDE DES COMPOSANTES /= LAGRANGE --
         CALL WPNORX(NFREQ,NEQ,DLAGR,VECTC,RESUK)
C
C        - CALCUL DES PARAMETRES GENERALISES ---
         CALL WPPGEN(LMASSE,LAMOR,LRAIDE,RESUR(4*MXRESF+1),
     &               RESUR(6*MXRESF+1),RESUR(5*MXRESF+1),
     &               VECTC,NEQ,NFREQ,DBLOQ)
C
C        - CALCUL DE LA NORME D'ERREUR SUR LE MODE ---
         CALL WPERMO(LMASSE,LRAIDE,LAMOR,NFREQ,VECTC,
     &               RESUR(MXRESF+1),RESUR(2*MXRESF+1),DBLOQ,
     &               OMECOR,RESUR(3*MXRESF+1))
C
C        - STOCKAGE DES VECTEURS PROPRES ---
         CALL VPSTOR ( INEG, 'C', MODES, NFREQ, NEQ, RBID, VECTC,
     +                 MXRESF, NBPARI, NBPARR, NBPARK, NOPARA,
     +                 RESUI, RESUR, RESUK, IPREC )
      ENDIF
C     ------------------------------------------------------------------
      END
