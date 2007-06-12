      SUBROUTINE FCENT(NOMTE,XI,NB1,VECL)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 11/04/97   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.      
C ======================================================================
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*16  NOMTE
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX --------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX --------------------
C
      INTEGER NB1
      REAL*8 RHO,EPAIS,PESAN,DETJ
      REAL*8 XI(3,*),VOMEGA(3),VECL(51),VECL1(42)
C     REAL*8 VECTC(3),VECPTX(3,3)
C
      CALL JEVECH ('PROTATR','L',IROTA)
      VOMEGA(1)=ZR(IROTA)*ZR(IROTA+1)
      VOMEGA(2)=ZR(IROTA)*ZR(IROTA+2)
      VOMEGA(3)=ZR(IROTA)*ZR(IROTA+3)
C
      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESI',' ', LZI )
      NB1  =ZI(LZI-1+1)
      NPGSN=ZI(LZI-1+4)
C
      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESR',' ', LZR )
C
      CALL DXROEP(RHO,EPAIS)
C
      CALL R8INIR(42,0.D0,VECL1,1)
C
      DO 40 INTSN=1,NPGSN
C        CALL VECTCI(INTSN,NB1,XI,ZR(LZR),VECTC,RNORMC,VECPTX)
         CALL VECTCI(INTSN,NB1,XI,ZR(LZR),RNORMC)
         CALL FORCEN(RNORMC,INTSN,NB1,XI,ZR(LZR),RHO,EPAIS,VOMEGA,VECL1)
 40   CONTINUE
C
      CALL VEXPAN(NB1,VECL1,VECL)
      DO 60 I=1,3
         VECL(6*NB1+I)=0.D0
 60   CONTINUE
C
      END
