      SUBROUTINE VEBUME(MODELZ,DEPLAZ,LISCHA,VECELZ)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 19/12/2007   AUTEUR ABBAS M.ABBAS 
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
C RESPONSABLE MABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*(*) MODELZ,DEPLAZ,VECELZ
      CHARACTER*19  LISCHA
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (CALCUL)
C
C CALCUL DES VECTEURS ELEMENTAIRES B.U - ELEMENTS DE LAGRANGE
C      
C ----------------------------------------------------------------------
C
C      
C IN  MODELE : NOM DU MODELE
C IN  DEPLA  : CHAMP DE DEPLACEMENTS
C IN  LISCHA : SD L_CHARGES
C OUT VECELE : VECTEURS ELEMENTAIRES     
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
      INTEGER            ZI
      COMMON  / IVARJE / ZI(1)
      REAL*8             ZR
      COMMON  / RVARJE / ZR(1)
      COMPLEX*16         ZC
      COMMON  / CVARJE / ZC(1)
      LOGICAL            ZL
      COMMON  / LVARJE / ZL(1)
      CHARACTER*8        ZK8
      CHARACTER*16                ZK16
      CHARACTER*24                          ZK24
      CHARACTER*32                                    ZK32
      CHARACTER*80                                              ZK80
      COMMON  / KVARJE / ZK8(1) , ZK16(1) , ZK24(1) , ZK32(1) , ZK80(1)
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C 
      INTEGER      NBOUT,NBIN
      PARAMETER    (NBOUT=1, NBIN=2)
      CHARACTER*8  LPAOUT(NBOUT),LPAIN(NBIN)
      CHARACTER*19 LCHOUT(NBOUT),LCHIN(NBIN)
C
      CHARACTER*8  NOMCHA,K8BID,MASQUE
      CHARACTER*16 OPTION
      CHARACTER*24 LIGRCH
      INTEGER      IRET,NCHAR,NDIR,ICHA,IBID
      INTEGER      JLVE ,JCHAR,JINF      
      CHARACTER*8  MODELE,VECELE
      CHARACTER*19 DEPLA       
      INTEGER      IFMDBG,NIVDBG                                        
      LOGICAL      DEBUG
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()  
      CALL INFDBG('PRE_CALCUL',IFMDBG,NIVDBG)        
C
C --- INITIALISATIONS
C
      MASQUE = '.0000000'
      VECELE = VECELZ
      MODELE = MODELZ
      DEPLA  = DEPLAZ
      OPTION = 'MECA_BU_R'
      IF (NIVDBG.GE.2) THEN
        DEBUG  = .TRUE.
      ELSE
        DEBUG  = .FALSE.
      ENDIF
C
C --- INITIALISATION DES CHAMPS POUR CALCUL
C
      CALL INICAL(NBIN  ,LPAIN ,LCHIN ,
     &            NBOUT ,LPAOUT,LCHOUT) 
C
C --- ACCES AUX CHARGES
C           
      CALL JEEXIN(LISCHA(1:19)//'.LCHA',IRET)
      IF ( IRET .EQ. 0 ) GOTO 9999
      CALL JELIRA(LISCHA(1:19)//'.LCHA','LONMAX',NCHAR,K8BID)
      CALL JEVEUO(LISCHA(1:19)//'.LCHA','L',JCHAR)
      CALL JEVEUO(LISCHA(1:19)//'.INFC','L',JINF)
C
C --- ALLOCATION DU VECT_ELEM RESULTAT :
C
      CALL DETRSD('VECT_ELEM',VECELE)
      CALL MEMARE('V',VECELE,MODELE(1:8),' ',' ','CHAR_MECA')
      CALL WKVECT(VECELE(1:8)//'.LISTE_RESU','V V K24',NCHAR,JLVE)
      CALL JEECRA(VECELE(1:8)//'.LISTE_RESU','LONUTI',0,K8BID)
C
C --- CALCUL DE L'OPTION B.U
C 
      NDIR = 0
      DO 10 ICHA = 1,NCHAR
        IF (ZI(JINF+ICHA).LE.0) GO TO 10
        NOMCHA = ZK24(JCHAR+ICHA-1) (1:8)
        LIGRCH = NOMCHA//'.CHME.LIGRE'
        CALL JEEXIN(NOMCHA//'.CHME.LIGRE.LIEL',IRET)
        IF (IRET.LE.0) GO TO 10
        CALL EXISD('CHAMP_GD',NOMCHA//'.CHME.CMULT',IRET)
        IF (IRET.LE.0) GO TO 10

        LPAIN(1)  = 'PDDLMUR'
        LCHIN(1)  = NOMCHA(1:8)//'.CHME.CMULT'
        LPAIN(2)  = 'PDDLIMR'
        LCHIN(2)  = DEPLA
        LPAOUT(1) = 'PVECTUR'
        LCHOUT(1) = '&&VEBUME.???????'
        CALL GCNCO2(MASQUE)
        LCHOUT(1)(10:16) = MASQUE(2:8)
        CALL CORICH('E',LCHOUT(1),ICHA,IBID)
C          
        CALL CALCUL('S',OPTION,LIGRCH,NBIN ,LCHIN ,LPAIN ,
     &                                NBOUT,LCHOUT,LPAOUT,'V')
C
        IF (DEBUG) THEN
          CALL DBGCAL(OPTION,IFMDBG,
     &                NBIN  ,LPAIN ,LCHIN ,
     &                NBOUT ,LPAOUT,LCHOUT)
        ENDIF   
C     
        NDIR = NDIR + 1        
        ZK24(JLVE-1+NDIR) = LCHOUT(1)
   10 CONTINUE
C   
      CALL JEECRA(VECELE(1:8)//'.LISTE_RESU','LONUTI',NDIR,K8BID)

 9999 CONTINUE

      CALL JEDEMA()
      END
