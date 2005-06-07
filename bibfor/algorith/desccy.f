      SUBROUTINE DESCCY(NOMRES)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/02/96   AUTEUR VABHHTS J.PELLET 
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
C***********************************************************************
C    P. RICHARD     DATE 07/03/91
C-----------------------------------------------------------------------
C  BUT:  CREATION DE LA NUMEROTATION GENERALISEE POUR LE PROBLEME
      IMPLICIT REAL*8 (A-H,O-Z)
C        CYCLIQUE
C-----------------------------------------------------------------------
C
C NOMRES   /I/: NOM UTILISATEUR DU RESULTAT
C BASMOD   /I/: NOM UTILISATEUR DE L'EVENTUELLE BASE MODALE (OU BLANC)
C RESCYC   /I/: NOM UTILISATEUR EVENTUEL CONCEPT MODE CYCLIQUE(OU BLANC)
C NUMCYC   /O/: NOM K24 DE LA NUMEROTATION RESULTAT
C
C-----------------------------------------------------------------------
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
      CHARACTER*16              ZK16
      CHARACTER*24                        ZK24
      CHARACTER*32                                  ZK32
      CHARACTER*80                                            ZK80
      COMMON  /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
      CHARACTER*32 JEXNUM
C
C----------  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      CHARACTER*6  PGC
      CHARACTER*8  INTF,KBID,BASMOD,NOMRES
      CHARACTER*24 NOEINT
      CHARACTER*1 K1BID
C
C-----------------------------------------------------------------------
      DATA PGC /'DESCCY'/
      CALL JEMARQ()
      KBID=' '
C-----------------------------------------------------------------------
C
C------------------RECUPERATION CONCEPT AMONT---------------------------
C
      CALL JEVEUO(NOMRES//'      .CYCL.REFE','L',LLREF)
      INTF=ZK24(LLREF+1)
      BASMOD=ZK24(LLREF+2)
C
C-----RECUPERATION NUMEROS INTERFACES DROITE GAUCHE ET AXE--------------
C
      CALL JEVEUO(NOMRES//'      .CYCL.NUIN','L',LDDNIN)
      NUMD=ZI(LDDNIN)
      NUMG=ZI(LDDNIN+1)
      NUMA=ZI(LDDNIN+2)
C
C----------RECUPERATION DU DESCRIPTEUR DES DEFORMEES STATIQUES----------
C
      CALL JEVEUO(INTF//'      .INTD.DEFO','L',LLDESC)
      CALL JELIRA(INTF//'      .INTD.DEFO','LONMAX',NBNOT,K1BID)
      NBNOT=NBNOT/3
C
C--------RECUPERATION DES DEFINITIONS DES INTERFACES DROITE ET GAUCHE---
C
      NOEINT=INTF//'      .INTD.LINO'
C
      CALL JEVEUO(JEXNUM(NOEINT,NUMD),'L',LDNOED)
      CALL JELIRA(JEXNUM(NOEINT,NUMD),'LONMAX',NBD,K1BID)
C
      CALL JEVEUO(JEXNUM(NOEINT,NUMG),'L',LDNOEG)
      CALL JELIRA(JEXNUM(NOEINT,NUMG),'LONMAX',NBG,K1BID)
C
      IF(NUMA.GT.0) THEN
        CALL JEVEUO(JEXNUM(NOEINT,NUMA),'L',LDNOEA)
        CALL JELIRA(JEXNUM(NOEINT,NUMA),'LONMAX',NBA,K1BID)
      ENDIF
C
      IF(NBG.NE.NBD) THEN
        CALL UTDEBM('F',PGC,
     &'LES DEUX INTERFACES ONT PAS MEME NOMBRE DE NOEUDS')
        CALL UTIMPI('L','NOMBRE NOEUDS INTERFACE DROITE --> ',1,NBD)
        CALL UTIMPI('L','NOMBRE NOEUDS INTERFACE GAUCHE --> ',1,NBG)
        CALL UTFINM
      ENDIF
C
C------COMPTAGE DEFORMEES STATIQUES INTERFACE DROITE GAUCHE-------------
C
      CALL BMNODI(BASMOD,KBID,'        ',NUMD,0,IBID,NBDD)
      KBID=' '
      CALL BMNODI(BASMOD,KBID,'        ',NUMG,0,IBID,NBDG)
C
C--------------TEST SUR NOMBRE DE DDL AUX INTERFACES--------------------
C
      IF(NBDD.NE.NBDG) THEN
        CALL UTDEBM('F',PGC,
     &'LES DEUX INTERFACES ONT PAS MEME NOMBRE DE DEGRES DE LIBERTE')
        CALL UTIMPI('L','NOMBRE DDL INTERFACE DROITE --> ',1,NBDD)
        CALL UTIMPI('L','NOMBRE DDL INTERFACE GAUCHE --> ',1,NBDG)
        CALL UTFINM
      ENDIF
C
C-----COMPTAGE NOMBRE DEFORMEES STATIQUE SUR EVENTUELLE INTERFACE AXE---
C
      NBDA=0
      IF(NUMA.GT.0) THEN
        KBID=' '
        CALL BMNODI(BASMOD,KBID,'        ',NUMA,0,IBID,NBDA)
      ELSE
        NBDA=0
      ENDIF
C
C--------DETERMINATION DU NOMBRE DE MODES PROPRES DE LA BASE------------
C
C  NOMBRE DE MODES DEMANDES
C
      CALL GETVIS('   ','NB_MODE',1,1,1,NBMOD1,IBID)
C
C  NOMBRE DE MODES EXISTANTS
C
      CALL BMNBMD(BASMOD,'MODE',NBMOD2)
C
C  TEST
C
      IF(NBMOD2.EQ.0) THEN
        CALL UTDEBM('F',PGC,
     &'ARRET SUR BASE MODALE NE COMPORTANT PAS DE MODES PROPRES')
        CALL UTFINM
      ENDIF
      NBMOD=MIN(NBMOD1,NBMOD2)
C
C---------DETERMINATION DU NOMBRE DE MODES PROPRES A CALCULER-----------
C
      CALL GETVIS('CALCUL','NMAX_FREQ',1,1,0,IBID,NBOC)
C
      IF(NBOC.EQ.0) THEN
        NBMCAL=NBMOD
      ELSE
        CALL GETVIS('CALCUL','NMAX_FREQ',1,1,1,NBMCAL,IBID)
      ENDIF
C
      IF(NBMCAL.GT.NBMOD) THEN
        NBTEMP=NBMCAL-NBMOD
        CALL UTDEBM('A',PGC,'NOMBRE DE MODES PROPRES DEMANDE SUPERIEUR'
     &//' AU NOMBRE DE MODES DYNAMIQUES DE LA BASE')
        CALL UTIMPI('L','NOMBRE DE MODES DEMANDES -->',1,NBMCAL)
        CALL UTIMPI('L','NOMBRE DE MODES DE LA BASE -->',1,NBMOD)
        CALL UTIMPI('L','NOMBRE DE FREQUENCES DOUTEUSES -->',
     &1,NBTEMP)
        CALL UTFINM
      ENDIF
C
C----------------ALLOCATION DE L'OBJET .DESC----------------------------
C
      CALL WKVECT(NOMRES//'      .CYCL.DESC','G V I',4,LDNUMG)
C
C------------------CREATION DE LA NUMEROTATION--------------------------
C
      ZI(LDNUMG)=NBMOD
      ZI(LDNUMG+1)=NBDD
      ZI(LDNUMG+2)=NBDA
      ZI(LDNUMG+3)=NBMCAL
C
 9999 CONTINUE
      CALL JEDEMA()
      END
