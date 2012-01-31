      SUBROUTINE NDYNKK(SDDYNA,CHAINE,NOMSD)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 31/01/2012   AUTEUR IDOUX L.IDOUX 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
      IMPLICIT NONE
      CHARACTER*19  SDDYNA
      CHARACTER*(*) CHAINE
      CHARACTER*19  NOMSD
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (UTILITAIRE)
C
C INTERROGE SDDYNA POUR RENVOYER UNE CHAINE
C      
C ----------------------------------------------------------------------
C
C
C OUT NOMSD  : NOM DE LA SD 
C IN  SDDYNA : NOM DE LA SD DEDIEE A LA DYNAMIQUE
C IN  CHAINE :  = / 'MULTI_APPUI' 
C                 / 'AMOR_MODAL'
C                
C
C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
C -------------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ----------------
C
      CHARACTER*24 NOSD ,TCHA  
      INTEGER      JNOSD,JTCHA 
      CHARACTER*24 VECENT,VECABS   
      INTEGER      JVECEN,JVECAB
      CHARACTER*24 VEOL ,VAOL
      INTEGER      JVEOL,JVAOL 
      LOGICAL      NDYNLO,LDYNA
      CHARACTER*24 CHAM24
      CHARACTER*19 SDAMMO
      CHARACTER*15 SDMUAP,SDPRMO,SDEXSO
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      LDYNA  = NDYNLO(SDDYNA,'DYNAMIQUE')
      NOMSD  = ' '      
C
C --- ACCES AUX OBJETS DE LA SD SDDYNA
C
      IF (LDYNA) THEN
        NOSD   = SDDYNA(1:15)//'.NOM_SD' 
        VEOL   = SDDYNA(1:15)//'.VEEL_OLD'  
        VAOL   = SDDYNA(1:15)//'.VEAS_OLD'        
        TCHA   = SDDYNA(1:15)//'.TYPE_CHA'
        VECENT = SDDYNA(1:15)//'.VECENT'
        VECABS = SDDYNA(1:15)//'.VECABS'
        CALL JEVEUO(VECENT,'L',JVECEN)
        CALL JEVEUO(VECABS,'L',JVECAB)       
        CALL JEVEUO(NOSD  ,'L',JNOSD ) 
        CALL JEVEUO(VEOL  ,'E',JVEOL )
        CALL JEVEUO(VAOL  ,'E',JVAOL ) 
        CALL JEVEUO(TCHA  ,'L',JTCHA ) 
      ELSE
        GOTO 999
      ENDIF
C
      IF(CHAINE(1:6).EQ.'DEPENT')THEN
        CHAM24 = ZK24(JVECEN+1-1)        
      ELSEIF(CHAINE(1:6).EQ.'VITENT')THEN
        CHAM24 = ZK24(JVECEN+2-1)
      ELSEIF(CHAINE(1:6).EQ.'ACCENT')THEN
        CHAM24 = ZK24(JVECEN+3-1)
      ELSEIF(CHAINE(1:6).EQ.'DEPABS')THEN
        CHAM24 = ZK24(JVECAB+1-1)        
      ELSEIF(CHAINE(1:6).EQ.'VITABS')THEN
        CHAM24 = ZK24(JVECAB+2-1)
      ELSEIF(CHAINE(1:6).EQ.'ACCABS')THEN
        CHAM24 = ZK24(JVECAB+3-1) 
C
      ELSEIF(CHAINE(1:6).EQ.'STADYN')THEN
        CHAM24 = ZK24(JNOSD+4-1)         
C           
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VEFEDO')THEN
        CHAM24 = ZK24(JVEOL+1-1)          
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VEFSDO')THEN
        CHAM24 = ZK24(JVEOL+2-1)  
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VEDIDO')THEN
        CHAM24 = ZK24(JVEOL+3-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VEDIDI')THEN
        CHAM24 = ZK24(JVEOL+4-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VEFINT')THEN
        CHAM24 = ZK24(JVEOL+5-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VEONDP')THEN
        CHAM24 = ZK24(JVEOL+6-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VELAPL')THEN
        CHAM24 = ZK24(JVEOL+7-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_VESSTF')THEN
        CHAM24 = ZK24(JVEOL+8-1)
C
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNFEDO')THEN
        CHAM24 = ZK24(JVAOL+1-1)          
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNFSDO')THEN
        CHAM24 = ZK24(JVAOL+2-1)  
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNDIDO')THEN
        CHAM24 = ZK24(JVAOL+3-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNDIDI')THEN
        CHAM24 = ZK24(JVAOL+4-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNFINT')THEN
        CHAM24 = ZK24(JVAOL+5-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNONDP')THEN
        CHAM24 = ZK24(JVAOL+6-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNLAPL')THEN
        CHAM24 = ZK24(JVAOL+7-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNSSTF')THEN
        CHAM24 = ZK24(JVAOL+8-1)
      ELSEIF(CHAINE(1:11).EQ.'OLDP_CNCINE')THEN
        CHAM24 = ZK24(JVAOL+9-1)               
C        
      ELSEIF(CHAINE(1:6).EQ.'CHONDP')THEN
        CHAM24 = ZK24(JTCHA+1-1)
C
C --- SD AMORTISSEMENT MODAL
C        
      ELSEIF(CHAINE(1:6).EQ.'SDAMMO')THEN
        SDAMMO = ZK24(JNOSD+2-1)(1:19)
        CHAM24 = SDAMMO
C
C --- SD EXCIT_SOL
C        
      ELSEIF(CHAINE(1:6).EQ.'SDEXSO')THEN
        SDEXSO = ZK24(JNOSD+5-1)(1:15)
        CHAM24 = SDEXSO
C
C --- SD PROJECTION MODALE
C
      ELSE IF(CHAINE(1:11).EQ.'PRMO_DEPGEM')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.DGM'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_DEPGEP')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.DGP'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_VITGEM')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.VGM'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_VITGEP')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.VGP'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_ACCGEM')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.AGM'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_ACCGEP')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.AGP'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_BASMOD')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.BAM'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_MASGEN')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.MAG'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_RIGGEN')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.RIG'              
      ELSE IF(CHAINE(1:11).EQ.'PRMO_AMOGEN')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.AMOG'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_FONGEN')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.FOG'
      ELSE IF(CHAINE(1:11).EQ.'PRMO_FORGEN')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.FRG'        
      ELSE IF(CHAINE(1:11).EQ.'PRMO_ACCGCN')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.AGN'     
      ELSE IF(CHAINE(1:11).EQ.'PRMO_VALFON')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.VAF'        
      ELSE IF(CHAINE(1:11).EQ.'PRMO_FMODAL')THEN
        SDPRMO = ZK24(JNOSD+3-1)(1:15)
        CHAM24 = SDPRMO(1:15)//'.FMD'        
C
C --- SD MULTI_APPUi
C
      ELSE IF(CHAINE(1:11).EQ.'MUAP_MAFDEP')THEN
        SDMUAP = ZK24(JNOSD+1-1)(1:15)
        CHAM24 = SDMUAP(1:15)//'.FDP' 
      ELSE IF(CHAINE(1:11).EQ.'MUAP_MAFVIT')THEN
        SDMUAP = ZK24(JNOSD+1-1)(1:15)
        CHAM24 = SDMUAP(1:15)//'.FVT'
      ELSE IF(CHAINE(1:11).EQ.'MUAP_MAFACC')THEN
        SDMUAP = ZK24(JNOSD+1-1)(1:15)
        CHAM24 = SDMUAP(1:15)//'.FAC'
      ELSE IF(CHAINE(1:11).EQ.'MUAP_MAMULA') THEN
        SDMUAP = ZK24(JNOSD+1-1)(1:15)
        CHAM24 = SDMUAP(1:15)//'.MUA'
      ELSE IF(CHAINE(1:11).EQ.'MUAP_MAPSID') THEN
        SDMUAP = ZK24(JNOSD+1-1)(1:15)
        CHAM24 = SDMUAP(1:15)//'.PSD'
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
 999  CONTINUE 
C 
      NOMSD  = CHAM24(1:19) 
C
      CALL JEDEMA()

      END
