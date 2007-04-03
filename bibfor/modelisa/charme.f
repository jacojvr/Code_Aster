      SUBROUTINE CHARME ( FONREE )

C MODIF MODELISA  DATE 03/04/2007   AUTEUR DURAND C.DURAND 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
      IMPLICIT NONE
      CHARACTER*4         FONREE

C ----------------------------------------------------------------------
C
C      OPERATEURS :     AFFE_CHAR_MECA ET AFFE_CHAR_MECA_C
C                                      ET AFFE_CHAR_MECA_F
C
C      MOTS-CLES ACTUELLEMENT TRAITES:
C
C        MODELE
C        TEMP_CALCULEE
C        EPSA_CALCULEE
C        EVOL_CHAR
C        PESANTEUR
C        ROTATION
C        DDL_IMPO, FACE_IMPO
C        LIAISON_DDL, LIAISON_OBLIQUE
C        FORCE_NODALE
C        CHARGE_REP: FORCE_CONTOUR FORCE_INTERNE FORCE_ARETE
C                    FORCE_FACE    FORCE_POUTRE  FORCE_COQUE
C        RELA_CINE_BP
C        EPSI_INIT
C        PRES_REP
C        FLUX_THM_REP
C        FORCE_ELEC
C        INTE_ELEC
C        VITE_FACE
C        ONDE_FLUI
C        IMPE_FACE
C        ONDE_PLANE
C        CONTACT
C        LIAISON_GROUP
C        LIAISON_UNIF
C        LIAISON_SOLIDE
C        LIAISON_ELEM
C        LIAISON_CHAMNO
C        LIAISON_COQUE
C        LIAISON_MAIL
C        LIAISON_CYCL
C ----------------------------------------------------------------------
C --------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER           ZI
      COMMON / IVARJE / ZI(1)
      REAL*8            ZR
      COMMON / RVARJE / ZR(1)
      COMPLEX*16        ZC
      COMMON / CVARJE / ZC(1)
      LOGICAL           ZL
      COMMON / LVARJE / ZL(1)
      CHARACTER*8       ZK8
      CHARACTER*16              ZK16
      CHARACTER*24                       ZK24
      CHARACTER*32                                ZK32
      CHARACTER*80                                         ZK80
      COMMON / KVARJE / ZK8(1), ZK16(1), ZK24(1), ZK32(1), ZK80(1)
C     ----------- COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER      NBOCC(6), I, IFACE, IGREL, INEMA, IRET,
     &             NDIM, NBET, IRET2,IBID
      CHARACTER*5  PARAM(7),PARA
      CHARACTER*8  CHAR, NOMA, NOMO
      CHARACTER*16 TYPE, OPER , CHREP(6), MOTFAC
      CHARACTER*19 LIGRCH, LIGRMO, LIGRET, LIGREL
C
      DATA CHREP / 'FORCE_CONTOUR' , 'FORCE_INTERNE' , 'FORCE_ARETE' ,
     &             'FORCE_FACE'    , 'FORCE_POUTRE'  , 'FORCE_COQUE'   /
      DATA PARAM / 'F1D2D'         , 'F3D3D'         , 'F1D3D'       ,
     &             'F2D3D'         , 'F1D1D'         , 'FCO3D'       ,
     &             'FCO2D'         /
C     ------------------------------------------------------------------
C
C
      CALL GETRES ( CHAR, TYPE, OPER )
C
C --- NOMS DE LIGREL, MAILLAGE , DIMENSION DU PB
C
      CALL CAGENE ( CHAR, OPER, LIGRMO, NOMA, NDIM )
      NOMO = LIGRMO(1:8)
C
C --- ALLOCATION DU LIGREL DE CHARGE
C                  (DDL-IMPO, FORCE_NO, FACE_IMPO,LIAISON_GROUP)
C
      CALL ALLIGR ( CHAR, OPER, NOMA, FONREE, LIGRCH )
C
C       IFACE = INDICATEUR DE PRESENCE A LA FOIS DE DDL_IMPO ET
C       FACE_IMPO AVEC AU MOINS UN BLOCAGE DE TYPE DX DY DZ DRX ....
C       (NECESSAIRE POUR LA REGLE DE SURCHARGE ENTRE LES 2 MOTS-CLE )
C
      IF (FONREE.NE.'COMP') THEN
         IFACE = 0
         CALL DDLFAC ( FONREE, IFACE )
      ENDIF
C
C
      IGREL = 0
      INEMA = 0
C
C --- FORCE_NODALE ---
C
      IF (FONREE.NE.'COMP') THEN
C         ================
         CALL CAFONO ( CHAR, LIGRCH, IGREL, INEMA, NOMA, LIGRMO, FONREE)
      ENDIF
C
C --- CHARGES REPARTIES: FORCE_CONTOUR FORCE_INTERNE FORCE_ARETE
C                        FORCE_FACE    FORCE_POUTRE  FORCE_COQUE
C
      DO 10 I = 1,6
         IF (FONREE.EQ.'COMP'.AND.CHREP(I).NE.'FORCE_POUTRE') THEN
           NBOCC(I) = 0
         ELSE
           CALL GETFAC ( CHREP(I) , NBOCC(I) )
         ENDIF
   10 CONTINUE
C
C --- VERIFICATION DE LA DIMENSION DES TYPE_ELEM DU MODELE ---
C
      IF (NDIM.GT.3) CALL U2MESS('A','MODELISA4_4')
C
      IF ( NDIM .EQ. 3 ) THEN
         DO 20 I = 1 , 6
            IF ( NBOCC(I) .NE. 0 ) THEN
C
               CALL CACHRE ( CHAR , LIGRMO ,  NOMA , NDIM ,
     &                       FONREE , PARAM(I) , CHREP(I) )

            ENDIF
   20    CONTINUE
C
      ELSE
         DO 15 I = 4 , 5
            IF ( NBOCC(I) .NE. 0 ) THEN
C            --------- FORCE_FACE    INTERDIT EN 2D
C            --------- FORCE_POUTRE  INTERDIT EN 2D
               CALL U2MESK('A','MODELISA4_5',1,CHREP(I))
           ENDIF
   15    CONTINUE
         DO 25 I = 1 , 6
            IF ( NBOCC(I) .NE. 0 ) THEN
C
               PARA = PARAM(I)
C    CAS DE FORCE INTERNE EN 2D
               IF ( I .EQ. 2 ) PARA = 'F2D2D'
C    CAS DES COQCYL AXI
               IF ( I .EQ. 6 .AND. NDIM . EQ. 2 ) PARA = 'FCO2D'
               CALL CACHRE ( CHAR , LIGRMO ,  NOMA , NDIM ,
     &                       FONREE , PARA , CHREP(I) )
            ENDIF
   25    CONTINUE
      ENDIF
C
      IF (FONREE.NE.'COMP') THEN
C         ================
C
C --- DEFORMATION INITIALE ----
C
         CALL CBCHEI ( CHAR, NOMA, LIGRMO, NDIM, FONREE )
C
C --- SIGM_INTERNE ----
C
         CALL CBSINT ( CHAR, NOMA, LIGRMO, NDIM, FONREE )
C
C --- PRESSION ---
C
         CALL CBPRES ( CHAR, NOMA, LIGRMO, NDIM, FONREE )
C
C --- CONTACT UNILATERAL GRANDS DEPLACEMENTS
C
         CALL CALICO ( CHAR, NOMA, LIGRMO, NDIM, FONREE )
C
C --- LIAISON UNILATERALE SIMPLE
C
         CALL CALIUN ( CHAR, NOMA, LIGRMO, NDIM, FONREE )
C
C --- VITE_FACE ---
C
         CALL CBVITN ( CHAR, NOMA, LIGRMO, FONREE )
C
C --- IMPE_FACE ---
C
         CALL CBIMPD ( CHAR, NOMA, LIGRMO, FONREE )
C
      ENDIF
C
C --- TEMPERATURE, PRESSION, PESANTEUR, ROTATION, FORCES ELECTROS
C     DEFORMATIONS PLANES GENERALISEES, LIAISON UNILATERALE,
C     DEFORMATIONS ANELASTIQUES, RELA_CINE_BP ---
C
      IF (FONREE.EQ.'REEL') THEN
C         ================
         CALL CBTEMP ( CHAR )
         CALL CBPRCA ( CHAR )
         CALL CBPESA ( CHAR, NOMA )
         CALL CBROTA ( CHAR, NOMA )
         CALL CAPREC ( CHAR, NOMA )
C
C --- FORCE_ELEC ----
C
         CALL CBELEC ( CHAR, LIGRMO, NOMA )
C
C --- GRAPPE_FLUIDE ----
C
         CALL CAGRFL ( CHAR, NOMA )
C
C --- FORCES DE LAPLACE ----
C
         CALL CBLAPL ( CHAR, LIGRMO, NOMA )
C
C --- ONDE_FLUI ---
C
         CALL CBONDE ( CHAR, NOMA, LIGRMO, FONREE )
C
C --- DDL_POUTRE ---
C
         CALL CADDLP ( FONREE, CHAR )
C
      ENDIF
C
C --- ONDE_PLANE ---
C
      IF (FONREE.EQ.'FONC') THEN
C         ================
         CALL CBONDP( CHAR, NOMA )
      ENDIF
C
C --- SI DDL_IMPO OU(ET) FACE_IMPO :
C        DESTRUCTION DES 3 OBJETS TEMPORAIRES SERVANT A LA SURCHARGE
C
      CALL JEEXIN ( '&&CAFACI.DESGI', IRET )
      IF (IRET.NE.0) THEN
         CALL JEDETR ( '&&CAFACI.VALDDL'      )
         CALL JEDETR ( '&&CAFACI.DESGI'       )
         CALL JEDETR ( '&&CAFACI.NOMS_NOEUDS' )
      ENDIF
C
C --- DDL_IMPO ---
C
      MOTFAC = 'DDL_IMPO        '
      CALL CADDLI ( OPER, MOTFAC, FONREE, CHAR )
C
C --- LIAISON_XFEM ---
C
      CALL CAXFEM ( FONREE, CHAR )
C
C --- LIAISON_DDL ---
C
      CALL CALIAI ( FONREE, CHAR )
C
      IF (FONREE.EQ.'REEL') THEN
C         ================
C
C --- LIAISON_MAIL ---
C
         CALL CALIRC ( CHAR )
C
C --- LIAISON_CYCL ---
C
         CALL CALYRC ( CHAR )
C
C --- LIAISON_ELEM ---
C
         CALL CALIEL ( FONREE, CHAR )
C
C --- LIAISON_CHAMNO ---
C
         CALL CALICH ( CHAR )
C
C --- VECT_ASSE ---
C
         CALL CAVEAS (CHAR)
C
C --- ARLEQUIN ---
C
         CALL CAARLE (CHAR)
C
C
C --- CHAMNO_IMPO ---
C
         CALL CAIMCH ( CHAR )

      ENDIF
C
      IF (FONREE.NE.'COMP') THEN
C         ================
C
C --- FACE_IMPO ---
C
         CALL CAFACI ( FONREE, CHAR )
C
C --- LIAISON_OBLIQUE ---
C
         CALL CALIOB ( FONREE, CHAR )
C
C --- LIAISON_GROUP ---
C
         CALL CALIAG ( FONREE, CHAR )
CLIAISON_CYC
C --- LIAISON_UNIF ---
C
         CALL CAGROU ( FONREE, CHAR )
C
C --- LIAISON_SOLIDE ---
C
         CALL CALISO ( CHAR )
C
C --- LIAISON_COQUE ---
C
         CALL CALICP ( CHAR )
C
      ENDIF
C
      LIGRET = '&&CALICO.LIGRET'
      LIGREL = '&&CALICO.LIGREL'
      CALL JEEXIN(LIGRET//'.NOMA',IRET2)
      IF (IRET2.NE.0) THEN
C
C ---   CREATION DU LIGREL A PARTIR DU LIGRET DANS LE CAS DU CONTACT
C ---   'CONTINU' :
C       ---------
        CALL LGTLGR('V',LIGRET,LIGREL)
      ENDIF
      CALL DETRSD('LIGRET',LIGRET)
      CALL JEEXIN(LIGRCH//'.NOMA',IRET)
      IF (IRET.NE.0) THEN
         IF (IRET2.NE.0) THEN
C
C ---      CONCATENATION DU LIGREL DE CONTACT 'CONTINU' ET DU
C ---      LIGREL DE CHARGE :
C          ----------------
           CALL COLIGR('G',LIGREL,LIGRCH,LIGRCH)
         ENDIF
      ELSE
        IF (IRET2.NE.0) THEN
C
C ---      S'IL N'Y A QUE LE LIGREL DE CONTACT 'CONTINU' , ON LE COPIE
C ---      SUR LE LIGREL DE CHARGE :
C          -----------------------
          CALL COPISD('LIGREL','G',LIGREL,LIGRCH)
        ENDIF
      ENDIF
      CALL DETRSD('LIGREL',LIGREL)
C
C --- MISE A JOUR DU LIGREL DE CHARGE SI IL EXISTE EN FONCTION
C     DE LA TAILLE MAX DES .RESL
C
      CALL JEEXIN (LIGRCH//'.NOMA', IRET )
      IF (IRET.NE.0) THEN
        CALL ADALIG(LIGRCH)
        CALL INITEL(LIGRCH)
        CALL JEECRA(LIGRCH//'.NOMA','DOCU',IBID,'MECA')
      ENDIF
C
      CALL JEDETC('V',CHAR,1)
C
      IF (FONREE.EQ.'COMP') GOTO 9999
C         ================
C
C     VERIFICATION DES NORMALES AUX MAILLES SURFACIQUES EN 3D
C     ET LINEIQUES EN 2D
C
      CALL CHVENO ( FONREE, NOMA, NOMO )
C
 9999 CONTINUE
      END
