      SUBROUTINE TRIGD(DG1,DEB1,DG2,DEB2,CUMUL,INO,NNO)
      IMPLICIT NONE

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 28/07/2008   AUTEUR PELLET J.PELLET 
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
C RESPONSABLE                            VABHHTS J.PELLET
C     ARGUMENTS:
C     ----------
      INTEGER IGD,NCMPMX,DG1(*),DG2(*),DEB1,DEB2,INO,NNO
      LOGICAL CUMUL
C ----------------------------------------------------------------------
C     ENTREES:
C       IGD    : GRANDEUR (COMMON)
C       NCMPMX : NOMBRE MAX DE CMP DE IGD (COMMON)
C       IACHIN : ADRESSE JEVEUX DE CHIN.VALE (COMMON)
C       IANUEQ : ADRESSE JEVEUX DE L'OBJET .NUEQ (PROF_CHNO)(COMMON)
C       LPRNO  : 1: CHAM_NO A PROF_CHNO (COMMON)
C                0: CHAM_NO A REPRESENTATION CONSTANTE OU CARTE.
C                SI LPRNO =1 IL FAUT FAIRE L'INDIRECTION PAR .NUEQ
C       IACHLO : ADRESSE JEVEUX DU CHAMP LOCAL (COMMON)
C       DG1    : DG DE LA GRANDEUR DE CHIN
C       DEB1   : ADRESSE DU DEBUT DE LA GRANDEUR DANS CHIN.VALE
C       DG2    : DG DE LA GRANDEUR DE CHLOC
C       DEB2   : ADRESSE DU DEBUT DE LA GRANDEUR DANS CHLOC.VALE
C       CUMUL  : / .F. : ON AFFECTE DANS DEB2 LA GRANDEUR LUE
C                / .T. : ON CUMULE DANS DEB2 LA GRANDEUR LUE
C                CUMUL= .T. => ON VEUT FAIRE "MOYENNE" CHNO -> ELEM
C       INO    : NUMERO DU NOEUD ASSOCIE A DEB1
C                (INO N'EST UTILISE QUE SI CUMUL)
C       NNO    : NOMBRE DE NEOUDS DE LA MAILLE
C                (NNO N'EST UTILISE QUE SI CUMUL)

C     SORTIES:
C       RECOPIE DE CHIN.VALE DANS CHLOC POUR LES CMPS VOULUS.
C       DEB2   : EST MIS A JOUR POUR LE NOEUD SUIVANT (SI EXCHNO).
C                ET POUR L'ELEMENT SUIVANT SI EXCART OU EXCHNO.
C ----------------------------------------------------------------------
      LOGICAL EXISDG
      CHARACTER*32 JEXNUM

      COMMON /CAII01/IGD,NEC,NCMPMX,IACHIN,IACHLO,IICHIN,IANUEQ,LPRNO,
     &       ILCHLO
      COMMON /CAKK02/TYPEGD
      CHARACTER*8 TYPEGD

      LOGICAL CHANGE
      INTEGER CMP,IND1,IND2,ILCHLO
      INTEGER NEC,NEC2,NECOLD,IACHLO,IACHIN,IICHIN,IANUEQ,LPRNO
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C    -------------------------------------------------------------------
      PARAMETER (NEC2=6)
      INTEGER DG1OLD(NEC2),DG2OLD(NEC2),POSCMP(NEC2*30)
      INTEGER IEQ,I
      SAVE DG1OLD,DG2OLD,POSCMP,IND2,NECOLD
      DATA DG1OLD/NEC2*0/
      DATA DG2OLD/NEC2*0/
      DATA NECOLD/0/

      CALL ASSERT(NEC.LE.NEC2)


C     -- ON REGARDE S'IL FAUT REMPLIR POSCMP OU SI ON PEUT UTILISER
C        LE TABLEAU REMPLI PRECEDEMMENT :
      CHANGE = .FALSE.
      IF (NEC.NE.NECOLD) CHANGE = .TRUE.
      DO 10,I = 1,NEC
        IF (DG1(I).NE.DG1OLD(I)) CHANGE = .TRUE.
        IF (DG2(I).NE.DG2OLD(I)) CHANGE = .TRUE.
   10 CONTINUE

      IF (.NOT.CHANGE) GO TO 40
      DO 20,I = 1,NEC2
        DG1OLD(I) = DG1(I)
        DG2OLD(I) = DG2(I)
        NECOLD = NEC
   20 CONTINUE



C     1. REMPLISSAGE DE POSCMP:
C     -------------------------
      IND1 = 0
      IND2 = 0
      DO 30 CMP = 1,NCMPMX
        IF (EXISDG(DG1,CMP)) IND1 = IND1 + 1
        IF (EXISDG(DG2,CMP)) THEN
          IND2 = IND2 + 1
          IF (EXISDG(DG1,CMP)) THEN
            POSCMP(IND2) = IND1
          ELSE
            POSCMP(IND2) = 0
          END IF
        END IF
   30 CONTINUE


   40 CONTINUE


C     2. RECOPIE DES VALEURS DANS LE CHAMP_LOCAL :
C     --------------------------------------------

      DO 50 CMP = 1,IND2
        IF (POSCMP(CMP).GT.0) THEN
          IEQ = DEB1 - 1 + POSCMP(CMP)
          IF (LPRNO.EQ.1) IEQ = ZI(IANUEQ-1+IEQ)

          IF (.NOT.CUMUL) THEN
            IF (TYPEGD.EQ.'R') THEN
              ZR(IACHLO-1+DEB2-1+CMP) = ZR(IACHIN-1+IEQ)
            ELSE IF (TYPEGD.EQ.'I') THEN
              ZI(IACHLO-1+DEB2-1+CMP) = ZI(IACHIN-1+IEQ)
            ELSE IF (TYPEGD.EQ.'C') THEN
              ZC(IACHLO-1+DEB2-1+CMP) = ZC(IACHIN-1+IEQ)
            ELSE IF (TYPEGD(1:3).EQ.'K8 ') THEN
              ZK8(IACHLO-1+DEB2-1+CMP) = ZK8(IACHIN-1+IEQ)
            ELSE IF (TYPEGD(1:3).EQ.'K16') THEN
              ZK16(IACHLO-1+DEB2-1+CMP) = ZK16(IACHIN-1+IEQ)
            ELSE IF (TYPEGD(1:3).EQ.'K24') THEN
              ZK24(IACHLO-1+DEB2-1+CMP) = ZK24(IACHIN-1+IEQ)
            ELSE
              CALL ASSERT(.FALSE.)
            END IF

          ELSE
            IF (TYPEGD.EQ.'R') THEN
              ZR(IACHLO-1+DEB2-1+CMP) = ZR(IACHLO-1+DEB2-1+CMP) +
     &                                  ZR(IACHIN-1+IEQ)
            ELSE IF (TYPEGD.EQ.'C') THEN
              ZC(IACHLO-1+DEB2-1+CMP) = ZC(IACHLO-1+DEB2-1+CMP) +
     &                                  ZC(IACHIN-1+IEQ)
            ELSE
              CALL ASSERT(.FALSE.)
            END IF
          END IF


          IF (CUMUL) THEN
            IF (INO.EQ.1) THEN
              ZL(ILCHLO-1+DEB2-1+CMP) = .TRUE.
            ELSE
            END IF
          ELSE
            ZL(ILCHLO-1+DEB2-1+CMP) = .TRUE.
          END IF

        ELSE
          ZL(ILCHLO-1+DEB2-1+CMP) = .FALSE.
        END IF
   50 CONTINUE


      IF (CUMUL) THEN
        IF (INO.EQ.NNO) DEB2 = DEB2 + IND2
      ELSE
        DEB2 = DEB2 + IND2
      END IF
      END
