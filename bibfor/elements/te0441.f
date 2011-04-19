      SUBROUTINE TE0441(OPTION,NOMTE)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF ELEMENTS  DATE 20/04/2011   AUTEUR COURTOIS M.COURTOIS 
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
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
C ======================================================================

      IMPLICIT NONE
      CHARACTER*16 OPTION,NOMTE
C......................................................................
C
C    - FONCTION REALISEE:  CALCUL DES VECTEURS ELEMENTAIRES
C                          OPTIONS  CHAR_MECA_PESA_R ET CHAR_MECA_ROTA_R
C                          POUR LES �L�MENTS X-FEM
C
C    - ARGUMENTS:
C        DONNEES:      OPTION       -->  OPTION DE CALCUL
C                      NOMTE        -->  NOM DU TYPE ELEMENT
C ......................................................................


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

      INTEGER J,KK,NDIM,NNO,NNOP,NNOPS,NNOS,NNOM,NDDL,NPG,SINGU
      INTEGER NFH,DDLS,NFE,DDLC,NSE,ISE,IN,INO,IBID,DDLM
      INTEGER JPINTT,JCNSET,JHEAVT,JLONCH,JLSN,JLST,JCOORS,JSTNO,JPMILT
      INTEGER IVECTU,ITEMPS,IGEOM,IDECPG,IROTA,IPESA,IMATE
      INTEGER IRESE,NFISS,JFISNO
      REAL*8  RBID,FNO(81),RHO,OM,OMO
      INTEGER ICODRE(3)
      CHARACTER*8   ELREFP,ELRESE(6),FAMI(6),ENR,LAG
      CHARACTER*16  PHENOM
      CHARACTER*24  COORSE
      LOGICAL LBID,ISMALI

      DATA    ELRESE /'SE2','TR3','TE4','SE3','TR6','TE4'/
      DATA    FAMI   /'BID','RIGI','XINT','BID','RIGI','XINT'/

C-----------------------------------------------------------------------

      CALL JEMARQ()

C     ELEMENT DE REFERENCE PARENT
      CALL ELREF1(ELREFP)
      CALL ELREF4(' ','RIGI',NDIM,NNOP,NNOPS,IBID,IBID,IBID,IBID,IBID)

C     SOUS-ELEMENT DE REFERENCE : RECUP DE NNO, NPG
      IF (.NOT.ISMALI(ELREFP).AND. NDIM.LE.2) THEN
        IRESE=3
      ELSE
        IRESE=0
      ENDIF
      CALL ELREF4(ELRESE(NDIM+IRESE),FAMI(NDIM+IRESE),IBID,NNO,NNOS,NPG,
     &                                           IBID,IBID,IBID,IBID)

C     INITIALISATION DES DIMENSIONS DES DDLS X-FEM
      CALL XTEINI(NOMTE,NFH,NFE,SINGU,DDLC,NNOM,DDLS,NDDL,
     &            DDLM,NFISS,IBID)

C     PARAMETRE DU VECTEUR ELEMENTAIRE
      CALL JEVECH('PVECTUR','E',IVECTU)

C     PARAM�TRES PROPRES � X-FEM
      CALL JEVECH('PPINTTO','L',JPINTT)
      CALL JEVECH('PCNSETO','L',JCNSET)
      CALL JEVECH('PHEAVTO','L',JHEAVT)
      CALL JEVECH('PLONCHA','L',JLONCH)
      CALL JEVECH('PLSN',   'L',JLSN)
      CALL JEVECH('PLST',   'L',JLST)
      CALL JEVECH('PGEOMER','L',IGEOM)
      CALL JEVECH('PSTANO' ,'L',JSTNO)
      CALL JEVECH('PMATERC','L',IMATE)
C     PROPRE AUX ELEMENTS 1D ET 2D (QUADRATIQUES)
      CALL TEATTR (NOMTE,'S','XFEM',ENR,IBID)
      IF (IBID.EQ.0 .AND.(ENR.EQ.'XH'.OR.ENR.EQ.'XHC').AND. NDIM.LE.2)
     &  CALL JEVECH('PPMILTO','L',JPMILT)
      IF (NFISS.GT.1) CALL JEVECH('PFISNO','L',JFISNO)

C     PARAMETRE MATERIAU : RHO MASSE VOLUMIQUE
      CALL RCCOMA(ZI(IMATE),'ELAS',PHENOM,ICODRE)
      CALL RCVALB('RIGI',1,1,'+',ZI(IMATE),' ',PHENOM,
     &            1,' ',RBID,1,'RHO',RHO,ICODRE,1)

C     CALCUL DE L'EFFORT VOLUMIQUE AUX NOEUDS DE L'ELEMENT PARENT : FNO
      CALL VECINI(NDIM*NNOP,0.D0,FNO)

      IF (OPTION.EQ.'CHAR_MECA_PESA_R') THEN

        CALL JEVECH('PPESANR','L',IPESA)

        DO 10 INO=1,NNOP
          DO 11 J=1,NDIM
            KK = NDIM*(INO-1)+J
            FNO(KK) = FNO(KK) + RHO*ZR(IPESA)*ZR(IPESA+J)
 11       CONTINUE
 10     CONTINUE

      ELSEIF (OPTION.EQ.'CHAR_MECA_ROTA_R') THEN

        CALL JEVECH('PROTATR','L',IROTA)

        OM = ZR(IROTA)
        DO 20 INO=1,NNOP
          OMO = 0.D0
          DO 21 J=1,NDIM
            OMO = OMO + ZR(IROTA+J)* ZR(IGEOM+NDIM*(INO-1)+J-1)
 21      CONTINUE
          DO 22 J=1,NDIM
            KK = NDIM*(INO-1)+J
            FNO(KK)=FNO(KK)+RHO*OM*OM*(ZR(IGEOM+KK-1)-OMO*ZR(IROTA+J))
 22       CONTINUE
 20     CONTINUE

      ENDIF

C     R�CUP�RATION DE LA SUBDIVISION DE L'�L�MENT EN NSE SOUS ELEMENT
      NSE=ZI(JLONCH-1+1)

C       BOUCLE SUR LES NSE SOUS-ELEMENTS
      DO 110 ISE=1,NSE

C       COORD DU SOUS-�LT EN QUESTION
        COORSE='&&TE0441.COORSE'
        CALL WKVECT(COORSE,'V V R',NDIM*NNO,JCOORS)

C       BOUCLE SUR LES SOMMETS DU SOUS-TRIA (DU SOUS-SEG)
        DO 111 IN=1,NNO
          INO=ZI(JCNSET-1+NNO*(ISE-1)+IN)
          DO 112 J=1,NDIM
            IF (INO.LT.1000) THEN
              ZR(JCOORS-1+NDIM*(IN-1)+J)=ZR(IGEOM-1+NDIM*(INO-1)+J)
            ELSEIF (INO.GT.1000 .AND. INO.LT.2000) THEN
              ZR(JCOORS-1+NDIM*(IN-1)+J)=
     &                             ZR(JPINTT-1+NDIM*(INO-1000-1)+J)
            ELSEIF (INO.GT.2000 .AND. INO.LT.3000) THEN
              ZR(JCOORS-1+NDIM*(IN-1)+J)=
     &                             ZR(JPMILT-1+NDIM*(INO-2000-1)+J)
            ELSEIF (INO.GT.3000) THEN
              ZR(JCOORS-1+NDIM*(IN-1)+J)=
     &                             ZR(JPMILT-1+NDIM*(INO-3000-1)+J)
            ENDIF
 112      CONTINUE
 111    CONTINUE

C       POSITION DANS LA FAMILLE 'XFEM' DU 1ER PG DU SE COURANT
        IDECPG = NPG * (ISE-1)

        CALL XPESRO(ELREFP,NDIM,COORSE,IGEOM,JHEAVT,JFISNO,NFH,DDLC,
     &              NFE,NFISS,ISE,NNOP,NPG,JLSN,JLST,IDECPG,ITEMPS,
     &              IVECTU,FNO)

        CALL JEDETR(COORSE)

 110  CONTINUE

C     SUPPRESSION DES DDLS SUPERFLUS
      CALL TEATTR (NOMTE,'C','XLAG',LAG,IBID)
      IF (IBID.EQ.0.AND.LAG.EQ.'ARETE') THEN
        NNOP = NNOS
      ENDIF
      CALL XTEDDL(NDIM,NFH,NFE,DDLS,NDDL,NNOP,NNOPS,ZI(JSTNO),
     &             .FALSE.,LBID,OPTION,NOMTE,
     &             RBID,ZR(IVECTU),DDLM,NFISS,JFISNO)

      CALL JEDEMA()
      END
