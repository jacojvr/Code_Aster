      SUBROUTINE NMVCD2(INDEZ,CHMAT,EXIVC,EXIREF)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 28/01/2008   AUTEUR PELLET J.PELLET 
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

      CHARACTER*(*) INDEZ
      CHARACTER*(*) CHMAT
      LOGICAL       EXIVC,EXIREF


C ------------------------------------------------------------------
C  TEST SI UNE VARIABLE DE COMMANDE EST PRESENTE
C ------------------------------------------------------------------
C IN   INDEX   K8  INDEX DE LA VARIABLE DE COMMANDE
C IN   CHMAT   K*  SD CHMAT
C OUT  EXIVC    L  TRUE : VARIABLE DE COMMANDE EST PRESENTE
C OUT  EXIREF   L  TRUE :VARIABLE DE COMMANDE (VALE_REF) EST PRESENTE
C ----------------------------------------------------------------------

C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------


      INTEGER  NMAX,JCVVAR,I,IRET1,IRET2,JCVEXI
      CHARACTER*1 K1BID
      CHARACTER*8 INDEX,CHMAT8

      CALL JEMARQ()
      CHMAT8=CHMAT
      INDEX=INDEZ
      EXIVC=.FALSE.
      CALL JEEXIN(CHMAT8// '.CVRCVARC',IRET1)
      IF ( IRET1.NE.0) THEN
        CALL JELIRA(CHMAT8// '.CVRCVARC','LONMAX',NMAX,K1BID)
        CALL JEVEUO(CHMAT8// '.CVRCVARC','L',JCVVAR)
        DO 1 I=1,NMAX
          IF (ZK8(JCVVAR-1+I).EQ.INDEX) THEN
            EXIVC=.TRUE.
            GOTO 2
          ENDIF
1       CONTINUE
2       CONTINUE
      ENDIF


      EXIREF=.FALSE.
      CALL JEEXIN(CHMAT8//'.'//INDEX//'.1.VALE',IRET1)
      IF (IRET1.NE.0) EXIREF=.TRUE.


      CALL JEDEMA
      END
