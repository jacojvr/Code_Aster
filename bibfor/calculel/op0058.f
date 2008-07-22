      SUBROUTINE OP0058(IER)
C ----------------------------------------------------------------------
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
C     COMMANDE :  CALC_ELEM
C        CALCUL DES CONTRAINTES (DEFORM ...) ELEMENTAIRES EN MECANIQUE.
C        CALCUL DES FLUX ELEMENTAIRES EN THERMIQUE.
C        CALCUL DES INTENSITES        EN ACOUSTIQUE
C        CALCUL DES INDICATEURS D'ERREURS EN MECANIQUE ET EN THERMIQUE
C   -------------------------------------------------------------------
C CORPS DU PROGRAMME
C ----------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER IER
C   ----- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      INTEGER        ZI
      COMMON /IVARJE/ZI(1)
      REAL*8         ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16     ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL        ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8    ZK8
      CHARACTER*16          ZK16
      CHARACTER*24                  ZK24
      CHARACTER*32                          ZK32
      CHARACTER*80                                  ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     ----- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
      CHARACTER*6 NOMPRO
      PARAMETER  (NOMPRO='OP0058')
C
      INTEGER      IFM,NIV,N0,NUORD,NCHAR,IBID,IERD,JORDR,NP,NC
      INTEGER      NBORDR,IRET
      REAL*8       PREC
      CHARACTER*4  CTYP
      CHARACTER*8  RESUC1,RESUCO,MODELE,CARA,CRIT
      CHARACTER*16 NOMCMD,TYSD,PHENO,CONCEP
      CHARACTER*19 KNUM,KCHA,SOLVEU
      CHARACTER*24 MATE
      LOGICAL      NEWCAL
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
C
      KCHA = '&&'//NOMPRO//'.CHARGES   '
      KNUM = '&&'//NOMPRO//'.NUME_ORDRE'

      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)

      CALL GETRES(RESUC1,CONCEP,NOMCMD)

      CALL GETVID(' ','RESULTAT',1,1,1,RESUCO,N0)
      NEWCAL = .FALSE.
      CALL JEEXIN(RESUC1//'           .DESC',IRET)
      IF (IRET.EQ.0) NEWCAL = .TRUE.
      CALL GETTCO(RESUCO,TYSD)

      CALL GETVR8(' ','PRECISION',1,1,1,PREC,NP)
      CALL GETVTX(' ','CRITERE',1,1,1,CRIT,NC)
      CALL RSUTNU(RESUCO,' ',0,KNUM,NBORDR,PREC,CRIT,IRET)
      IF (IRET.EQ.10) THEN
      CALL U2MESK('A','CALCULEL4_8',1,RESUCO)
        GO TO 9999
      END IF
      IF (IRET.NE.0) THEN
        CALL U2MESS('A','ALGORITH3_41')
        GO TO 9999
      END IF

      CALL JEVEUO(KNUM,'L',JORDR)
      NUORD = ZI(JORDR)

C     -- CREATION DU SOLVEUR :
      SOLVEU = '&&OP0058.SOLVEUR'
      CALL CRESOL(SOLVEU,' ')

      CALL MEDOM1(MODELE,MATE,CARA,KCHA,NCHAR,CTYP,RESUCO,NUORD)
      CALL DISMOI('F','PHENOMENE' ,MODELE,'MODELE',IBID,PHENO,IERD)
C
C     --- TRAITEMENT DU PHENOMENE MECANIQUE ---
      IF (PHENO(1:4).EQ.'MECA') THEN

         CALL MECALM
     &  (NEWCAL,TYSD,KNUM,KCHA,RESUCO,RESUC1,CONCEP,NBORDR,
     &   MODELE,MATE,CARA,NCHAR,CTYP)

C     --- TRAITEMENT DES PHENOMENES THERMIQUES ET ACOUSTIQUES ---
      ELSEIF ((PHENO(1:4).EQ.'THER') .OR. (PHENO(1:4).EQ.'ACOU'))THEN

         CALL THACLM
     &  (NEWCAL,TYSD,KNUM,KCHA,PHENO,RESUCO,RESUC1,CONCEP,NBORDR,
     &   MODELE,MATE,CARA,NCHAR,CTYP)

      ENDIF

 9999 CONTINUE

      CALL JEDEMA()
      END
