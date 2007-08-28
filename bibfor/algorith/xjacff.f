      SUBROUTINE XJACFF(ELREFP,FPG,JINTER,IFA,CFACE,IPG,NNO,IGEOM,
     &                                       G,CINEM,JAC,FF,DFDI,ND)
      IMPLICIT NONE 

      INTEGER       JINTER,IFA,CFACE(5,3),IPG,NNO,IGEOM
      REAL*8        JAC,FF(*),DFDI(NNO,3),ND(3)
      CHARACTER*3   CINEM
      CHARACTER*8   ELREFP,FPG

C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 21/08/2007   AUTEUR GENIAUT S.GENIAUT 
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
C RESPONSABLE GENIAUT S.GENIAUT
C
C                   CALCUL DU JACOBIEN DE LA TRANSFORMATION FACETTE
C                       R�ELLE EN 3D � FACETTE DE R�F�RENCE 2D
C                   ET DES FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C               ET DE LA NORMALE � LA FACETTE ORIENT�E DE ESCL -> MAIT
C     ENTREE
C       ELREFP  : TYPE DE L'ELEMENT DE REF PARENT
C       FPG     : FAMILLE DE POINTS DE GAUSS (SCHEMA D'INTEGRATION)
C       PINTER  : COORDONN�ES DES POINTS D'INTERSECTION
C       IFA     : INDINCE DE LA FACETTE COURANTE
C       CFACE   : CONNECTIVIT� DES NOEUDS DES FACETTES
C       IPG     : NUM�RO DU POINTS DE GAUSS
C       NNO     : NOMBRE DE NOEUDS DE L'ELEMENT DE REF PARENT
C       IGEOM   : COORDONNEES DES NOEUDS DE L'ELEMENT DE REF PARENT
C       CINEM   : CALCUL DES QUANTIT�S CIN�MATIQUES 
C                'NON' : ON S'ARRETE APRES LE CALCUL DES FF
C                'DFF' : ON S'ARRETE APRES LE CALCUL DES DERIVEES DES FF
C                'OUI' : ON VA JUSQU'AU BOUT

C
C     SORTIE
C       G       : COORDONN�ES R�ELLES 3D DU POINT DE GAUSS
C       JAC     : PRODUIT DU JACOBIEN ET DU POIDS
C       FF      : FF DE L'�L�MENT PARENT AU POINT DE GAUSS
C       ND      : NORMALE � LA FACETTE ORIENT�E DE ESCL -> MAIT
C
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
      REAL*8          A(3),B(3),C(3),AB(3),AC(3),Y(3),NORME,NAB,G(3)
      REAL*8          RBID,XG,YG,XE(3),DDOT,GRAD(3,3)
      REAL*8          F(3,3),EPS(6),RBID1(3),RBID2(3)
      INTEGER         IBID,IBID1,IBID2,IBID3,IBID4
      INTEGER         J,NNOF,NPGF,IPOIDF,IVFF,IDFDEF,JCOR2D
      CHARACTER*24    COOR2D
C ----------------------------------------------------------------------

      CALL JEMARQ()

      CALL ELREF4('TR3',FPG,IBID1,NNOF,IBID2,IBID3,IPOIDF,IVFF,
     &                                                    IDFDEF,IBID4)
      CALL ASSERT(NNOF.EQ.3)

C     COORDONN�ES DES SOMMETS DE LA FACETTE DANS LE REP�RE GLOBAL 3D
      DO 10 J=1,3
        A(J)=ZR(JINTER-1+3*(CFACE(IFA,1)-1)+J)
        B(J)=ZR(JINTER-1+3*(CFACE(IFA,2)-1)+J)
        C(J)=ZR(JINTER-1+3*(CFACE(IFA,3)-1)+J)
        AB(J)=B(J)-A(J)
        AC(J)=C(J)-A(J)
 10   CONTINUE 

      CALL PROVEC(AB,AC,ND)
      CALL NORMEV(ND,NORME)
      CALL NORMEV(AB,NAB)
      CALL PROVEC(ND,AB,Y)

C     COORDONN�ES DES SOMMETS DE LA FACETTE DANS LE REP�RE LOCAL 2D
      COOR2D='&&JACFF.COOR2D'
      CALL WKVECT(COOR2D,'V V R',6,JCOR2D)
      ZR(JCOR2D-1+1)=0.D0
      ZR(JCOR2D-1+2)=0.D0
      ZR(JCOR2D-1+3)=NAB
      ZR(JCOR2D-1+4)=0.D0
      ZR(JCOR2D-1+5)=DDOT(3,AC,1,AB,1)
      ZR(JCOR2D-1+6)=DDOT(3,AC,1,Y ,1)

C     CALCUL DE JAC EN 2D
      CALL DFDM2D(NNOF,IPG,IPOIDF,IDFDEF,ZR(JCOR2D),RBID1,RBID2,JAC)

C     COORDONN�ES R�ELLES 2D DU POINT DE GAUSS IPG
      XG=0.D0
      YG=0.D0
      DO 20 J=1,NNOF
         XG=XG+ZR(IVFF-1+NNOF*(IPG-1)+J)*ZR(JCOR2D-1+2*J-1)
         YG=YG+ZR(IVFF-1+NNOF*(IPG-1)+J)*ZR(JCOR2D-1+2*J)
 20   CONTINUE

C     COORDONN�ES R�ELLES 3D DU POINT DE GAUSS
      G(1)=A(1)+AB(1)*XG+Y(1)*YG
      G(2)=A(2)+AB(2)*XG+Y(2)*YG
      G(3)=A(3)+AB(3)*XG+Y(3)*YG

C     CALCUL DES FF DE L'�L�MENT PARENT EN CE POINT DE GAUSS
C     (ON MET RBID ET IBID DE PARTOUT CAR ON VA PAS DU TOUT Y TOUCHER)
      CALL REEREF(ELREFP,NNO,IGEOM,G,RBID,.FALSE.,3,RBID,IBID,IBID,
     &              IBID,RBID,RBID,CINEM,XE,FF,DFDI,F,EPS,GRAD)
      CALL JEDETR(COOR2D)

      CALL JEDEMA()
      END
