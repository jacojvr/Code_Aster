      SUBROUTINE EXLIM2(SDFETI,NOMSD,LLIGRS,LIGRSD,NBCHA,NUMSD,NBSD,
     &                  INFOFE,NBPROC)
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 16/01/2006   AUTEUR BOITEAU O.BOITEAU 
C ======================================================================
C COPYRIGHT (C) 1991 - 2004  EDF R&D                  WWW.CODE-ASTER.ORG
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
C-----------------------------------------------------------------------
C IN  : SDFETI : NOM DE LA SD_FETI
C IN  : NOMSD  : NOM DU SOUS-DOMAINE
C IN/OUT: LLIGRS : NOM DU VECTEUR CONTENANT LA LISTE DES LIGRELS
C                ASSOCIES A NOMSD POUR CONSTITUER SON NUME_DDL
C IN  : LIGRSD : NOM DU LIGREL TEMPORAIRE EGALE A LA RESTRICTION DU SD
C                AU MODELE
C IN  : NUMSD  : NUMERO DE SOUS-DOMAINE
C OUT : NBCHA  : NOMBRE DE CHARGES ASSOCIEES A NOMSD
C IN  :  NBSD  : NOMBRE DE SOUS-DOMAINES
C IN  : NBPROC : NOMBRE DE PROCESSEURS
C-----------------------------------------------------------------------
C TOLE CRP_20
C RESPONSABLE BOITEAU O.BOITEAU
C CORPS DU PROGRAMME
      IMPLICIT NONE
      
C DECLARATION PARAMETRES D'APPELS
      INTEGER      NBCHA,NUMSD,NBSD,NBPROC
      CHARACTER*8  NOMSD
      CHARACTER*19 LIGRSD
      CHARACTER*24 SDFETI,LLIGRS,INFOFE
      
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
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
      CHARACTER*32       JEXNOM,        JEXNUM
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

C DECLARATION VARIABLES LOCALES      
      INTEGER      IRET,K,IFLII,NBMATA,NBMAT1,K1,IFLIM,NBGREL,I,IFEL1,
     &             NMGREL,IGREL,J,NUMGRE,NMGRE1,L,NUMGR1,LADR,IFM,NIV,
     &             IFLIN,LONT,NBNO,NBNEMA,INEMA,IBID,INBNO,M,NBMAT2,
     &             MADR,NADR,NBNOET,IFEL2,IFEL3,NBMAS,IDECA,IFEL3O,
     &             IVLIGR,IDD,IRET1,NBCHA2,NBMAS2,NBNO2,IFETB,
     &             LOFETB,LOFEL4,IFEL4,IFEL5,IAUX1,IAUX4,LOFEL5,IDIME,
     &             IFETI,NBDDLI,NBNOI,IAUXZI,IMULT,NBNOE2,LOFEL6,LOFEL7
      CHARACTER*2  K2BID
      CHARACTER*3  K3BID
      CHARACTER*8  K8BID,NOMSD2
      CHARACTER*19 LIGRCH
      CHARACTER*24 K24B,K24DUL,K24CHL,K24DUN,K24CHN,K24CF1,K24CF2,
     &             K24CF3,NOMSDA,K24CF4,K24CF5
      
      CALL JEMARQ()
C RECUPERATION ET MAJ DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)
      K24B=SDFETI(1:19)//'.FLIN'
      CALL JEEXIN(JEXNOM(K24B,NOMSD),IRET)
      IF (IRET.NE.0) THEN
C SOUS-DOMAINE CONCERNE PAR DES LIGRELS TARDIFS DE CHARGE 
C C'EST A DIRE COMPORTANT DES MAILLES TARDIVES (A NOEUDS TARDIFS OU PAS)
C A NOEUDS TARDIFS:    DDL_IMPO/FACE_IMPO/LIAISON_DDL/OBLIQUE....
C SANS NOEUD TARDIF: FORCE_NODALE     
        CALL JEVEUO(JEXNOM(K24B,NOMSD),'L',IFLIN)
        CALL JELIRA(JEXNOM(K24B,NOMSD),'LONMAX',NBCHA,K8BID)    
        CALL JEVEUO(JEXNOM(K24B(1:23)//'I',NOMSD),'L',IFLII)
        CALL JEVEUO(JEXNOM(K24B(1:23)//'M',NOMSD),'L',IFLIM)    
      ELSE
        NBCHA=0
      ENDIF
      CALL WKVECT(LLIGRS,'V V K24',NBCHA+1,IVLIGR)
      ZK24(IVLIGR)='                        '
      ZK24(IVLIGR)=LIGRSD

C-------------
C PRETRAITEMENT POUR DIMENSIONNER D'EVENTUELS VECTEURS AXILIAIRES .FEL4
C ET .FEL5
C OB D
      IF (NBCHA.NE.0) THEN
        CALL JEVEUO(JEXNOM(SDFETI(1:19)//'.FETB',NOMSD),'L',IFETB)
        CALL JELIRA(JEXNOM(SDFETI(1:19)//'.FETB',NOMSD),'LONMAX',LOFETB,
     &            K8BID)
        LOFETB=LOFETB-1
        IMULT=2
C RECHERCHE DE LA MULTIPLICITE MAXIMALE (IMULT) DES NOEUDS D'INTERFACE
        CALL JEVEUO(SDFETI(1:19)//'.FETI','L',IFETI)
        CALL JEVEUO(SDFETI(1:19)//'.FDIM','L',IDIME)
        NBNOI=ZI(IDIME+1)-1
        NBDDLI=ZI(IDIME+3)
        DO 305 I=0,LOFETB
          IAUXZI=-ZI(IFETB+I)
          IF (IAUXZI.GT.0) THEN
            DO 300 K=0,NBNOI
              IF (ZI(IFETI+4*K).EQ.IAUXZI) THEN
                IF (ZI(IFETI+4*K+1).GT.IMULT) IMULT=ZI(IFETI+4*K+1)
              ENDIF
  300       CONTINUE
          ENDIF
  305   CONTINUE

        LOFEL6 = 3*IMULT*NBDDLI/(NBNOI+1)
C ON DIMENSIONNE .FEL5 EN TENANT COMPTE DE DEUX LAGRANGES PAR DDLS BLO
C CABLES
        LOFEL7=LOFEL6*2
      ENDIF
C OB F
C-------------

         
C BOUCLE SUR LES CHARGES LIEES AU SOUS-DOMAINE
      IDECA=0             
      DO 100 K=1,NBCHA
        CALL JEMARQ()
        K1=K-1
        NBMATA=ZI(IFLII+2*K1)
        NBMAT1=ZI(IFLII+2*K1+1)
                
        IF (NBMATA.NE.NBMAT1) THEN
C-----------------------------------------------------------------------
C  ON DUPLIQUE LA CHARGE
C-----------------------------------------------------------------------
C OBJET JEVEUX .LIEL DE LA CHARGE A DISSOCIER
          LIGRCH=ZK24(IFLIN+K1)(1:19)     
          K24CHL=LIGRCH//'.LIEL'
                
C LIGREL DE CHARGE PARTAGE ENTRE PLUSIEURS SOUS-DOMAINES, ON VA LE
C DUPLIQUER. SON NOUVEAU NOM TEMPORAIRE DU LIGREL DUPLIQUE EST
C 'F'//GNCON(2:8)//LIGRCH(9:19)
          CALL GCNCON('.',K8BID)
          K8BID(1:1)='F'
          K24DUL=K8BID//K24CHL(9:24)
          
C ON VA STOCKER LE NOM DU NOUVEAU LIGREL DANS LE .FEL1 SI IL EXISTE
C SINON ON LE CREER
C OB D
          K24CF1=K24CHL(1:19)//'.FEL1'
C           K24CF1=K24CHL(1:19)//'.FETL'
C OB F
          CALL JEEXIN(K24CF1,IRET)
          IF (IRET.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL1
            CALL WKVECT(K24CF1,'V V K24',NBSD,IFEL1)
            DO 200 I=1,NBSD
              ZK24(IFEL1+I-1)=' '
 200        CONTINUE              
          ELSE
            CALL JEVEUO(K24CF1,'E',IFEL1)
          ENDIF
          ZK24(IFEL1+NUMSD-1)=K24DUL(1:19)
          
C ON DUPLIQUE LES ELEMENTS DU .LIEL ET DU .NEMA           
          CALL JECREC(K24DUL,'V V I','NU','CONTIG','VARIABLE',NBMAT1)
          LONT=2*NBMAT1
          CALL JEECRA(K24DUL,'LONT',LONT,' ')
          
          K24DUN=K24DUL(1:19)//'.NEMA'
          K24CHN=K24CHL(1:19)//'.NEMA'
          CALL JELIRA(K24CHN,'NUTIOC',NBMAS,K8BID)        
          CALL JECREC(K24DUN,'V V I','NU','CONTIG','VARIABLE',NBMAT1)
          CALL JELIRA(K24CHN,'LONT',LONT,K8BID)
          CALL JEECRA(K24DUN,'LONT',LONT,' ')
          CALL JEVEUO(K24CHL(1:19)//'.NBNO','L',INBNO)
          NBNO=ZI(INBNO)
C POUR DIMENSIONNER LES .FEL4 ET .FEL5
          NBNOE2=MAX(NBNO,NBMAS)
          LOFEL4=NBNOE2*LOFEL6
          LOFEL5=NBNOE2*LOFEL7

C ON VA STOCKER LES ANCIENS NUMEROS DE MAILLES TARDIVES DANS LE .FEL2
C ET LES ANCIENS NUMEROS DE NOEUDS TARDIFS DANS LE .FEL3
C SI IL EXISTE, SINON ON LE CREER.
          K24CF2=K24CHL(1:19)//'.FEL2'
          CALL JEEXIN(K24CF2,IRET)
          IF (IRET.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL2
            NBMAS2=2*NBMAS
            CALL WKVECT(K24CF2,'V V I',NBMAS2,IFEL2)
            DO 201 I=1,NBMAS2
              ZI(IFEL2+I-1)=0
  201       CONTINUE             
          ELSE
            CALL JEVEUO(K24CF2,'E',IFEL2)
          ENDIF
C SI SEULEMENT MAILLE TARDIVE SANS NOEUD TARDIF, PAS BESOIN DE .FEL3
          IF (NBNO.GT.0) THEN
            K24CF3=K24CHL(1:19)//'.FEL3'
            CALL JEEXIN(K24CF3,IRET)
            IF (IRET.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL3
              NBNO2=2*NBNO
              CALL WKVECT(K24CF3,'V V I',NBNO2,IFEL3)
              DO 202 I=1,NBNO2
                ZI(IFEL3+I-1)=0
  202         CONTINUE      
            ELSE
              CALL JEVEUO(K24CF3,'E',IFEL3)
            ENDIF
          ENDIF
          K24CF4=K24CHL(1:19)//'.FEL4'
          CALL JEEXIN(K24CF4,IRET)
          IF (IRET.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL4
            CALL WKVECT(K24CF4,'V V I',LOFEL4,IFEL4)
            ZI(IFEL4)=0
          ELSE
            CALL JEVEUO(K24CF4,'E',IFEL4)
          ENDIF
C SI SEULEMENT MAILLE TARDIVE SANS NOEUD TARDIF, PAS BESOIN DE .FEL5
          IF (NBNO.GT.0) THEN
            K24CF5=K24CHL(1:19)//'.FEL5'
            CALL JEEXIN(K24CF5,IRET)
            IF (IRET.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL5
              CALL WKVECT(K24CF5,'V V I',LOFEL5,IFEL5)
              ZI(IFEL5)=0
            ELSE
              CALL JEVEUO(K24CF5,'E',IFEL5)
            ENDIF
          ENDIF                         
C BOUCLE SUR LES GRELS DU .LIEL
          NBMAT2=0
          NBNOET=0              
          CALL JELIRA(K24CHL,'NUTIOC',NBGREL,K8BID)  
          DO 30 I=1,NBGREL
            CALL JELIRA(JEXNUM(K24CHL,I),'LONMAX',NMGREL,K8BID)
            CALL JEVEUO(JEXNUM(K24CHL,I),'L',IGREL)

C BOUCLE SUR LES MAILLES DES GRELS
            NMGRE1=NMGREL-1
            DO 20 J=0,NMGRE1
            
              NUMGRE=ZI(IGREL+J)
              
              IF (NUMGRE.LT.0) THEN
C MAILLE TARDIVE A DUPLIQUER EVENTUELLEMENT

                DO 10 L=1,NBMAT1
                
                  NUMGR1=ZI(IFLIM+IDECA+L-1)
                                  
                  IF (NUMGR1.EQ.-NUMGRE) THEN
C ON LA DUPLIQUE DANS .LIEL EN CREEANT UN GREL LIMITE A CETTE MAILLE
                    NBMAT2=NBMAT2+1                               
                    CALL JECROC(JEXNUM(K24DUL,NBMAT2))
                    CALL JEECRA(JEXNUM(K24DUL,NBMAT2),'LONMAX',2,K8BID)
                    CALL JEVEUO(JEXNUM(K24DUL,NBMAT2),'E',LADR)
C ON RECOPIE LE NUMERO NEGATIF DE MAILLE ET SON TYPE
                    ZI(LADR)=-NBMAT2
                    ZI(LADR+1)=ZI(IGREL+NMGRE1)

C---------------
C TRAITEMENTS LIES AUX .FEL2/.FEL4 POUR MAILLE TARDIVE D'INTERFACE
                    IAUX1=IFEL2+2*(NUMGR1-1)+1
                    IF (ZI(IAUX1).LT.0) THEN
                        IAUX4=ZI(IFEL4)
                        ZI(IFEL4+IAUX4+1)=-NBMAT2
                        ZI(IFEL4+IAUX4+2)=NUMSD
                        ZI(IFEL4+IAUX4+3)=NUMGR1
                        ZI(IAUX1)=ZI(IAUX1)-1
                        ZI(IFEL4)=IAUX4+3
                    ELSE
                      IF ((ZI(IAUX1-1).EQ.0).AND.(ZI(IAUX1).EQ.0)) THEN
C C'EST LA PREMIERE FOIS QUE CETTE MAILLE TARDIVE EST ENUMEREE: ON
C L'ENREGISTRE SIMPLEMENT
                        ZI(IAUX1-1)=-NBMAT2
                        ZI(IAUX1)=NUMSD
                      ELSE
C C'EST LA DEUXIEME FOIS: ON MET EN PLACE LE PROCESSUS VIA .FEL4 CAR
C C'EST UNE MAILLE TARDIVE CONCERNANT UN POINT D'INTERFACE
C DERNIERE ADRESSE PRISE PAR L'OBJET .FEL4
                        IAUX4=ZI(IFEL4)
                        ZI(IFEL4+IAUX4+1)=ZI(IAUX1-1)
                        ZI(IFEL4+IAUX4+2)=ZI(IAUX1)
                        ZI(IFEL4+IAUX4+3)=NUMGR1
                        ZI(IFEL4+IAUX4+4)=-NBMAT2
                        ZI(IFEL4+IAUX4+5)=NUMSD
                        ZI(IFEL4+IAUX4+6)=NUMGR1
                        ZI(IAUX1)=-2
                        ZI(IFEL4)=IAUX4+6
                      ENDIF
                    ENDIF
C------------------

C ON DUPLIQUE LES INFOS DU .NEMA (DESCRIPTION DES NOEUDS TARDIFS
C ASSOCIES A LA MAILLE TARDIVE
                    CALL JELIRA(JEXNUM(K24CHN,NUMGR1),'LONMAX',NBNEMA,
     &                K8BID)
                    CALL JEVEUO(JEXNUM(K24CHN,NUMGR1),'L',MADR)
                    CALL JECROC(JEXNUM(K24DUN,NBMAT2))
                    CALL JEECRA(JEXNUM(K24DUN,NBMAT2),'LONMAX',NBNEMA,
     &                K8BID)
                    CALL JEVEUO(JEXNUM(K24DUN,NBMAT2),'E',NADR)
                    NBNEMA=NBNEMA-1
                    DO 3 M=0,NBNEMA
                      IF (ZI(MADR+M).LT.0) THEN
C NOEUD TARDIF                
                        IBID=ABS(ZI(MADR+M))
C ON VA TESTER LA PRESENCE EVENTUELLE D'UNE VALEUR NON NULLE POUR
C TRAITER LE CAS DES DDL_IMPO QUI UTILISENT, POUR DES MAILLES TARDIVES
C DISTINCTES, LES MEMES LAGRANGES (IL NE FAUT DONC PAS INCREMENTER LEURS
C NOUVELLES VALEURS).
C---------------
C TRAITEMENTS LIES AUX .FEL3/.FEL5 POUR NOEUD TARDIF D'INTERFACE
                        IAUX1=IFEL3+2*(IBID-1)+1
                        IF (ZI(IAUX1).LT.0) THEN
                          IAUX4=ZI(IFEL5)
                          NBNOET=NBNOET+1
                          ZI(IFEL5+IAUX4+1)=-NBNOET
                          ZI(IFEL5+IAUX4+2)=NUMSD
                          ZI(IFEL5+IAUX4+3)=IBID
                          ZI(IAUX1)=ZI(IAUX1)-1
                          ZI(IFEL5)=IAUX4+3
                          ZI(NADR+M)=-NBNOET
                        ELSE
                          IF ((ZI(IAUX1-1).EQ.0).AND.(ZI(IAUX1).EQ.0))
     &                    THEN
C C'EST LA PREMIERE FOIS QUE CE NOEUD TARDIF EST ENUMERE: ON
C L'ENREGISTRE SIMPLEMENT
                             NBNOET=NBNOET+1
                             ZI(IAUX1-1)=-NBNOET
                             ZI(IAUX1)=NUMSD                  
                             ZI(NADR+M)=-NBNOET
                           ELSE IF 
     &                     ((ZI(IAUX1-1).NE.0).AND.(NUMSD.EQ.ZI(IAUX1)))
     &                     THEN
C C'EST UN NOEUD TARDIF DE LIAISON_DDL POUR CE SD, IL NE FAUT PAS LE
C DUPLIQUER, IL EXISTE DEJA
                             ZI(NADR+M)=ZI(IAUX1-1)
                           ELSE
C C'EST LA DEUXIEME FOIS: ON MET EN PLACE LE PROCESSUS VIA .FEL5 CAR
C C'EST UN NOEUD TARDIF CONCERNANT UN POINT D'INTERFACE
C DERNIERE ADRESSE PRISE PAR L'OBJET .FEL5
                             IAUX4=ZI(IFEL5)
                             ZI(IFEL5+IAUX4+1)=ZI(IAUX1-1)
                             ZI(IFEL5+IAUX4+2)=ZI(IAUX1)
                             ZI(IFEL5+IAUX4+3)=IBID
                             NBNOET=NBNOET+1
                             ZI(IFEL5+IAUX4+4)=-NBNOET
                             ZI(IFEL5+IAUX4+5)=NUMSD
                             ZI(IFEL5+IAUX4+6)=IBID
                             ZI(IAUX1)=-2
                             ZI(IFEL5)=IAUX4+6
                             ZI(NADR+M)=-NBNOET
                           ENDIF
                         ENDIF
C------------------

                      ELSE
C NOEUD PHYSIQUE                      
                        ZI(NADR+M)=ZI(MADR+M)
                      ENDIF     
    3               CONTINUE
                    GOTO 15
                  ENDIF
   10           CONTINUE
              
              ENDIF
              
C LABEL DE SORTIE DE BOUCLE SUR LE MAILLE DE '.FLIM'          
   15         CONTINUE
     
   20       CONTINUE
            
   30     CONTINUE

C ON RENTRE NUMERO DE NOEUD TARDIF MAX (EN VALEUR ABSOLUE) DANS .NBNO
          CALL WKVECT(K24DUL(1:19)//'.NBNO','V V I',1,INBNO)
          ZI(INBNO)=NBNOET
          
C ADAPTATION DE L'OBJET JEVEUX K24DUL (ON REGROUPE LES MAILLES PAR TYPE
C DANS UN SEUL GREL)
          CALL ADALIG(K24DUL(1:19))

C ON DUPLIQUE LES AUTRES OBJETS DU LIGREL DE CHARGE
          CALL JEDUPO(LIGRCH//'.PRNS','V',K24DUL(1:19)//'.PRNS',.FALSE.)
          CALL JEDUPO(LIGRCH//'.LGNS','V',K24DUL(1:19)//'.LGNS',.FALSE.)
          CALL JEDUPO(LIGRCH//'.NOMA','V',K24DUL(1:19)//'.NOMA',.FALSE.)
          CALL JEDUPO(LIGRCH//'.PRNM','V',K24DUL(1:19)//'.PRNM',.FALSE.)

C CREATION DE LA CORRESPONDANCE MAILLE --> (IGREL,IM) POUR LE .REPE
          CALL CORMGI('V',K24DUL(1:19))
                  
C ON STOCKE LE NOM DU LIGREL DE CHARGE TEMPORAIRE DANS LA LISTE
          ZK24(IVLIGR+K)='                        '               
          ZK24(IVLIGR+K)=K24DUL(1:19)
          IF (INFOFE(1:1).EQ.'T') THEN
            WRITE(IFM,*)'<FETI/EXLIM2> PROJECTION DU LIGREL ',
     &        LIGRCH,' POUR SOUS-DOMAINE ',NOMSD
            WRITE(IFM,*)'NOM DU PROJETE :',ZK24(IVLIGR+K)
          ENDIF

C ON DETRUIT LES .FEL4 TE .FEL5 INUTILES
          IF (ZI(IFEL4).EQ.0) CALL JEDETR(K24CF4)
          IF (NBNO.GT.0) THEN
            IF (ZI(IFEL5).EQ.0) CALL JEDETR(K24CF5)
          ENDIF

C POUR MONITORING
C          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24CF1(1:19),1,'V')
C          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24CF2(1:19),1,'V')
C          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24CF3(1:19),1,'V')
C          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24CF4(1:19),1,'V')
C          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24CF5(1:19),1,'V')
C          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,K24DUL(1:19),1,'V')
                    
        ELSE
C-----------------------------------------------------------------------
C  ON NE DUPLIQUE PAS LA CHARGE
C-----------------------------------------------------------------------
C ON VA STOCKER LE NOM DU NOUVEAU LIGREL DANS LE .FEL1 SI IL EXISTE
C SINON ON LE CREER
C OB D
          K24CF1=ZK24(IFLIN+K1)(1:19)//'.FEL1'
C          K24CF1=ZK24(IFLIN+K1)(1:19)//'.FETL'
C OB F
          CALL JEEXIN(K24CF1,IRET)
          IF (IRET.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL1
            CALL WKVECT(K24CF1,'V V K24',NBSD,IFEL1)
            DO 90 I=1,NBSD
              ZK24(IFEL1+I-1)=' '
   90       CONTINUE      
          ELSE
C INCOHERENCE QUE POUR LE SEQUENTIEL, CF BOUCLE 150 CI-DESSOUS
            IF (NBPROC.EQ.1) THEN
              CALL UTMESS('F','EXLIM2',
     &          'INCOHERENCE .FLII POUR LIGREL '//K24CF1(1:19))
            ELSE
              CALL JEVEUO(K24CF1,'E',IFEL1)
            ENDIF
          ENDIF
          ZK24(IFEL1+NUMSD-1)=K24CF1(1:19)
                
C ON STOCKE LE NOM DU LIGREL DE CHARGE INITIAL DANS LA LISTE
          ZK24(IVLIGR+K)='                        '
          ZK24(IVLIGR+K)=ZK24(IFLIN+K-1)
          IF (INFOFE(1:1).EQ.'T')
     &      WRITE(IFM,*)'<FETI/EXLIM2> ASSOCIATION DU LIGREL DE '//
     &        'CHARGE ',ZK24(IVLIGR+K)(1:19),'POUR SOUS-DOMAINE ',NOMSD
        ENDIF
        IDECA=IDECA+NBMAT1


        IF (INFOFE(2:2).EQ.'T') THEN 
          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,ZK24(IVLIGR+K)(1:19),1,'V')
          CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,ZK24(IFLIN+K-1)(1:19),1,'V')
        ENDIF
        CALL JEDEMA()     
  100 CONTINUE
   
C MONITORING
      IF (INFOFE(1:1).EQ.'T')
     &  WRITE(IFM,*)'<FETI/EXLIM2> REMPLISSAGE OBJET JEVEUX ',
     &        LLIGRS(1:19)
      IF (INFOFE(2:2).EQ.'T') 
     &  CALL UTIMSD(IFM,2,.FALSE.,.TRUE.,LLIGRS(1:19),1,'V')

      IF (NBPROC.GT.1) THEN
C INIT POUR JENUNO
        NOMSDA=SDFETI(1:19)//'.FETA'
C SI ON EST EN PARALLELE, COMPTE-TENU DE LA GESTION PARTIELLE DES
C DONNEES, POUR UN PROCESSEUR DONNE, IL FAUT GENERER TOUT LES .FEL1
C POTENTIELS, SINON LES BOUCLES DE ASSMAM, QUI ELLES FONCTIONNENT SUR
C TOUS LES CHARGEMENTS, SONT PERDUES !
        DO 150 IDD=1,NBSD
C POUR NE PAS REFAIRE LE TRAVAIL FAIT JUSTE AU DESSUS
          IF (IDD.NE.NUMSD) THEN
            CALL JENUNO(JEXNUM(NOMSDA,IDD),NOMSD2)
            CALL JEEXIN(JEXNOM(K24B,NOMSD2),IRET)
            IF (IRET.NE.0) THEN
C SOUS-DOMAINE CONCERNE PAR DES LIGRELS TARDIFS DE CHARGE      
              CALL JEVEUO(JEXNOM(K24B,NOMSD2),'L',IFLIN)
              CALL JELIRA(JEXNOM(K24B,NOMSD2),'LONMAX',NBCHA2,K8BID)
              DO 140 K=1,NBCHA2
                K1=K-1
C OB D
                K24CF1=ZK24(IFLIN+K1)(1:19)//'.FEL1'
C                K24CF1=ZK24(IFLIN+K1)(1:19)//'.FETL'
C OB F
                CALL JEEXIN(K24CF1,IRET1)
                IF (IRET1.EQ.0) THEN
C CONSTITUTION OBJET STOCKAGE.FEL1
                  CALL WKVECT(K24CF1,'V V K24',NBSD,IFEL1)
                ENDIF      
  140         CONTINUE
            ENDIF
          ENDIF
  150   CONTINUE
      ENDIF             

      CALL JEDEMA()
      
      END
