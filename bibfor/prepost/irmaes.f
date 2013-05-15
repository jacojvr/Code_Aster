      SUBROUTINE IRMAES(IDFIMD,NOMAAS,NOMAMD,NBIMPR,CAIMPI,
     &                  MODNUM,NUANOM,NOMTYP,NNOTYP,SDCARM)
      IMPLICIT NONE
C
      INTEGER NTYMAX
      PARAMETER (NTYMAX = 69)
C
      CHARACTER*8   NOMAAS,NOMTYP(*),SDCARM
      CHARACTER*64  NOMAMD
      INTEGER       NBIMPR,CAIMPI(10,NBIMPR),MODNUM(NTYMAX)
      INTEGER       NNOTYP(*),NUANOM(NTYMAX,*)
      INTEGER       IDFIMD,NVTYGE
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 07/05/2013   AUTEUR SELLENET N.SELLENET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2013  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE SELLENET N.SELLENET
C ----------------------------------------------------------------------
C  IMPR_RESU - IMPRESSION DANS LE MAILLAGE DES ELEMENTS DE STRUCTURE
C  -    -                         --           -           -
C ----------------------------------------------------------------------
C
C IN  :
C   IDFIMD  K*   ENTIER LIE AU FICHIER MED OUVERT
C   NOMAAS  K8   NOM DU MAILLAGE ASTER
C   NOMAMD  K*   NOM DU MAILLAGE MED
C   NBIMPR  K*   NOMBRE D'IMPRESSIONS
C   CAIMPI  K*   ENTIERS POUR CHAQUE IMPRESSION
C   MODNUM  I(*) INDICATEUR SI LA SPECIFICATION DE NUMEROTATION DES
C                NOEUDS DES MAILLES EST DIFFERENTES ENTRE ASTER ET MED
C   NUANOM  I*   TABLEAU DE CORRESPONDANCE DES NOEUDS MED/ASTER.
C                NUANOM(ITYP,J): NUMERO DANS ASTER DU J IEME NOEUD DE LA
C                MAILLE DE TYPE ITYP DANS MED.
C   NOMTYP  K8(*)NOM DES TYPES POUR CHAQUE MAILLE
C   NNOTYP  I(*) NOMBRE DE NOEUDS PAR TYPES DE MAILLES
C   SDCARM  K*   SD_CARA_ELEM EN CHAM_ELEM_S
C
C
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXATR
C
      INTEGER      CODRET,IPOIN,ITYP,LETYPE,INO,IRET,NBCMP,IAD
      INTEGER      JCNXMA(NTYMAX),IMA,NBSECT,NBFIBR,NBCOUC
      INTEGER      NBMAIL,JTYPMA,JPOIN,JCONX,NMATYP(NTYMAX),ICMPSE
      INTEGER      JATTMA(NTYMAX),JCCESV,JCCESL,JCCESD,JCCESC
      INTEGER      EDFUIN,EDELST,EDNODA,INDIK8,JOCESV,JOCESL,JOCESD
      INTEGER      JOCESC,JORIMA(NTYMAX),ICMPOR,JPCESV,JPCESL,JPCESD
      INTEGER      JPCESC,ICMPR1,ICMPEP,JRMIN(NTYMAX),JRMAX(NTYMAX)
      PARAMETER   (EDFUIN=0)
      PARAMETER   (EDELST=5)
      PARAMETER   (EDNODA=0)
C
      CHARACTER*1  K1BID
      CHARACTER*8  SAUX08
      CHARACTER*64 ATEPAI,ATANGV,ATRMAX,ATRMIN
      PARAMETER   (ATEPAI = 'EPAISSEUR')
      PARAMETER   (ATANGV = 'ANGLE DE VRILLE')
      PARAMETER   (ATRMIN = 'RAYON MIN')
      PARAMETER   (ATRMAX = 'RAYON MAX')
C
      LOGICAL EXICOQ,EXITUY,EXIPMF
C
      CALL JEVEUO(NOMAAS//'.TYPMAIL','L',JTYPMA)
      CALL JELIRA(NOMAAS//'.NOMMAI','NOMUTI',NBMAIL,K1BID)
      CALL JEVEUO(JEXATR(NOMAAS//'.CONNEX','LONCUM'),'L',JPOIN)
      CALL JEVEUO(NOMAAS//'.CONNEX','L',JCONX)
C
      EXICOQ = .FALSE.
      CALL EXISD('CHAM_ELEM_S',SDCARM//'.CARCOQUE',IRET)
      IF ( IRET.NE.0 ) THEN
        EXICOQ = .TRUE.
        CALL JEVEUO(SDCARM//'.CARCOQUE  .CESV','L',JCCESV)
        CALL JEVEUO(SDCARM//'.CARCOQUE  .CESL','L',JCCESL)
        CALL JEVEUO(SDCARM//'.CARCOQUE  .CESD','L',JCCESD)
        CALL JEVEUO(SDCARM//'.CARCOQUE  .CESC','L',JCCESC)
        NBCMP = ZI(JCCESD+1)
        ICMPSE = INDIK8(ZK8(JCCESC),'EP',1,NBCMP)
      ENDIF
C
      EXITUY = .FALSE.
      CALL EXISD('CHAM_ELEM_S',SDCARM//'.CARGEOPO',IRET)
      IF ( IRET.NE.0 ) THEN
        EXITUY = .TRUE.
        CALL JEVEUO(SDCARM//'.CARGEOPO  .CESV','L',JPCESV)
        CALL JEVEUO(SDCARM//'.CARGEOPO  .CESL','L',JPCESL)
        CALL JEVEUO(SDCARM//'.CARGEOPO  .CESD','L',JPCESD)
        CALL JEVEUO(SDCARM//'.CARGEOPO  .CESC','L',JPCESC)
        NBCMP = ZI(JPCESD+1)
        ICMPR1 = INDIK8(ZK8(JPCESC),'R1',1,NBCMP)
        ICMPEP = INDIK8(ZK8(JPCESC),'EP1',1,NBCMP)
        IF ( ICMPR1.EQ.0.OR.ICMPEP.EQ.0 ) EXITUY = .FALSE.
      ENDIF
C
      EXIPMF = .FALSE.
      CALL EXISD('CHAM_ELEM_S',SDCARM//'.CAFIBR',IRET)
      IF ( IRET.NE.0 ) THEN
        EXIPMF = .TRUE.
      ENDIF
C
      IF ( EXITUY.OR.EXIPMF ) THEN
        CALL JEVEUO(SDCARM//'.CARORIEN  .CESV','L',JOCESV)
        CALL JEVEUO(SDCARM//'.CARORIEN  .CESL','L',JOCESL)
        CALL JEVEUO(SDCARM//'.CARORIEN  .CESD','L',JOCESD)
        CALL JEVEUO(SDCARM//'.CARORIEN  .CESC','L',JOCESC)
        NBCMP = ZI(JOCESD+1)
        ICMPOR = INDIK8(ZK8(JOCESC),'GAMMA',1,NBCMP)
      ENDIF
C
C     -- DECOMPTE DU NOMBRE DE MAILLES PAR TYPE
      DO 211 , ITYP = 1 , NTYMAX
        NMATYP(ITYP) = 0
  211 CONTINUE
C
      DO 212 , IMA = 1, NBMAIL
        NMATYP(ZI(JTYPMA-1+IMA)) = NMATYP(ZI(JTYPMA-1+IMA)) + 1
  212 CONTINUE
C
C     -- CREATION D'UN VECTEURS PAR TYPE DE MAILLE PRESENT CONTENANT
C          LA CONNECTIVITE DES MAILLE/TYPE
C          (CONNECTIVITE = NOEUDS + UNE VALEUR BIDON(0) SI BESOIN)
      DO 23 , ITYP = 1, NTYMAX
        IF ( NMATYP(ITYP).NE.0 ) THEN
          CALL WKVECT('&&IRMAES.CNX.'//NOMTYP(ITYP),'V V I',
     &                 NNOTYP(ITYP)*NMATYP(ITYP),JCNXMA(ITYP))
          IF ( EXICOQ ) THEN
            CALL WKVECT('&&IRMAES.EPAI.'//NOMTYP(ITYP),'V V R',
     &                   NMATYP(ITYP),JATTMA(ITYP))
          ENDIF
          IF ( EXIPMF.OR.EXITUY ) THEN
            CALL WKVECT('&&IRMAES.ORIE.'//NOMTYP(ITYP),'V V R',
     &                   NMATYP(ITYP),JORIMA(ITYP))
          ENDIF
          IF ( EXITUY ) THEN
            CALL WKVECT('&&IRMAES.RMIN.'//NOMTYP(ITYP),'V V R',
     &                   NMATYP(ITYP),JRMIN(ITYP))
            CALL WKVECT('&&IRMAES.RMAX.'//NOMTYP(ITYP),'V V R',
     &                   NMATYP(ITYP),JRMAX(ITYP))
          ENDIF
        ENDIF
 23   CONTINUE
C
C     -- ON PARCOURT TOUTES LES MAILLES. POUR CHACUNE D'ELLES, ON
C          STOCKE SA CONNECTIVITE
C          LA CONNECTIVITE EST FOURNIE EN STOCKANT TOUS LES NOEUDS A
C          LA SUITE POUR UNE MAILLE DONNEE.
C          C'EST CE QU'ON APPELLE LE MODE ENTRELACE DANS MED
C          A LA FIN DE CETTE PHASE, NMATYP CONTIENT LE NOMBRE DE MAILLES
C          POUR CHAQUE TYPE
      DO 241 , ITYP = 1 , NTYMAX
        NMATYP(ITYP) = 0
  241 CONTINUE
C
      DO 242 , IMA = 1, NBMAIL
C
        ITYP   = ZI(JTYPMA-1+IMA)
C
        IPOIN  = ZI(JPOIN-1+IMA)
        NMATYP(ITYP) = NMATYP(ITYP) + 1
C
        IF ( EXICOQ ) THEN
          CALL CESEXI('C',JCCESD,JCCESL,IMA,1,1,ICMPSE,IAD)
          IF ( IAD.GT.0 ) THEN
            ZR(JATTMA(ITYP)+NMATYP(ITYP)-1) = ZR(JCCESV-1+IAD)
          ELSE
            ZR(JATTMA(ITYP)+NMATYP(ITYP)-1) = 0.D0
          ENDIF
        ENDIF
        IF ( EXIPMF.OR.EXITUY ) THEN
          CALL CESEXI('C',JOCESD,JOCESL,IMA,1,1,ICMPOR,IAD)
          IF ( IAD.GT.0 ) THEN
            ZR(JORIMA(ITYP)+NMATYP(ITYP)-1) = ZR(JOCESV-1+IAD)
          ELSE
            ZR(JORIMA(ITYP)+NMATYP(ITYP)-1) = 0.D0
          ENDIF
        ENDIF
        IF ( EXITUY ) THEN
          CALL CESEXI('C',JPCESD,JPCESL,IMA,1,1,ICMPR1,IAD)
          IF ( IAD.GT.0 ) THEN
            ZR(JRMIN(ITYP)+NMATYP(ITYP)-1) = ZR(JPCESV-1+IAD)
          ELSE
            ZR(JRMIN(ITYP)+NMATYP(ITYP)-1) = 0.D0
          ENDIF
          CALL CESEXI('C',JPCESD,JPCESL,IMA,1,1,ICMPEP,IAD)
          IF ( IAD.GT.0 ) THEN
            ZR(JRMAX(ITYP)+NMATYP(ITYP)-1) =
     &        ZR(JRMIN(ITYP)+NMATYP(ITYP)-1)+ZR(JPCESV-1+IAD)
          ELSE
            ZR(JRMAX(ITYP)+NMATYP(ITYP)-1) = 0.D0
          ENDIF
        ENDIF
C       CONNECTIVITE DE LA MAILLE TYPE ITYP DANS VECT CNX:
C       I) POUR LES TYPES DE MAILLE DONT LA NUMEROTATION DES NOEUDS
C          ENTRE ASTER ET MED EST IDENTIQUE:
        IF(MODNUM(ITYP).EQ.0)THEN
          DO 2421 , INO = 1, NNOTYP(ITYP)
            ZI(JCNXMA(ITYP)-1+(NMATYP(ITYP)-1)*NNOTYP(ITYP)+INO) =
     &       ZI(JCONX-1+IPOIN-1+INO)
 2421     CONTINUE
C       II) POUR LES TYPES DE MAILLE DONT LA NUMEROTATION DES NOEUDS
C          ENTRE ASTER ET MED EST DIFFERENTE (CF LRMTYP):
        ELSE
          DO 2422 , INO = 1, NNOTYP(ITYP)
            ZI(JCNXMA(ITYP)-1+(NMATYP(ITYP)-1)*NNOTYP(ITYP)+INO) =
     &       ZI(JCONX-1+IPOIN-1+NUANOM(ITYP,INO))
 2422     CONTINUE
        ENDIF
C
  242 CONTINUE
C
C     -- ECRITURE
      DO 31, LETYPE = 1, NBIMPR
C
C       -- PASSAGE DU NUMERO DE TYPE MED AU NUMERO DE TYPE ASTER
        ITYP = CAIMPI(8,LETYPE)
        NVTYGE = CAIMPI(9,LETYPE)
        NBCOUC = CAIMPI(4,LETYPE)
        NBSECT = CAIMPI(5,LETYPE)
        NBFIBR = CAIMPI(6,LETYPE)
C
        IF ( NMATYP(ITYP).NE.0.AND.(NBCOUC.NE.0.OR.
     &       NBSECT.NE.0.OR.NBFIBR.NE.0)) THEN
C
C         -- LES CONNECTIVITES
C          LA CONNECTIVITE EST FOURNIE EN STOCKANT TOUS LES NOEUDS A
C          LA SUITE POUR UNE MAILLE DONNEE.
C          C'EST CE QUE MED APPELLE LE MODE ENTRELACE
          CALL MFCONE(IDFIMD,NOMAMD,ZI(JCNXMA(ITYP)),
     &                NNOTYP(ITYP)*NMATYP(ITYP),EDFUIN,
     &                NMATYP(ITYP),
     &                EDELST,NVTYGE,EDNODA,CODRET)
          IF ( CODRET.NE.0 ) THEN
            SAUX08='MFCONE  '
            CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
          ENDIF
C
C         -- ATTRIBUTS VARIABLE, ICI L'EPAISSEUR
          IF ( NBCOUC.NE.0.AND.NBSECT.EQ.0 ) THEN
            CALL MFESAR(IDFIMD,NOMAMD,NVTYGE,ATEPAI,NMATYP(ITYP),
     &                  ZR(JATTMA(ITYP)),CODRET)
            IF ( CODRET.NE.0 ) THEN
              SAUX08='MFESAR'
              CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
            ENDIF
          ENDIF
C
C         -- ATTRIBUTS VARIABLE, ICI GAMMA
          IF ( NBFIBR.NE.0.OR.NBSECT.NE.0 ) THEN
            CALL MFESAR(IDFIMD,NOMAMD,NVTYGE,ATANGV,NMATYP(ITYP),
     &                  ZR(JORIMA(ITYP)),CODRET)
            IF ( CODRET.NE.0 ) THEN
              SAUX08='MFESAR'
              CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
            ENDIF
          ENDIF
C
C         -- ATTRIBUTS VARIABLE, ICI RMIN ET RMAX
          IF ( NBSECT.NE.0 ) THEN
            CALL MFESAR(IDFIMD,NOMAMD,NVTYGE,ATRMIN,NMATYP(ITYP),
     &                  ZR(JRMIN(ITYP)),CODRET)
            IF ( CODRET.NE.0 ) THEN
              SAUX08='MFESAR'
              CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
            ENDIF
            CALL MFESAR(IDFIMD,NOMAMD,NVTYGE,ATRMAX,NMATYP(ITYP),
     &                  ZR(JRMAX(ITYP)),CODRET)
            IF ( CODRET.NE.0 ) THEN
              SAUX08='MFESAR'
              CALL U2MESG('F','DVP_97',1,SAUX08,1,CODRET,0,0.D0)
            ENDIF
          ENDIF
C
        ENDIF
C
 31   CONTINUE
C
      DO 41 , ITYP = 1, NTYMAX
        IF ( NMATYP(ITYP).NE.0 ) THEN
          CALL JEDETR('&&IRMAES.CNX.'//NOMTYP(ITYP))
          CALL JEDETR('&&IRMAES.EPAI.'//NOMTYP(ITYP))
          IF ( EXIPMF.OR.EXITUY )
     &      CALL JEDETR('&&IRMAES.ORIE.'//NOMTYP(ITYP))
          IF ( EXITUY ) THEN
            CALL JEDETR('&&IRMAES.RMIN.'//NOMTYP(ITYP))
            CALL JEDETR('&&IRMAES.RMAX.'//NOMTYP(ITYP))
          ENDIF
        ENDIF
 41   CONTINUE
C
      END
