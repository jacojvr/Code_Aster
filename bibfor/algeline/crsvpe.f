      SUBROUTINE CRSVPE(MOTFAC,SOLVEU,ISTOP,NPREC,SYME,EPSMAT,MIXPRE,
     &                  KMD)
      IMPLICIT NONE
      INTEGER      ISTOP,NPREC
      REAL*8       EPSMAT
      CHARACTER*3  SYME,MIXPRE,KMD
      CHARACTER*16 MOTFAC
      CHARACTER*19 SOLVEU
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGELINE  DATE 09/11/2009   AUTEUR TARDIEU N.TARDIEU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2008  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ----------------------------------------------------------
C  BUT : REMPLISSAGE SD_SOLVEUR PETSC
C
C IN K19 SOLVEU  : NOM DU SOLVEUR DONNE EN ENTREE
C OUT    SOLVEU  : LE SOLVEUR EST CREE ET INSTANCIE
C IN  IN ISTOP   : PARAMETRE LIE AUX MOT-CLE STOP_SINGULIER
C IN  IN NPREC   :                           NPREC
C IN  K3 SYME    :                           SYME
C IN  R8 EPSMAT  :                           FILTRAGE_MATRICE
C IN  K3 MIXPRE  :                           MIXER_PRECISION
C IN  K3 KMD     :                           MATR_DISTRIBUEE
C ----------------------------------------------------------

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------

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

C --- FIN DECLARATIONS NORMALISEES JEVEUX --------------------

      INTEGER      IBID,NIREMP,NMAXIT
      INTEGER      ISLVK,ISLVI,ISLVR
      REAL*8       FILLIN,EPSMAX
      CHARACTER*8  KVARI,KPREC,RENUM
      LOGICAL      GETEXM

C------------------------------------------------------------------
      CALL JEMARQ()

C --- LECTURES PARAMETRES DEDIES AU SOLVEUR
C  -  PARAMETRES FORCEMMENT PRESENTS
      CALL GETVTX(MOTFAC,'ALGORITHME'      ,1,1,1,KVARI ,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVTX(MOTFAC,'PRE_COND'        ,1,1,1,KPREC ,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVTX(MOTFAC,'RENUM'           ,1,1,1,RENUM ,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVR8(MOTFAC,'RESI_RELA'       ,1,1,1,EPSMAX,IBID)
      CALL ASSERT(IBID.EQ.1)
      CALL GETVIS(MOTFAC,'NMAX_ITER'       ,1,1,1,NMAXIT,IBID)
      CALL ASSERT(IBID.EQ.1)
C  -  PARAMETRES OPTIONNELS LIES A PRE_COND='LDLT_INC'
      CALL GETVIS(MOTFAC,'NIVE_REMPLISSAGE',1,1,1,NIREMP,IBID)
      CALL GETVR8(MOTFAC,'REMPLISSAGE'     ,1,1,1,FILLIN,IBID)

C --- ON REMPLIT LA SD_SOLVEUR
      CALL JEVEUO(SOLVEU//'.SLVK','E',ISLVK)
      CALL JEVEUO(SOLVEU//'.SLVR','E',ISLVR)
      CALL JEVEUO(SOLVEU//'.SLVI','E',ISLVI)

      ZK24(ISLVK-1+1) = 'PETSC'
      ZK24(ISLVK-1+2) = KPREC
      ZK24(ISLVK-1+3) = KVARI
      ZK24(ISLVK-1+4) = RENUM
      ZK24(ISLVK-1+5) = SYME
      ZK24(ISLVK-1+6) = 'XXXX'
      ZK24(ISLVK-1+7) = 'XXXX'
      ZK24(ISLVK-1+8) = 'XXXX'
      ZK24(ISLVK-1+9) = 'XXXX'
      ZK24(ISLVK-1+10)= 'XXXX'
      ZK24(ISLVK-1+11)= 'XXXX'

      ZR(ISLVR-1+1) = 0.D0
      ZR(ISLVR-1+2) = EPSMAX
      ZR(ISLVR-1+3) = FILLIN
      ZR(ISLVR-1+4) = 0.D0

      ZI(ISLVI-1+1) = -9999
      ZI(ISLVI-1+2) = NMAXIT
      ZI(ISLVI-1+3) = NIREMP
      ZI(ISLVI-1+4) = -9999
      ZI(ISLVI-1+5) = -9999
      ZI(ISLVI-1+6) = -9999
      ZI(ISLVI-1+7) = -9999


C FIN ------------------------------------------------------
      CALL JEDEMA()
      END
