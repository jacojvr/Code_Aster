      SUBROUTINE VERIOB(OBZ,VERIF,IARG1)
      IMPLICIT NONE
      CHARACTER*(*) OBZ,VERIF
      INTEGER IARG1
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF UTILITAI  DATE 05/09/2006   AUTEUR CIBHHPD L.SALMONA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2006  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE VABHHTS J.PELLET
C ----------------------------------------------------------------------
C  BUT : VERIFIER UN OBJET JEVEUX
C        => ERREUR <F> SI FAUX
C  IN   OBZ   : NOM D'UN OBJET JEVEUX
C  IN   VERIF  :   /'EXIS'  : ON VERIFIE QUE OBZ EXISTE
C                     SI IARG1=0 : FAUX => ERREUR <F>
C                     SI IARG1=1 : FAUX => ALARME <A>
C                  /'NOEXIS'  : ON VERIFIE QUE OBZ N'EXISTE PAS
C                     SI IARG1=0 : FAUX => ERREUR <F>
C                     SI IARG1=1 : FAUX => ALARME <A>
C                  /'LONMAX_EGAL'  : ON VERIFIE QUE OBZ A UN LONMAX
C                                    EGAL A IARG1
C  IN   IARG1  :   ARGUMENT ENTIER NUMERO 1 (SI VERIF LE NECESSITE)
C ----------------------------------------------------------------------
      CHARACTER*32 OB
      CHARACTER*1 CMES,KBID,TMES
      INTEGER I1,I2,IBID,I3, I4
 
C -DEB------------------------------------------------------------------

      OB=OBZ
      CMES='F'
      CALL JEEXIN(OB,I1)

C ---VERIFICATION DE L'EXISTENCE

      IF (VERIF.EQ.'EXIS') THEN
        CALL ASSERT(IARG1.EQ.0 .OR. IARG1.EQ.1)
        IF (IARG1.EQ.1) CMES='A'
        IF (I1.EQ.0) CALL UTMESS(CMES,'VERIOB','OBJET INEXISTANT: '//OB)

C ---VERIFICATION DE LA NON EXISTENCE

      ELSE IF (VERIF.EQ.'NOEXIS') THEN
        CALL ASSERT(IARG1.EQ.0 .OR. IARG1.EQ.1)
        IF (IARG1.EQ.1) CMES='A'
        IF (I1.GT.0) CALL UTMESS(CMES,'VERIOB','OBJET EXISTANT: '//OB)

C ---VERIFICATION DE LA DIMENSION LONMAX D'UN VECTEUR

      ELSE IF (VERIF.EQ.'LONMAX_EGAL') THEN
        CALL JELIRA(OB,'LONMAX',I2,KBID)
        IF (I2.NE.IARG1)
     &     CALL UTMESS(CMES,'VERIOB','OBJET: '//OB//
     &                 ' DE LONMAX INCORRECT.')
     
C ---VERIFICATION DE LA DIMENSION NUTIOC D'UNE COLLECTION

      ELSE IF (VERIF.EQ.'LON_COLL') THEN
        CALL JELIRA(OB,'NUTIOC',I3,KBID)
        IF (I3.NE.IARG1)
     &    CALL UTMESS(CMES,'VERIOB','COLLECTION: '//OB//
     &                 ' DE LON_COLL INCORRECT.')

C ---VERIFICATION DE LA LONGUEUR DU NOM NOMMAX
     
      ELSE IF (VERIF.EQ.'LON_NOM') THEN
       CALL JELIRA(OB,'NOMMAX',I4,KBID)
       IF (I4.NE.IARG1)
     &   CALL UTMESS(CMES,'VERIOB','COLLECTION: '//OB//
     &                ' DE LON_NOM INCORRECT.')
         
C ---VERIFICATION DU TYPE : ENTIER

      ELSE IF (VERIF.EQ.'I') THEN
       CALL JELIRA(OB,'TYPE',IBID,TMES)
       IF (TMES(1:1).NE.'I') 
     &   CALL UTMESS(CMES,'VERIOB','OBJET: '//OB//
     &                ' DE TYPE ENTIER INCORRECT.')
      
      
C ---VERIFICATION DU TYPE : REEL

      ELSE IF (VERIF.EQ.'R') THEN
       CALL JELIRA(OB,'TYPE',IBID,TMES)
        IF(TMES.NE.'R') 
     &   CALL UTMESS(CMES,'VERIOB','OBJET: '//OB//
     &                ' DE TYPE REEL INCORRECT.')
      
      
C ---VERIFICATION DU TYPE : COMPLEXE  

      ELSE IF (VERIF.EQ.'C') THEN
       CALL JELIRA(OB,'TYPE',IBID,TMES)
        IF(TMES.NE.'C') 
     &    CALL UTMESS(CMES,'VERIOB','OBJET: '//OB//
     &                ' DE TYPE COMPLEXE INCORRECT.')
     
             
C ---VERIFICATION DU TYPE : LOGIQUE

      ELSE IF (VERIF.EQ.'L') THEN
       CALL JELIRA(OB,'TYPE',IBID,TMES)
        IF(TMES.NE.'L') 
     &    CALL UTMESS(CMES,'VERIOB','OBJET: '//OB//
     &                ' DE TYPE LOGIQUE INCORRECT.')

C ---VERIFICATION DU TYPE : CHAINE

      ELSE IF (VERIF.EQ.'K') THEN
       CALL JELIRA(OB,'TYPE',IBID,TMES)
        IF(TMES.NE.'K') 
     &   CALL UTMESS(CMES,'VERIOB','OBJET: '//OB//
     &                ' DE TYPE CHAINE INCORRECT.')
     
 
C ---RETOUR CODE ERREUR
     
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF

      END
