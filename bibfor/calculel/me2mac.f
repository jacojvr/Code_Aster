      SUBROUTINE ME2MAC(MODELE,NCHAR,LCHAR,MATE,VECEL)
      IMPLICIT REAL*8 (A-H,O-Z)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 11/09/2002   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2001  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
C (AT YOUR OPTION) ANY LATER VERSION.

C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

C     ARGUMENTS:
C     ----------
      CHARACTER*8 MODELE,LCHAR(*),VECEL
      CHARACTER*24 MATE
      INTEGER NCHAR
C ----------------------------------------------------------------------
C     BUT:
C     CALCUL DE TOUS LES SECONDS MEMBRES ELEMENTAIRES PROVENANT DES
C     CHARGES_ACOUSTIQUES

C     ENTREES:

C     LES NOMS QUI SUIVENT SONT LES PREFIXES UTILISATEUR K8:
C        MODELE : NOM DU MODELE
C        NCHAR  : NOMBRE DE CHARGES
C        LCHAR  : LISTE DES CHARGES
C        MATE   : CARTE DE MATERIAU CODE
C                 SI VECEL EXISTE DEJA, ON LE DETRUIT.

C     SORTIES:
C     SONT TRAITES ACTUELLEMENT LES CHAMPS:
C        LCHAR(ICHA)//'.CHAC.CIMPO     ' : PRESSION    IMPOSEE
C        LCHAR(ICHA)//'.CHAC.VITFA     ' : VITESSE NORMALE FACE

C ----------------------------------------------------------------------

C     FONCTIONS EXTERNES:
C     -------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR

C     VARIABLES LOCALES:
C     ------------------
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL,EXIGEO,EXICAR,LFONC
      CHARACTER*8 ZK8,LPAIN(5),LPAOUT(1),LIPARA(1),K8BID
      CHARACTER*16 ZK16,OPTION
      CHARACTER*24 ZK24,CHGEOM,LCHIN(5),LCHOUT(1)
      CHARACTER*24 LIGRMO,LIGRCH
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80

      CALL JEMARQ()

      CALL MEGEOM(MODELE,LCHAR(1),EXIGEO,CHGEOM)

      CALL JEEXIN(VECEL//'.REFE_RESU',IRET)
      IF (IRET.GT.0) THEN
        CALL JEDETR(VECEL//'.REFE_RESU')
        CALL JEDETR(VECEL//'.LISTE_RESU')
      END IF
      CALL MEMARE('G',VECEL,MODELE,MATE,' ','CHAR_ACOU')
      CALL JECREO(VECEL//'.LISTE_RESU','G V K24')
      LONLIS = MAX(1,5*NCHAR)
      CALL JEECRA(VECEL//'.LISTE_RESU','LONMAX',LONLIS,' ')
      CALL JEVEUO(VECEL//'.LISTE_RESU','E',JLIRES)

      LPAOUT(1) = 'PVECTTC'
      LCHOUT(1) = VECEL//'.VE000'
      ILIRES = 0

C     BOUCLE SUR LES CHARGES POUR CALCULER :
C        ( CHAR_ACOU_VNOR_F , ISO_FACE ) SUR LE MODELE
C         ( ACOU_DDLI_F    , CAL_TI   )  SUR LE LIGREL(CHARGE)


      IF (NCHAR.NE.0) THEN
        LPAIN(1) = 'PGEOMER'
        LCHIN(1) = CHGEOM
        LPAIN(2) = 'PMATERC'
        LCHIN(2) = MATE
        IF (MODELE.NE.'        ') THEN
          LIGRMO = MODELE//'.MODELE'
        ELSE
          CALL JEVEUO(LCHAR(1)//'.CHAC      .NOMO','L',JNOMO)
          LIGRMO = ZK8(JNOMO)//'.MODELE'
        END IF
        DO 10 ICHA = 1,NCHAR
          CALL DISMOI('F','TYPE_CHARGE',LCHAR(ICHA),'CHARGE',IBID,K8BID,
     &                IERD)
          IF (K8BID(5:7).EQ.'_FO') THEN
            LFONC = .TRUE.
          ELSE
            LFONC = .FALSE.
          END IF

          LIGRCH = LCHAR(ICHA)//'.CHAC.LIGRE      '

C           --  ( CHAR_ACOU_VNOR_F , ISO_FACE ) SUR LE MODELE

          CALL EXISD('CHAMP_GD',LIGRCH(1:13)//'.VITFA',IRET)
          IF (IRET.NE.0) THEN
            IF (LFONC) THEN
              OPTION = 'CHAR_ACOU_VNOR_F'
              LPAIN(3) = 'PVITENF'
            ELSE
              OPTION = 'CHAR_ACOU_VNOR_C'
              LPAIN(3) = 'PVITENC'
            END IF
            LCHIN(3) = LIGRCH(1:13)//'.VITFA     '
            ILIRES = ILIRES + 1
            CALL CODENT(ILIRES,'D0',LCHOUT(1) (12:14))
            CALL CALCUL('S',OPTION,LIGRMO,3,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &                  'G')
            CALL EXISD('CHAMP_GD',LCHOUT(1) (1:19),IRET)
            IF (IRET.NE.0) THEN
              ZK24(JLIRES-1+ILIRES) = LCHOUT(1)
              CALL JEECRA(VECEL//'.LISTE_RESU','LONUTI',ILIRES,' ')
            ELSE
              ILIRES = ILIRES - 1
            END IF
          END IF
C           --   ( ACOU_DDLI_F    , CAL_TI   )  SUR LE LIGREL(CHARGE)
          CALL EXISD('CHAMP_GD',LIGRCH(1:13)//'.CIMPO',IRET)
          IF (IRET.NE.0) THEN
            IF (LFONC) THEN
              OPTION = 'ACOU_DDLI_F'
              LPAIN(3) = 'PDDLIMF'
            ELSE
              OPTION = 'ACOU_DDLI_C'
              LPAIN(3) = 'PDDLIMC'
            END IF
            LCHIN(3) = LIGRCH(1:13)//'.CIMPO     '
            ILIRES = ILIRES + 1
            CALL CODENT(ILIRES,'D0',LCHOUT(1) (12:14))
            CALL CALCUL('S',OPTION,LIGRCH,3,LCHIN,LPAIN,1,LCHOUT,LPAOUT,
     &                  'G')
            CALL EXISD('CHAMP_GD',LCHOUT(1) (1:19),IRET)
            IF (IRET.NE.0) THEN
              ZK24(JLIRES-1+ILIRES) = LCHOUT(1)
              CALL JEECRA(VECEL//'.LISTE_RESU','LONUTI',ILIRES,' ')
            ELSE
              ILIRES = ILIRES - 1
            END IF
          END IF
   10   CONTINUE
      END IF

   20 CONTINUE
      CALL JEDEMA()
      END
