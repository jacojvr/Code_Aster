      SUBROUTINE COPCOG(NOMA,DEFICO,NEWGEO,
     &                  POSMA,XPG,YPG,
     &                  GEOM)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 05/09/2006   AUTEUR MABBAS M.ABBAS 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
      CHARACTER*8  NOMA
      CHARACTER*24 DEFICO
      CHARACTER*24 NEWGEO   
      INTEGER      POSMA        
      REAL*8       XPG
      REAL*8       YPG
      REAL*8       GEOM(3) 
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : MAPPAR
C ----------------------------------------------------------------------
C
C CALCUL DES COORDONNEES D'UN POINT DE CONTACT
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NEWGEO : NOUVELLE GEOMETRIE (AVEC DEPLACEMENT GEOMETRIQUE)
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  POSMA  : INDICE DE LA MAILLE ESCLAVE DANS CONTAMA
C IN  XPG    : COORDONNEE X DU POINT DE GAUSS
C IN  YPG    : COORDONNEE Y DU POINT DE GAUSS
C OUT GEOM   : COORDONNEES DU POINT DU CONTACT (EN 2D Z=0)
C
C -------------- DEBUT DECLARATIONS NORMALISEES JEVEUX -----------------
C           
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C
C ---------------- FIN DECLARATIONS NORMALISEES JEVEUX -----------------
C
      CHARACTER*24 CONTMA,CONTNO,NOMACO,PNOMA
      INTEGER JNOCO,JMACO,JNOMA,JPONO,JCOOR
      INTEGER NNO,JDEC,INO,NO(9),POSNNO(9),I,J,IBID,NUMA
      REAL*8 FF(9)
      REAL*8 COOR(27)
      CHARACTER*8 ALIAS
C            
C-----------------------------------------------------------------------
C
      CALL JEMARQ()
C      
      CONTMA = DEFICO(1:16)//'.MAILCO'
      CONTNO = DEFICO(1:16)//'.NOEUCO'
      NOMACO = DEFICO(1:16)//'.NOMACO'
      PNOMA  = DEFICO(1:16)//'.PNOMACO'
      CALL JEVEUO(CONTNO,'L',JNOCO)
      CALL JEVEUO(CONTMA,'L',JMACO)
      CALL JEVEUO(NOMACO,'L',JNOMA)
      CALL JEVEUO(PNOMA,'L',JPONO)
      CALL JEVEUO(NEWGEO(1:19)//'.VALE','L',JCOOR)  
C
C --- INITIALISATIONS
C
      DO 40 I=1,3
        GEOM(I)=0.D0
   40 CONTINUE          
C
C --- INFOS SUR LA MAILLE ESCLAVE 
C 
      NUMA = ZI(JMACO+POSMA-1)
      JDEC = ZI(JPONO+POSMA-1)      
      CALL MMELTY(NOMA,NUMA,ALIAS,NNO,IBID) 
C
C --- COORDONNEES DES NOEUDS DE LA MAILLE ESCLAVE
C
      DO 10 INO = 1,NNO
        POSNNO(INO+1) = ZI(JNOMA+JDEC+INO-1)
        NO(INO)       = ZI(JNOCO+POSNNO(INO+1)-1)
   10 CONTINUE

      DO 30 INO = 1,NNO
        COOR(3* (INO-1)+1) = ZR(JCOOR+3* (NO(INO)-1))
        COOR(3* (INO-1)+2) = ZR(JCOOR+3* (NO(INO)-1)+1)
        COOR(3* (INO-1)+3) = ZR(JCOOR+3* (NO(INO)-1)+2)
   30 CONTINUE
C
C --- COORDONNEES DU POINT DE CONTACT
C
      CALL CALFFX(ALIAS,XPG,YPG,FF)
      DO 60 I = 1,3
        DO 50 J = 1,NNO
          GEOM(I) = FF(J)*COOR((J-1)*3+I) + GEOM(I)
   50   CONTINUE
   60 CONTINUE
C
      CALL JEDEMA()
      END
