      SUBROUTINE XMILFI(ELP,NDIM,NNO,PTINT,JTABCO,JTABLS,IPP,IP,MILFI)
      IMPLICIT NONE

      INTEGER       NDIM,NNO,JTABCO,JTABLS,IPP,IP
      CHARACTER*8   ELP
      REAL*8        MILFI(NDIM),PTINT(*)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 31/01/2012   AUTEUR REZETTE C.REZETTE 
C TOLE CRS_1404
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
C                      TROUVER LES COORDONNES DU PT MILIEU ENTRE LES
C                      DEUX POINTS D'INTERSECTION
C
C     ENTREE
C       NDIM    : DIMENSION TOPOLOGIQUE DU MAILLAGE
C       PTINT  : COORDONNÉES DES POINTS D'INTERSECTION
C       JTABCO  : ADRESSE DES COORDONNEES DES NOEUDS DE L'ELEMENT
C       JTABLS  : ADRESSE DES LSN DES NOEUDS DE L'ELEMENT
C       IPP     : NUMERO NOEUD PREMIER POINT INTER
C       IP      : NUMERO NOEUD DEUXIEME POINT INTER
C     SORTIE
C       MILFI   : COORDONNES DU PT MILIEU ENTRE IPP ET IP
C     ----------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  ------------------------
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  ------------------------
C
      REAL*8       KSI(NDIM)
      REAL*8       EPSMAX,RBID
      INTEGER      IBID,ITEMAX
      CHARACTER*6  NAME
C
C --------------------------------------------------------------------

      CALL JEMARQ()

      ITEMAX=500
      EPSMAX=1.D-9
      NAME='XMILFI'

C     CALCUL DES COORDONNEES DE REFERENCE
C     DU POINT PAR UN ALGO DE NEWTON
      CALL XNEWTO(ELP,NAME,IBID,NNO,NDIM,PTINT,ZR(JTABCO),JTABLS,IPP,
     &                  IP,RBID,ITEMAX,EPSMAX,KSI)

      CALL ASSERT(KSI(1).GE.-1.D0 .AND. KSI(1).LE.1.D0)
      CALL ASSERT(KSI(2).GE.-1.D0 .AND. KSI(2).LE.1.D0)

C --- COORDONNES DU POINT DANS L'ELEMENT REEL
      CALL REEREL(ELP,NNO,NDIM,ZR(JTABCO),KSI,MILFI)

      CALL JEDEMA()
      END
