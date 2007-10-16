      SUBROUTINE NMASYM(FAMI,KPG,KSP,ICODMA,OPTION,XLONG0,A,
     &                 TMOINS,TPLUS,
     &                 DLONG0,EFFNOM,
     &                 VIM,EFFNOP,VIP,KLV,FONO)
C ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ALGORITH  DATE 16/10/2007   AUTEUR SALMONA L.SALMONA 
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
C ------------------------------------------------------------------
      IMPLICIT NONE
      INTEGER KPG,KSP,NEQ,NBT,NVAR,ICODMA
      PARAMETER   (NEQ = 6,NBT = 21,NVAR=4)

      CHARACTER*(*) FAMI,OPTION
      REAL*8        XLONG0,A,SYC,SYT,ETC,ETT,CR
      REAL*8        E,DLONG0,TMOINS,TPLUS
      REAL*8        EFFNOM,VIM(NVAR)
      REAL*8        EFFNOP,VIP(NVAR),FONO(NEQ),KLV(NBT)
C -------------------------------------------------------------------
C
C    TRAITEMENT DE LA RELATION DE COMPORTEMENT -ELASTOPLASTICITE-
C    ECROUISSAGE ISOTROPE ASYMETRIQUE LINEAIRE - VON MISES-
C    POUR UN MODELE BARRE ELEMENT MECA_BARRE
C
C -------------------------------------------------------------------
C IN  :
C       XLONG0 : LONGUEUR DE L'ELEMENT DE BARRE AU REPOS
C       A      : SECTION DE LA BARRE
C       TMOINS : INSTANT PRECEDENT
C       TPLUS  : INSTANT COURANT
C       XLONGM : LONGEUR DE L'ELEMENT AU TEMPS MOINS
C       DLONG0 : INCREMENT D'ALLONGEMENT DE L'ELEMENT
C       EFFNOM : EFFORT NORMAL PRECEDENT
C       OPTION : OPTION DEMANDEE (R_M_T,FULL OU RAPH_MECA)
C
C OUT : EFFNOP : CONTRAINTE A L'INSTANT ACTUEL
C       VIP    : VARIABLE INTERNE A L'INSTANT ACTUEL
C       FONO   : FORCES NODALES COURANTES
C       KLV    : MATRICE TANGENTE
C
C----------VARIABLES LOCALES
C
      REAL*8      SIGM,DEPS,DSDEM,DSDEP,SIGP,XRIG
      INTEGER NBPAR,NBRES
C
      REAL*8       VALPAR,VALRES(4)
      CHARACTER*2  FB2, CODRES(4)
      CHARACTER*8  NOMPAR,NOMELA,NOMASL(4)
      DATA NOMELA / 'E' /
      DATA NOMASL / 'SY_C', 'DC_SIGM_','SY_T','DT_SIGM_' /

C----------INITIALISATIONS

      CALL R8INIR (NBT,0.D0,KLV,1)
      CALL R8INIR (NEQ,0.D0,FONO,1)
C
C----------RECUPERATION DES CARACTERISTIQUES
C
      DEPS = DLONG0/XLONG0
      SIGM    =EFFNOM/A
C
C --- CARACTERISTIQUES ELASTIQUES
C
      NBRES = 2
      NBPAR  = 0
      NOMPAR = '  '
      VALPAR = 0.D0
      FB2 = 'FM'

      CALL RCVALB(FAMI,1,1,'+',ICODMA,' ','ELAS',
     &             NBPAR,NOMPAR,VALPAR,1,NOMELA,
     &             VALRES,CODRES,FB2)
      E     = VALRES(1)
C
C --- CARACTERISTIQUES ECROUISSAGE LINEAIRE ASYMETRIQUE
C

CJMP  NBRES = 5
      NBRES = 4
      NBPAR  = 0
      CALL RCVALB(FAMI,1,1,'+',ICODMA,' ','ECRO_ASYM_LINE',
     &           NBPAR,NOMPAR,VALPAR,
     &           NBRES, NOMASL, VALRES,CODRES,FB2)
        SYC    = VALRES(1)
        ETC    = VALRES(2)
        SYT    = VALRES(3)
        ETT    = VALRES(4)
CJMP    CR     = VALRES(5) MODELE DE RESTAURATION PAS AU POINT

       CR = 0.D0

C
      CALL  NM1DAS(FAMI,KPG,KSP,E,SYC,SYT,ETC,ETT,CR,
     &   TMOINS,TPLUS,ICODMA,SIGM,DEPS,VIM,SIGP,VIP,DSDEM,DSDEP)
      EFFNOP=SIGP*A
C
C --- CALCUL DU COEFFICIENT NON NUL DE LA MATRICE TANGENTE
C
      IF ( OPTION(1:10) .EQ. 'RIGI_MECA_'.OR.
     &     OPTION(1:9)  .EQ. 'FULL_MECA'         ) THEN
C
         IF (OPTION(11:14).EQ.'ELAS') THEN
           XRIG=E*A/XLONG0
         ELSE
           IF ( OPTION(1:14) .EQ. 'RIGI_MECA_TANG' ) THEN
             XRIG= DSDEM*A/XLONG0
           ELSE
             XRIG= DSDEP*A/XLONG0
           ENDIF
         ENDIF
         KLV(1)  =  XRIG
         KLV(7)  = -XRIG
         KLV(10)  = XRIG
      ENDIF
C
C --- CALCUL DES FORCES NODALES
C
      FONO(1) = -EFFNOP
      FONO(4) =  EFFNOP
C
C -------------------------------------------------------------
C
      END
