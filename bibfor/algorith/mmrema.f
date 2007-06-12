      SUBROUTINE MMREMA(NOMA,DEFICO,NEWGEO,
     &                  IZONE,GEOM,POSNO,DIRAPP,DIR,
     &                  POSMIN,JEUMIN,NMIN,T1MIN,T2MIN,
     &                  XIMIN,YIMIN,PROJIN)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 12/02/2007   AUTEUR KHAM M.KHAM 
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
      IMPLICIT NONE
      CHARACTER*8  NOMA
      CHARACTER*24 NEWGEO
      CHARACTER*24 DEFICO
      INTEGER      IZONE
      REAL*8       GEOM(3)
      INTEGER      POSNO
      LOGICAL      DIRAPP
      REAL*8       DIR(3)
      INTEGER      POSMIN
      REAL*8       JEUMIN
      REAL*8       NMIN(3)
      REAL*8       T1MIN(3),T2MIN(3)
      REAL*8       XIMIN,YIMIN
      LOGICAL      PROJIN
C
C ----------------------------------------------------------------------
C ROUTINE APPELEE PAR : MAPPAR
C ----------------------------------------------------------------------
C
C RECHERCHER LA MAILLE MAITRE LA PLUS PROCHE CONNAISSANT LE NOEUD 
C MAITRE LE PLUS PROCHE DU POINT DE CONTACT ET FAIRE LA PROJECTION 
C SELON UNE DIRECTION DE RECHERCHE DONNEE
C
C IN  NOMA   : NOM DU MAILLAGE
C IN  NEWGEO : NOUVELLE GEOMETRIE (AVEC DEPLACEMENT GEOMETRIQUE)
C IN  DEFICO : SD POUR LA DEFINITION DE CONTACT
C IN  IZONE  : NUMERO DE LA ZONE DE CONTACT
C IN  GEOM   : COORDONNEES DU POINT DE CONTACT
C IN  POSNO  : POSITION DU NOEUD MAITRE LE PLUS PROCHE
C IN  DIRAPP : VAUT .TRUE. SI APPARIEMENT DANS UNE DIRECTION DE 
C              RECHERCHE DONNEE (PAR DIR)
C IN  DIR    : DIRECTION DE RECHERCHE DONNEE
C OUT POSMIN : POSITION DE LA MAILLE MAITRE LA PLUS PROCHE
C OUT JEUMIN : JEU MINIMUM
C OUT NMIN   : NORMALE
C OUT T1MIN  : PREMIER VECTEUR TANGENT
C OUT T2MIN  : DEUXIEME VECTEUR TANGENT
C OUT XIMIN  : COORDONNEE X DE LE PROJECTION MINIMALE DU POINT DE 
C              CONTACT SUR LA MAILLE MAITRE
C OUT YIMIN  : COORDONNEE Y DE LE PROJECTION MINIMALE DU POINT DE 
C              CONTACT SUR LA MAILLE MAITRE
C OUT PROJIN : VAUT .TRUE. SI LA PROJECTION DU POINT DE CONTACT N'EST
C              PAS LE RESULTAT DU RABATTEMENT 
C              .FALSE. S'IL Y A EU RABATTEMENT PARCE QU'ELLE SERAIT
C              TOMBEEE HORS DE LA MAILLE MAITRE (A LA TOLERANCE PRES)
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
      INTEGER JDEC,JDEC1,ITEMAX
      INTEGER POSMA,IMA,NBMA,K,I
      INTEGER INO,POSNNO(10),IBID,NIVERR,NNO   
      INTEGER NUMA,NO(9),NDIM
      REAL*8 JEU,R8GAEM,TAU1(3),TAU2(3),TOLEOU,R8BID,EPSMAX
      REAL*8       COOR(30),XI,YI,NORM(3)
      CHARACTER*8  ALIAS
      CHARACTER*24 CONTNO,CONTMA,MANOCO,PMANO,PNOMA,NOMACO
      INTEGER      JNOCO,JMACO,JMANO,JPOMA,JPONO,JNOMA,JCOOR 
      CHARACTER*24 K24BID,K24BLA
      LOGICAL      LDIST,LBID,LDMIN
      DATA K24BLA /' '/         
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
      CONTNO = DEFICO(1:16)//'.NOEUCO'
      CONTMA = DEFICO(1:16)//'.MAILCO'
      NOMACO = DEFICO(1:16)//'.NOMACO'
      MANOCO = DEFICO(1:16)//'.MANOCO'
      PMANO  = DEFICO(1:16)//'.PMANOCO'
      PNOMA  = DEFICO(1:16)//'.PNOMACO'
      PMANO  = DEFICO(1:16)//'.PMANOCO'
      CALL JEVEUO(CONTNO,'L',JNOCO)
      CALL JEVEUO(CONTMA,'L',JMACO)
      CALL JEVEUO(MANOCO,'L',JMANO)
      CALL JEVEUO(PMANO, 'L',JPOMA)
      CALL JEVEUO(PNOMA, 'L',JPONO)
      CALL JEVEUO(NOMACO,'L',JNOMA)
      CALL JEVEUO(NEWGEO(1:19)//'.VALE','L',JCOOR)      
C
C --- INITIALISATIONS
C
      JEUMIN = R8GAEM()
      PROJIN = .TRUE.
      POSMIN = 0          
      DO 64 I=1,30
        COOR(I)=0.D0
64    CONTINUE        
C
C --- PARAMETRES
C
      CALL MMINFP(IZONE,DEFICO,K24BLA,'TOLE_PROJ_EXT',
     &            IBID,TOLEOU,K24BID,LBID)
      IF (DIRAPP) TOLEOU=0.D0
      CALL MMINFP(IZONE,DEFICO,K24BLA,'PROJ_NEWT_EPSI',
     &            IBID,EPSMAX,K24BID,LBID)   
      CALL MMINFP(IZONE,DEFICO,K24BLA,'PROJ_NEWT_ITER',
     &            ITEMAX,R8BID,K24BID,LBID)       
C
C --- BOUCLE SUR LES MAILLES CONTENANT LE NOEUD MAITRE LE NOEUD MAITRE
C --- LE PLUS PROCHE
C   
      NBMA = ZI(JPOMA+POSNO) - ZI(JPOMA+POSNO-1)
      JDEC = ZI(JPOMA+POSNO-1)

      DO 50 IMA = 1,NBMA
        POSMA = ZI(JMANO+JDEC+IMA-1)
        NUMA  = ZI(JMACO+POSMA-1)
        CALL MMELTY(NOMA,NUMA,ALIAS,NNO,NDIM)
C
C --- COORDONNEES DU POINT DE CONTACT (SUR LA MAILLE ESCLAVE)
C
        DO 20 I = 1,3
          COOR(I) = GEOM(I)
   20   CONTINUE
C   
C --- COORDONNEES DES NOEUDS DE LA MAILLE MAITRE
C
        JDEC1 = ZI(JPONO+POSMA-1)
        DO 10 INO = 1,NNO
          POSNNO(INO+1) = ZI(JNOMA+JDEC1+INO-1)
          NO(INO) = ZI(JNOCO+POSNNO(INO+1)-1)
   10   CONTINUE
        DO 30 INO = 1,NNO
          COOR(3* (INO)+1) = ZR(JCOOR+3* (NO(INO)-1))
          COOR(3* (INO)+2) = ZR(JCOOR+3* (NO(INO)-1)+1)
          COOR(3* (INO)+3) = ZR(JCOOR+3* (NO(INO)-1)+2)
   30   CONTINUE
C
C --- PROJECTION SUR LA MAILLE MAITRE
C --- CALCUL DU JEU MINIMUM, DES COORDONNEES DU POINT PROJETE
C --- ET DES DEUX VECTEURS TANGENTS
C
        CALL MMPROJ(ALIAS,NDIM,NNO,COOR,
     &              ITEMAX,EPSMAX,TOLEOU,DIRAPP,DIR,
     &              XI,YI,NORM,TAU1,TAU2,JEU,LDIST,NIVERR)
C     
        IF (NIVERR.EQ.2) THEN  
         CALL MMERRO(DEFICO,K24BLA,NOMA,
     &               'MMREMA','F','MAT_SING',
     &                NUMA,-1,IBID,
     &                IBID,R8BID,K24BID)
        ELSEIF (NIVERR.EQ.3) THEN
         CALL MMERRO(DEFICO,K24BLA,NOMA,
     &               'MMREMA','F','NON_CONV',
     &                NUMA,-1,IBID,
     &                IBID,R8BID,K24BID)
        ELSEIF (NIVERR.EQ.4) THEN
         CALL MMERRO(DEFICO,K24BLA,NOMA,
     &               'MMREMA','F','VECT_TANG_NUL',
     &                NUMA,-1,IBID,
     &                IBID,R8BID,K24BID)
        ELSEIF (NIVERR.EQ.1) THEN
         CALL MMERRO(DEFICO,K24BLA,NOMA,
     &               'MMREMA','F','ELEM_INC',
     &                NUMA,-1,IBID,
     &                IBID,R8BID,K24BID)          
        ENDIF 
C
C --- SI JEU (AVANT CORRECTION) < JEU MINIMUM, STOCKER LES VALEURS
C
        IF (JEU.LT.JEUMIN) THEN
          POSMIN = POSMA
          JEUMIN = JEU
          LDMIN  = LDIST
          DO 40 K = 1,3
            T1MIN(K) = TAU1(K)
            T2MIN(K) = TAU2(K)
            NMIN(K)  = NORM(K)
   40     CONTINUE
          XIMIN = XI
          YIMIN = YI
        END IF
   50 CONTINUE
C
C --- TRAITEMENT DU CAS DU RABATTEMENT
C
      IF (.NOT.LDMIN) PROJIN = .FALSE.
      IF (TOLEOU.EQ.-1.D0) PROJIN = .TRUE.
      IF (DIRAPP) PROJIN = .TRUE.

C ----------------------------------------------------------------------

      CALL JEDEMA()
      END
