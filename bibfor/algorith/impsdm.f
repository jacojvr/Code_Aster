      SUBROUTINE IMPSDM(IMPRCO,COLONN,MARQ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      CHARACTER*14 IMPRCO
      CHARACTER*9  COLONN
      CHARACTER*1  MARQ
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR :
C ----------------------------------------------------------------------
C
C OPERATIONS ELEMENTAIRES SUR LA SD AFFICHAGE DE COLONNES
C AFFECTATION D'UN MARQUAGE POUR LA COLONNE
C SI LA COLONNE A UN CODE INCORRECT: ERREUR FATALE
C SI LA COLONNE N'EXISTE PAS POUR L'AFFICHAGE COURANT: ON IGNORE
C
C IN IMPRCO : SD SUR L'AFFICHAGE DES COLONNES
C IN COLONN : CODE TYPE DE LA COLONNE (VOIR LISTE DANS IMPREF)
C IN MARQ   : MARQUAGE DE LA COLONNE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      JIMPMA,JIMPIN,JIMPCO,JIMPTY
      CHARACTER*24 IMPMAR,IMPINF,IMPCOL,IMPTYP
      INTEGER      ICOL,NBCOL,ICOD,I,FORCOL
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C ---
C
      IMPINF = IMPRCO(1:14)//'INFO'
      IMPCOL = IMPRCO(1:14)//'DEFI.COL'
      IMPMAR = IMPRCO(1:14)//'DEFI.MAR'
      IMPTYP = IMPRCO(1:14)//'DEFI.TYP'
      CALL JEVEUO(IMPINF,'L',JIMPIN)
      CALL JEVEUO(IMPCOL,'L',JIMPCO)
      CALL JEVEUO(IMPMAR,'E',JIMPMA)
      CALL JEVEUO(IMPTYP,'L',JIMPTY)
C
C --- NOMBRE DE COLONNES
C
      ICOL  = 0
      NBCOL = ZI(JIMPIN-1+4)
C
C --- RECHERCHE DE LA COLONNE AYANT CE TYPE
C
      CALL IMPCOD(COLONN,ICOD)

      IF (ICOD.EQ.0) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
      DO 10 I = 1,NBCOL
       IF (ZI(JIMPCO-1+I).EQ.ICOD) THEN
         ICOL = I
         GOTO 20
       ENDIF
  10  CONTINUE
      IF (ICOL.EQ.0) THEN
         GOTO 999
      ENDIF
  20  CONTINUE
C
C --- RECUP DU FORMAT DE LA COLONNE
C
      FORCOL    = ZI(JIMPTY-1+ICOL)
      IF (FORCOL.EQ.3) THEN
        CALL ASSERT(.FALSE.)
      ENDIF
C
C --- ECRITURE DE LA MARQUE DE LA COLONNE
C
      ZK8(JIMPMA-1+ICOL) = MARQ
C
C ---
C
 999  CONTINUE
      CALL JEDEMA()
      END
