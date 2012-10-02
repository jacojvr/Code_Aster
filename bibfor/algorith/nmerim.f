      SUBROUTINE NMERIM(SDERRO)
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*24  SDERRO
C
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (SD ERREUR)
C
C EMISSION MESSAGE ERRREUR
C
C ----------------------------------------------------------------------
C
C
C IN  SDERRO : SD ERREUR
C
C
C
C
      LOGICAL ITEMAX,ERRLDC,ERRPIL,ERRFC1,ERRFC2
      LOGICAL ERRCD1,ERRCD2
      LOGICAL MTUCPN,MTUCPP,ARRUSE
      LOGICAL ERRCCG,ERRCCF,ERRCCC
      LOGICAL ERRRES
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- EVENEMENTS ERREURS
C
      CALL NMERGE(SDERRO,'ERRE_INTE',ERRLDC)
      CALL NMERGE(SDERRO,'ERRE_PILO',ERRPIL)
      CALL NMERGE(SDERRO,'ERRE_FACS',ERRFC1)
      CALL NMERGE(SDERRO,'ERRE_FACT',ERRFC2)
      CALL NMERGE(SDERRO,'ERRE_CTD1',ERRCD1)
      CALL NMERGE(SDERRO,'ERRE_CTD2',ERRCD2)
      CALL NMERGE(SDERRO,'ERRE_TIMN',MTUCPN)
      CALL NMERGE(SDERRO,'ERRE_TIMP',MTUCPP)
      CALL NMERGE(SDERRO,'ERRE_EXCP',ARRUSE)
      CALL NMERGE(SDERRO,'ITER_MAXI',ITEMAX)
      CALL NMERGE(SDERRO,'ERRE_CTCG',ERRCCG)
      CALL NMERGE(SDERRO,'ERRE_CTCF',ERRCCF)
      CALL NMERGE(SDERRO,'ERRE_CTCC',ERRCCC)
      CALL NMERGE(SDERRO,'SOLV_ITMX',ERRRES)
C
C --- EMISSION DES MESSAGES
C
      IF (ERRLDC) THEN
        CALL U2MESS('I','MECANONLINE6_29')
      ELSE IF (ERRPIL) THEN
        CALL U2MESS('I','MECANONLINE6_30')
      ELSE IF (ITEMAX) THEN
        CALL U2MESS('I','MECANONLINE6_31')
      ELSE IF (ERRCD1.OR.ERRCD2) THEN
        CALL U2MESS('I','MECANONLINE6_32')
      ELSE IF (ERRFC1.OR.ERRFC2) THEN
        CALL U2MESS('I','MECANONLINE6_34')
      ELSE IF (MTUCPN) THEN
        CALL U2MESS('I','MECANONLINE6_35')
      ELSE IF (MTUCPP) THEN
        CALL U2MESS('I','MECANONLINE6_33')
      ELSE IF (ARRUSE) THEN
        CALL U2MESS('I','MECANONLINE6_36')
      ELSE IF (ERRCCG) THEN
        CALL U2MESS('I','MECANONLINE6_37')
      ELSE IF (ERRCCF) THEN
        CALL U2MESS('I','MECANONLINE6_38')
      ELSE IF (ERRCCC) THEN
        CALL U2MESS('I','MECANONLINE6_39')
      ELSE IF (ERRRES) THEN
        CALL U2MESS('I','MECANONLINE6_43')
      ELSE
        CALL ASSERT(.FALSE.)
      END IF
C
      CALL JEDEMA()
      END
