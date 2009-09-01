      SUBROUTINE XPOAJN(IN,MA2,ENTITE,INO,JLSN,JDIRNO,NDIM,PREFNO,
     &                  NNN,INN,INNTOT,INOTOT,NBNOC,NBNOFI,INOFI,
     &                  IACOO1,IACOO2)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 01/09/2009   AUTEUR SELLENET N.SELLENET 
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
C RESPONSABLE GENIAUT S.GENIAUT

      IMPLICIT NONE

      CHARACTER*2   PREFNO(4)
      CHARACTER*8   MA2,ENTITE
      INTEGER       INO,JLSN,JDIRNO,NNN,INN,INNTOT,INOTOT,NBNOC
      INTEGER       NBNOFI,INOFI,IACOO1,IACOO2,I,IN,NDIM
C
C            ON AJOUTE UN NOUVEAU NOEUD AU NOUVEAU MAILLAGE X-FEM
C  
C   IN
C     IN     : POSITION DU NOEUD OU DU POINT DANS LE DIRNO LOCAL
C     ENTITE : NOEUD OU POINT D'INTERSECTION
C     INO    : NUMERO DU NOEUD DANS LE MAILLAGE SAIN
C     JLSN   : ADRESSE DU CHAM_NO_S DE LA LEVEL NORMALE
C     JDIRNO : ADRESSE DU TABLEAU DIRNO LOCAL
C     NDIM   : DIMENSION DU MAILLAGE
C     PREFNO : PREFERENCES POUR LE NOMAGE DES NOUVELLES ENTITES
C     NNN    : NOMBRE DE NOUVEAU NOEUDS A CREER SUR LA MAILLE PARENT
C     INN    : COMPTEUR LOCAL DU NOMBRE DE NOUVEAUX NOEUDS CREES
C     INNTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVEAUX NOEUDS CREES
C     INOTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVEAUX NOMS DE NOEUDS 
C     NBNOC  : NOMBRE DE NOEUDS CLASSIQUES DU MAILLAGE FISSURE
C     NBNOFI : NOMBRE DE NOEUDS SITUES SUR LA FISSURE
C     INOFI  : LISTE DES NOEUDS SITUES SUR LA FISSURE
C     IACOO1 : SI ENTITE='NOEUD' :
C                  ADRESSE DES COORDONNES DES NOEUDS DU MAILLAGE SAIN 
C              SI ENTITE='POINT' :
C                  ADRESSE DES COORDONNES DES POINTS D'INTERSECTION 
C     IACOO2 :  ADRESSE DES COORDONNES DES NOEUDS DU MAILLAGE FISSURE 

C   OUT
C     INN    : COMPTEUR LOCAL DU NOMBRE DE NOUVEAU NOEUDS CREES
C     INNTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVEAU NOEUDS CREES
C     INOTOT : COMPTEUR TOTAL DU NOMBRE DE NOUVEAUX NOMS DE NOEUDS 
C     MA2    : NOM DU MAILLAGE FISSURE
C     NBNOFI : NOMBRE DE NOEUDS SITUES SUR LA FISSURE
C     INOFI  : LISTE DES NOEUDS SITUES SUR LA FISSURE
C     IACOO2 :  ADRESSE DES COORDONNES DES NOEUDS DU MAILLAGE FISSURE 


C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
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
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------


      REAL*8        CO(3)
      INTEGER       IRET,NDOUBL,J
      CHARACTER*2   NM(2)
      CHARACTER*6   CHN
      CHARACTER*8   VALK(2)
      CHARACTER*16  K16B,NOMCMD
      DATA          VALK /'NOEUDS','XPOAJN'/



      CALL JEMARQ()
      CALL VECINI(3,0.D0,CO)

C     ATTENTION : CONVENTION : D'ABORD LE NOEUD "-", PUIS LE NOEUD "+"

      IF (ENTITE.EQ.'NOEUD'.AND.ZR(JLSN-1+INO).NE.0.D0) THEN
        NDOUBL=1
        NM(1)=PREFNO(1)
      ELSE
        NDOUBL=2
        NM(1)=PREFNO(2)
        NM(2)=PREFNO(3)
      ENDIF

      IF (ENTITE.EQ.'NOEUD') THEN 
        CO(1)=ZR(IACOO1-1+3*(INO-1)+1)
        CO(2)=ZR(IACOO1-1+3*(INO-1)+2)
        CO(3)=ZR(IACOO1-1+3*(INO-1)+3)
      ELSEIF (ENTITE.EQ.'POINT') THEN 
        DO 10 I=1,NDIM
          CO(I)=ZR(IACOO1-1+I)
 10     CONTINUE
      ENDIF

C     COMPTEUR DES NOMS DES NOEUDS
      IF (INOTOT.GE.999999) CALL U2MESK('F','XFEM_8',1,VALK)
      INOTOT= INOTOT +1

      ZI(JDIRNO-1+3*(IN-1)+1) = NDOUBL

      DO 100 I=1,NDOUBL

        INN = INN + 1
        INNTOT = INNTOT + 1
        CALL ASSERT(INN.LE.NNN)

        ZI(JDIRNO-1+3*(IN-1)+1+I) = NBNOC + INNTOT
        CALL CODENT(INOTOT,'G',CHN)

        CALL JECROC(JEXNOM(MA2//'.NOMNOE',NM(I)//CHN))

        DO 20 J=1,3
          ZR(IACOO2-1+3*(NBNOC+INNTOT-1)+J)=CO(J)
 20     CONTINUE

C       LISTE DES NOEUDS PORTANT DDLS DE CONTACT
        IF (NDOUBL.EQ.2.AND.ENTITE.EQ.'POINT') THEN
          NBNOFI=NBNOFI+1
          ZI(INOFI-1+NBNOFI)=NBNOC+INNTOT
        ENDIF

 100  CONTINUE

      CALL JEDEMA()
      END
