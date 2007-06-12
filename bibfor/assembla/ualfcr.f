      SUBROUTINE UALFCR(MATAZ,BASZ)
      IMPLICIT NONE
      CHARACTER*(*) MATAZ,BASZ
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ASSEMBLA  DATE 28/02/2006   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     CREATION DE L'OBJET MATAZ.UALF POUR CONTENIR LA FACTORISEE LDLT
C     DE LA MATRICE MATAZ
C     RQ : CETTE ROUTINE CREE (SI NECESSAIRE) LE STOCKAGE MORSE DE MATAZ
C     ------------------------------------------------------------------
C IN  JXVAR K19 MATAZ     : NOM D'UNE S.D. MATR_ASSE
C IN        K1  BASZ      : BASE DE CREATION POUR .UALF
C                  SI BASZ=' ' ON PREND LA MEME BASE QUE CELLE DE .VALM
C     ------------------------------------------------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32,JEXNUM
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)

C-----------------------------------------------------------------------
C     VARIABLES LOCALES
      CHARACTER*1  BASE,KBID,TYRC,BASTO
      CHARACTER*14 NU
      CHARACTER*19 STOMOR,STOLCI,MATAS
      INTEGER JSCDE,NEQ,NBLOC,IBID,NBLOCM
      INTEGER JSMHC, JSMDI, JSCDI, JSCHC
      INTEGER ITBLOC,IEQ,IBLOC,JUALF,JVALE,KTERM,NBTERM,ILIG
      INTEGER ISMDI,ISMDI0,IBLOAV,ISCDI,JREFA,JSCIB,KBLOCM,IRET
      REAL*8  RTBLOC,JEVTBL
C     ------------------------------------------------------------------



      CALL JEMARQ()
      MATAS=MATAZ
      BASE=BASZ
      IF (BASE.EQ.' ') CALL JELIRA(MATAS//'.VALM','CLAS',IBID,BASE)

C     -- ON DETRUIT .UALF S'IL EXISTE DEJA :
      CALL JEDETR(MATAS//'.UALF')

      CALL JEVEUO(MATAS//'.REFA','L',JREFA)
      NU=ZK24(JREFA-1+2)(1:14)
      STOMOR=NU//'.SMOS'
      STOLCI=NU//'.SLCS'

C     -- SI LE STOCKAGE STOLCI N'EST PAS ENCORE CREE, ON LE FAIT :
      CALL JEEXIN(STOLCI//'.SCDE',IRET)
      IF (IRET.EQ.0) THEN
         CALL JELIRA(STOMOR//'.SMDI','CLAS',IBID,BASTO)
         RTBLOC=JEVTBL()
         CALL SMOSLI(STOMOR,STOLCI,BASTO,RTBLOC)
      ENDIF

      CALL JEVEUO(STOMOR//'.SMDI','L',JSMDI)
      CALL JEVEUO(STOMOR//'.SMHC','L',JSMHC)

      CALL JEVEUO(STOLCI//'.SCDE','L',JSCDE)
      CALL JEVEUO(STOLCI//'.SCDI','L',JSCDI)
      CALL JEVEUO(STOLCI//'.SCHC','L',JSCHC)
      CALL JEVEUO(STOLCI//'.SCIB','L',JSCIB)
      NEQ=ZI(JSCDE-1+1)
      ITBLOC= ZI(JSCDE-1+2)
      NBLOC= ZI(JSCDE-1+3)

      CALL JELIRA(MATAS//'.VALM','NMAXOC',NBLOCM,KBID)
      CALL ASSERT(NBLOCM.EQ.1 .OR. NBLOCM.EQ.2)

C     -- REEL OU COMPLEXE ?
      CALL JELIRA(MATAS//'.VALM','TYPE',IBID,TYRC)
      CALL ASSERT(TYRC.EQ.'R' .OR. TYRC.EQ.'C')


C     1. ALLOCATION DE .UALF :
C     ----------------------------------------
      CALL JECREC(MATAS//'.UALF', BASE//' V '//TYRC,'NU','DISPERSE',
     &            'CONSTANT',NBLOCM*NBLOC)
      CALL JEECRA(MATAS//'.UALF','LONMAX',ITBLOC,KBID)
      DO 3,IBLOC=1,NBLOCM*NBLOC
         CALL JECROC(JEXNUM(MATAS//'.UALF',IBLOC))
3     CONTINUE



C     2. REMPLISSAGE DE .UALF :
C     ----------------------------------------
      DO 10, KBLOCM=1,NBLOCM
        CALL JEVEUO(JEXNUM(MATAS//'.VALM',KBLOCM),'L',JVALE)
        IBLOAV=0+NBLOC*(KBLOCM-1)
        ISMDI0=0
        DO 1, IEQ=1,NEQ
           ISCDI=ZI(JSCDI-1+IEQ)
           IBLOC=ZI(JSCIB-1+IEQ)+NBLOC*(KBLOCM-1)

C          -- ON RAMENE LE BLOC EN MEMOIRE SI NECESSAIRE:
           IF (IBLOC.NE.IBLOAV) THEN
              CALL JEVEUO(JEXNUM(MATAS//'.UALF',IBLOC),'E',JUALF)
              IF (IBLOAV.NE.0) THEN
                   CALL JELIBE(JEXNUM(MATAS//'.UALF',IBLOAV))
              ENDIF
              IBLOAV=IBLOC
           ENDIF

           ISMDI=ZI(JSMDI-1+IEQ)
           NBTERM=ISMDI-ISMDI0

           DO 2, KTERM=1,NBTERM
              ILIG=ZI(JSMHC-1+ISMDI0+KTERM)
              IF (TYRC.EQ.'R') THEN
                ZR(JUALF-1+ ISCDI +ILIG-IEQ)=ZR(JVALE-1+ISMDI0+KTERM)
              ELSE
                ZC(JUALF-1+ ISCDI +ILIG-IEQ)=ZC(JVALE-1+ISMDI0+KTERM)
              ENDIF
2          CONTINUE
           CALL ASSERT(ILIG.EQ.IEQ)

           ISMDI0=ISMDI
1       CONTINUE
10    CONTINUE


      CALL JEDEMA()
      END
