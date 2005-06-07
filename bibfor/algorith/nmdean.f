      SUBROUTINE NMDEAN (LISCHA,INSTAN,EPAMOI)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 06/12/2000   AUTEUR VABHHTS J.PELLET 
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
      CHARACTER*19       LISCHA
      CHARACTER*19   EPAMOI
      REAL*8                                       INSTAN
C ----------------------------------------------------------------------
C     DETERMINATION DU CHAMP DE DEFORMATIONS ANELASTIQUES
C
C IN  LISCHA  : SD L_CHARGES
C IN  INSTAM  : INSTAM DE LA DETERMINATION
C VAR EPAMOI  : CHAM_ELEM DE DEFORMATIONS ANELASTIQUES
C
C --- DEBUT DECLARATIONS NORMALISEES JEVEUX ----------------------------
C
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
C
C --- FIN DECLARATIONS NORMALISEES JEVEUX ------------------------------
C
      INTEGER            NCHAR,IRET,NUMCHA
      CHARACTER*1        BASE
      CHARACTER*8        EPSI,K8BID
      CHARACTER*16       TYSD
      CHARACTER*19       CH19
      CHARACTER*24       NOM24,LIGRMO
      COMPLEX*16         CBID
C
      CALL JEMARQ()
      BASE   = 'V'
      NUMCHA = 0
C
      CALL JEEXIN(LISCHA // '.LCHA',IRET)
      IF ( IRET .NE. 0 ) THEN
        CALL JELIRA(LISCHA // '.LCHA','LONMAX',NCHAR,K8BID)
        CALL JEVEUO(LISCHA // '.LCHA','L',JCHAR)
C
        CALL JEVEUO(LISCHA // '.INFC','L',JINF)
        NUMCHA = ZI(JINF+4*NCHAR+4)
      ENDIF
      IF ( NUMCHA .GT. 0 ) THEN
        NOM24 = ZK24(JCHAR+NUMCHA-1)(1:8)//'.CHME.EPSI.ANEL '
        CALL JEVEUO(NOM24,'L',JANEL)
        EPSI = ZK8(JANEL)
C
C ----- SI LE CHAMP CHEPSI EXISTE DEJA , ON LE DETRUIT:
C
        CALL DETRSD('CHAMP_GD',EPAMOI)
C
        CALL GETTCO(EPSI,TYSD)
        IF (TYSD(1:9).EQ.'EVOL_NOLI') THEN
          CALL DISMOI('F','NB_CHAMP_UTI',EPSI,'RESULTAT',NBCHAM,
     &                K8BID,IERD)
          IF (NBCHAM.GT.0) THEN
C
C --------- RECUPERATION DU CHAMP DE DEFORMATIONS DANS EPSI
C
            CALL RSINCH(EPSI,'EPSA_ELNO','INST',INSTAN,EPAMOI,
     &                  'CONSTANT','CONSTANT',0,BASE,ICORET)
            IF (ICORET.GE.10) THEN
              CALL UTDEBM('F','NMDEAN','INTERPOLATION DEF.ANELASTIQ. :')
              CALL UTIMPK('L','EVOL_NOLI:',1,EPSI)
              CALL UTIMPR('S','INSTANT:',1,TIME2)
              CALL UTIMPI('L','ICORET:',1,ICORET)
              CALL UTFINM()
            END IF
          ELSE
            CALL UTMESS('F','NMDEAN_01',' LE CONCEPT EVOL_NOLI : '//
     &                 EPSI//' NE CONTIENT AUCUN CHAMP DE DEF.ANELAS.')
          END IF
        END IF

      END IF
C FIN ------------------------------------------------------------------
      CALL JEDEMA()
      END
