      SUBROUTINE TE0409 ( OPTION , NOMTE )
      IMPLICIT NONE
      CHARACTER*16        OPTION , NOMTE
C     ----------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 16/12/2004   AUTEUR VABHHTS J.PELLET 
C ======================================================================
C COPYRIGHT (C) 1991 - 2003  EDF R&D                  WWW.CODE-ASTER.ORG
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
C
C   CALCUL DES OPTIONS DES ELEMENTS DE PLAQUE POUR LA MODELISATION DKGT
C     -----------------------------------------------------------------
C                            TRIANGLE  QUADRANGLE
C        KIRCHOFF  (MINCE)      DKT       DKQ
C
C        OPTIONS     RIGI_MECA       RIGI_MECA_TANG  
C                    FULL_MECA       RAPH_MECA  
C                    MASS_MECA       MASS_INER 
C                    EPOT_ELEM_DEPL  ECIN_ELEM_DEPL
C                    FORCE_NODA
C                    SIEF_ELNO_ELGA  VARI_ELNO_ELGA
C
C --------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ---------------------
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
C --------- FIN  DECLARATIONS  NORMALISEES  JEVEUX ---------------------
C
      INTEGER NNOS,   IPOIDS,  IVF,    IDFDX, JGANO
      INTEGER MULTIC, JTAB(7), CODRET, JDEPM, JDEPR
      INTEGER ICOMPO, I1,      I2,     J,     LT2EV, JVECT, IPG
      INTEGER ICONTP, NPG
      INTEGER ICHG,   ICHN,    NCMP,   NBVAR, NBCOU, K,     IAD,  K1
      INTEGER ICONTM, JCRET
      INTEGER JMATE,  LZI,     NNO,    LZR,   JGEOM, JMATR 
      INTEGER JENER,  I,      JFREQ,   IACCE
      INTEGER IVECT,  NDDL,    NVEC,   NDIM,  IRET
      LOGICAL LCOELA
      CHARACTER*2  CODRE2(33)
      CHARACTER*10 PHENOM
C
      REAL*8 PGL(3,3)  ,XYZL(3,4),BSIGMA(24), EFFGT(32)
      REAL*8 VECLOC(24),ENER(3),  MATP(24,24),MATV(300)
C
C     ---> POUR DKT MATELEM = 3 * 6 DDL = 171 TERMES STOCKAGE SYME
C     ---> POUR DKQ MATELEM = 4 * 6 DDL = 300 TERMES STOCKAGE SYME
      REAL*8 MATLOC(300),RHO,EPAIS
C
C     ---> POUR DKT EFFINT = 24
C     ---> POUR DKQ EFFINT = 32
      REAL*8 EFFINT(32), EFFIN2(32)
C
C     --->   UML : DEPLACEMENT A L'INSTANT T- (REPERE LOCAL)
C     --->   DUL : INCREMENT DE DEPLACEMENT   (REPERE LOCAL)
      REAL*8 UML(6,4),DUL(6,4)
C     ------------------------------------------------------------------
C DEB
C
      CALL ELREF4(' ','RIGI',NDIM,NNO,NNOS,NPG,IPOIDS,IVF,IDFDX,JGANO)
C
      LCOELA = .FALSE.
C
      IF ((OPTION.EQ.'FULL_MECA').OR.
     +    (OPTION.EQ.'RAPH_MECA').OR.
     +    (OPTION.EQ.'RIGI_MECA_TANG')) THEN
C
C ---   RECUPERATION DU MATERIAU :
C       ------------------------
        CALL JEVECH('PMATERC','L',JMATE)
        CALL RCCOMA(ZI(JMATE),'ELAS',PHENOM,CODRE2)
C
C --    DETECTION D'UN MATERIAU ELAS_COQUE :
C       ----------------------------------
        IF (PHENOM.EQ.'ELAS_COQUE') LCOELA = .TRUE.
      ENDIF
C
      CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESR','L',LZR)
C
      IF ((OPTION.NE.'SIEF_ELNO_ELGA') .AND.
     +    (OPTION.NE.'VARI_ELNO_ELGA')) THEN
C
        CALL JEVECH('PGEOMER','L',JGEOM)
C
        IF (NNO.EQ.3) THEN
          CALL DXTPGL(ZR(JGEOM),PGL)
        ELSE IF (NNO.EQ.4) THEN
          CALL DXQPGL(ZR(JGEOM),PGL)
        END IF
C
        CALL UTPVGL(NNO,3,PGL,ZR(JGEOM),XYZL)
C
      END IF
C
      IF (OPTION.EQ.'RIGI_MECA' .OR. OPTION.EQ.'EPOT_ELEM_DEPL') THEN
C     ---------------------------------------------------------------
C
        IF (NOMTE.EQ.'MEDKTG3') THEN
          CALL DKTRIG(NOMTE,XYZL,OPTION,PGL,MATLOC,ENER,MULTIC,.FALSE.)
        ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
          CALL DKQRIG(NOMTE,XYZL,OPTION,PGL,MATLOC,ENER)
        END IF
C
        IF (OPTION.EQ.'RIGI_MECA') THEN
          CALL JEVECH('PMATUUR','E',JMATR)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(JMATR))
        ELSE IF (OPTION.EQ.'EPOT_ELEM_DEPL') THEN
          CALL JEVECH('PENERDR','E',JENER)
          DO 10 I = 1,3
            ZR(JENER-1+I) = ENER(I)
   10     CONTINUE
        END IF
C
      ELSE IF (OPTION.EQ.'MASS_MECA' .OR.
     +         OPTION.EQ.'MASS_MECA_DIAG' .OR. 
     +         OPTION.EQ.'M_GAMMA' .OR.
     +         OPTION.EQ.'ECIN_ELEM_DEPL') THEN
C     --------------------------------------
        IF (NOMTE.EQ.'MEDKTG3') THEN
          CALL DKTMAS(NOMTE,XYZL,OPTION,PGL,MATLOC,ENER,MULTIC,.FALSE.)
        ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
          CALL DKQMAS(NOMTE,XYZL,OPTION,PGL,MATLOC,ENER)
        END IF
        IF (OPTION.EQ.'MASS_MECA') THEN
          CALL JEVECH('PMATUUR','E',JMATR)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(JMATR))
        ELSE IF (OPTION.EQ.'ECIN_ELEM_DEPL') THEN
          CALL JEVECH('PENERCR','E',JENER)
          CALL JEVECH('PFREQR','L',JFREQ)
          DO 20 I = 1,3
            ZR(JENER-1+I) = ZR(JFREQ)*ENER(I)
   20     CONTINUE
        ELSE IF (OPTION.EQ.'M_GAMMA') THEN
          CALL JEVECH('PDEPLAR','L',IACCE)
          CALL JEVECH('PVECTUR','E',IVECT)
          NDDL = 6*NNO
          NVEC = NDDL* (NDDL+1)/2
          CALL UTPSLG(NNO,6,PGL,MATLOC,MATV)
          CALL VECMA(MATV,NVEC,MATP,NDDL)
          CALL PMAVEC('ZERO',NDDL,MATP,ZR(IACCE),ZR(IVECT))
        ELSE IF (OPTION.EQ.'MASS_MECA_DIAG') THEN
          CALL JEVECH('PMATUUR','E',JMATR)
          NDDL = 6*NNO
          NDIM = NDDL* (NDDL+1)/2
          DO 30 I = 1,NDIM
            ZR(JMATR-1+I) = MATLOC(I)
   30     CONTINUE
        END IF
C
      ELSE IF (OPTION.EQ.'MASS_INER') THEN
C     --------------------------------------
        CALL JEVECH('PMASSINE','E',JMATR)
        CALL DXROEP(RHO,EPAIS)
        CALL DXINER(NNO,ZR(JGEOM),RHO,EPAIS,ZR(JMATR),ZR(JMATR+1),
     +              ZR(JMATR+4))
C
C     -- OPTIONS NON-LINEAIRES :
C     --------------------------
      ELSE IF ((OPTION.EQ.'FULL_MECA') .OR. (OPTION.EQ.'RAPH_MECA') .OR.
     +         (OPTION.EQ.'RIGI_MECA_TANG')) THEN
C
        CALL JEVECH('PDEPLMR','L',JDEPM)
        CALL JEVECH('PDEPLPR','L',JDEPR)
        CALL JEVECH('PCOMPOR','L',ICOMPO)
        IF ( ZK16(ICOMPO+3) .EQ. 'COMP_ELAS' ) THEN
           IF (.NOT.LCOELA) THEN
             CALL UTMESS('F','TE0409','COMP_ELAS NON VALIDE')
           ENDIF
        ENDIF
        IF (ZK16(ICOMPO+2) (6:10).EQ.'_REAC') THEN
C
          CALL UTMESS('A','TE0409',' LA REACTUALISATION DE LA '//
     +                'GEOMETRIE (DEFORMATION : PETIT_REAC '//
     +                'SOUS LE MOT CLE COMP_INCR) '//
     +                'EST DECONSEILLEE POUR LES ELEMENTS DE PLAQUE.')
C
          DO 40 I = 1,NNO
            I1 = 3* (I-1)
            I2 = 6* (I-1)
            ZR(JGEOM+I1)   = ZR(JGEOM+I1)   + ZR(JDEPM+I2) 
     +                                      + ZR(JDEPR+I2)
            ZR(JGEOM+I1+1) = ZR(JGEOM+I1+1) + ZR(JDEPM+I2+1) +
     +                       ZR(JDEPR+I2+1)
            ZR(JGEOM+I1+2) = ZR(JGEOM+I1+2) + ZR(JDEPM+I2+2) +
     +                       ZR(JDEPR+I2+2)
   40     CONTINUE
C
          IF (NNO.EQ.3) THEN
            CALL DXTPGL(ZR(JGEOM),PGL)
          ELSE IF (NNO.EQ.4) THEN
            CALL DXQPGL(ZR(JGEOM),PGL)
          END IF
C
          CALL UTPVGL(NNO,3,PGL,ZR(JGEOM),XYZL)
C
        END IF
C
        CALL UTPVGL(NNO,6,PGL,ZR(JDEPM),UML)
        CALL UTPVGL(NNO,6,PGL,ZR(JDEPR),DUL)
C
        IF (NOMTE.EQ.'MEDKTG3') THEN
          LT2EV = 51 
          IF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_INCR') THEN
            CALL DXGLRC(NOMTE,OPTION,ZK16(ICOMPO),XYZL,UML,DUL,VECLOC,
     +                  MATLOC,EFFINT,PGL,CODRET)
          ELSEIF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_ELAS') THEN
          CALL UTMESS('F','TE0409','LES COMPORTEMENTS ELASTIQUES '// 
     &                'DE TYPE COMP_ELAS NE SONT PAS DISPONIBLES '//
     &                'POUR LA MODELISATION DKTG.')
         ENDIF
        ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
          LT2EV = 81
          IF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_INCR') THEN
            CALL DXGLRC(NOMTE,OPTION,ZK16(ICOMPO),XYZL,UML,DUL,VECLOC,
     +                  MATLOC,EFFINT,PGL,CODRET)
          ELSEIF (ZK16(ICOMPO+3) (1:9).EQ.'COMP_ELAS') THEN
          CALL UTMESS('F','TE0409','LES COMPORTEMENTS ELASTIQUES '// 
     &                'DE TYPE COMP_ELAS NE SONT PAS DISPONIBLES '//
     &                'POUR LA MODELISATION DKTG.')
          ENDIF
        ELSE
          CALL UTMESS('F','TE0409',NOMTE//' NON IMPLANTE.')
        END IF
C
        IF (OPTION.EQ.'FULL_MECA') THEN
          CALL JEVECH('PMATUUR','E',JMATR)
          CALL JEVECH('PVECTUR','E',JVECT)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(JMATR))
          CALL UTPVLG(NNO,6,PGL,VECLOC,ZR(JVECT))
        ELSE IF (OPTION.EQ.'RAPH_MECA') THEN
          CALL JEVECH('PVECTUR','E',JVECT)
          CALL UTPVLG(NNO,6,PGL,VECLOC,ZR(JVECT))
        ELSE IF (OPTION.EQ.'RIGI_MECA_TANG') THEN
          CALL JEVECH('PMATUUR','E',JMATR)
          CALL UTPSLG(NNO,6,PGL,MATLOC,ZR(JMATR))
        END IF
C

      ELSE IF (OPTION.EQ.'SIEF_ELNO_ELGA') THEN
C     ---------------------------------------
          CALL JEVECH('PGEOMER','L',JGEOM)
          CALL JEVETE('&INEL.'//NOMTE(1:8)//'.DESR','L',LZR)
          CALL TECACH('NNN','PCOMPOR',1,ICOMPO,IRET)
          IF (ZK16(ICOMPO+2)(1:8).EQ.'GREEN_GR') THEN
             CALL UTMESS('F','TE0409','OPTION "SIEF_ELNO_ELGA" NON '//
     +                    'IMPLANTEE POUR LA DEFORMATION "GREEN_GR"')
          ENDIF

          IF (NOMTE.EQ.'MEDKTG3') THEN
            LT2EV = 51
          ELSE IF (NOMTE.EQ.'MEDKQG4') THEN
            LT2EV = 81
          ENDIF
         IF (NNO.EQ.3) THEN
           CALL DXTPGL(ZR(JGEOM),PGL)
          ELSE IF (NNO.EQ.4) THEN
            CALL DXQPGL(ZR(JGEOM),PGL)
          END IF
          CALL DXREPE(NNO,PGL,ZR(LZR))
          CALL TECACH('OON','PCONTRR',7,JTAB,IRET)
          CALL R8INIR(32,0.D0,EFFINT,1)
          DO 779,IPG=1,NPG
            ICONTM=JTAB(1)+8*(IPG-1)
            CALL DCOPY(8,ZR(ICONTM),1,EFFINT(8*(IPG-1)+1),1)
779       CONTINUE

C --- PASSAGE DU VECTEUR DES EFFORTS GENERALISES AUX POINTS
C --- D'INTEGRATION DU REPERE LOCAL AU REPERE INTRINSEQUE :
C     -----------------------------------------------------
          CALL DXEFRO(NPG,ZR(LZR-1+LT2EV),EFFINT,EFFIN2)
            IPG=1
          CALL JEVECH('PSIEFNOR','E',ICHN)
          CALL PPGAN2(JGANO,8,EFFIN2,ZR(ICHN))

      ELSE IF (OPTION.EQ.'VARI_ELNO_ELGA') THEN
C     ---------------------------------------
          CALL JEVECH('PVARIGR','L',ICHG)
          CALL JEVECH('PVARINR','E',ICHN)
          CALL TECACH('OON','PVARIGR',7,JTAB,IRET)
          NCMP = JTAB(6)*JTAB(7)
          CALL PPGAN2(JGANO,NCMP,ZR(ICHG),ZR(ICHN))

      ELSE IF (OPTION.EQ.'FORC_NODA') THEN
C     ---------------------------------------

C --- VECTEUR DES EFFORTS GENERALISES AUX POINTS
C --- D'INTEGRATION DU REPERE LOCAL
        CALL TECACH('OON','PCONTMR',7,JTAB,IRET)
        DO 778,IPG=1,NPG
          ICONTM=JTAB(1)+8*(IPG-1)
          CALL DCOPY(8,ZR(ICONTM),1,EFFGT(8*(IPG-1)+1),1)
778     CONTINUE
C
C --- CALCUL DES EFFORTS INTERNES (I.E. SOMME_VOL(BT_SIG))
C     ----------------------------------------------------
C
        CALL DXBSIG(NOMTE,XYZL,PGL,EFFGT,BSIGMA)
C
C --- AFFECTATION DES VALEURS DE BSIGMA AU VECTEUR EN SORTIE
C     ------------------------------------------------------
        CALL JEVECH('PVECTUR','E',JVECT)
        K = 0
        DO 90 I = 1,NNO
          DO 80 J = 1,6
            K = K + 1
            ZR(JVECT+K-1) = BSIGMA(K)
   80     CONTINUE
   90   CONTINUE
      ELSE
        CALL UTMESS('E','TE0409','OPTION NON TRAITEE')
      END IF
C
      CODRET = 0
      IF ( OPTION(1:9).EQ.'FULL_MECA'  .OR.
     +     OPTION(1:9).EQ.'RAPH_MECA'  ) THEN
         CALL JEVECH ( 'PCODRET', 'E', JCRET )
         ZI(JCRET) = CODRET
      ENDIF
C
      END
