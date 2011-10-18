      SUBROUTINE XPRLS(NOMA,CNSLN,CNSLT,GRLN,GRLT,CNSVN,CNSVT,
     &                 CNSBL,DELTAT,NODTOR,ELETOR,LIGGRD,DELTA)
      IMPLICIT NONE
      REAL*8         DELTAT
      CHARACTER*8    NOMA
      CHARACTER*19   CNSLN,CNSLT,GRLN,GRLT,CNSVN,CNSVT,CNSBL,NODTOR,
     &               ELETOR,LIGGRD,DELTA

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 18/10/2011   AUTEUR COLOMBO D.COLOMBO 
C ======================================================================
C COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE MASSIN P.MASSIN
C     ------------------------------------------------------------------
C
C       XPRLS   : X-FEM PROPAGATION DES LEVEL SETS
C       -----     -     --              -     -
C    PROPAGATION DES LEVEL SETS AU PAS DE TEMP SUIVANT
C
C    ENTREE
C        MODEL   : NOM DU CONCEPT MODELE
C        NOMA    : NOM DU CONCEPT MAILLAGE
C        CNSLT   : CHAM_NO_S LEVEL SET TANGENTIELLE
C        CNSLN   : CHAM_NO_S LEVEL SET NORMALE
C        GRLT    : CHAM_NO_S GRADIENT DE LEVEL SET TANGENTIELLE
C        GRLN    : CHAM_NO_S GRADIENT DE LEVEL SET NORMALE
C        CNSVN   : CHAM_NO_S DES COMPOSANTES NORMALES DE LA VITESSE DE
C                  PROPAGATION
C        CNSVT   : CHAM_NO_S DES COMPOSANTES TANGENTES DE LA VITESSE DE
C                  PROPAGATION
C        CNSBL   : CHAM_NO_S DES VECTEURS NORMALE ET TANGENTIELLE DE LA
C                  BASE LOCALE
C                  IN CHAQUE NODE DU MAILLAGE
C        DELTAT  : TEMPS TOTAL D'INTEGRATION
C        NODTOR  : LISTE DES NOEUDS DEFINISSANT LE DOMAINE DE CALCUL
C        ELETOR  : LISTE DES ELEMENTS DEFINISSANT LE DOMAINE DE CALCUL
C        LIGGRD  : LIGREL DU DOMAINE DE CALCUL (VOIR XPRTOR.F)
C        DELTA   : VECTEUR CONTENANT LES CORRECTIONS A APPORTER AU 
C                  LEVELS SETS
C
C    SORTIE
C        CNSLT   : CHAM_NO_S LEVEL SET TANGENTIELLE
C        CNSLN   : CHAM_NO_S LEVEL SET NORMALE
C        GRLT    : CHAM_NO_S GRADIENT DE LEVEL SET TANGENTIELLE
C        GRLN    : CHAM_NO_S GRADIENT DE LEVEL SET NORMALE
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

      INTEGER    I,IFM,NIV,NBNO,IRET,JLTNO,JLNNO,JGRTNO,JGRNNO,NDIM,
     &           J,JELCAL,JNODTO,NODE,NBNOMA,IER
      INTEGER    IBID,NELETO,JDELTA
      CHARACTER*8      K8B,LPAIN(2),LPAOUT(1)
      CHARACTER*19     CHGRLT,CHGRLN,CHAMS,CNOLT,CNOLN
      CHARACTER*24     LCHIN(2),LCHOUT(1)
      REAL*8           NORMGN,NORMGT

      REAL*8           R8MIEM,R8PREM,VNSCGN,VTSCGT
      CHARACTER*8      TYPCMP(3),KBID
      CHARACTER*19     CNSVVT,CNSVVN
      INTEGER          JVTV,JVTL,JVNV,JVNL,JCNSVN,JCNSVT

      INTEGER JBL

C-----------------------------------------------------------------------
C     DEBUT
C-----------------------------------------------------------------------

      CALL JEMARQ()
      CALL INFMAJ()
      CALL INFNIV(IFM,NIV)

C     RETRIEVE THE LOCAL REFERENCE SYSTEM FOR EACH NODE IN THE MESH
      CALL JEVEUO(CNSBL//'.CNSV','E',JBL)

C     RECUPERATION DE CARACTERISTIQUES DU MAILLAGE
      CALL DISMOI('F','NB_NO_MAILLA',NOMA,'MAILLAGE',NBNOMA,K8B,IRET)

C     RETRIEVE THE DIMENSION OF THE PROBLEM (2D AND 3D ARE SUPPORTED)
      CALL DISMOI('F','DIM_GEOM',NOMA,'MAILLAGE',NDIM,KBID,IRET)

C     RETRIEVE THE NUMBER OF THE NODES THAT MUST TO BE USED IN THE
C     CALCULUS (SAME ORDER THAN THE ONE USED IN THE CONNECTION TABLE)
      CALL JEVEUO(NODTOR,'L',JNODTO)

C     RETRIEVE THE TOTAL NUMBER OF THE NODES THAT MUST BE ELABORATED
      CALL JELIRA(NODTOR,'LONMAX',NBNO,K8B)

C     RETRIEVE THE LIST OF THE ELEMENTS SUPPORTING THE NODES IN THE TORE
      CALL JEVEUO(ELETOR,'L',JELCAL)

C     RETRIEVE THE NUMBER OF ELEMENTS DEFINING THE TORE
      CALL JELIRA(ELETOR,'LONMAX',NELETO,K8B)

C     RETRIEVE THE correction to give to the level set at the node
C     projeted on the virtual front
      CALL JEVEUO(DELTA,'L',JDELTA)

C ***************************************************************
C CALCULATE THE NORMAL AND TANGENTIAL PROPAGATION SPEED VECTOR FOR
C EACH NODE IN THE MESH (WITH RESPECT TO THE CRACK PLANE).
C ***************************************************************

C     CREATION OF THE NORMAL AND TANGENTIAL PROPAGATION SPEED VECTORS
C     DATA STRUCTURES (CHAMP_NO_S)
      CNSVVT = '&&XPRLS.CNSVT'
      CNSVVN = '&&XPRLS.CNSVN'
      TYPCMP(1)='X1'
      TYPCMP(2)='X2'
      TYPCMP(3)='X3'
      CALL CNSCRE(NOMA,'NEUT_R',NDIM,TYPCMP,'V',CNSVVT)
      CALL CNSCRE(NOMA,'NEUT_R',NDIM,TYPCMP,'V',CNSVVN)

      CALL JEVEUO(CNSVVT//'.CNSV','E',JVTV)
      CALL JEVEUO(CNSVVT//'.CNSL','E',JVTL)
      CALL JEVEUO(CNSVVN//'.CNSV','E',JVNV)
      CALL JEVEUO(CNSVVN//'.CNSL','E',JVNL)

C     RETRIEVE THE GRADIENT OF THE TWO LEVEL SETS
      CALL JEVEUO(GRLT//'.CNSV','E',JGRTNO)
      CALL JEVEUO(GRLN//'.CNSV','E',JGRNNO)

C     RETRIEVE THE NORMAL AND TANGENTIAL PROPAGATION SPEEDS (SCALAR
C     VALUE). THESE VALUES WILL BE USED BELOW TO CALCULATE THE
C     PROPAGATION SPEED VECTORS FOR EACH NODE
      CALL JEVEUO(CNSVN//'.CNSV','L',JCNSVN)
      CALL JEVEUO(CNSVT//'.CNSV','L',JCNSVT)

C     ELABORATE EACH NODE IN THE TORE
      DO 400 I=1,NBNO

C         RETREIVE THE NODE NUMBER
          NODE = ZI(JNODTO-1+I)

C           EVALUATE THE SPEED VECTORS
            CALL JEVEUO(CNSLT//'.CNSV','E',JLTNO)

C           CHECK IF THE NODE IS ON THE EXISTING CRACK SURFACE
            IF (ZR(JLTNO-1+NODE).LT.R8MIEM()) THEN

C              CALCULATE THE NORM OF THE GRADIENTS IN ORDER TO EVALUATE
C              THE NORMAL AND TANGENTIAL UNIT VECTORS
               IF(NDIM.EQ.2) THEN
                 NORMGT = ( ZR(JGRTNO-1+2*(NODE-1)+1)**2.D0 +
     &                      ZR(JGRTNO-1+2*(NODE-1)+2)**2.D0 )**.5D0
                 NORMGN = ( ZR(JGRNNO-1+2*(NODE-1)+1)**2.D0 +
     &                      ZR(JGRNNO-1+2*(NODE-1)+2)**2.D0 )**.5D0
               ELSE
                 NORMGT = ( ZR(JGRTNO-1+3*(NODE-1)+1)**2.D0 +
     &                      ZR(JGRTNO-1+3*(NODE-1)+2)**2.D0 +
     &                      ZR(JGRTNO-1+3*(NODE-1)+3)**2.D0 )**.5D0
                 NORMGN = ( ZR(JGRNNO-1+3*(NODE-1)+1)**2.D0 +
     &                      ZR(JGRNNO-1+3*(NODE-1)+2)**2.D0 +
     &                      ZR(JGRNNO-1+3*(NODE-1)+3)**2.D0 )**.5D0
               ENDIF

C              IF THE TANGENTIAL LEVELSET IS NEGATIVE, THE NODE BELONGS
C              TO THE EXISTING CRACK SURFACE. THEREFORE THE GRADIENT OF
C              THE LEVEL SETS IS A GOOD CANDIDATE FOR THE LOCAL
C              REFERENCE SYSTEM.
               DO 405 J=1,NDIM
                 IF(NORMGN.GT.R8PREM()) THEN
                    ZR(JVNV-1+NDIM*(NODE-1)+J) = ZR(JCNSVN-1+NODE)*
     &                              ZR(JGRNNO-1+NDIM*(NODE-1)+J)/NORMGN
                 ELSE
                    ZR(JVNV-1+NDIM*(NODE-1)+J) = 0.D0
                 ENDIF

                 IF(NORMGT.GT.R8PREM()) THEN
                    ZR(JVTV-1+NDIM*(NODE-1)+J) = ZR(JCNSVT-1+NODE)*
     &                              ZR(JGRTNO-1+NDIM*(NODE-1)+J)/NORMGT
                 ELSE
                    ZR(JVTV-1+NDIM*(NODE-1)+J) = 0.D0
                 ENDIF
405            CONTINUE

            ELSE

C              IF THE TANGENTIAL LEVELSET IS POSITIVE, THE LOCAL
C              REFERENCE SYSTEM CALCULATED PREVIOUSLY FROM THE
C              INFORMATIONS ON THE CRACK FRONT CAN BE USED
               DO 406 J=1,NDIM
                 ZR(JVNV-1+NDIM*(NODE-1)+J) = ZR(JCNSVN-1+NODE)*
     &                                     ZR(JBL-1+2*NDIM*(NODE-1)+J)
                 ZR(JVTV-1+NDIM*(NODE-1)+J) = ZR(JCNSVT-1+NODE)*
     &                                ZR(JBL-1+2*NDIM*(NODE-1)+NDIM+J)
406            CONTINUE

            ENDIF

400   CONTINUE

C ***************************************************************
C UPDATE THE LEVEL SETS
C ***************************************************************

C     CREATION DES OBJETS VOLATILES
      CHGRLT = '&&XPRLS.CHGRLT'
      CHGRLN = '&&XPRLS.CHGRLN'
      CHAMS  = '&&XPRLS.CHAMS'
      CNOLT  = '&&XPRLS.CNOLT'
      CNOLN  = '&&XPRLS.CNOLN'

C     RECUPERATION DE L'ADRESSE DES VALEURS DE LT, LN ET LEURS GRADIENTS
      CALL JEVEUO(CNSLT//'.CNSV','E',JLTNO)
      CALL JEVEUO(CNSLN//'.CNSV','E',JLNNO)
      CALL JEVEUO(GRLT//'.CNSV','E',JGRTNO)
      CALL JEVEUO(GRLN//'.CNSV','E',JGRNNO)

C     UPDATE THE LEVEL SETS FOR EACH NODE IN THE TORE
      DO 100 I=1,NBNO

C         RETREIVE THE NODE NUMBER
          NODE = ZI(JNODTO-1+I)

          VNSCGN = 0.D0
          VTSCGT = 0.D0

          DO 105 J=1,NDIM

C            SCALAR PRODUCT BETWEEN THE NORMAL PROPAGATION SPEED
C            VECTOR AND THE NORMAL GRADIENT
             VNSCGN = VNSCGN +
     &          ZR(JVNV-1+NDIM*(NODE-1)+J)*ZR(JGRNNO-1+NDIM*(NODE-1)+J)

C            SCALAR PRODUCT BETWEEN THE TANGENTIAL PROPAGATION SPEED
C            VECTOR AND  THE TANGENTIAL GRADIENT
             VTSCGT = VTSCGT +
     &         ZR(JVTV-1+NDIM*(NODE-1)+J)*ZR(JGRTNO-1+NDIM*(NODE-1)+J)



105       CONTINUE

C         UPDATE THE LEVEL SETS
          IF(ZR(JLTNO-1+NODE).GT.R8PREM()) THEN
             ZR(JLNNO-1+NODE)=ZR(JLNNO-1+NODE)-DELTAT*VNSCGN+
     &          ZR(JDELTA+2*(NODE-1))
          ELSE
             ZR(JLNNO-1+NODE)=ZR(JLNNO-1+NODE)-DELTAT*VNSCGN
          ENDIF
          ZR(JLTNO-1+NODE)=ZR(JLTNO-1+NODE)-DELTAT*VTSCGT
     &               +ZR(JDELTA+2*(NODE-1)+1)


 100  CONTINUE

C-----------------------------------------------------------------------
C     CALCUL DES GRADIENTS DES LEVEL SETS RESULTANTES
C-----------------------------------------------------------------------

C  GRADIENT DE LT
      CALL CNSCNO(CNSLT,' ','NON','V',CNOLT,'F',IBID)

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = NOMA//'.COORDO'
      LPAIN(2) = 'PNEUTER'
      LCHIN(2) = CNOLT
      LPAOUT(1)= 'PGNEUTR'
      LCHOUT(1)= CHGRLT

      CALL CALCUL('S','GRAD_NEUT_R',LIGGRD,2,LCHIN,LPAIN,1,
     &            LCHOUT,LPAOUT,'V','OUI')

      CALL CELCES ( CHGRLT, 'V', CHAMS )
      CALL CESCNS ( CHAMS, ' ', 'V', GRLT, ' ', IER )

C  GRADIENT DE LN
      CALL CNSCNO(CNSLN,' ','NON','V',CNOLN,'F',IBID)

      LPAIN(1) = 'PGEOMER'
      LCHIN(1) = NOMA//'.COORDO'
      LPAIN(2) = 'PNEUTER'
      LCHIN(2) = CNOLN
      LPAOUT(1)= 'PGNEUTR'
      LCHOUT(1)= CHGRLN

      CALL CALCUL('S','GRAD_NEUT_R',LIGGRD,2,LCHIN,LPAIN,1,
     &            LCHOUT,LPAOUT,'V','OUI')

      CALL CELCES ( CHGRLN, 'V', CHAMS )
      CALL CESCNS ( CHAMS, ' ', 'V', GRLN, ' ', IER )

C  DESTRUCTION DES OBJETS VOLATILES
      CALL JEDETR(CHGRLT)
      CALL JEDETR(CHGRLN)
      CALL JEDETR(CHAMS)
      CALL JEDETR(CNOLT)
      CALL JEDETR(CNOLN)
      CALL JEDETR(CNSVVT)
      CALL JEDETR(CNSVVN)

C-----------------------------------------------------------------------
C     FIN
C-----------------------------------------------------------------------
      CALL JEDEMA()
      END
