      SUBROUTINE IMPVOI(TEXTE,NBMA,IADDVO,IADVOI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF DEBUG  DATE 18/06/2012   AUTEUR COURTOIS M.COURTOIS 
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
      IMPLICIT NONE
      INCLUDE 'jeveux.h'
      CHARACTER*(*) TEXTE
      INTEGER NBMA,IADDVO,IADVOI
      INTEGER IMA,IV,IS
C-----------FONCTIONS  D ACCES A VGE -----------------------------------
      INTEGER ZZADVO,ZZNBVO,ZZADVE,ZZMAVO,ZZTYVO,ZZNBNO,ZZNBSC,ZZLOC1,
     &        ZZLOC2
C     IADDVO : ADRESSE JEVEUX DU TABLEAU DE POINTEURS DANS LA SD EL_VOIS
C     IADVOI : ADRESSE JEVEUX DE LA SD EL_VOIS
C
C     DES DONNEES DES VOISINS DE LA MAILLE IMA (0 SI MAILLE PAS ACTIVE)
      ZZADVO(IMA)=ZI(IADDVO+IMA-1)+IADVOI

C     NOMBBRE DE VOISINS DE IMA EME MAILLE
      ZZNBVO(IMA)=ZI(ZZADVO(IMA)-1+1)

C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C     ADRESSE DES DONNEES
C FAUX ???      ZZADVE(IMA,IV) = ZI(ZZADVO(IMA)-1+1+IV)+IADVOI-1
      ZZADVE(IMA,IV)=ZI(ZZADVO(IMA)-1+1+IV)+ZZADVO(IMA)-1

C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C     TYPE DE VOISINAGE :
C        3D PAR FACE    : F3 : 1
C        2D PAR FACE    : F2 : 2
C        3D PAR ARRETE  : A3 : 3
C        2D PAR ARRETE  : A2 : 4
C        1D PAR ARRETE  : A1 : 5
C        3D PAR SOMMET  : S3 : 6
C        2D PAR SOMMET  : S2 : 7
C        1D PAR SOMMET  : S1 : 8
C        0D PAR SOMMET  : S0 : 9
      ZZTYVO(IMA,IV)=ZI(ZZADVE(IMA,IV)-1+1)

C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C     NUMERO DE MAILLE
      ZZMAVO(IMA,IV)=ZI(ZZADVE(IMA,IV)-1+2)

C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C     NOMBRE DE NOEUDS DE MAILLE
      ZZNBNO(IMA,IV)=ZI(ZZADVE(IMA,IV)-1+3)


C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C        NOMBRE DE SOMMETS COMMUNS
      ZZNBSC(IMA,IV)=ZI(ZZADVE(IMA,IV)-1+4)


C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C     POUR LE SOMMET COMMUN IS
C     NUMERO LOCAL DANS IMA
      ZZLOC1(IMA,IV,IS)=ZI(ZZADVE(IMA,IV)-1+4+1+2*(IS-1))



C     POUR LA MAILLE IMA
C     POUR LE VOISIN IV
C    POUR LE SOMMET COMMUN IS
C     NUMERO LOCAL DANS IV
      ZZLOC2(IMA,IV,IS)=ZI(ZZADVE(IMA,IV)-1+4+1+2*(IS-1)+1)
C-----------FIN FONCTIONS  D ACCES A VGE -------------------------------


      WRITE (6,*)
      WRITE (6,*)' IMPRESSION OBJET VOISINAGE VGE '
      WRITE (6,*)TEXTE
      WRITE (6,*)

      DO 30 IMA=1,NBMA
        WRITE (6,9000)IMA,ZZNBVO(IMA)
        DO 20 IV=1,ZZNBVO(IMA)
          WRITE (6,9010)IV,ZZTYVO(IMA,IV),ZZMAVO(IMA,IV),
     &      ZZNBNO(IMA,IV),ZZNBSC(IMA,IV)
          DO 10 IS=1,ZZNBSC(IMA,IV)
            WRITE (6,9020)IS,ZZLOC1(IMA,IV,IS),ZZLOC2(IMA,IV,IS)
   10     CONTINUE
   20   CONTINUE
   30 CONTINUE
      WRITE (6,*)' FIN IMPRESSION OBJET VOISINAGE VGE '
      WRITE (6,*)

 9000 FORMAT (' MAILLE ',I8,' NB VOIS ',I2)
 9010 FORMAT (' VOISIN ',I2,' TYPE ',I2,' MAILLE ',I8,' NB NOEUDS ',I2,
     &       ' NB SOMMETS COMMUN ',I2)
 9020 FORMAT (' IS ',I2,' NUMLOC ',I2,' NUMLOC DANS VOISIN ',I2)
      END
