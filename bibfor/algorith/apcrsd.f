      SUBROUTINE APCRSD(SDAPPA,NBZONE,NTPT  ,NTMA  ,NTNO  ,
     &                  NTMANO,NBNO  )
C     
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 17/10/2011   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT     NONE
      CHARACTER*19 SDAPPA
      INTEGER      NBZONE,NTPT,NTMA,NTMANO,NTNO,NBNO
C      
C ----------------------------------------------------------------------
C
C ROUTINE APPARIEMENT 
C
C CREATION DE LA SD
C
C ----------------------------------------------------------------------
C
C
C IN  SDAPPA : NOM DE LA SD APPARIEMENT
C IN  NBZONE : NOMBRE DE ZONES
C IN  NTPT   : NOMBRE TOTAL DE POINT A APPARIER
C IN  NTMA   : NOMBRE TOTAL DE MAILLES
C IN  NTNO   : NOMBRE TOTAL DE NOEUDS
C IN  NTMANO : NOMBRE TOTAL DE NOEUD AUX ELEMENTS (ELNO)
C IN  NBNO   : NOMBRE DE NOEUD TOTAL DU MAILLAGE
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
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
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER      IFM,NIV
      CHARACTER*24 NOMSD,APPAR
      INTEGER      JNOMSD,JAPPA
      CHARACTER*24 APINZI,APINZR
      INTEGER      JPINZI,JPINZR
      CHARACTER*24 APINFI,APINFR
      INTEGER      JPINFI,JPINFR
      CHARACTER*24 APPOIN,APINFP
      INTEGER      JPOIN,JINFP
      CHARACTER*24 APNOMS
      INTEGER      JPNOMS
      CHARACTER*24 APDIST,APTAU1,APTAU2,APPROJ
      INTEGER      JDIST,JTAU1,JTAU2,JPROJ
      CHARACTER*24 APTGNO,APTGEL
      INTEGER      JPTGNO
      CHARACTER*24 APVERK,APVERA
      INTEGER      JLISTN,JLISTA
      CHARACTER*8  K8BID
      INTEGER      APMMVD,ZINZR,ZINZI,ZINFI,ZINFR
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
      CALL INFDBG('APPARIEMENT',IFM,NIV)
C
C --- AFFICHAGE
C
      IF (NIV.GE.2) THEN
        WRITE (IFM,*) '<APPARIEMENT> CREATION DE LA SD APPARIEMENT' 
      ENDIF
C
C --- LONGUEURS DES SDAPPA
C
      ZINZR  = APMMVD('ZINZR')
      ZINZI  = APMMVD('ZINZI')
      ZINFR  = APMMVD('ZINFR')
      ZINFI  = APMMVD('ZINFI')
C
C --- CREATION SD NOMS
C
      NOMSD  = SDAPPA(1:19)//'.NOSD'        
      CALL WKVECT(NOMSD ,'V V K24',3     ,JNOMSD)
C
C --- CREATION SD APPARIEMENT 
C 
      APPAR  = SDAPPA(1:19)//'.APPA'
      CALL WKVECT(APPAR ,'V V I',4*NTPT,JAPPA)      
C
C --- CREATION SD POUR DISTANCE ET TANGENTES
C      
      APDIST = SDAPPA(1:19)//'.DIST'
      APTAU1 = SDAPPA(1:19)//'.TAU1'
      APTAU2 = SDAPPA(1:19)//'.TAU2'
      CALL WKVECT(APDIST,'V V R',4*NTPT  ,JDIST)
      CALL WKVECT(APTAU1,'V V R',3*NTPT  ,JTAU1)
      CALL WKVECT(APTAU2,'V V R',3*NTPT  ,JTAU2)
C
C --- CREATION SD COORDONNEES DE LA PROJECTION
C
      APPROJ = SDAPPA(1:19)//'.PROJ'   
      CALL WKVECT(APPROJ,'V V R',2*NTPT  ,JPROJ)
C
C --- CREATION SD COORDONNEES DES POINTS
C
      APPOIN = SDAPPA(1:19)//'.POIN'
      CALL WKVECT(APPOIN,'V V R',3*NTPT  ,JPOIN)
C
C --- CREATION SD INFOS DES POINTS
C
      APINFP = SDAPPA(1:19)//'.INFP'
      CALL WKVECT(APINFP,'V V I',NTPT    ,JINFP)      
C
C --- CREATION SD INFORMATIONS GLOBALES
C
      APINFI = SDAPPA(1:19)//'.INFI'
      CALL WKVECT(APINFI,'V V I',ZINFI,JPINFI)
      APINFR = SDAPPA(1:19)//'.INFR'
      CALL WKVECT(APINFR,'V V R',ZINFR,JPINFR)
C
C --- CREATION SD INFORMATIONS PAR ZONE
C
      APINZI = SDAPPA(1:19)//'.INZI'
      CALL WKVECT(APINZI,'V V I',ZINZI*NBZONE,JPINZI)
      APINZR = SDAPPA(1:19)//'.INZR'
      CALL WKVECT(APINZR,'V V R',ZINZR*NBZONE ,JPINZR)     
C
C --- CREATION SD NOMS DES POINTS DE CONTACT      
C
      APNOMS = SDAPPA(1:19)//'.NOMS'
      CALL WKVECT(APNOMS,'V V K16',NTPT  ,JPNOMS)
C
C --- CREATION SD TANGENTES EN TOUS LES NOEUDS      
C           
      APTGNO = SDAPPA(1:19)//'.TGNO'
      CALL WKVECT(APTGNO,'V V R',6*NTNO ,JPTGNO)
C
C --- CREATION SD TANGENTES AUX NOEUDS PAR ELEMENT
C        
      APTGEL = SDAPPA(1:19)//'.TGEL'
      CALL JECREC(APTGEL,'V V R','NU','CONTIG','VARIABLE',NTMA)
      CALL JEECRA(APTGEL,'LONT',6*NTMANO,K8BID)
C
C --- CREATION SD VERIFICATION FACETTISATION
C
      APVERK = SDAPPA(1:19)//'.VERK'
      APVERA = SDAPPA(1:19)//'.VERA'
      CALL WKVECT(APVERK,'V V K8',NBNO,JLISTN)
      CALL WKVECT(APVERA,'V V R',NBNO,JLISTA)
      CALL JEECRA(APVERK,'LONUTI',0,K8BID)
C
      CALL JEDEMA()
C 
      END
