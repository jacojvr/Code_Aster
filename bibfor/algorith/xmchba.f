      SUBROUTINE XMCHBA(NOMA  ,NBMA  ,LIGREL,NOMPAZ,OPTIOZ,
     &                  CHELEM)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 27/06/2011   AUTEUR MASSIN P.MASSIN 
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT      NONE
      CHARACTER*19  CHELEM
      CHARACTER*(*) NOMPAZ,OPTIOZ
      INTEGER       NBMA
      CHARACTER*8   NOMA
      CHARACTER*19  LIGREL
C
C ----------------------------------------------------------------------
C
C ROUTINE XFEM (METHODE XFEM - CREATION CHAM_ELEM)
C
C ROUTINE GENERIQUE DE CREATION DE CHAM_ELEM VIERGE
C
C CETTE ROUTINE NE SERT PLUS A RIEN, ELLE DOIT ETRE RESORBE
C
C ----------------------------------------------------------------------
C
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NBMA   : NOMBRE DE MAILLES
C IN  OPTION : OPTION POUR CALCUL
C IN  NOMAPR : NOM DU PARAMETRE DU CHAM_ELEM
C IN  LIGREL : NOM DU LIGREL DES MAILLES TARDIVES
C OUT CHELEM : CHAM_ELEM A CREER
C
C ----------------------------------------------------------------------
C
      CHARACTER*8   NOMPAR
      CHARACTER*16  OPTION
      CHARACTER*19  CHELEX
      INTEGER       IRET
C
C ----------------------------------------------------------------------
C
C
C --- INITIALISATIONS
C
      NOMPAR = NOMPAZ
      OPTION = OPTIOZ
      CHELEX = '&&XMCHBA.CES'
C
C --- CREATION DU CHAM_ELEM_S POUR EXTENSION CHAM_ELEM
C
      CALL XMCHEX(NOMA  ,NBMA  ,CHELEX,CHELEX)
C
C --- CREATION DU CHAM_ELEM ETENDU
C
      CALL ALCHML(LIGREL,OPTION,NOMPAR,'V',CHELEM,IRET,CHELEX)
      CALL ASSERT(IRET.EQ.0)

C
C --- DESTRUTION DU CHAM_ELEM_S POUR EXTENSION
C
      CALL DETRSD('CHAM_ELEM_S',CHELEX)
C
      END
