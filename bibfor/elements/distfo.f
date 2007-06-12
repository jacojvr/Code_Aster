      FUNCTION DISTFO(IFONC,XX,YY,NORMX,NORMY)

        IMPLICIT  NONE
C-----------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 29/09/2006   AUTEUR VABHHTS J.PELLET 
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
      REAL*8 DISTFO

      INTEGER      IFONC,I,ITMAX,IER
      REAL*8       XX,YY,NORMX,NORMY,FX,X0,Y0,DY
      REAL*8       XI,YI,XM1,RES,YM1,RP,DYM1,TOL,RPX
      REAL*8       XM2,YM2,DYI

      TOL = 1.0D-3
      X0 = XX / NORMX
      Y0 = YY / NORMY
      RES = 1.0D6
      XI = X0

      YM1 = 0.0D0
      XI  = 0.0D0
      ITMAX = 1000
      XM1   = 1.0D20
      YM1   = 1.0D20

      XI  = XI* NORMX
      CALL CAFONC(IFONC,XI,YI)
      CALL CDNFON(IFONC,XI,1,DYI,IER)
      YI   = YI/ NORMY
      XI   = XI/ NORMX
      DYI  = DYI * NORMX / NORMY

      DO 20, I = 1,ITMAX
        XM2   = XM1
        YM2   = YM1
        XM1   = XI
        YM1   = YI
        DYM1  = DYI

        RP  = (XM2 - XM1)*(XM2 - XM1) + (YM2 - YM1)*(YM2 - YM1)
        RES = SQRT(RP*RP)
        IF (RES .LT. TOL) GOTO 30

C        RP  =  1.0D0/(DYM1 + 1.0D0/DYM1)
        RP  =  DYM1/(DYM1*DYM1 + 1.0D0)
C        XI  =  RP*(Y0 - YM1 + DYM1*XM1 + X0/DYM1)
        XI  =  RP*(Y0 - YM1 + DYM1*XM1) + X0/(DYM1*DYM1 + 1.0D0)

        XI  = XI* NORMX
        CALL CAFONC(IFONC,XI,YI)
        CALL CDNFON(IFONC,XI,1,DYI,IER)
        YI   = YI/ NORMY
        XI   = XI/ NORMX
        DYI  = DYI * NORMX / NORMY

 20   CONTINUE
      CALL U2MESS('A','ELEMENTS_33')
 30   CONTINUE
      RP = (XM1 - X0)*(XM1 - X0)
      RP = RP + (YM1 - Y0)*(YM1 - Y0)
      DISTFO = SQRT(RP)

      END
