      REAL*8 FUNCTION NDYNRE ( SDDYNA, CHAINE)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 19/12/2007   AUTEUR ABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
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
C 
C ----------------------------------------------------------------------
C
C ROUTINE MECA_NON_LINE (SDDYNA - UTILITAIRE)
C
C INTERROGE SDDYNA POUR RENVOYER UN REEL
C      
C ----------------------------------------------------------------------
C
C
C OUT NDYNRE : PARAMETRE REEL DE L'OBJET .PARA_SCHEMA DEMANDE
C IN  SDDYNA : NOM DE LA SD DEDIEE A LA DYNAMIQUE
C IN  CHAINE : NOM DU PARAMETRE
C                    = 'ALPHA','DELTA','PHI','THETA'
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
       LOGICAL      LSCHE1,NDYNLO
       INTEGER      JPSCHE,JCFSC
       CHARACTER*19 VALK(2)
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C --- INITIALISATIONS
C
      CALL JEVEUO(SDDYNA(1:15)//'.PARA_SCH','L',JPSCHE)
      CALL JEVEUO(SDDYNA(1:15)//'.COEF_SCH','L',JCFSC)
      
      IF (CHAINE.EQ.'ALPHA')THEN
        VALK(1)='THETA_METHODE'
        LSCHE1 = NDYNLO ( SDDYNA,VALK(1))
        IF(LSCHE1)THEN
          VALK(2)=CHAINE
          CALL U2MESK('F','UTILITAI7_6',2,VALK)
        ELSE
          NDYNRE=ZR(JPSCHE+1-1)
        ENDIF
      ELSEIF (CHAINE.EQ.'DELTA')THEN
        VALK(1)='THETA_METHODE'
        LSCHE1 = NDYNLO ( SDDYNA,'THETA_METHODE')
        IF(LSCHE1)THEN
          VALK(2)=CHAINE
          CALL U2MESK('F','UTILITAI7_6',2,VALK)
        ELSE
          NDYNRE=ZR(JPSCHE+2-1)
        ENDIF
      ELSEIF (CHAINE.EQ.'PHI')THEN
        LSCHE1 = NDYNLO ( SDDYNA,'IMPLICITE')
        IF(LSCHE1)THEN
          IF(NDYNLO(SDDYNA,'NEWMARK'))VALK(1)='NEWMARK'
          IF(NDYNLO(SDDYNA,'THETA_METHODE'))VALK(1)='THETA_METHODE'
          IF(NDYNLO(SDDYNA,'HHT'))VALK(1)='HHT'
          VALK(2)=CHAINE
          CALL U2MESK('F','UTILITAI7_6',2,VALK)
        ELSE
          NDYNRE=ZR(JPSCHE+3-1)
        ENDIF
      ELSEIF (CHAINE.EQ.'THETA')THEN
        LSCHE1 = NDYNLO ( SDDYNA,'THETA_METHODE')
        IF(LSCHE1)THEN
          NDYNRE=ZR(JPSCHE+4-1)
        ELSE
          IF(NDYNLO(SDDYNA,'NEWMARK'))VALK(1)='NEWMARK'
          IF(NDYNLO(SDDYNA,'HHT'))VALK(1)='HHT'
          IF(NDYNLO(SDDYNA,'TCHAMWA'))VALK(1)='TCHAMWA'
          IF(NDYNLO(SDDYNA,'DIFF_CENT'))VALK(1)='DIFF_CENT'
          VALK(2)=CHAINE
          CALL U2MESK('F','UTILITAI7_6',2,VALK)
        ENDIF
      ELSEIF (CHAINE.EQ.'COEDEP')THEN
        NDYNRE = ZR(JCFSC+1-1)
      ELSEIF (CHAINE.EQ.'COEVIT')THEN
        NDYNRE = ZR(JCFSC+2-1) 
      ELSEIF (CHAINE.EQ.'COEACC')THEN
        NDYNRE = ZR(JCFSC+3-1)                     
      ELSE
        VALK(1)=CHAINE
        CALL U2MESK('F','UTILITAI7_7',1,VALK)
      ENDIF
C
      CALL JEDEMA()

      END
