      SUBROUTINE W175AF (MODELE,CHFER1)
      IMPLICIT NONE
      CHARACTER*8  MODELE
      CHARACTER*19 CHFER1
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 11/10/2010   AUTEUR PELLET J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2010  EDF R&D                  WWW.CODE-ASTER.ORG
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
C ======================================================================
C BUT : CREER LE CHAMP DE DONNEES POUR CALC_FERRAILLAGE
C
C-----------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
      CHARACTER*32     JEXNOM, JEXNUM
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
      INTEGER       GD,IBID,NOCC,NCMPMX,NBTOU,IRET
      INTEGER       N1,N2,N3,N4,N5,N6
      INTEGER       JNCMP,JVALV,JMAIL,IOCC,NBMAIL
      REAL*8        VALR
      CHARACTER*8   K8B,  TYPMCL(2),NOMA,TYPCB
      CHARACTER*16  MOTCLS(2)
      CHARACTER*24  MESMAI
C     ------------------------------------------------------------------
      CALL JEMARQ()

      CALL DISMOI('F','NOM_MAILLA',MODELE,'MODELE',IBID,NOMA,IRET)
      CALL ASSERT(NOMA.NE.' ')

      CALL GETFAC ( 'AFFE', NOCC )

      MESMAI = '&&W175AF.MES_MAILLES'
      MOTCLS(1) = 'GROUP_MA'
      MOTCLS(2) = 'MAILLE'
      TYPMCL(1) = 'GROUP_MA'
      TYPMCL(2) = 'MAILLE'

C     1- ALLOCATION DU CHAMP CHFER1 (CARTE)
C     --------------------------------------------
      CALL ALCART ( 'V', CHFER1, NOMA, 'FER1_R' )
      CALL JEVEUO ( CHFER1//'.NCMP', 'E', JNCMP )
      CALL JEVEUO ( CHFER1//'.VALV', 'E', JVALV )

      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','FER1_R'),GD)
      CALL JELIRA(JEXNUM('&CATA.GD.NOMCMP',GD),'LONMAX',NCMPMX,K8B)

      CALL ASSERT(NCMPMX.EQ.7)
      ZK8(JNCMP-1+1)='TYPCOMB'
      ZK8(JNCMP-1+2)='ENROBG'
      ZK8(JNCMP-1+3)='CEQUI'
      ZK8(JNCMP-1+4)='SIGACI'
      ZK8(JNCMP-1+5)='SIGBET'
      ZK8(JNCMP-1+6)='PIVA'
      ZK8(JNCMP-1+7)='PIVB'


C     2. MOTS CLES GLOBAUX :
C     ----------------------
C     2.1 TYPE_COMB :
      CALL GETVTX (' ','TYPE_COMB',0,1,1,TYPCB,N1)
      CALL ASSERT(TYPCB.EQ.'ELU'.OR.TYPCB.EQ.'ELS')
      IF (TYPCB.EQ.'ELU') VALR=0.D0
      IF (TYPCB.EQ.'ELS') VALR=1.D0
      ZR(JVALV-1+1)=VALR


C     3- BOUCLE SUR LES OCCURENCES DU MOT CLE AFFE
C     --------------------------------------------
      DO 30 IOCC = 1,NOCC

        CALL GETVR8('AFFE','ENROBG',    IOCC,1,1,ZR(JVALV-1+2),N1)
        CALL GETVR8('AFFE','CEQUI',     IOCC,1,1,ZR(JVALV-1+3),N2)
        CALL GETVR8('AFFE','SIGM_ACIER',IOCC,1,1,ZR(JVALV-1+4),N3)
        CALL GETVR8('AFFE','SIGM_BETON',IOCC,1,1,ZR(JVALV-1+5),N4)
        CALL GETVR8('AFFE','PIVA',      IOCC,1,1,ZR(JVALV-1+6),N5)
        CALL GETVR8('AFFE','PIVB',      IOCC,1,1,ZR(JVALV-1+7),N6)

        IF (TYPCB.EQ.'ELU') THEN
          IF (N5.EQ.0.OR.N6.EQ.0) CALL U2MESS('F','CALCULEL_73')
        ELSE
          IF (N2.EQ.0) CALL U2MESS('F','CALCULEL_73')
        ENDIF

        CALL GETVTX ( 'AFFE', 'TOUT', IOCC, 1, 1, K8B, NBTOU )
        IF ( NBTOU .NE. 0 ) THEN
          CALL NOCART(CHFER1,1,' ','NOM',0,' ',0,' ',NCMPMX)

        ELSE
           CALL RELIEM(' ', NOMA, 'NU_MAILLE', 'AFFE', IOCC, 2,
     &                                 MOTCLS, TYPMCL, MESMAI, NBMAIL )
           CALL JEVEUO ( MESMAI, 'L', JMAIL )
           CALL NOCART(CHFER1,3,' ','NUM',NBMAIL,K8B,ZI(JMAIL),
     &                 ' ',NCMPMX)
           CALL JEDETR ( MESMAI )
        ENDIF
   30 CONTINUE

      CALL TECART(CHFER1)
      CALL JEDETR(CHFER1//'.NCMP')
      CALL JEDETR(CHFER1//'.VALV')

   40 CONTINUE
      CALL JEDEMA()
      END
