      SUBROUTINE PMEVDR(SDDISC,TABINC,LICCVG,ITEMAX,CONVER,
     &                  ACTITE)
C
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT     NONE
      INCLUDE 'jeveux.h'
      LOGICAL      ITEMAX,CONVER
      CHARACTER*19 SDDISC,TABINC(*)
      INTEGER      LICCVG(*),ACTITE
C
C ----------------------------------------------------------------------
C
C ROUTINE SIMU_POINT_MAT
C
C VERIFICATION DES CRITERES DE DIVERGENCE DE TYPE EVENT-DRIVEN
C
C ----------------------------------------------------------------------
C
C
C IN  SDDISC : SD DISCRETISATION
C IN  TABINC : TABLE INCREMENTS DES VARIABLES
C IN  ITEMAX : .TRUE. SI ITERATION MAXIMUM ATTEINTE
C IN  CONVER : .TRUE. SI CONVERGENCE REALISEE
C IN  LICCVG : CODES RETOURS D'ERREUR
C              (2) : INTEGRATION DE LA LOI DE COMPORTEMENT
C                  = 0 OK
C                  = 1 ECHEC DANS L'INTEGRATION : PAS DE RESULTATS
C                  = 3 SIZZ NON NUL (DEBORST) ON CONTINUE A ITERER
C                  = 1 MATRICE DE CONTACT SINGULIERE
C              (5) : MATRICE DU SYSTEME (MATASS)
C                  = 0 OK
C                  = 1 MATRICE SINGULIERE
C                  = 3 ON NE SAIT PAS SI SINGULIERE
C OUT ACTITE : BOUCLE NEWTON -> ACTION POUR LA SUITE
C     0 - NEWTON OK   - ON SORT
C     1 - NEWTON NOOK - IL FAUT FAIRE QUELQUE CHOSE
C     2 - NEWTON NCVG - ON CONTINUE NEWTON
C     3 - NEWTON STOP - TEMPS/USR1
C
C
C
C
      INTEGER      IFM,NIV
      INTEGER      FACCVG,LDCCVG,NUMINS
      LOGICAL      LERROR,LSVIMX,LDVRES,LINSTA,LCRITL
      CHARACTER*24 K24BLA
      INTEGER      IEVDAC
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFNIV(IFM,NIV)
C
C --- INITIALISATIONS
C
      LDCCVG = LICCVG(2)
      FACCVG = LICCVG(5)
      LERROR =(LDCCVG.EQ.1) . OR. (FACCVG.NE.0) .OR. ITEMAX
      IEVDAC = 0
      K24BLA = ' '
      LSVIMX = .FALSE.
      LDVRES = .FALSE.
      LINSTA = .FALSE.
      LCRITL = .FALSE.
      NUMINS = -1
C
C --- NEWTON A CONVERGE ?
C
      IF (CONVER) THEN
        ACTITE = 0
      ELSE
        ACTITE = 2
      ENDIF
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<SIMUPOINTMAT> EVALUATION DES EVENT-DRIVEN'
      ENDIF
C
C --- DETECTION DU PREMIER EVENEMENT DECLENCHE
C
      CALL NMEVEL(SDDISC,NUMINS,K24BLA,K24BLA,TABINC,
     &            'NEWT',LSVIMX,LDVRES,LINSTA,LCRITL,
     &            LERROR,CONVER)
C
C --- UN EVENEMENT SE DECLENCHE
C
      CALL NMACTO(SDDISC,IEVDAC)
      IF (IEVDAC.NE.0) THEN
        ACTITE = 1
      ENDIF
C
      CALL JEDEMA()
      END
