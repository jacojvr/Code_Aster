      SUBROUTINE SURFC3(CHAR,NOMA,IFM)
C      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 07/05/2007   AUTEUR PROIX J-M.PROIX 
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
      CHARACTER*8 CHAR
      CHARACTER*8 NOMA
      INTEGER     IFM      
C      
C ----------------------------------------------------------------------
C
C ROUTINE CONTACT (METHODE XFEM   - AFFICHAGE DONNEES)
C
C AFFICHAGE LES INFOS CONTENUES DANS LA SD CONTACT POUR LA FORMULATION
C XFEM
C      
C ----------------------------------------------------------------------
C
C
C IN  CHAR   : NOM UTILISATEUR DU CONCEPT DE CHARGE
C IN  NOMA   : NOM DU MAILLAGE
C IN  IFM    : UNITE D'IMPRESSION
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
      INTEGER      CFMMVD,ZECPD,ZCMCF
      INTEGER      NZOCO
      INTEGER      IZONE,FORM   
C
      CHARACTER*24 ECPDON,CARACF  
      INTEGER      JECPD ,JCMCF  
C
      CHARACTER*24 FORMCO,METHCO
      INTEGER      JFORM ,JMETH  
C      
C      CHARACTER*24 XFIESC,XSIESC,XSIMAI
C      INTEGER      JFIESC,JSIESC,JSIMAI
      CHARACTER*24 XCONTA,XFIMAI
      INTEGER      JCONTX,JFIMAI      
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ
C   
C --- COMMUNS TOUTES FORMULATIONS 
C 
      FORMCO = CHAR(1:8)//'.CONTACT.FORMCO'
      METHCO = CHAR(1:8)//'.CONTACT.METHCO' 
      CALL JEVEUO(FORMCO,'L',JFORM)      
      CALL JEVEUO(METHCO,'L',JMETH)   
      NZOCO  = ZI(JMETH)
C
      IZONE  = 1
      FORM   = ZI(JFORM-1+IZONE)
      IF (FORM.NE.3) THEN
        GOTO 999
      ENDIF      
C   
C --- COMMUNS AVEC FORM. CONTINUE
C 
      ECPDON = CHAR(1:8)//'.CONTACT.ECPDON'
      CARACF = CHAR(1:8)//'.CONTACT.CARACF'
C
      CALL JEVEUO(ECPDON,'L',JECPD)
      CALL JEVEUO(CARACF,'L',JCMCF)      
C     
      ZCMCF = CFMMVD('ZCMCF')      
      ZECPD = CFMMVD('ZECPD') 
C
C --- SPECIFIQUES XFEM
C 
C     XFIESC = CHAR(1:8)//'.CONTACT.XFIESC'   
C     XSIESC = CHAR(1:8)//'.CONTACT.XSIESC'   
C     XSIMAI = CHAR(1:8)//'.CONTACT.XSIMAI' 
      XFIMAI = CHAR(1:8)//'.CONTACT.XFIMAI' 
      XCONTA = CHAR(1:8)//'.CONTACT.XFEM'  
C
      CALL JEVEUO(XFIMAI,'L',JFIMAI) 
      CALL JEVEUO(XCONTA,'L',JCONTX)     
C     CALL JEVEUO(XFIESC,'L',JFIESC)       
C     CALL JEVEUO(XSIESC,'L',JSIESC) 
C     CALL JEVEUO(XSIMAI,'L',JSIMAI)  
      IF (ZI(JCONTX-1+1).NE.NZOCO) CALL ASSERT(.FALSE.)  
      IF (ZI(JCONTX-1+2).NE.1) CALL ASSERT(.FALSE.)        
C
C --- IMPRESSIONS POUR L'UTILISATEUR
C 
      WRITE (IFM,*)      
      WRITE (IFM,*) '<CONTACT> INFOS SPECIFIQUES SUR LA FORMULATION'//
     &              ' XFEM'
      WRITE (IFM,*)
C      
      WRITE (IFM,*) '<CONTACT> ... ZONES XFEM.'
      DO 610 IZONE = 1,NZOCO
        WRITE (IFM,*) '<CONTACT> ...... ZONE : ',IZONE          
        WRITE (IFM,1010) ZK8(JFIMAI-1+IZONE) 
C        WRITE (IFM,1011) ZI(JSIMAI-1+IZONE) 
C       WRITE (IFM,1090) ZK8(JFIESC-1+IZONE) 
C       WRITE (IFM,1091) ZI(JSIESC-1+IZONE)         
 610  CONTINUE 
C      
 1010 FORMAT (' <CONTACT> ...... FISS. MAITRE : ',A18)
 1011 FORMAT (' <CONTACT> ...... SIGN. MAITRE : ',I1)
 1090 FORMAT (' <CONTACT> ...... FISS. ESCLAVE: ',A18)
 1091 FORMAT (' <CONTACT> ...... SIGN. ESCLAVE: ',I1)                 
C
C --- INFOS SPECIFIQUES POUR FORMULATION CONTINUE
C
      WRITE (IFM,*) '<CONTACT> ... PARAMETRES DIVERS POUR FORM. XFEM.'
      DO 310 IZONE = 1,NZOCO
        WRITE (IFM,*) '<CONTACT> ...... ZONE : ',IZONE          
        WRITE (IFM,1020) '<INUTILISE>     ',ZI(JECPD+ZECPD*(IZONE-1)+1)
        WRITE (IFM,1020) 'ITER_CONT_MAXI  ',ZI(JECPD+ZECPD*(IZONE-1)+2)
        WRITE (IFM,1020) 'ITER_FROT_MAXI  ',ZI(JECPD+ZECPD*(IZONE-1)+3)
        WRITE (IFM,1020) 'ITER_GEOM_MAXI  ',ZI(JECPD+ZECPD*(IZONE-1)+4)
        WRITE (IFM,1020) 'CONTACT_INIT    ',ZI(JECPD+ZECPD*(IZONE-1)+5)
        WRITE (IFM,1020) '<INUTILISE>     ',ZI(JECPD+ZECPD*(IZONE-1)+6)
 310  CONTINUE 
C
      DO 320 IZONE = 1,NZOCO
        WRITE (IFM,*) '<CONTACT> ...... ZONE : ',IZONE          
        WRITE (IFM,1070) 'INTEGRATION     ',ZR(JCMCF+ZCMCF*(IZONE-1)+1)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+16)
        WRITE (IFM,1070) 'COEF_REGU_CONT  ',ZR(JCMCF+ZCMCF*(IZONE-1)+2)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+17)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+18)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+19)
        WRITE (IFM,1070) 'COEF_REGU_FROT  ',ZR(JCMCF+ZCMCF*(IZONE-1)+3)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+20)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+21)
        WRITE (IFM,1070) 'FROTTEMENT      ',ZR(JCMCF+ZCMCF*(IZONE-1)+5)
        WRITE (IFM,1070) 'COULOMB         ',ZR(JCMCF+ZCMCF*(IZONE-1)+4)
        WRITE (IFM,1070) 'SEUIL_INIT      ',ZR(JCMCF+ZCMCF*(IZONE-1)+6)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+7)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+8)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+9)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+10)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+13)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+14)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+15)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+11)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+12)
        WRITE (IFM,1070) '<INUTILISE>     ',ZR(JCMCF+ZCMCF*(IZONE-1)+22)
        WRITE (IFM,1070) 'COEF_ECHELLE    ',ZR(JCMCF+ZCMCF*(IZONE-1)+23)
        WRITE (IFM,1070) 'ALGO_LAGR       ',ZR(JCMCF+ZCMCF*(IZONE-1)+24)
 320  CONTINUE  
C
 1070 FORMAT (' <CONTACT> ...... PARAM. : ',A16,'VAL. : ',E12.5) 
 1020 FORMAT (' <CONTACT> ...... PARAM. : ',A16,'VAL. : ',I5)   
C      
 999  CONTINUE
      CALL JEDEMA
      END
