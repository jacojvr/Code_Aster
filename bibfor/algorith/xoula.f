      FUNCTION XOULA(CFACE,IFA,I,JAINT,TYPMA)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/01/2005   AUTEUR GENIAUT S.GENIAUT 
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

      IMPLICIT NONE
      CHARACTER*8  TYPMA
      INTEGER      CFACE(5,3),IFA,I,JAINT,XOULA

C-----------------------------------------------------------------------
C     BUT: RETOURNE LE NUM�RO LOCAL DU NOEUD PORTANT LE DDL 
C              LAMDBA AU SOMMET DE LA FACETTE CONSID�R�E

C ARGUMENTS D'ENTR�E:
C     CFACE     : CONNECTIVIT� DES NOEUDS DES FACETTES   
C     IFA       : NUM�RO DE LA FACETTE
C     I         : NUM�RO DU SOMMET DE LA FACETTE
C     JAINT     : ADRESSE DES INFORMATIONS CONCERNANT LES ARETES COUP�ES
C     TYPMA     : TYPE DE LA MAILLE

C-----------------------------------------------------------------------
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
      CHARACTER*32       JEXNUM , JEXNOM , JEXR8 , JEXATR
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
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
C --- VARIABLES

      INTEGER      NLI,IN,IA,NOMIL 

C     NUMERO DU LAMBDA ASSOCI� AU SOMMET I DE LA FACETTE IFA
      NLI=CFACE(IFA,I)

C     NUMERO DU NOEUD ASSOCI�E � CE LAMBDA (0 SI ARETE)
      IN=NINT(ZR(JAINT-1+4*(NLI-1)+2))
      
      IF (IN.EQ.0) THEN
C       NUMERO DE L'ARETE ASSOCI�E � CE LAMBDA
        IA=NINT(ZR(JAINT-1+4*(NLI-1)+1))
        CALL ASSERT(IA.NE.0)
C       NUMERO DU NOEUD MILIEU ASSOCI�E A CETTE ARETE
        IN=NOMIL(TYPMA,IA)
      ENDIF

      XOULA=IN

      END
