      SUBROUTINE XDECOU(IT,CONNEC,LSN,IGEOM,PINTER,NINTER,NPTS,AINTER)
      IMPLICIT NONE 

      REAL*8        LSN(*)
      INTEGER       IT,CONNEC(6,4),NINTER,IGEOM,NPTS
      CHARACTER*24  PINTER,AINTER
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 25/01/2005   AUTEUR GENIAUT S.GENIAUT 
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
C                      TROUVER LES PTS D'INTERSECTION ENTRE LES ARETES
C                      ET LE PLAN DE FISSURE 
C                    
C     ENTREE
C       IT       : INDICE DU TETRA EN COURS
C       CONNEC   : CONNECTIVIT� DES NOEUDS DU TETRA
C       LSN      : VALEURS DE LA LEVEL SET NORMALE
C       IGEOM    : ADRESSE DES COORDONN�ES DES NOEUDS DE L'ELT PARENT
C
C     SORTIE
C       PINTER   : COORDONN�ES DES POINTS D'INTERSECTION
C       NINTER   : NB DE POINTS D'INTERSECTION
C       NPTS     : NB DE PTS D'INTERSECTION COINCIDANT AVEC UN NOEUD
C       AINTER   : INFOS ARETE ASSOCI�E AU POINTS D'INTERSECTION
C     ------------------------------------------------------------------
C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER          ZI
      COMMON  /IVARJE/ ZI(1)
      REAL*8           ZR
      COMMON  /RVARJE/ ZR(1)
      COMPLEX*16       ZC
      COMMON  /CVARJE/ ZC(1)
      LOGICAL          ZL
      COMMON  /LVARJE/ ZL(1)
      CHARACTER*8      ZK8
      CHARACTER*16             ZK16
      CHARACTER*24                      ZK24
      CHARACTER*32                               ZK32
      CHARACTER*80                                        ZK80
      COMMON  /KVARJE/ ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------
C
      REAL*8          A(3),B(3),C(3),LSNA,LSNB,PADIST,LONGAR,TAMPOR(3)
      REAL*8          ALPHA
      INTEGER         AR(12,2),NBAR,NTA,NTB,NA,NB,JPTINT,INS,JAINT
      INTEGER         IA,I,IPT,IBID,PP,PD,K
      CHARACTER*8     TYPMA
C ----------------------------------------------------------------------

      CALL JEMARQ()

C     CR�ATION DU VECTEUR DES COORDONN�ES DES POINTS D'INTERSECTION
      CALL WKVECT(PINTER,'V V R',3*12,JPTINT)

C     VECTEUR R�EL � 4 COMPOSANTES, POUR CHAQUE PT D'INTER : 
C     - NUM�RO ARETE CORRESPONDANTE (0 SI C'EST UN NOEUD SOMMET)
C     - VRAI NUM�RO ARETE CORRESPONDANTE (SERT QUE POUR NOEUD SOMMET)
C     - LONGUEUR DE L'ARETE
C     - POSITION DU PT SUR L'ARETE
      CALL WKVECT(AINTER,'V V R',12*4,JAINT)

      TYPMA='TETRA4'
      IPT=0
C     COMPTEUR DE POINT INTERSECTION = NOEUD SOMMENT
      INS=0
      CALL CONARE(TYPMA,AR,NBAR)
C     BOUCLE SUR LES ARETES POUR D�TERMINER LES POINTS D'INTERSECTION
      DO 100 IA=1,NBAR
C       NUM NO DES TETRAS
        NTA=AR(IA,1)
        NTB=AR(IA,2)                
C       NUM NO DE L'HEXA
        NA=CONNEC(IT,NTA)
        NB=CONNEC(IT,NTB)    
        LSNA=LSN(NA)
        LSNB=LSN(NB)
        DO 110 I=1,3  
          A(I)=ZR(IGEOM-1+3*(NA-1)+I)
          B(I)=ZR(IGEOM-1+3*(NB-1)+I)
 110    CONTINUE       
        LONGAR=PADIST(3,A,B)

        IF ((LSNA*LSNB).LE.0) THEN
          IF (LSNA.EQ.0) THEN
C           ON AJOUTE A LA LISTE LE POINT A
            CALL XAJPIN(JPTINT,12,IPT,INS,A,LONGAR,JAINT,0,IA,0.D0)
          ENDIF
          IF (LSNB.EQ.0) THEN
C           ON AJOUTE A LA LISTE LE POINT B
            CALL XAJPIN(JPTINT,12,IPT,INS,B,LONGAR,JAINT,0,IA,LONGAR)
          ENDIF
          IF (LSNA.NE.0.AND.LSNB.NE.0) THEN
C           INTERPOLATION DES COORDONN�ES DE C
            DO 130 I=1,3
              C(I)=A(I)-LSNA/(LSNB-LSNA)*(B(I)-A(I))            
 130        CONTINUE
C           POSITION DU PT D'INTERSECTION SUR L'ARETE
            ALPHA=PADIST(3,A,C)
C           ON AJOUTE A LA LISTE LE POINT C
            CALL XAJPIN(JPTINT,12,IPT,IBID,C,LONGAR,JAINT,IA,IA,ALPHA)
          ENDIF
        ENDIF

 100  CONTINUE
      NINTER=IPT 
      NPTS  =INS

C     TRI DES POINTS D'INTERSECTION PAR ORDRE CROISSANT DES ARETES 
      DO 200 PD=1,NINTER-1
         PP=PD
         DO 201 I=PP,NINTER
           IF (ZR(JAINT-1+4*(I-1)+1).LT.ZR(JAINT-1+4*(PP-1)+1)) PP=I
 201     CONTINUE
         DO 202 K=1,4
          TAMPOR(K)=ZR(JAINT-1+4*(PP-1)+K)
          ZR(JAINT-1+4*(PP-1)+K)=ZR(JAINT-1+4*(PD-1)+K)
          ZR(JAINT-1+4*(PD-1)+K)=TAMPOR(K)
 202     CONTINUE
         DO 203 K=1,3
           TAMPOR(K)=ZR(JPTINT-1+3*(PP-1)+K)
           ZR(JPTINT-1+3*(PP-1)+K)=ZR(JPTINT-1+3*(PD-1)+K)
           ZR(JPTINT-1+3*(PD-1)+K)=TAMPOR(K)
 203     CONTINUE
 200   CONTINUE

      IF(0.EQ.1) THEN
      IF (NINTER.GT.0) THEN
        WRITE(6,*)'NB PT INTER : ',NINTER
        WRITE(6,*)'NB PT SOMMET : ',NPTS
        DO 199 IPT=1,NINTER
          C(1)=ZR(JPTINT-1+3*(IPT-1)+1) 
          C(2)=ZR(JPTINT-1+3*(IPT-1)+2) 
          C(3)=ZR(JPTINT-1+3*(IPT-1)+3)
          WRITE(6,*)' ',C  
          WRITE(6,*)'ARETE N ',ZR(JAINT-1+(I-1)*4+1)
 199    CONTINUE
      ENDIF
      ENDIF

      CALL JEDEMA()
      END
