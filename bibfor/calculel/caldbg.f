      SUBROUTINE CALDBG(OPTION,INOUT,NCHAM,LCHAM,LPARAM)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 22/07/2008   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER NCHAM,I,IRET
      CHARACTER*(*) INOUT
      CHARACTER*19 LCHAM(*)
      CHARACTER*8 LPARAM(*)
      CHARACTER*16 OPTION
C ----------------------------------------------------------------------
C     BUT : IMPRIMER SUR UNE LIGNE LA VALEUR
C           D'UNE LISTE DE CHAMPS POUR COMPARER 2 VERSIONS
C ----------------------------------------------------------------------
      CHARACTER*19 CHAMP
      CHARACTER*24 OJB
      CHARACTER*4 INOU2
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR,SOMMR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C DEB-------------------------------------------------------------------

      CALL JEMARQ()
      INOU2=INOUT

C     1- POUR FAIRE DU DEBUG PAR COMPARAISON DE 2 VERSIONS:
C     -----------------------------------------------------
      DO 10,I = 1,NCHAM
        CHAMP = LCHAM(I)
        CALL EXISD('CARTE',CHAMP,IRET)
        IF (IRET.GT.0) OJB = CHAMP//'.VALE'
        CALL EXISD('CHAM_NO',CHAMP,IRET)
        IF (IRET.GT.0) OJB = CHAMP//'.VALE'
        CALL EXISD('CHAM_ELEM',CHAMP,IRET)
        IF (IRET.GT.0) OJB = CHAMP//'.CELV'
        CALL EXISD('RESUELEM',CHAMP,IRET)
        IF (IRET.GT.0) OJB = CHAMP//'.RESL'

        CALL DBGOBJ(OJB,'OUI',6,'&&CALCUL|'//INOU2//'|'//LPARAM(I))
   10 CONTINUE

      CALL JEDEMA()

      END
