      SUBROUTINE PEECIN(RESU,MODELE,MATE,CARA,NCHAR,LCHAR,NH,NBOCC)
      IMPLICIT   NONE
      INCLUDE 'jeveux.h'

      CHARACTER*32 JEXNOM
      INTEGER NCHAR,NH,NBOCC
      CHARACTER*(*) RESU,MODELE,MATE,CARA,LCHAR(*)
C     ------------------------------------------------------------------
C MODIF UTILITAI  DATE 25/02/2013   AUTEUR SELLENET N.SELLENET 
C ======================================================================
C            CONFIGURATION MANAGEMENT OF EDF VERSION
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C     OPERATEUR   POST_ELEM
C     TRAITEMENT DU MOT CLE-FACTEUR "ENER_CIN"
C     ------------------------------------------------------------------

      INTEGER ND,NR,NI,IRET,NP,NC,JORD,JINS,JAD,NBORDR,IORD,NUMORD,
     &        IAINST,JNMO,IBID,IE,JREF,NT,NM,NG,NBGRMA,IG,JGR,NBMA,NUME,
     &        IM,LFREQ,NBPARR,NBPARD,NBPAEP,IOCC,JMA,NF,INUME,IFM,NIV,
     &        IER
      PARAMETER (NBPAEP=2,NBPARR=6,NBPARD=4)
      REAL*8 PREC,XFREQ,R8DEPI,VARPEP(NBPAEP),ALPHA,VALER(3),INST
      REAL*8 R8B,RUNDF,R8VIDE
      CHARACTER*1 BASE
      CHARACTER*2 CODRET
      CHARACTER*8 K8B,NOMA,RESUL,CRIT,NOMMAI,NOMMAS,
     &            TYPARR(NBPARR),TYPARD(NBPARD),VALEK(2),NOMGD
      CHARACTER*16 TYPRES,OPTION,OPTIO2,NOPARR(NBPARR),NOPARD(NBPARD),
     &             OPTMAS,TABTYP(3)
      CHARACTER*19 CHELEM,KNUM,KINS,DEPLA,LIGREL,CHVARC,CHVREF
      CHARACTER*24 CHMASD,CHFREQ,CHAMGD,CHNUMC,TYPCHA,CHTIME,K24B,
     &             CHGEOM,CHCARA(18),CHTEMP,OPT,
     &             MLGGMA,MLGNMA,CHHARM,NOMMA2,VALE2(2)
      LOGICAL EXITIM
      COMPLEX*16 C16B,CALPHA
      INTEGER      IARG

      DATA NOPARR/'NUME_ORDRE','FREQ','LIEU','ENTITE','TOTALE',
     &     'POUR_CENT'/
      DATA TYPARR/'I','R','K24','K8','R','R'/
      DATA NOPARD/'LIEU','ENTITE','TOTALE','POUR_CENT'/
      DATA TYPARD/'K8','K8','R','R'/
      DATA TABTYP/'NOEU#DEPL_R','NOEU#TEMP_R','ELEM#ENER_R'/
      DATA CHVARC,CHVREF /'&&PEECIN.VARC','&&PEECIN.VARC_REF'/
C     ------------------------------------------------------------------

      CALL JEMARQ()

C --- RECUPERATION DU NIVEAU D'IMPRESSION
      CALL INFNIV(IFM,NIV)

      BASE = 'V'
      K24B = ' '
      ALPHA = 1.D0
      CALPHA = (1.D0,1.D0)
      RUNDF = R8VIDE()
      EXITIM = .FALSE.
      INST = 0.D0
      CHTEMP = ' '
      CHFREQ = ' '
      CALL GETVID(' ','CHAM_GD',1,IARG,1,DEPLA,ND)
      IF(ND.NE.0)THEN
         CALL CHPVE2(DEPLA,3,TABTYP,IER)
      ENDIF
      CALL GETVR8(' ','FREQ',1,IARG,1,XFREQ,NF)
      CALL GETVID(' ','RESULTAT',1,IARG,1,RESUL,NR)
      CALL GETVR8(' ','INST',1,IARG,1,INST,NI)
      IF (NI.NE.0) EXITIM = .TRUE.
      IF (NR.NE.0) THEN
        CALL GETTCO(RESUL,TYPRES)
        IF (TYPRES(1:9).EQ.'MODE_MECA') THEN
          NOPARR(2) = 'FREQ'
        ELSE IF (TYPRES(1:9).EQ.'EVOL_THER' .OR.
     &           TYPRES(1:9).EQ.'EVOL_ELAS' .OR.
     &           TYPRES(1:9).EQ.'EVOL_NOLI' .OR.
     &           TYPRES(1:10).EQ.'DYNA_TRANS') THEN
          NOPARR(2) = 'INST'
        ELSE
          CALL U2MESS('F','UTILITAI3_68')
        END IF
      END IF

      OPTION = 'ENER_CIN'
      CALL MECHAM(OPTION,MODELE,CARA,NH,CHGEOM,CHCARA,CHHARM,IRET)
      IF (IRET.NE.0) GO TO 90
      NOMA = CHGEOM(1:8)
      MLGNMA = NOMA//'.NOMMAI'
      MLGGMA = NOMA//'.GROUPEMA'

      CALL EXLIM3('ENER_CIN','V',MODELE,LIGREL)

      KNUM = '&&PEECIN.NUME_ORDRE'
      KINS = '&&PEECIN.INSTANT'
C      TYPRES = ' '
      INUME = 1

      IF (ND.NE.0) THEN
        IF (NF.EQ.0) THEN
          XFREQ = 1.D0
          CALL U2MESS('I','UTILITAI3_69')
        ELSE
          CALL U2MESS('I','UTILITAI3_70')
          XFREQ = (R8DEPI()*XFREQ)**2
        END IF
        NBORDR = 1
        CALL WKVECT(KNUM,'V V I',NBORDR,JORD)
        ZI(JORD) = 1
        CALL WKVECT(KINS,'V V R',NBORDR,JINS)
        ZR(JINS) = INST
        CALL TBCRSD(RESU,'G')
        CALL TBAJPA(RESU,NBPARD,NOPARD,TYPARD)
      ELSE
        CALL GETVR8(' ','PRECISION',1,IARG,1,PREC,NP)
        CALL GETVTX(' ','CRITERE',1,IARG,1,CRIT,NC)
        CALL RSUTNU(RESUL,' ',0,KNUM,NBORDR,PREC,CRIT,IRET)
        IF (IRET.NE.0) GO TO 80
        CALL JEVEUO(KNUM,'L',JORD)
C        - DANS LE CAS OU CE N'EST PAS UN RESULTAT DE TYPE EVOL_NOLI -
C        --- ON RECUPERE L'OPTION DE CALCUL DE LA MATRICE DE MASSE ---
        IF (TYPRES(1:9).NE.'EVOL_NOLI') THEN
          CALL JEVEUO(RESUL//'           .REFD','L',JREF)
          NOMMAS = ZK24(JREF+1)(1:8)
          IF (NOMMAS.EQ.' ') GOTO 5
          CALL DISMOI('C','SUR_OPTION',NOMMAS,'MATR_ASSE',IBID,OPT,IE)
          IF (IE.NE.0) THEN
            CALL U2MESS('A','UTILITAI3_71')
          ELSE
            IF (OPT(1:14).EQ.'MASS_MECA_DIAG') INUME = 0
          END IF
    5     CONTINUE
        END IF
C        --- ON VERIFIE SI L'UTILISATEUR A DEMANDE L'UTILISATION ---
C        --- D'UNE MATRICE DE MASSE DIAGONALE                    ---
C        --- DANS LA COMMANDE POST_ELEM                          ---
        CALL GETVTX(OPTION(1:9),'OPTION',1,IARG,1,OPTMAS,NT)
        IF (OPTMAS(1:14).EQ.'MASS_MECA_DIAG') THEN
          INUME = 0
          CALL U2MESS('I','UTILITAI3_72')
        END IF

        CALL WKVECT(KINS,'V V R',NBORDR,JINS)
C            CAS D'UN CALCUL MODAL
C        --- ON RECUPERE LES FREQUENCES ---
        CALL JENONU(JEXNOM(RESUL//'           .NOVA','FREQ'),IRET)
        IF (IRET.NE.0) THEN
          DO 10 IORD = 1,NBORDR
            NUMORD = ZI(JORD+IORD-1)
            CALL RSADPA(RESUL,'L',1,'FREQ',NUMORD,0,IAINST,K8B)
            ZR(JINS+IORD-1) = ZR(IAINST)
   10     CONTINUE
        END IF
C            CAS CALCUL TRANSITOIRE
C            RECUPERATION DES INSTANTS
        CALL JENONU(JEXNOM(RESUL//'           .NOVA','INST'),IRET)
        IF (IRET.NE.0) THEN
          EXITIM = .TRUE.
          DO 20 IORD = 1,NBORDR
            NUMORD = ZI(JORD+IORD-1)
            CALL RSADPA(RESUL,'L',1,'INST',NUMORD,0,IAINST,K8B)
            ZR(JINS+IORD-1) = ZR(IAINST)
   20     CONTINUE
        END IF
        CALL TBCRSD(RESU,'G')
        CALL TBAJPA(RESU,NBPARR,NOPARR,TYPARR)
      END IF

      CALL MECHNC(NOMA,' ',0,CHNUMC)
      CHMASD = '&&PEECIN.MASD'
      CALL MECACT('V',CHMASD,'MAILLA',NOMA,'POSI',1,'POS',INUME,R8B,
     &            C16B,K8B)

      DO 70 IORD = 1,NBORDR
        CALL JEMARQ()
        CALL JERECU('V')
        NUMORD = ZI(JORD+IORD-1)
        INST = ZR(JINS+IORD-1)
        VALER(1) = INST
        IF (TYPRES.EQ.'FOURIER_ELAS') THEN
          CALL RSADPA(RESUL,'L',1,'NUME_MODE',NUMORD,0,JNMO,K8B)
          CALL MEHARM(MODELE,ZI(JNMO),CHHARM)
        END IF
        CHTIME = ' '
        IF (EXITIM) CALL MECHTI(NOMA,INST,RUNDF,RUNDF,CHTIME)

        IF (NR.NE.0) THEN
          CALL RSEXCH(' ',RESUL,'ECIN_ELEM',NUMORD,DEPLA,IRET)
          IF (IRET.GT.0) THEN
C   SI RESULTAT TRANSITOIRE ON RECUPERE LE CHAMP DE VITESSE
            IF (EXITIM) THEN
              CALL RSEXCH(' ',RESUL,'VITE',NUMORD,DEPLA,IRET)
              IF (IRET.GT.0) GO TO 72
C   SINON RESULTAT MODAL ET ON RECUPERE LE CHAMP DE DEPLACEMENT
            ELSE
              CALL RSEXCH(' ',RESUL,'DEPL',NUMORD,DEPLA,IRET)
              IF (IRET.GT.0) GO TO 72
            END IF
          END IF
C   SI RESULTAT TRANSITOIRE (OMEGA**2=1.0) :
          IF (EXITIM) THEN
            XFREQ = 1.D0
C   SINON C'EST UN RESULTAT MODAL :
          ELSE
C           --- C'EST BIEN OMEGA2 QUE L'ON RECUPERE ----
            CALL RSADPA(RESUL,'L',1,'OMEGA2',NUMORD,0,LFREQ,K8B)
            XFREQ = ZR(LFREQ)
          END IF
        END IF

        CHFREQ = '&&PEECIN.OMEGA2'
        CALL MECACT('V',CHFREQ,'MAILLA',NOMA,'OME2_R',1,'OMEG2',IBID,
     &              XFREQ,C16B,K8B)

        CALL DISMOI('F','NOM_GD',DEPLA,'CHAMP',IBID,NOMGD,IE)
        CALL DISMOI('F','TYPE_SUPERVIS',DEPLA,'CHAMP',IBID,TYPCHA,IE)
        IF (TYPCHA(1:7).EQ.'CHAM_NO')THEN
           IF (NOMGD(1:4).EQ.'DEPL') THEN
            OPTIO2 = 'ECIN_ELEM'
            CHAMGD = DEPLA
            CALL VRCINS(MODELE,MATE,CARA,INST,CHVARC,CODRET)
            CALL VRCREF(MODELE(1:8),MATE(1:8),CARA(1:8),CHVREF(1:19))
           ELSE IF (NOMGD(1:4).EQ.'TEMP') THEN
            OPTIO2 = 'ECIN_ELEM_TEMP'
            CHAMGD = ' '
            CHTEMP = DEPLA
          ELSE
            CALL U2MESS('F','UTILITAI3_73')
          END IF
        ELSEIF(TYPCHA(1:9).EQ.'CHAM_ELEM')THEN
          IF (NOMGD(1:4).EQ.'ENER') THEN
            CHELEM = DEPLA
            GO TO 30
          ELSE
            CALL U2MESS('F','UTILITAI3_73')
          END IF
        ELSE
          CALL U2MESS('F','UTILITAI3_73')
        END IF
        CHELEM = '&&PEECIN.CHAM_ELEM'
        IBID = 0
        CALL MECALC(OPTIO2,MODELE,CHAMGD,CHGEOM,MATE,CHCARA,CHTEMP,
     &              K24B,CHTIME,CHNUMC,K24B,K24B,K24B,CHFREQ,
     &              CHMASD,K24B,K24B,K24B,ALPHA,CALPHA,K24B,K24B,CHELEM,
     &              K24B,LIGREL,BASE,CHVARC,CHVREF,K24B,K24B,
     &                  K24B, K24B, K8B, IBID, K24B, IRET )
   30   CONTINUE

C        --- ON CALCULE L'ENERGIE TOTALE ---
        CALL PEENCA(CHELEM,NBPAEP,VARPEP,0,IBID)

        DO 60 IOCC = 1,NBOCC
          CALL GETVTX(OPTION(1:9),'TOUT',IOCC,IARG,0,K8B,NT)
          CALL GETVEM(NOMA,'MAILLE',OPTION(1:9),'MAILLE',IOCC,IARG,0,
     &                K8B,
     &                NM)
          CALL GETVEM(NOMA,'GROUP_MA',OPTION(1:9),'GROUP_MA',IOCC,IARG,
     &                0,
     &                K8B,NG)
          IF (NT.NE.0) THEN
            CALL PEENCA(CHELEM,NBPAEP,VARPEP,0,IBID)
            VALEK(1) = NOMA
            VALEK(2) = 'TOUT'
            IF (NR.NE.0) THEN
              VALER(2) = VARPEP(1)
              VALER(3) = VARPEP(2)
              CALL TBAJLI(RESU,NBPARR,NOPARR,NUMORD,VALER,C16B,VALEK,0)
            ELSE
              CALL TBAJLI(RESU,NBPARD,NOPARD,NUMORD,VARPEP,C16B,VALEK,0)
            END IF
          END IF
          IF (NG.NE.0) THEN
            NBGRMA = -NG
            CALL WKVECT('&&PEECIN_GROUPM','V V K24',NBGRMA,JGR)
            CALL GETVEM(NOMA,'GROUP_MA',OPTION(1:9),'GROUP_MA',IOCC,
     &                  IARG,
     &                  NBGRMA,ZK24(JGR),NG)
            VALE2(2) = 'GROUP_MA'
            DO 40 IG = 1,NBGRMA
              NOMMA2 = ZK24(JGR+IG-1)
              CALL JEEXIN(JEXNOM(MLGGMA,NOMMA2),IRET)
              IF (IRET.EQ.0) THEN
                CALL U2MESK('A','UTILITAI3_46',1,NOMMA2)
                GO TO 40
              END IF
              CALL JELIRA(JEXNOM(MLGGMA,NOMMA2),'LONUTI',NBMA,K8B)
              IF (NBMA.EQ.0) THEN
                CALL U2MESK('A','UTILITAI3_47',1,NOMMA2)
                GO TO 40
              END IF
              CALL JEVEUO(JEXNOM(MLGGMA,NOMMA2),'L',JAD)
              CALL PEENCA(CHELEM,NBPAEP,VARPEP,NBMA,ZI(JAD))
              VALE2(1) = NOMMA2
              IF (NR.NE.0) THEN
                VALER(2) = VARPEP(1)
                VALER(3) = VARPEP(2)
                CALL TBAJLI(RESU,NBPARR,NOPARR,NUMORD,VALER,C16B,VALE2,
     &                      0)
              ELSE
                CALL TBAJLI(RESU,NBPARD,NOPARD,NUMORD,VARPEP,C16B,VALE2,
     &                      0)
              END IF
   40       CONTINUE
            CALL JEDETR('&&PEECIN_GROUPM')
          END IF
          IF (NM.NE.0) THEN
            NBMA = -NM
            CALL WKVECT('&&PEECIN_MAILLE','V V K8',NBMA,JMA)
            CALL GETVEM(NOMA,'MAILLE',OPTION(1:9),'MAILLE',IOCC,IARG,
     &                  NBMA,
     &                  ZK8(JMA),NM)
            VALEK(2) = 'MAILLE'
            DO 50 IM = 1,NBMA
              NOMMAI = ZK8(JMA+IM-1)
              CALL JEEXIN(JEXNOM(MLGNMA,NOMMAI),IRET)
              IF (IRET.EQ.0) THEN
                CALL U2MESK('A','UTILITAI3_49',1,NOMMAI)
                GO TO 50
              END IF
              CALL JENONU(JEXNOM(MLGNMA,NOMMAI),NUME)
              CALL PEENCA(CHELEM,NBPAEP,VARPEP,1,NUME)
              VALEK(1) = NOMMAI
              IF (NR.NE.0) THEN
                VALER(2) = VARPEP(1)
                VALER(3) = VARPEP(2)
                CALL TBAJLI(RESU,NBPARR,NOPARR,NUMORD,VALER,C16B,VALEK,
     &                      0)
              ELSE
                CALL TBAJLI(RESU,NBPARD,NOPARD,NUMORD,VARPEP,C16B,VALEK,
     &                      0)
              END IF
   50       CONTINUE
            CALL JEDETR('&&PEECIN_MAILLE')
          END IF
   60   CONTINUE
        CALL JEDETR('&&PEECIN.PAR')
   72   CONTINUE
        CALL JEDEMA()
   70 CONTINUE

   80 CONTINUE
      CALL JEDETR(KNUM)
      CALL JEDETR(KINS)

   90 CONTINUE
      CALL JEDEMA()
      END
