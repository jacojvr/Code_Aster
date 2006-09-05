      SUBROUTINE CAZOCC(CHAR,MOTFAC,NOMA,NOMO,NDIM,IREAD,IWRITE)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 05/09/2006   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2005  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
      IMPLICIT NONE
      CHARACTER*8  CHAR
      CHARACTER*16 MOTFAC
      CHARACTER*8  NOMA
      CHARACTER*8  NOMO
      INTEGER      NDIM
      INTEGER      IREAD
      INTEGER      IWRITE
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : CAZOCO
C ----------------------------------------------------------------------
C
C LECTURE DES PRINCIPALES CARACTERISTIQUES DU CONTACT (SURFACE IREAD)
C REMPLISSAGE DE LA SD 'DEFICO' (SURFACE IWRITE) POUR 
C LA METHODE CONTINUE
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  MOTFAC : MOT-CLE FACTEUR (VALANT 'CONTACT')
C IN  NOMA   : NOM DU MAILLAGE
C IN  NOMO   : NOM DU MODELE
C IN  NDIM   : NOMBRE DE DIMENSIONS DU PROBLEME
C IN  IREAD  : INDICE POUR LIRE LES DONNEES DANS AFFE_CHAR_MECA
C IN  IWRITE : INDICE POUR ECRIRE LES DONNEES DANS LA SD DEFICONT
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER ZI
      COMMON /IVARJE/ ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      INTEGER REACCA,REACBS,REACBG
      INTEGER ZMETH,ZTOLE,ZECPD,ZCMCF,ZTGDE,ZDIRE,ZPOUD,CFMMVD
      CHARACTER*8 TYMOCL(2),STACO0,COMPLI,FONFIS,RACSUR
      CHARACTER*16 MOTCLE(2)
      CHARACTER*24 LISMA
      INTEGER NBMA1
      CHARACTER*16 MODELI,PHENOM
      INTEGER IER,IBID,NOC,NOCC
      CHARACTER*24 CARACF,ECPDON,DIRCO,METHCO,TANDEF,JEUSUP,TANPOU
      CHARACTER*24 TOLECO
      INTEGER JCMCF,JECPD,JDIR,JMETH,JTGDEF,JJSUP,JPOUDI,JTOLE
      CHARACTER*16 INTER,MODAX,FORMUL,TYPF
      REAL*8 DIR1(3),DIR(3),COEFRO,COCAU,COFAU,REACSI
      REAL*8 ASPER,KAPPAN,KAPPAV
      REAL*8 DIST1,DIST2,LAMB
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ
C
C --- INITIALISATIONS
C
      COCAU = 0.D0
      COFAU = 0.D0
      COEFRO = 0.D0
      REACSI = -1.0D+6
      
C ======================================================================
C --- LECTURE DES STRUCTURES DE DONNEES DE CONTACT
C ======================================================================
      DIRCO  = CHAR(1:8) // '.CONTACT.DIRCO'
      ECPDON = CHAR(1:8) // '.CONTACT.ECPDON'
      CARACF = CHAR(1:8) // '.CONTACT.CARACF'
      METHCO = CHAR(1:8) // '.CONTACT.METHCO'
      TANDEF = CHAR(1:8) // '.CONTACT.TANDEF'
      JEUSUP = CHAR(1:8) // '.CONTACT.JSUPCO'
      TANPOU = CHAR(1:8) // '.CONTACT.TANPOU'
      TOLECO = CHAR(1:8) // '.CONTACT.TOLECO'
C
      CALL JEVEUO(CARACF,'E',JCMCF)
      CALL JEVEUO(DIRCO,'E',JDIR)
      CALL JEVEUO(ECPDON,'E',JECPD)
      CALL JEVEUO(METHCO,'E',JMETH)
      CALL JEVEUO(TANDEF,'E',JTGDEF)
      CALL JEVEUO(JEUSUP,'E',JJSUP)
      CALL JEVEUO(TANPOU,'E',JPOUDI)
      CALL JEVEUO(TOLECO,'E',JTOLE)
C
      ZMETH = CFMMVD('ZMETH')
      ZTOLE = CFMMVD('ZTOLE')   
      ZECPD = CFMMVD('ZECPD')
      ZCMCF = CFMMVD('ZCMCF')
      ZTGDE = CFMMVD('ZTGDE')
      ZDIRE = CFMMVD('ZDIRE')  
      ZPOUD = CFMMVD('ZPOUD')    
C 
C --- RECUPERATION DU NOM DU PHENOMENE ET DE LA  MODELISATION          
C 
      CALL DISMOI('F','PHENOMENE',NOMO,'MODELE',IBID,PHENOM,IER)
      CALL DISMOI('F','MODELISATION',NOMO,'MODELE',IBID,MODELI,IER)

      ZI(JECPD) = 1

      CALL GETVTX(MOTFAC,'FORMULATION',IREAD,1,1,FORMUL,NOC)
      IF (FORMUL(1:4) .EQ. 'DEPL') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+6) = 1
      ELSEIF (FORMUL(1:4) .EQ. 'VITE') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+6) = 2
      ELSE
        CALL UTMESS('F','CAZOCC',
     &             'NE CORRESPOND A AUCUNE METHODE             
     &              DU MOT CLE FORMULATION')
      END IF

      CALL GETVTX(MOTFAC,'INTEGRATION',IREAD,1,1,INTER,NOC)
      IF (INTER(1:5) .EQ. 'NOEUD') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 1.D0
      ELSEIF (INTER(1:5) .EQ. 'GAUSS') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 2.D0
      ELSEIF (INTER(1:7) .EQ. 'SIMPSON') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 3.D0
        IF (INTER(1:8) .EQ. 'SIMPSON1') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 4.D0
        END IF
        IF (INTER(1:8) .EQ. 'SIMPSON2') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 5.D0
        END IF
      ELSEIF (INTER(1:6) .EQ. 'NCOTES') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 6.D0
        IF (INTER(1:7) .EQ. 'NCOTES1') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 7.D0
        END IF
        IF (INTER(1:7) .EQ. 'NCOTES2') THEN
          ZR(JCMCF+ZCMCF*(IWRITE-1)+1) = 8.D0
        END IF
      ELSE
        CALL UTMESS('F','CAZOCC',
     &             'NE CORRESPOND A AUCUNE METHODE             
     &              DU MOT CLE INTEGRATION')
      END IF

      CALL GETVR8(MOTFAC,'COEF_REGU_CONT',IREAD,1,1,COCAU,NOC)
      ZR(JCMCF+ZCMCF*(IWRITE-1)+2) = COCAU

      CALL GETVTX(MOTFAC,'FROTTEMENT',IREAD,1,1,TYPF,NOCC)
      IF (TYPF(1:7) .EQ. 'COULOMB') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+5) = 3.D0
        CALL GETVR8(MOTFAC,'COULOMB',IREAD,1,1,COEFRO,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+4) = COEFRO
        CALL GETVR8(MOTFAC,'COEF_REGU_FROT',IREAD,1,1,COFAU,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+3) = COFAU
        CALL GETVIS(MOTFAC,'ITER_FROT_MAXI',IREAD,1,1,REACBS,NOC)
        ZI(JECPD+ZECPD*(IWRITE-1)+3)  = REACBS
        CALL GETVR8(MOTFAC,'SEUIL_INIT',IREAD,1,1,REACSI,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+6) = REACSI
        IF (NOCC .NE. 0) THEN
          CALL GETVR8(MOTFAC,'VECT_Y',IREAD,1,3,DIR,NOC)
          IF (NOC.NE.0) THEN
            ZI(JMETH+ZMETH*(IWRITE-1)+2) = 1
          ENDIF  
          
          IF (NOC.NE.0 .AND. NDIM.GE.2) THEN
            ZR(JTGDEF+ZTGDE*(IWRITE-1)) = DIR(1)
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+1) = DIR(2)
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+2) = DIR(3)
          ELSE
            ZR(JTGDEF+ZTGDE*(IWRITE-1)) = 0.D0
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+1) = 0.D0
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+2) = 0.D0
          END IF

          CALL GETVR8(MOTFAC,'VECT_Z',IREAD,1,3,DIR,NOC)
          IF (NOC .NE. 0) THEN
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+3) = DIR(1)
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+4) = DIR(2)
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+5) = DIR(3)
          ELSE
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+3) = 0.D0
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+4) = 0.D0
            ZR(JTGDEF+ZTGDE*(IWRITE-1)+5) = 0.D0
          END IF
        END IF
      ELSEIF (TYPF(1:4) .EQ. 'SANS') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+5) = 1.D0
      ELSE
        CALL UTMESS('F','CAZOCC',
     &             'NE CORRESPOND A AUCUNE METHODE DU MOT CLE           
     &                           FROTTEMENT')
      END IF
      
C --- LECTURE DES PARAMETRES DE LA COMPLIANCE POUR METHODE CONTINUE

      CALL GETVTX(MOTFAC,'COMPLIANCE',IREAD,1,1,COMPLI,NOC)
      IF (COMPLI .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+7) = 1
        CALL GETVR8(MOTFAC,'ASPERITE',IREAD,1,1,ASPER,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+8) = ASPER
        CALL GETVR8(MOTFAC,'E_N',IREAD,1,1,KAPPAN,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+9) = KAPPAN
        CALL GETVR8(MOTFAC,'E_V',IREAD,1,1,KAPPAV,NOC)
        ZR(JCMCF+ZCMCF*(IWRITE-1)+10) = KAPPAV
      ELSE
        ZR(JCMCF+ZCMCF*(IWRITE-1)+7) = 0
        ZR(JCMCF+ZCMCF*(IWRITE-1)+8) = 0.D0
      END IF
      
C --- FIN LECTURE DES PARAMETRES DE LA COMPLIANCE METHODE CONTINUE

      CALL GETVTX(MOTFAC,'FOND_FISSURE',IREAD,1,1,FONFIS,NOC)
      IF (FONFIS .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+11) = 1.D0
      ELSE
        ZR(JCMCF+ZCMCF*(IWRITE-1)+11) = 0.D0       
      END IF
      CALL GETVTX(MOTFAC,'RACCORD_LINE_QUAD',IREAD,1,1,RACSUR,NOC)
      IF (RACSUR .EQ. 'OUI') THEN
        ZR(JCMCF+ZCMCF*(IWRITE-1)+12) = 1.D0
      ELSE
        ZR(JCMCF+ZCMCF*(IWRITE-1)+12) = 0.D0
      END IF
      
      CALL GETVTX(MOTFAC,'MODL_AXIS',IREAD,1,1,MODAX,NOC)
      IF (MODAX(1:3) .EQ. 'OUI') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+1) = 1
      ELSEIF (MODAX(1:3) .EQ. 'NON') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+1) = 0
      END IF

      CALL GETVIS(MOTFAC,'ITER_CONT_MAXI',IREAD,1,1,REACCA,NOC)
      ZI(JECPD+ZECPD*(IWRITE-1)+2) = REACCA

      CALL GETVIS(MOTFAC,'ITER_GEOM_MAXI',IREAD,1,1,REACBG,NOC)
      ZI(JECPD+ZECPD*(IWRITE-1)+4) = REACBG

      CALL GETVTX(MOTFAC,'CONTACT_INIT',IREAD,1,1,STACO0,NOC)
      IF (STACO0 .EQ. 'OUI') THEN
        ZI(JECPD+ZECPD*(IWRITE-1)+5) = 1
      ELSE
        ZI(JECPD+ZECPD*(IWRITE-1)+5) = 0
      END IF
      CALL GETVR8(MOTFAC,'DIRE_APPA',IREAD,1,3,DIR1,NOC)
      ZR(JDIR+ZDIRE*(IWRITE-1)) = DIR1(1)
      ZR(JDIR+ZDIRE*(IWRITE-1)+1) = DIR1(2)
      IF (NDIM .EQ. 3) THEN
        ZR(JDIR+ZDIRE*(IWRITE-1)+2) = DIR1(3)
      ELSE
        ZR(JDIR+ZDIRE*(IWRITE-1)+2) = 0.D0
      END IF
      MOTCLE(1) = 'GROUP_MA_ESCL'
      MOTCLE(2) = 'MAILLE_ESCL'
      TYMOCL(1) = 'GROUP_MA'
      TYMOCL(2) = 'MAILLE'
      LISMA = '&&CARACO.LISTE_MAILLES_1'
      CALL RELIEM(NOMO,NOMA,'NU_MAILLE',MOTFAC,IREAD,2,MOTCLE,TYMOCL,
     &            LISMA,NBMA1)

      IF (NDIM .EQ. 2) THEN
        MODELI = 'CONT_DVP_2D'
      ELSE
        MODELI = 'CONT_DVP_3D'
      END IF
C 
C --- CAS D'UN JEU SUPPLEMENTAIRE REEL (AFFE_CHAR_MECA) 
C
      CALL GETVR8(MOTFAC,'DIST_MAIT',IREAD,1,1,DIST1,NOC)
      CALL GETVR8(MOTFAC,'DIST_ESCL',IREAD,1,1,DIST2,NOC)
        ZR(JJSUP+IWRITE-1) = DIST1 + DIST2
C
C --- ORIENTATION DU REPERE LOCAL
C        
      CALL GETVR8(MOTFAC,'VECT_ORIE_POU',IREAD,1,3,DIR,NOC)
      IF (NOC.NE.0) THEN
        ZI(JMETH+ZMETH*(IWRITE-1)+2) = 2
        ZR(JPOUDI+ZPOUD*(IWRITE-1))   = DIR(1)
        ZR(JPOUDI+ZPOUD*(IWRITE-1)+1) = DIR(2)
        ZR(JPOUDI+ZPOUD*(IWRITE-1)+2) = DIR(3)
      ENDIF
C
C --- TOUTES LES AUTRES METHODES (DISCRETES)
C
C
C --- TOLE_PROJ_EXT
C --- TOLE_PROJ_EXT <0: LA PROJECTION HORS DE LA MAILLE EST INTERDITE
C --- TOLE_PROJ_EXT >0: LA PROJECTION HORS DE LA MAILLE EST AUTORISEE
C ---                    MAIS LIMITEE PAR LAMB
C
      CALL GETVR8(MOTFAC,'TOLE_PROJ_EXT',IREAD,1,1,LAMB,NOC)
      IF (LAMB .LT. 0.D0) THEN
        ZR(JTOLE+ZTOLE*(IWRITE-1)) = -1.D0
      ELSE
        ZR(JTOLE+ZTOLE*(IWRITE-1)) = LAMB
      END IF
C
C --- AJOUT DES ELEMENTS TARDIFS AU LIGREL
C        
      CALL AJELLT('&&CALICO.LIGRET',NOMA,NBMA1,LISMA,' ',PHENOM,MODELI,
     &           0,' ')

      CALL JEDEMA
      END
