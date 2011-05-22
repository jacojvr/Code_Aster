      SUBROUTINE OP0070()
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 24/05/2011   AUTEUR ABBAS M.ABBAS 
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
C    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================
C RESPONSABLE ABBAS M.ABBAS
C TOLE CRP_20
C
      IMPLICIT NONE
C
C ----------------------------------------------------------------------
C
C COMMANDE:  STAT_NON_LINE ET DYNA_NON_LINE
C
C ----------------------------------------------------------------------
C
C
C --- PARAMETRES DE MECA_NON_LINE
C
      INTEGER      ZPMET ,ZPCRI ,ZCONV
      INTEGER      ZPCON ,ZNMETH
      PARAMETER   (ZPMET  = 30,ZPCRI  = 12,ZCONV = 21)
      PARAMETER   (ZPCON  = 10,ZNMETH = 7 )
      REAL*8       PARMET(ZPMET),PARCRI(ZPCRI),CONV(ZCONV)
      REAL*8       PARCON(ZPCON)
      CHARACTER*16 METHOD(ZNMETH)
      INTEGER      FONACT(100)
      INTEGER      ZMEELM,ZMEASS,ZVEELM,ZVEASS
      PARAMETER    (ZMEELM=9 ,ZMEASS=4 ,ZVEELM=22,ZVEASS=32)
      INTEGER      ZSOLAL,ZVALIN
      PARAMETER    (ZSOLAL=17,ZVALIN=18)
C
C --- GESTION CODES RETOURS
C
      LOGICAL      MTCPUP
      LOGICAL      FINPAS
      INTEGER      ACTPAS,NBITER
C
      LOGICAL      FORCE ,LBID
C
C --- GESTION BOUCLE EN TEMPS
C
      INTEGER      NUMINS
C
C --- GESTION ERREUR
C
      INTEGER      LENOUT
      CHARACTER*16 COMPEX
C
      INTEGER      IBID
C
      REAL*8       ETA   ,R8BID
C
      CHARACTER*8  RESULT,MAILLA
C
      CHARACTER*16 K16BID
      CHARACTER*19 LISCHA,LISCH2
      CHARACTER*19 SOLVEU,MAPREC,MATASS
      CHARACTER*24 MODELE,MATE  ,CARELE,COMPOR
      CHARACTER*24 NUMEDD,NUMFIX
      CHARACTER*24 CARCRI,COMREF,CODERE
C
C --- FONCTIONNALITES ACTIVEES
C
      LOGICAL      LEXPL,LIMPL,LSTAT,LMPAS
C
C --- FONCTIONS
C
      LOGICAL      DIDERN,NDYNLO
      INTEGER      ETAUSR
C
C --- STRUCTURES DE DONNEES
C
      CHARACTER*24 SDIMPR,SDSENS,SDTIME,SDERRO
      CHARACTER*19 SDPILO,SDNUME,SDDYNA,SDDISC,SDCRIT
      CHARACTER*19 SDSUIV,SDOBSE,SDPOST
      CHARACTER*24 DEFICO,RESOCO,DEFICU,RESOCU
C
C --- VARIABLES CHAPEAUX
C
      CHARACTER*19 VALINC(ZVALIN),SOLALG(ZSOLAL)
C
C --- MATR_ELEM, VECT_ELEM ET MATR_ASSE
C
      CHARACTER*19 MEELEM(ZMEELM),VEELEM(ZVEELM)
      CHARACTER*19 MEASSE(ZMEASS),VEASSE(ZVEASS)
C
C ----------------------------------------------------------------------
C
      DATA SDPILO, SDOBSE    /'&&OP0070.PILO.','&&OP0070.OBSE.'/
      DATA SDIMPR, SDSUIV    /'&&OP0070.IMPR.','&&OP0070.SUIV.'/
      DATA SDSENS, SDPOST    /'&&OP0070.SENS.','&&OP0070.POST.'/
      DATA SDTIME, SDERRO    /'&&OP0070.TIME.','&&OP0070.ERRE.'/
      DATA SDNUME            /'&&OP0070.NUME.ROTAT'/
      DATA SDDISC            /'&&OP0070.DISC.'/
      DATA SDCRIT            /'&&OP0070.CRIT.'/
      DATA LISCHA            /'&&OP0070.LISCHA'/
      DATA CARCRI            /'&&OP0070.PARA_LDC'/
      DATA SOLVEU            /'&&OP0070.SOLVEUR'/
      DATA DEFICO, RESOCO    /'&&OP0070.DEFIC','&&OP0070.RESOC'/
      DATA DEFICU, RESOCU    /'&&OP0070.DEFUC', '&&OP0070.RESUC'/
      DATA COMREF            /'&&OP0070.COREF'/
      DATA MAPREC            /'&&OP0070.MAPREC'/
      DATA CODERE            /'&&OP0070.CODERE'/
C
C ----------------------------------------------------------------------
C
      CALL JEMARQ()
C
C -- TITRE
C
      CALL TITRE ()
      CALL INFMAJ()
      CALL INIDBG()
C
C ======================================================================
C     RECUPERATION DES OPERANDES ET INITIALISATION
C ======================================================================
C
C --- ON STOCKE LE COMPORTEMENT EN CAS D'ERREUR AVANT MNL : COMPEX
C --- PUIS ON PASSE DANS LE MODE "VALIDATION DU CONCEPT EN CAS D'ERREUR"
C
      CALL ONERRF(' ',COMPEX,LENOUT)
      CALL ONERRF('EXCEPTION+VALID',K16BID,IBID  )
C
C --- NOM DE LA SD RESULTAT
C
      CALL GETRES(RESULT,K16BID,K16BID)
C
C --- PREMIERES INITALISATIONS
C
      CALL NMINI0(ZPMET ,ZPCRI ,ZCONV ,ZPCON ,ZNMETH,
     &            FONACT,PARMET,PARCRI,CONV  ,PARCON,
     &            METHOD,ETA   ,NUMINS,MTCPUP,FINPAS,
     &            MATASS,ZMEELM,ZMEASS,ZVEELM,ZVEASS,
     &            ZSOLAL,ZVALIN)
C
C --- LECTURE DES OPERANDES DE LA COMMANDE
C
      CALL NMDATA(RESULT,MODELE,MATE  ,CARELE,COMPOR,
     &            LISCHA,SOLVEU,METHOD,PARMET,PARCRI,
     &            PARCON,CARCRI,SDDYNA,SDSENS,SDPOST,
     &            SDERRO)
C
C --- ETAT INITIAL ET CREATION DES STRUCTURES DE DONNEES
C
      CALL NMINIT(RESULT,MODELE,NUMEDD,NUMFIX,MATE  ,
     &            COMPOR,CARELE,PARMET,LISCHA,MAPREC,
     &            SOLVEU,CARCRI,NUMINS,SDDISC,SDNUME,
     &            DEFICO,SDCRIT,COMREF,FONACT,PARCON,
     &            PARCRI,METHOD,LISCH2,MAILLA,SDPILO,
     &            SDDYNA,SDIMPR,SDSUIV,SDSENS,SDOBSE,
     &            SDTIME,SDERRO,SDPOST,DEFICU,RESOCU,
     &            RESOCO,VALINC,SOLALG,MEASSE,VEELEM,
     &            MEELEM,VEASSE,CODERE)
C
C --- PREMIER INSTANT
C
      NUMINS = 1
C
C --- QUELQUES FONCTIONNALITES ACTIVEES
C
      LIMPL  = NDYNLO(SDDYNA,'IMPLICITE')
      LEXPL  = NDYNLO(SDDYNA,'EXPLICITE')  
      LSTAT  = NDYNLO(SDDYNA,'STATIQUE' )
      LMPAS  = NDYNLO(SDDYNA,'MULTI_PAS')
C
C ======================================================================
C  DEBUT DU PAS DE TEMPS
C ======================================================================
C
 200  CONTINUE
C
      CALL JERECU('V')
      CALL NMTIME('DEBUT','PAS',SDTIME,LBID  ,R8BID )
C
      IF (LEXPL) THEN
        CALL NDEXPL(MODELE,NUMEDD,NUMFIX,MATE  ,CARELE,
     &              COMREF,COMPOR,LISCHA,METHOD,FONACT,
     &              CARCRI,PARCON,SDNUME,SDDYNA,SDDISC,
     &              SDTIME,SDSENS,SDERRO,VALINC,NUMINS,
     &              SOLALG,SOLVEU,MATASS,MAPREC,MEELEM,
     &              MEASSE,VEELEM,VEASSE,ACTPAS)
        NBITER = 0
      ELSEIF (LSTAT.OR.LIMPL) THEN
        CALL NMNEWT(MAILLA,MODELE,NUMINS,NUMEDD,NUMFIX,
     &              MATE  ,CARELE,COMREF,COMPOR,LISCHA,
     &              METHOD,FONACT,CARCRI,PARCON,CONV  ,
     &              PARMET,PARCRI,SDSENS,SDTIME,SDERRO,
     &              SDIMPR,SDNUME,SDDYNA,SDDISC,SDCRIT,
     &              SDSUIV,SDPILO,SOLVEU,MAPREC,MATASS,
     &              VALINC,SOLALG,MEELEM,MEASSE,VEELEM,
     &              VEASSE,DEFICO,RESOCO,DEFICU,RESOCU,
     &              ETA   ,NBITER,FINPAS,ACTPAS)
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
      CALL NMTIME('FIN'  ,'PAS',SDTIME,LBID  ,R8BID )
C     
C ======================================================================
C  FIN DU PAS DE TEMPS
C ======================================================================
C

C
C --- SORTIE DU PAS DE TEMPS
C     1 - PAS SUIVANT
C     2 - ON REFAIT LE PAS
C     3 - ARRET DU CALCUL
C
      IF (ACTPAS.EQ.1) THEN
        GOTO 550
      ELSEIF (ACTPAS.EQ.2) THEN
        GOTO 600
      ELSEIF (ACTPAS.EQ.3) THEN
        GOTO 1000
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF  
C
 550  CONTINUE
C
C --- POST-TRAITEMENTS
C
      CALL NMPOST(MODELE,MAILLA,NUMEDD,NUMFIX,CARELE,
     &            COMPOR,SOLVEU,MAPREC,MATASS,NUMINS,
     &            MATE  ,COMREF,LISCHA,DEFICO,RESOCO,
     &            RESOCU,PARMET,PARCON,FONACT,CARCRI,
     &            SDDISC,SDTIME,SDOBSE,SDERRO,SDSENS,
     &            SDDYNA,SDPOST,VALINC,SOLALG,MEELEM,
     &            MEASSE,VEELEM,VEASSE)
C
C --- ARCHIVAGE DES RESULTATS
C
      FINPAS = FINPAS .OR. DIDERN(SDDISC, NUMINS)
C
      CALL NMTIME('DEBUT','ARC',SDTIME,LBID  ,R8BID )
C
      FORCE  = MTCPUP.OR.FINPAS
      CALL ONERRF(COMPEX,K16BID,IBID  )
      CALL NMARCH(NUMINS,MODELE,MATE  ,CARELE,FONACT,
     &            COMPOR,CARCRI,SDDISC,SDPOST,SDCRIT,
     &            SDERRO,SDSENS,SDDYNA,SDPILO,DEFICO,
     &            RESOCO,VALINC,LISCH2,FORCE )
      CALL ONERRF('EXCEPTION+VALID',K16BID,IBID  )
C
      CALL NMTIME('FIN','ARC',SDTIME,LBID  ,R8BID )      
C
C --- ADAPTATION DU NOUVEAU PAS DE TEMPS
C
      CALL NMADAT(SDDISC,NUMINS,NBITER,VALINC,FINPAS)
C
C --- MISE A JOUR DES CHAMPS POUR NOUVEAU PAS DE TEMPS
C
      CALL NMFPAS(FONACT,SDDYNA,SDPILO,ETA   ,VALINC,
     &            SOLALG)
      NUMINS = NUMINS + 1
C
 600  CONTINUE
C
C --- TEMPS DISPONIBLE POUR FAIRE UN NOUVEAU PAS DE TEMPS ?
C
      CALL NMTIME('MES','PAS',SDTIME,MTCPUP,R8BID )
C
C --- IMPRESSION STATISTIQUES POUR LE PAS DE TEMPS
C
      CALL NMSTAT('PAS',FONACT,SDTIME,SDDYNA,NUMINS,
     &            DEFICO,RESOCO)
C
C --- DERNIER INSTANT DE CALCUL ? -> ON SORT DE STAT_NON_LINE
C
      IF (FINPAS) THEN
        GOTO 900
      ENDIF
C
C --- VERIFICATION SI INTERRUPTION DEMANDEE PAR SIGNAL USR1
C
      IF (ETAUSR().EQ.1) THEN
        GOTO 1000
      ENDIF
C
C --- PLUS ASSEZ DE TEMPS -> ON SORT PROPREMENT
C
      IF (MTCPUP) THEN
        CALL NMERGE('SET','TIP',SDERRO,MTCPUP)
        GOTO 1000
      ENDIF
C
C --- SAUVEGARDE DU SECOND MEMBRE SI MULTI_PAS EN DYNAMIQUE
C
      IF (LMPAS) THEN
        CALL NMCHSV(FONACT,VEASSE,SDDYNA)
      ENDIF

      GOTO 200

C ======================================================================
C     GESTION DES ERREURS
C ======================================================================

1000  CONTINUE
C
C --- ON COMMENCE PAR ARCHIVER LE PAS DE TEMPS PRECEDENT
C
      IF (NUMINS.NE.1) THEN
        FORCE = .TRUE.
        CALL NMARCH(NUMINS-1,MODELE,MATE,CARELE,FONACT,
     &              COMPOR,CARCRI,SDDISC,SDPOST,SDCRIT,
     &              SDERRO,SDSENS,SDDYNA,SDPILO,DEFICO,
     &              RESOCO,VALINC,LISCH2,FORCE )
      ENDIF
C
C --- GESTION DES ERREURS ET EXCEPTIONS
C
      CALL NMERRO(SDERRO,SDTIME,NUMINS,NBITER)

C ======================================================================
C     SORTIE
C ======================================================================

 900  CONTINUE
C
C --- IMPRESSION STATISTIQUES FINALES
C
      CALL NMSTAT('FIN' ,FONACT,SDTIME,SDDYNA,NUMINS,
     &            DEFICO,RESOCO)
C
C --- ON REMET LE MECANISME D'EXCEPTION A SA VALEUR INITIALE
C
      CALL ONERRF(COMPEX,K16BID,IBID  )
C
C --- MENAGE
C
      CALL NMMENG(FONACT,MATASS,SOLVEU)
C
      CALL JEDEMA()

      END
