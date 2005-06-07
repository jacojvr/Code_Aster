      SUBROUTINE ORIENT(MDGENE,SST,JCOOR,INO,COORDO,ITRAN)
      IMPLICIT REAL*8 (A-H,O-Z)
C ----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 14/01/98   AUTEUR VABHHTS J.PELLET 
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
C
C     BUT: CALCUL DES COORDONNEES D'UN NOEUD D'UNE SOUS-STRUCTURE
C          DANS LE REPERE PHYSIQUE
C
C IN  : MDGENE : NOM UTILISATEUR DU MODELE GENERALISE
C IN  : SST    : NOM DE LA SOUS-STRUCTURE
C IN  : JCOOR  : ADRESSE JEVEUX DU .COORDO.VALE DU MAILLAGE DE SST
C IN  : INO    : DECALAGE DONNANT L'ADRESSE JEVEUX DU NOEUD
C OUT : COORDO : COORDONNEES DU NOEUD DANS LE REPERE PHYSIQUE
C IN  : ITRAN  : ENTIER = 1 : PRISE EN COMPTE DE LA TRANSLATION
C                       = 0 : NON PRISE EN COMPTE DE LA TRANSLATION
C
C ----------------------------------------------------------------------
C
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
C
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
C
      CHARACTER*32  JEXNUM,JEXNOM
C
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      PARAMETER   (NBCMPM=10)
      CHARACTER*8  SST
      CHARACTER*24 MDGENE
      INTEGER      JCOOR,INO
      REAL*8       MATROT(NBCMPM,NBCMPM),XANC(3),XNEW,COORDO(3),R8BID
      REAL*8       MATBUF(NBCMPM,NBCMPM),MATTMP(NBCMPM,NBCMPM)
C
C     ------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL JENONU(JEXNOM(MDGENE(1:14)//'.MODG.SSNO',SST),IBID)
      CALL JEVEUO(JEXNUM(MDGENE(1:14)//'.MODG.SSOR',IBID),'L',LLROT)
      CALL JEVEUO(JEXNUM(MDGENE(1:14)//'.MODG.SSTR',IBID),'L',LLTRA)
C
      CALL INTET0(ZR(LLROT),MATTMP,3)
      CALL INTET0(ZR(LLROT+1),MATROT,2)
      R8BID = 0.D0
      CALL R8INIR(NBCMPM*NBCMPM,R8BID,MATBUF,1)
      CALL PMPPR(MATTMP,NBCMPM,NBCMPM,1,MATROT,NBCMPM,NBCMPM,1,
     &                                  MATBUF,NBCMPM,NBCMPM)
      R8BID = 0.D0
      CALL R8INIR(NBCMPM*NBCMPM,R8BID,MATROT,1)
      CALL INTET0(ZR(LLROT+2),MATTMP,1)
      CALL PMPPR(MATBUF,NBCMPM,NBCMPM,1,MATTMP,NBCMPM,NBCMPM,1,
     &                                  MATROT,NBCMPM,NBCMPM)
C
      DO 10 K=1,3
        XANC(K)=ZR(JCOOR+(INO-1)*3+K-1)
10    CONTINUE
C
      DO 20 K=1,3
        XNEW=0.D0
        DO 30 L=1,3
          XNEW=XNEW+MATROT(K,L)*XANC(L)
30      CONTINUE
        IF (ITRAN.EQ.1) THEN
          COORDO(K)=XNEW+ZR(LLTRA+K-1)
        ELSEIF (ITRAN.EQ.0) THEN
          COORDO(K)=XNEW
        ELSE
          CALL UTMESS('F','ORIENT','ERREUR : ITRAN = 0 OU 1')
        ENDIF
20    CONTINUE
C
      CALL JEDEMA()
      END
