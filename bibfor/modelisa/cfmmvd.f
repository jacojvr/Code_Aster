      INTEGER FUNCTION CFMMVD(VECT)
C
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF MODELISA  DATE 30/01/2012   AUTEUR DESOZA T.DESOZA 
C ======================================================================
C COPYRIGHT (C) 1991 - 2012  EDF R&D                  WWW.CODE-ASTER.ORG
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
C RESPONSABLE ABBAS M.ABBAS
C
      IMPLICIT NONE
      CHARACTER*5 VECT
C
C ----------------------------------------------------------------------
C
C ROUTINE UTILITAIRE POUR LE CONTACT (TOUTES METHODES)
C
C RETOURNE LA LONGUEUR FIXE DES VECTEURS DE LA SD SDCONT
C
C ----------------------------------------------------------------------
C
C
C IN  VECT   : NOM DU VECTEUR DONT ON VEUT LA DIMENSION
C
C /!\ PENSER A MODIFIE SD_CONTACT.PY (POUR SD_VERI)
C
C ----------------------------------------------------------------------
C
      INTEGER   ZMETH,ZTOLE,ZTABF
      PARAMETER (ZMETH=22,ZTOLE=3 ,ZTABF=34)
      INTEGER   ZCMCF,ZTGDE,ZDIRN,ZDIME
      PARAMETER (ZCMCF=16,ZTGDE=6 ,ZDIRN=6 ,ZDIME = 18)
      INTEGER   ZPOUD,ZTYPM,ZPERC,ZTYPN
      PARAMETER (ZPOUD=3 ,ZTYPM=2 ,ZPERC=4 ,ZTYPN = 2)
      INTEGER   ZMESX,ZAPME,ZMAES
      PARAMETER (ZMESX=5, ZAPME=3 ,ZMAES=4)
      INTEGER   ZRESU,ZCMDF,ZCMXF
      PARAMETER (ZRESU=27,ZCMDF=6 ,ZCMXF=18)
      INTEGER   ZEXCL,ZPARR,ZPARI
      PARAMETER (ZEXCL=3 ,ZPARR=5 ,ZPARI=28)
      INTEGER   ZBOUC,ZTACO
      PARAMETER (ZBOUC=3 ,ZTACO=8)
      INTEGER   ZCOCO,ZTACF,ZETAT
      PARAMETER (ZCOCO=8,ZTACF=4 ,ZETAT=3)
C
C ----------------------------------------------------------------------
C

      IF (VECT.EQ.'ZMETH') THEN
        CFMMVD = ZMETH
      ELSE IF (VECT.EQ.'ZTOLE') THEN
        CFMMVD = ZTOLE
      ELSE IF (VECT.EQ.'ZTABF') THEN
        CFMMVD = ZTABF
      ELSE IF (VECT.EQ.'ZTACF') THEN
        CFMMVD = ZTACF
      ELSE IF (VECT.EQ.'ZCMCF') THEN
        CFMMVD = ZCMCF
      ELSE IF (VECT.EQ.'ZCMXF') THEN
        CFMMVD = ZCMXF
      ELSE IF (VECT.EQ.'ZTGDE') THEN
        CFMMVD = ZTGDE
      ELSE IF (VECT.EQ.'ZDIRN') THEN
        CFMMVD = ZDIRN
      ELSE IF (VECT.EQ.'ZPOUD') THEN
        CFMMVD = ZPOUD
      ELSE IF (VECT.EQ.'ZTYPM') THEN
        CFMMVD = ZTYPM
      ELSE IF (VECT.EQ.'ZTYPN') THEN
        CFMMVD = ZTYPN
      ELSE IF (VECT.EQ.'ZMESX') THEN
        CFMMVD = ZMESX
      ELSE IF (VECT.EQ.'ZAPME') THEN
        CFMMVD = ZAPME
      ELSE IF (VECT.EQ.'ZRESU') THEN
        CFMMVD = ZRESU
      ELSE IF (VECT.EQ.'ZCMDF') THEN
        CFMMVD = ZCMDF
      ELSE IF (VECT.EQ.'ZPERC') THEN
        CFMMVD = ZPERC
      ELSE IF (VECT.EQ.'ZEXCL') THEN
        CFMMVD = ZEXCL
      ELSE IF (VECT.EQ.'ZPARR') THEN
        CFMMVD = ZPARR
      ELSE IF (VECT.EQ.'ZPARI') THEN
        CFMMVD = ZPARI
      ELSE IF (VECT.EQ.'ZBOUC') THEN
        CFMMVD = ZBOUC
      ELSE IF (VECT.EQ.'ZCOCO') THEN
        CFMMVD = ZCOCO
      ELSE IF (VECT.EQ.'ZDIME') THEN
        CFMMVD = ZDIME
      ELSE IF (VECT.EQ.'ZMAES') THEN
        CFMMVD = ZMAES
      ELSE IF (VECT.EQ.'ZETAT') THEN
        CFMMVD = ZETAT
      ELSE IF (VECT.EQ.'ZTACO') THEN
        CFMMVD = ZTACO
      ELSE
        CALL ASSERT(.FALSE.)
      ENDIF
C
      END
