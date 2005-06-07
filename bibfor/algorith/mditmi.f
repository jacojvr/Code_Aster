      SUBROUTINE MDITMI(NOMCMD,TYPFLU,NOMBM,ICOUPL,NBM0,NBMODE,NBMD,
     &                 VGAP, ITRANS,EPS,TS,NTS,ITYPFL)
C
      IMPLICIT NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 10/10/2001   AUTEUR CIBHHLV L.VIVAN 
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
C TOLE CRP_21
C-----------------------------------------------------------------------
C DESCRIPTION : CALCUL DE LA REPONSE DYNAMIQUE NON-LINEAIRE D'UNE
C -----------   STRUCTURE PAR UNE METHODE INTEGRALE
C               RECUPERATION DES DONNEES
C
C               APPELANT : MDTR74
C
C-------------------   DECLARATION DES VARIABLES   ---------------------
C
C COMMUNS NORMALISES JEVEUX
C -------------------------
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
C
C ARGUMENTS
C ---------
      CHARACTER*16  NOMCMD
      CHARACTER*8   TYPFLU, NOMBM
      INTEGER       ICOUPL, NBM0, NBMODE, NBMD, JPULS, JMASG, JAMO1,
     &              JLOCF, ITYPFL
      INTEGER       NUMVIF, JBASE, JAMOG
      REAL*8        VGAP
      INTEGER       IVECI1, IVECR1, IVECR2, IVECR3, IVECR4, IVECR5,
     &              ITRANS
      REAL*8        EPS, TS
      INTEGER       NTS, NBMP
C
C VARIABLES LOCALES
C -----------------
      INTEGER       IAM, IB, IDIFF, IE, IM, INDIC, IV, J, JABSC,
     &              JBASF, JCODIM, JNUOR, JPHIE, JPOIDS, JRHOE, KCHREF,
     &              KDRIF, KFREQ, KFSIC, KMASG, KNUMO, KREFE, KVITE,
     &              LAMOG, LIRES, LMASG, LOMEG, LPROFV, N1, N2, NBAMOR,
     &              NBMCFC, NBNOEU, NEQ, NMP
      REAL*8        DEUXPI, R8B, XAMOR
      CHARACTER*3   OUINON, K3IV, K3IM
      CHARACTER*4   K4B
      CHARACTER*8   K8B, LISTAM, MAILLA, MATASS
      CHARACTER*14  NUMDDL
      CHARACTER*19  BASEFL
      CHARACTER*24  FSIC, CHREFE
C
C FONCTIONS INTRINSEQUES
C ----------------------
C     INTRINSIC     SQRT
C
C FONCTIONS EXTERNES
C ------------------
      REAL*8        R8DEPI
C     EXTERNAL      R8DEPI
C
C ROUTINES EXTERNES
C -----------------
C     EXTERNAL      COPMOD, DISMOI, GETVID, GETVIS, GETVR8, GETVTX,
C    &              JEDEMA, JELIRA, JEMARQ, JEVEUO, MDCONF, RSADPA,
C    &              RSORAC, UTDEBM, UTFINM, UTIMPI, UTIMPK, UTMESS,
C    &              WKVECT
C
C-------------------   DEBUT DU CODE EXECUTABLE    ---------------------
C
      CALL JEMARQ( )
C
      DEUXPI = R8DEPI()
      IV = 1
C
C
C 1.  RECUPERATION DU CONCEPT MELASFLU
C     --------------------------------
      CALL GETVID ( ' ', 'BASE_ELAS_FLUI', 0,1,1, BASEFL, N1 )
      CALL JEVEUO ( BASEFL//'.REFE', 'L', KREFE )
      TYPFLU = ZK8(KREFE)
      NOMBM  = ZK8(KREFE+1)
C
C
C 2.  CARACTERISATION DU TYPE DE LA CONFIGURATION ETUDIEE
C     ---------------------------------------------------
      FSIC = TYPFLU//'           .FSIC'
      CALL JEVEUO(FSIC,'L',KFSIC)
      ITYPFL = ZI(KFSIC)
      ICOUPL = ZI(KFSIC+1)
C
      IF ( (ITYPFL.NE.1).AND.(ITYPFL.NE.2) )
     &   CALL UTMESS('F',NOMCMD,'LE CALCUL DE LA REPONSE TEMPORELLE '//
     &   'N''EST PAS POSSIBLE POUR LE TYPE DE STRUCTURE ETUDIEE.')
C
      IF ( ICOUPL.NE.1 )
     &   CALL UTMESS('A',NOMCMD,'LE COUPLAGE FLUIDE-STRUCTURE '//
     &   'N''A PAS ETE PRIS EN COMPTE EN AMONT.')
C
C
C 3.  RECUPERATION DU NOMBRE DE NOEUDS DU MAILLAGE
C     --------------------------------------------
      CALL JELIRA (BASEFL//'.NUMO','LONMAX',NBMCFC,K8B)
      CALL JEVEUO (BASEFL//'.NUMO','L',KNUMO)
      WRITE(CHREFE,'(A8,A5,2I3.3,A5)') BASEFL(1:8),'.C01.',ZI(KNUMO),
     &                                 IV,'.REFE'
      CALL JEVEUO (CHREFE,'L',KCHREF)
      MAILLA = ZK24(KCHREF)(1:8)
      CALL DISMOI('F','NB_NO_MAILLA',MAILLA,'MAILLAGE',NBNOEU,K8B,IE)
C
C
C 4.  RECUPERATION DU NOMBRE D'EQUATIONS DU MODELE
C     --------------------------------------------
      CALL JEVEUO(NOMBM//'           .REFE','L',KDRIF)
      MATASS =  ZK24(KDRIF)(1:8)
      CALL DISMOI('F','NOM_NUME_DDL',MATASS,'MATR_ASSE',IB,NUMDDL,IE)
      CALL DISMOI('F','NB_EQUA'     ,MATASS,'MATR_ASSE',NEQ,K8B,IE)
C
C
C 5.  RECUPERATION DU NOMBRE DE MODE SUR BASE COMPLETE
C     ET SUR BASE REDUITE
C     -------------------
CCC      CALL RSORAC (NOMBM,'LONUTI',IB,R8B,K8B,C16B,0.0D0,K8B,
CCC     &             NBM0,1,NBTROU)
      NBM0 = NBMCFC
C
      CALL GETVIS ( ' ', 'NB_MODE', 0,1,1, NBMODE, N1 )
      IF ( N1.EQ.0 ) THEN
         NBMODE = NBM0
      ELSE IF ( NBMODE.GT.NBM0 ) THEN
         NBMODE = NBM0
         WRITE(K4B,'(I4)') NBM0
         CALL UTMESS('A',NOMCMD,'NB_MODE EST SUPERIEUR AU NOMBRE DE '//
     &               'MODES DU CONCEPT '//NOMBM//'. ON IMPOSE DONC '//
     &               'NB_MODE = '//K4B//', I.E. EGAL AU NOMBRE DE '//
     &               'MODES DU CONCEPT '//NOMBM//'.')
      ENDIF
C
      CALL GETVIS ( ' ', 'NB_MODE_DIAG', 0,1,1, NBMD, N1 )
      IF ( N1.EQ.0 ) THEN
         NBMD = NBMODE
      ELSE 
         IF (NBMD.NE.NBMODE) THEN
         NBMD = NBMODE
         WRITE(K4B,'(I4)') NBMODE
         CALL UTMESS('F',NOMCMD,'NB_MODE_DIAG EST DIFFERENT DE '//
     &               'NB_MODE NOMBRE DE MODES DE LA BASE MODALE . '//
     &               'COMPLETE L''OPTION BASE REDUITE N''EST PLUS '//
     &               'DISPONIBLE.')
         ENDIF
      ENDIF
C
C
C 6.  RECUPERATION DES CARACTERISTIQUES MODALES
C     -----------------------------------------
C 6.1 CREATION DES OBJETS DE STOCKAGE
C
      CALL WKVECT('&&MDITMI.PULSATIO','V V R8',NBMODE    ,JPULS)
      CALL WKVECT('&&MDITMI.MASSEGEN','V V R8',NBMODE    ,JMASG)
      CALL WKVECT('&&MDITMI.AMORTI'  ,'V V R8',NBMODE    ,JAMOG)
      CALL WKVECT('&&MDITMI.AMORTGEN','V V R8',NBMODE    ,JAMO1)
      CALL WKVECT('&&MDITMI.BASEMODE','V V R8',NBMODE*NEQ,JBASE)
      CALL WKVECT('&&MDITMI.LOCFL0'  ,'V V L' ,NBMODE    ,JLOCF)
C
C 6.2 PULSATIONS ET MASSES MODALES
C     STRUCTURE NON COUPLEE AVEC LE FLUIDE
C
      DO 10 IM = 1, NBMODE
         CALL RSADPA(NOMBM,'L',1,'OMEGA2',IM,0,LOMEG,K8B)
         ZR(JPULS+IM-1) = SQRT ( ZR(LOMEG) )
         CALL RSADPA(NOMBM,'L',1,'MASS_GENE',IM,0,LMASG,K8B)
         ZR(JMASG+IM-1) = ZR(LMASG)
         ZL(JLOCF+IM-1) = .FALSE.
  10  CONTINUE
C
C 6.3 AMORTISSEMENTS MODAUX
C     STRUCTURE NON COUPLEE AVEC LE FLUIDE
C
      CALL GETVR8(' ','AMOR_REDUIT',0,1,0,R8B,N1)
      CALL GETVID(' ','LIST_AMOR'  ,0,1,0,K8B,N2)
      IF ( (N1.NE.0).OR.(N2.NE.0) ) THEN
         IF ( N1.NE.0 ) THEN
            NBAMOR = -N1
         ELSE
            CALL GETVID(' ','LIST_AMOR'  ,0,1,0,LISTAM,IB)
            CALL JELIRA(LISTAM//'           .VALE','LONMAX',NBAMOR,K8B)
         ENDIF
         IF ( NBAMOR.GT.NBMODE ) THEN
            CALL UTDEBM('A',NOMCMD,
     &         'LE NOMBRE D''AMORTISSEMENTS REDUITS EST TROP GRAND')
            CALL UTIMPI('L','LE NOMBRE DE MODES RETENUS VAUT ',1,NBMODE)
            CALL UTIMPI('L','ET LE NOMBRE DE COEFFICIENTS : ',1,NBAMOR)
            CALL UTIMPI('L','ON NE GARDE DONC QUE LES ',1,NBMODE)
            CALL UTIMPK('S',' ',1,'PREMIERS COEFFICIENTS')
            CALL UTFINM()
         ENDIF
         IF ( NBAMOR.GE.NBMODE ) THEN
            IF ( N1.NE.0 ) THEN
               CALL GETVR8(' ','AMOR_REDUIT',0,1,NBMODE,ZR(JAMOG),IB)
            ELSE
               CALL JEVEUO(LISTAM//'           .VALE','L',LAMOG)
               DO 20 IAM = 1, NBMODE
                  ZR(JAMOG+IAM-1) = ZR(LAMOG+IAM-1)
  20           CONTINUE
            ENDIF
         ELSE
            IDIFF = NBMODE - NBAMOR
            CALL UTDEBM('I',NOMCMD,
     &         'LE NOMBRE D''AMORTISSEMENTS REDUITS EST INSUFFISANT')
            CALL UTIMPI('L','IL EN MANQUE : ',1,IDIFF)
            CALL UTIMPI('L','CAR LE NOMBRE DE MODES VAUT : ',1,NBMODE)
            CALL UTIMPI('L','ON RAJOUTE ',1,IDIFF)
            CALL UTIMPK('S',' ',1,'AMORTISSEMENTS REDUITS AVEC LA')
            CALL UTIMPK('S',' ',1,'VALEUR DU DERNIER MODE PROPRE')
            CALL UTFINM()
            IF ( N1.NE.0 ) THEN
               CALL GETVR8(' ','AMOR_REDUIT',0,1,NBAMOR,ZR(JAMOG),IB)
            ELSE
               CALL JEVEUO(LISTAM//'           .VALE','L',LAMOG)
               DO 30 IAM = 1, NBAMOR
                  ZR(JAMOG+IAM-1) = ZR(LAMOG+IAM-1)
  30           CONTINUE
            ENDIF
            XAMOR = ZR(JAMOG+NBAMOR-1)
            DO 31 IAM = NBAMOR+1, NBMODE
               ZR(JAMOG+IAM-1) = XAMOR
  31        CONTINUE
         ENDIF
         DO 40 IM = 1, NBMODE
            ZR(JAMO1+IM-1) = 2.0D0 * ZR(JAMOG+IM-1) * ZR(JMASG+IM-1)
     &                                              * ZR(JPULS+IM-1)
  40     CONTINUE
      ENDIF
C
C 6.4 DEFORMEES MODALES
C
      CALL COPMOD(NOMBM,'DEPL',NEQ,NUMDDL,NBMODE,ZR(JBASE))
C
C 6.5 RECUPERATION DE LA VITESSE D'ECOULEMENT DU FLUIDE
C
      CALL GETVIS( ' ', 'NUME_VITE_FLUI', 0,1,1, NUMVIF, N1 )
      CALL JEVEUO(BASEFL//'.VITE','L',KVITE)
      VGAP = ZR(KVITE+NUMVIF-1)
C
C 6.6 PULSATIONS, MASSES ET AMORTISSEMENTS MODAUX
C     STRUCTURE COUPLEE AVEC LE FLUIDE A LA VITESSE D'ECOULEMENT CHOISIE
C
      CALL JEVEUO(BASEFL//'.FREQ','L',KFREQ)
      CALL JEVEUO(BASEFL//'.MASG','L',KMASG)
      DO 50 J = 1, NBMCFC
         IM = ZI(KNUMO+J-1)
         IF ( IM.LE.NBMODE ) THEN
            IF ( ZR(KFREQ+2*(J-1)+2*NBMCFC*(NUMVIF-1)).LT.0.0D0 ) THEN
               WRITE(K3IV,'(I3)') NUMVIF
               WRITE(K3IM,'(I3)') IM
               CALL UTMESS('F',NOMCMD,'LE CALCUL DES PARAMETRES DU '//
     &                     'MODE NO'//K3IM//' PAR L''OPERATEUR '//
     &                     '<CALC_FLUI_STRU> N''A PAS CONVERGE POUR '//
     &                     'LA VITESSE NO'//K3IV//'. LE CALCUL DE LA '//
     &                     'REPONSE DYNAMIQUE DE LA SRUCTURE N''EST '//
     &                     'DONC PAS POSSIBLE.')
            ELSE
               ZR(JPULS+IM-1) = DEUXPI * ZR(KFREQ+2*(J-1)
     &                                      +2*NBMCFC*(NUMVIF-1))
            ENDIF
            ZR(JMASG+IM-1) = ZR(KMASG+J-1)
            ZR(JAMOG+IM-1) = ZR(KFREQ+2*(J-1)+2*NBMCFC*(NUMVIF-1)+1)
            ZR(JAMO1+IM-1) = 2.0D0 * ZR(JAMOG+IM-1) * ZR(JMASG+IM-1)
     &                                              * ZR(JPULS+IM-1)
            ZL(JLOCF+IM-1) = .TRUE.
         ENDIF
  50  CONTINUE
C
C
C 7.  RECUPERATION DES CARACTERISTIQUES DE LA CONFIGURATION ETUDIEE
C     -------------------------------------------------------------
C 7.1 CREATION DES OBJETS DE STOCKAGE
C
      CALL WKVECT ('&&MDITMI.NUOR','V V I',NBMODE,JNUOR)
      DO 60 J = 1, NBMODE
          ZI(JNUOR+J-1) = J
  60  CONTINUE
C
      IF ( ITYPFL.EQ.1 ) THEN
         CALL WKVECT('&&MDITMI.TEMP.IRES'  ,'V V I' , NBNOEU    ,LIRES )
         CALL WKVECT('&&MDITMI.TEMP.PROFV' ,'V V R8', 2*NBNOEU+1,LPROFV)
         CALL WKVECT('&&MDITMI.TEMP.RHOE'  ,'V V R8', NBNOEU    ,JRHOE )
         CALL WKVECT('&&MDITMI.TEMP.BASEFL','V V R8', NBMODE*NBNOEU,
     &                                                           JBASF )
         CALL WKVECT('&&MDITMI.TEMP.PHIE'  ,'V V R8', 1         ,JPHIE )
         CALL WKVECT('&&MDITMI.TEMP.ABSCV' ,'V V R8', NBNOEU    ,JABSC )
         IVECI1 = LIRES
         IVECR1 = LPROFV
         IVECR2 = JRHOE
         IVECR3 = JBASF
         IVECR4 = JPHIE
         IVECR5 = JABSC
      ELSE IF ( ITYPFL.EQ.2 ) THEN
         CALL WKVECT('&&MDITMI.TEMP.CODIM' ,'V V R8', 4         ,JCODIM)
         CALL WKVECT('&&MDITMI.TEMP.POIDS' ,'V V R8', 2*NBMODE  ,JPOIDS)
         CALL WKVECT('&&MDITMI.TEMP.PHIE'  ,'V V R8', 1         ,JPHIE )
         IVECI1= 1
         IVECR1= JMASG
         IVECR2 = JCODIM
         IVECR3 = JPOIDS
         IVECR4  = JPHIE
         IVECR5= 1
      ENDIF
C
C 7.2 RECUPERATION DES CARACTERISTIQUES
C
      CALL MDCONF(TYPFLU,NOMBM,MAILLA,NBMODE,NBNOEU,ZI(JNUOR),
     &            1,INDIC,ZI(IVECI1),ZR(IVECR1),ZR(IVECR2),
     &            ZR(IVECR3),ZR(IVECR4),ZR(IVECR5))
C
C
C 8.  RECUPERATION DES OPTIONS DE CALCUL
C     ----------------------------------
C 8.1 CALCUL OU NON D'UN TRANSITOIRE
C
      ITRANS = 0
      CALL GETVTX ( ' ', 'ETAT_STAT'  , 0,1,1, OUINON, N1 )
      CALL GETVR8 ( ' ', 'PREC_DUREE' , 0,1,1, EPS   , N1 )
      CALL GETVR8 ( ' ', 'TS_REG_ETAB', 0,1,1, TS    , NTS )
      IF ( OUINON.EQ.'OUI' ) ITRANS = 1
C
C 8.2 PRISE EN COMPTE OU NON DU SAUT DE FORCE FLUIDELASTIQUE
C     D'AMORTISSEMENT AU COURS DES PHASES DE CHOC
C
      ICOUPL = 0
      CALL GETVTX ( ' ', 'CHOC_FLUI'    , 0,1,1, OUINON, N1  )
      CALL GETVIS ( ' ', 'NB_MODE_FLUI' , 0,1,1, NBMP  , NMP )
      IF ( OUINON.EQ.'OUI' ) ICOUPL = 1
      IF ( NBMP.EQ.0 ) ICOUPL = 0
C
      IF ( NMP.EQ.0 ) THEN
         NBMP = NBMCFC
         IF ( ICOUPL.EQ.1 ) THEN
            WRITE(K4B,'(I4)') NBMP
            CALL UTMESS('A',NOMCMD,'PAS DE MOT-CLE <NB_MODE_FLUI>. '//
     &         'LES '//K4B//' MODES DU CONCEPT '//BASEFL(1:8)//' '//
     &         'SONT PRIS EN COMPTE POUR LE CALCUL DU SAUT DE FORCE '//
     &         'FLUIDELASTIQUE D''AMORTISSEMENT AU COURS DES PHASES '//
     &         'DE CHOC.')
         ENDIF
      ELSE IF ( NBMP.GT.NBMCFC ) THEN
         NBMP = NBMCFC
         IF ( ICOUPL.EQ.1 ) THEN
            WRITE(K4B,'(I4)') NBMP
            CALL UTMESS('A',NOMCMD,'NB_MODE_FLUI EST PLUS GRAND QUE '//
     &         'LE NOMBRE DE MODES DU CONCEPT '//BASEFL(1:8)//'. '//
     &          K4B//' MODES SONT PRIS EN COMPTE POUR LE CALCUL '//
     &         'DU SAUT DE FORCE FLUIDELASTIQUE D''AMORTISSEMENT AU '//
     &         'COURS DES PHASES DE CHOC.')
         ENDIF
      ENDIF
C
      CALL JEDEMA( )
C
C --- FIN DE MDITMI.
      END
