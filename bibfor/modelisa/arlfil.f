      SUBROUTINE ARLFIL(NOMA  ,NOMB  ,BC    ,NOM1  ,NOM2)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 09/01/2007   AUTEUR ABBAS M.ABBAS 
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
      CHARACTER*10 NOMA,NOMB,NOM1,NOM2
      REAL*8       BC(2,3)
C      
C ----------------------------------------------------------------------
C
C ROUTINE ARLEQUIN
C
C FILTRAGE DES MAILLES SITUEES DANS LA ZONE DE SUPERPOSITION
C
C ----------------------------------------------------------------------
C
C IN  NOMA   : NOM DE LA SD DE STOCKAGE MAILLES GROUP_MA_1
C IN  NOMB   : NOM DE LA SD DE STOCKAGE MAILLES GROUP_MA_2  
C IN  BC     : BOITE ENGLOBANT LA ZONE DE RECOUVREMENT
C OUT NOM1   : NOM DE LA SD DE STOCKAGE MAILLES GROUP_MA_1 APRES
C              FILTRAGE 
C OUT NOM2   : NOM DE LA SD DE STOCKAGE MAILLES GROUP_MA_2 APRES
C              FILTRAGE
C OUT NBMA1  : NOMBRE DE MAILLES DANS LE GROUP_MA APRES FILTRAGE
C      
C ----------------------------------------------------------------------
C
      INTEGER      IFM,NIV              
C      
C ----------------------------------------------------------------------
C
      CALL INFNIV(IFM,NIV)     
C
C --- FILTRAGE GROUPE 1
C
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_1 - FILTRAGE...'
      ENDIF
C      
      CALL ARLFLT(NOMA,BC,NOM1)  
C     
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_1 - BOITES APRES FILTRAGE ...'
        CALL ARLIMP(IFM,'BOITE',NOM1)
      ENDIF          
C
C --- FILTRAGE GROUPE 2
C     
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_2 - FILTRAGE...'
      ENDIF      
      CALL ARLFLT(NOMB,BC,NOM2)
C     
      IF (NIV.GE.2) THEN
        WRITE(IFM,*) '<ARLEQUIN> GROUP_MA_2 - BOITES APRES FILTRAGE ...'
        CALL ARLIMP(IFM,'BOITE',NOM2)
      ENDIF        
C
      END
