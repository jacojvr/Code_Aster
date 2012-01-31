      SUBROUTINE FONNO1 (NOMA,NDIM,NA,NB,NBMAC,MACOFO)
      IMPLICIT NONE
      INTEGER             NA,NB,NDIM,NBMAC
      CHARACTER*8         NOMA
      CHARACTER*19        MACOFO
      
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 30/01/2012   AUTEUR MACOCCO K.MACOCCO 
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
C       ----------------------------------------------------------------
C       RECUPERATION DES NUMEROS DES MAILLES CONNECTEES AU 
C       SEGMENT DU FOND -> REMPLISSAGE DU VECTEUR &&FONNOR.MACOFOND
C       ----------------------------------------------------------------
C    ENTREES
C       NOMA  : NOM DU MAILLAGE
C       NDIM  : DIMENSION DU MODELE
C       NA    : NUMERO DU NOEUD SOMMET COURANT
C       NB    : NUMERO DU NOEUD SOMMET SUIVANT
C    SORTIE
C       MACOFO : VECTEUR DES MAILLES (PRINCIPALES) CONNECTEES AU SEGMENT
C                DU FOND DE FISSURE COURANT
C       NBMAC  : NOMBRE DE MAILLES REMPLIES DANS MACOFO
C               
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
      CHARACTER*32     JEXNUM,JEXATR
C     ----- FIN COMMUNS NORMALISES  JEVEUX  ----------------------------
C
      INTEGER       JDRVLC,IATYMA,JMACO,IAMASE,JCNCIN,ITYP
      INTEGER       NBMACA,ADRA,IRET,COMP1,IMA,NUMAC,INO1,NDIME,NN
      CHARACTER*8   K8B, TYPE
      CHARACTER*24  NCNCIN
C     -----------------------------------------------------------------

      CALL JEMARQ()
C
C     RECUPERATION DE LA CONNECTIVITE INVERSE
      NCNCIN = '&&OP0055.CONNECINVERSE'
      CALL JEVEUO ( JEXATR(NCNCIN,'LONCUM'), 'L', JDRVLC )
      CALL JEVEUO ( JEXNUM(NCNCIN,1)       , 'L', JCNCIN )

C
C     RECUPERATION DE L'ADRESSE DES TYPFON DE MAILLES
      CALL JEVEUO ( NOMA//'.TYPMAIL','L',IATYMA)

C     MAILLES CONNECTEES A NA
      ADRA   = ZI(JDRVLC-1 + NA)
      NBMACA = ZI(JDRVLC-1 + NA+1) - ZI(JDRVLC-1 + NA)
C
C     ALLOCATION DU VECTEUR DES MAILLES CONNECTEES AU SEGMENT DU FOND
      CALL WKVECT(MACOFO,'V V I',NBMACA,JMACO)

      COMP1=0
      DO 10 IMA=1,NBMACA
C       NUMERO DE LA MAILLE
        NUMAC = ZI(JCNCIN-1 + ADRA+IMA-1)
        ITYP = IATYMA-1+NUMAC
        CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(ITYP)),TYPE)
        CALL DISMOI('F','DIM_TOPO',TYPE,'TYPE_MAILLE',NDIME,K8B,IRET)
C       ON ZAPPE LES MAILLES DE BORDS
        IF (NDIME.NE.NDIM) GOTO 10

        IF (NDIM.EQ.2) THEN
          COMP1=COMP1+1
          ZI(JMACO-1+COMP1)=NUMAC
        ELSEIF (NDIM.EQ.3) THEN
C         EN 3D ON DOIT AVOIR AUSSI LE NOEUD NB
          CALL JEVEUO(JEXNUM(NOMA//'.CONNEX',NUMAC),'L',IAMASE)
          CALL DISMOI('F','NBNO_TYPMAIL',TYPE,'TYPE_MAILLE',
     &         NN,K8B,IRET)
          DO 100 INO1=1,NN
            IF (ZI(IAMASE-1 + INO1).EQ.NB) THEN
              COMP1=COMP1+1
              ZI(JMACO-1+COMP1)=NUMAC
            ENDIF
 100      CONTINUE
        ENDIF
 10   CONTINUE

C     NB MAILLES CONNECTEES AU SEGMENT
      NBMAC = COMP1
      CALL JEDEMA()
      END
