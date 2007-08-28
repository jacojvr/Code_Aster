      SUBROUTINE TE0535(OPTION,NOMTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 27/08/2007   AUTEUR SALMONA L.SALMONA 
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
      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C     ------------------------------------------------------------------

C     CALCUL DES OPTIONS FULL_MECA OU RAPH_MECA OU RIGI_MECA_TANG
C     POUR LES ELEMENTS DE POUTRE 'MECA_POU_D_EM'

C     ------------------------------------------------------------------
C IN  OPTION : K16 : NOM DE L'OPTION A CALCULER

C IN  NOMTE  : K16 : NOM DU TYPE ELEMENT
C        'MECA_POU_D_EM' : POUTRE DROITE D'EULER MULTIFIBRES
C     ------------------------------------------------------------------

C     ----- DEBUT COMMUNS NORMALISES  JEVEUX  --------------------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
C     -----  FIN  COMMUNS NORMALISES  JEVEUX  --------------------------

      INTEGER IGEOM,ICOMPO,IMATE,ISECT,IORIEN,ND,NK,IRET
      INTEGER ICARCR,ICONTM,IDEPLM,IDEPLP,IMATUU,ISECAN
      INTEGER IVECTU,ICONTP,NNO,NC,IVARIM,IVARIP,I
      PARAMETER (NNO=2,NC=6,ND=NC*NNO,NK=ND* (ND+1)/2)
      REAL*8 E,NU,G,XL,XJX,GXJX,ALPHA,EPSM
      INTEGER LX
      REAL*8 PGL(3,3),FL(ND),KLV(NK),SK(NK)
      REAL*8 DEPLM(12),DEPLP(12),DEPLT(12),MATSEC(6),DEGE(6)
      REAL*8 ZERO,DEUX
      PARAMETER (ZERO=0.0D+0,DEUX=2.D+0)
      INTEGER JDEFM,JDEFP,JMODFB,JSIGFB,NBFIB,NCARFI,JACF,NBVALC
      INTEGER JMDFBS,JTAB(7),IVARMP
      INTEGER IP,INBF,JCRET,CODRET
      INTEGER IPOSCP,IPOSIG,IPOMOD
      INTEGER IINSTP,IINSTM
      REAL*8 XI,WI,B(4),GG,VS(3),VE(12),R8VIDE
      REAL*8 DEFAM(6),DEFAP(6)
      LOGICAL VECTEU
      REAL*8 ALICOM,DALICO,SS1,HV,HE,PETIT,MINUS
      REAL*8 VV(12),FV(12),SV(78),KSG(3)
      INTEGER ICOMAX,ICO
      CHARACTER*8 MATOR

      INTEGER NBGF,ISDCOM,NBFIG,ICP,NBGFMX

C     ------------------------------------------------------------------

      CALL JEVECH('PNBSP_I','L',INBF)
C     nombre de fibres total de l'element
      NBFIB = ZI(INBF)
      CALL JEVECH('PFIBRES','L',JACF)
      NCARFI = 3
      CODRET=0

      VECTEU = OPTION .EQ.'FULL_MECA'.OR.OPTION.EQ.'RAPH_MECA'

      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PCOMPOR','L',ICOMPO)
      CALL JEVECH('PINSTMR','L',IINSTM)
      CALL JEVECH('PINSTPR','L',IINSTP)
      CALL JEVECH('PMATERC','L',IMATE)
      CALL JEVECH('PCAGNPO','L',ISECT)
      CALL JEVECH('PCAORIE','L',IORIEN)
      CALL JEVECH('PCARCRI','L',ICARCR)
      CALL JEVECH('PDEPLMR','L',IDEPLM)

C ---- LA PRESENCE DU CHAMP DE DEPLACEMENT A L INSTANT T+
C ---- DEVRAIT ETRE CONDITIONNE  PAR L OPTION (AVEC RIGI_MECA_TANG
C ---- CA N A PAS DE SENS).
C ---- CEPENDANT CE CHAMP EST INITIALISE A 0 PAR LA ROUTINE NMMATR.
      CALL JEVECH('PDEPLPR','L',IDEPLP)
      CALL TECACH('OON','PCONTMR',7,JTAB,IRET)
      IF (JTAB(7).NE. (NBFIB+6)) CALL U2MESS('F','CALCULEL_2')
      ICONTM = JTAB(1)

      CALL TECACH('OON','PVARIMR',7,JTAB,IRET)
      IF (JTAB(7).NE. (NBFIB+6)) CALL U2MESS('F','CALCULEL_2')
      IVARIM = JTAB(1)

      IF (VECTEU) THEN
         CALL TECACH('OON','PVARIMP',7,JTAB,IRET)
         IF (JTAB(7).NE. (NBFIB+6)) CALL U2MESS('F','ALGORITH_19')
         IVARMP = JTAB(1)
      ENDIF

C DEFORMATIONS ANELASTIQUES
      CALL R8INIR (6,0.D0,DEFAM,1)
      CALL R8INIR (6,0.D0,DEFAP,1)

C --- PARAMETRES EN SORTIE

      IF (OPTION.EQ.'RIGI_MECA_TANG') THEN
        CALL JEVECH('PMATUUR','E',IMATUU)
        IVARIP = IVARIM
        ICONTP = ICONTM
      ELSE IF (OPTION.EQ.'FULL_MECA') THEN
        CALL JEVECH('PMATUUR','E',IMATUU)
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)

      ELSE IF (OPTION.EQ.'RAPH_MECA') THEN
        CALL JEVECH('PVECTUR','E',IVECTU)
        CALL JEVECH('PCONTPR','E',ICONTP)
        CALL JEVECH('PVARIPR','E',IVARIP)

      END IF

C=====================================================================
C     --- RECUPERATION DU NOMBRE DE FIBRES TOTAL DE L'ELEMENT
C         ET DU NOMBRE DE GROUPES DE FIBRES SUR CET ELEMENT
      NBGF = ZI(INBF+1)

C --- Recuperation de la SD_COMPOR ou le comportement des groupes de
C     fibres de cet element est stock�
C     (NOM, MATER, RELATION, NBFIG pour chaque groupe
C     dans l'ordre croissant de num�ros de groupes)
      CALL JEVEUO(ZK16(ICOMPO-1+6),'L',ISDCOM)
      READ (ZK16(ICOMPO-1+2),'(I16)') NBVALC

C --- ON RESERVE QUELQUES PLACES
      CALL WKVECT('&&TE0535.DEFMFIB','V V R8',NBFIB,JDEFM)
      CALL WKVECT('&&TE0535.DEFPFIB','V V R8',NBFIB,JDEFP)
      CALL WKVECT('&&TE0535.MODUFIB','V V R8',(NBFIB*2),JMODFB)
      CALL WKVECT('&&TE0535.SIGFIB','V V R8',(NBFIB*2),JSIGFB)


C=====================================================================



C --- LONGUEUR DE L'ELEMENT ---
      LX = IGEOM - 1
      XL = SQRT((ZR(LX+4)-ZR(LX+1))**2+ (ZR(LX+5)-ZR(LX+2))**2+
     &     (ZR(LX+6)-ZR(LX+3))**2)
      IF (XL.EQ.ZERO) THEN
        CALL U2MESS('F','ELEMENTS_17')
      END IF
C --- CARACTERISTIQUES ELASTIQUES (PAS DE TEMPERATURE POUR L'INSTANT)
C on prend le E et NU du materiau torsion (voir OP0059)
      READ(ZK16(ICOMPO-1+7),'(I16)')NBGFMX
      MATOR=ZK16(ISDCOM-1+NBGFMX*6+1)(1:8)
      CALL MATELA(ZI(IMATE),MATOR,0,0.D0,E,NU,ALPHA)
      G = E/ (2.D0* (1.D0+NU))
C --- TORSION A PART
      XJX = ZR(ISECT+7)
      GXJX = G*XJX

C --- CALCUL DES MATRICES DE CHANGEMENT DE REPERE
      CALL MATROT(ZR(IORIEN),PGL)

C --- DEPLACEMENTS DANS LE REPERE LOCAL
      CALL UTPVGL(NNO,NC,PGL,ZR(IDEPLM),DEPLM)
      CALL UTPVGL(NNO,NC,PGL,ZR(IDEPLP),DEPLP)
      EPSM = (DEPLM(7)-DEPLM(1))/XL

C --- ON RECUPERE ALPHA MODE INCOMPATIBLE=ALICO STOCKE DANS LA PREMIERE
C      DES 6 FAUSSES FIBRES DU SECOND POINT DE GAUSS
      ALICOM=ZR(ICONTM+2*NBFIB+6)

C --- MISES A ZERO
      CALL R8INIR (NK,ZERO,KLV,1)
      CALL R8INIR (NK,ZERO,SK,1)
      CALL R8INIR (12,ZERO,FL,1)
      CALL R8INIR (12,ZERO,FV,1)

C

C --- BOUCLE POUR CALCULER LE ALPHA MODE INCOMPATIBLE : ALICO
      ICOMAX=100
      MINUS=1.D-6
      SS1=ZERO
      DALICO=ZERO
      DO 700 ICO=1,ICOMAX
        HE=ZERO
        HV=ZERO
C  BOUCLE SUR LES POINTS DE GAUSS
        DO 500 IP=1,2
C ---     POSITION, POIDS X JACOBIEN ET MATRICE B ET G
          CALL PMFPTI(IP,XL,XI,WI,B,GG)
C ---   DEFORMATIONS MOINS ET INCREMENT DE DEFORMATION POUR CHAQUE FIBRE
C  --     MOINS --> M
          CALL PMFDGE(B,GG,DEPLM,ALICOM,DEGE)
          CALL PMFDEF(NBFIB,NCARFI,ZR(JACF),DEGE,ZR(JDEFM))
C  --     INCREMENT --> P
          CALL PMFDGE(B,GG,DEPLP,DALICO,DEGE)
          CALL PMFDEF(NBFIB,NCARFI,ZR(JACF),DEGE,ZR(JDEFP))

          IPOSIG=JSIGFB + NBFIB*(IP-1)
          IPOMOD=JMODFB + NBFIB*(IP-1)
C ---     MODULE ET CONTRAINTES SUR CHAQUE FIBRE (COMPORTEMENT)
          CALL PMFMCF(IP,NBGF,NBFIB,ZI(INBF+2),ZK16(ISDCOM),
     &             ZR(ICARCR),OPTION,
     &             ZR(IINSTM),ZR(IINSTP),
     &             ZI(IMATE),NBVALC,
     &             DEFAM,DEFAP,
     &             ZR(IVARIM),ZR(IVARMP),
     &             ZR(ICONTM),ZR(JDEFM),ZR(JDEFP),
     &             EPSM,
     &             ZR(IPOMOD),ZR(IPOSIG),
     &             ZR(IVARIP),ISECAN,CODRET)

C --       CALCUL MATRICE SECTION
           CALL PMFITE(NBFIB,NCARFI,ZR(JACF),ZR(IPOMOD),MATSEC)

C ---       INTEGRATION DES CONTRAINTES SUR LA SECTION
           CALL PMFITS(NBFIB,NCARFI,ZR(JACF),ZR(IPOSIG),VS)

C --    PETITS CALCULS MODE INCOMPATIBLE HV=INT(GT KS G), HE=INT(GT FS)
          HV=HV+WI*GG*GG*MATSEC(1)
           HE=HE+WI*GG*VS(1)
C --- FIN BOUCLE POINTS DE GAUSS
 500    CONTINUE
C -- ENCORE UN PEU DE MODE INCOMPATIBLE
        DALICO=DALICO-HE/HV
        IF(ICO.EQ.1)THEN
          IF (ABS(VS(1)).LE.MINUS)THEN
            GOTO 710
          ELSE
            SS1=ABS(VS(1))
          ENDIF
        ENDIF
        IF(ABS(HE).LE.(SS1*MINUS))THEN
          GOTO 710
        ENDIF
C -- FIN BOUCLE CALCUL ALICO
 700  CONTINUE
 710  CONTINUE


C -- QUAND ON A CONVERGE SUR ALICO, ON PEUT INTEGRER SUR L'ELELMENT

      DO 800 IP=1,2
        CALL PMFPTI(IP,XL,XI,WI,B,GG)
C ---   CALCUL LA MATRICE ELEMENTAIRE (SAUF POUR RAPH_MECA)
        IF (OPTION.NE.'RAPH_MECA')THEN
          IPOMOD=JMODFB + NBFIB*(IP-1)
          CALL PMFITE(NBFIB,NCARFI,ZR(JACF),ZR(IPOMOD),MATSEC)
          CALL PMFBKB(MATSEC,B,WI,GXJX,SK)
          DO 3,I = 1,NK
            KLV(I)=KLV(I)+SK(I)
  3       CONTINUE
C --      ON SE SERT DE PMFBTS POUR CALCULER BT KS G CAR G EST SCALAIRE
          KSG(1)=MATSEC(1)*GG
          KSG(2)=MATSEC(2)*GG
          KSG(3)=MATSEC(3)*GG
          CALL PMFBTS(B,WI,KSG,VV)
          DO 4,I=1,12
            FV(I)=FV(I)+VV(I)
  4       CONTINUE
        ENDIF
C ---   SI PAS RIGI_MECA_TANG, ON CALCULE LES FORCES INTERNES
        IF(OPTION.NE.'RIGI_MECA_TANG')THEN
          IPOSIG=JSIGFB + NBFIB*(IP-1)
          CALL PMFITS(NBFIB,NCARFI,ZR(JACF),ZR(IPOSIG),VS)
          CALL PMFBTS(B,WI,VS,VE)
          DO 5,I=1,12
            FL(I)=FL(I)+VE(I)
  5       CONTINUE
        ENDIF
 800  CONTINUE
C --    ON MODIFIE LA MATRICE DE RAIDEUR PAR CONDENSATION STATIQUE
      IF (OPTION.NE.'RAPH_MECA')THEN
        CALL PMFFFT(FV,SV)
        DO 6 I=1,NK
          KLV(I)=KLV(I)-SV(I)/HV
  6     CONTINUE
      ENDIF




C --- TORSION A PART POUR LES FORCES INTERNE
      FL(10)=GXJX*(DEPLM(10)+DEPLP(10)-DEPLM(4)-DEPLP(4))/XL
      FL(4)=-FL(10)


C --- PASSAGE DU REPERE LOCAL AU REPERE GLOBAL ---

      IF (OPTION.EQ.'RIGI_MECA_TANG' .OR. OPTION.EQ.'FULL_MECA') THEN
C ---    ON SORT LA MATRICE DE RIGIDITE TANGENTE
        CALL UTPSLG(NNO,NC,PGL,KLV,ZR(IMATUU))
      END IF
      IF (OPTION.EQ.'RAPH_MECA' .OR. OPTION.EQ.'FULL_MECA') THEN
C ---    ON SORT LES CONTRAINTES SUR CHAQUE FIBRE
         DO 310 IP=1,2
           IPOSCP=ICONTP + (NBFIB+6)*(IP-1)
           IPOSIG=JSIGFB + NBFIB*(IP-1)
           DO 300 I=0,NBFIB-1
             ZR(IPOSCP+I)=ZR(IPOSIG+I)
  300      CONTINUE
  310    CONTINUE
         CALL UTPVLG ( NNO, NC, PGL, FL, ZR(IVECTU) )

C ---   ON STOCKE LES FORCES INTEGREES POUR EVITER DES CALCULS PLUS TARD
C       NX=FL(7), TY=FL(8), TZ=FL(9), MX=FL(10)
C       MY=(FL(11)-FL(5))/DEUX, MZ=(FL(12)-FL(6))/DEUX
C       ATTENTION STOCKAGE SUR LES 6 FAUSSES FIBRES DU 1ER PT DE GAUSS
        IPOSCP=ICONTP+NBFIB
        ZR(IPOSCP-1+1)=FL(7)
        ZR(IPOSCP-1+2)=FL(8)
        ZR(IPOSCP-1+3)=FL(9)
        ZR(IPOSCP-1+4)=FL(10)
        ZR(IPOSCP-1+5)=(FL(11)-FL(5))/DEUX
        ZR(IPOSCP-1+6)=(FL(12)-FL(6))/DEUX
C       ON STOCKE LE ALPHA MODE INCOMPATIBLE
C    ATTENTION STOCKAGE SUR LA PREMIERE FAUSSE FIBRES DU 2ND PT DE GAUSS
        ZR(ICONTP+2*NBFIB+6)=ALICOM+DALICO
C ---   FIN STOCK

        CALL JEVECH('PCODRET','E',JCRET)
        ZI(JCRET) = CODRET

      END IF

      CALL JEDETR('&&TE0535.DEFMFIB')
      CALL JEDETR('&&TE0535.DEFPFIB')
      CALL JEDETR('&&TE0535.MODUFIB')
      CALL JEDETR('&&TE0535.SIGFIB')

 1000 FORMAT(6(D10.4,2X))
      END
