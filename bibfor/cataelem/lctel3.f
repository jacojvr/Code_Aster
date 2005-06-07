      SUBROUTINE LCTEL3()
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CATAELEM  DATE 30/01/2002   AUTEUR VABHHTS J.TESELET 
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
      IMPLICIT REAL*8 (A-H,O-Z)
C
C ----------------------------------------------------------------------
C     BUT: CREER APOSTERIORI L'OBJET &CATA.TE.DIM_GEOM
C          QUI CONTIENT LA DIMENSION GEOMETRIQUE DES TYPE_ELEM
C          0 : LE TYPE_ELEM N'UTILISE PAS LA GRANDEUR "GEOM_R"
C          1 : LE TYPE_ELEM UTILISE LA CMP "X"
C          2 : LE TYPE_ELEM UTILISE LA CMP "Y"
C          3 : LE TYPE_ELEM UTILISE LA CMP "Z"
C
C ----------------------------------------------------------------------
C---------------- COMMUNS NORMALISES  JEVEUX  --------------------------
      CHARACTER*32 JEXNUM,JEXNOM,JEXATR,JEXR8
      COMMON /IVARJE/ZI(1)
      COMMON /RVARJE/ZR(1)
      COMMON /CVARJE/ZC(1)
      COMMON /LVARJE/ZL(1)
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      INTEGER ZI,INDIK8,DG
      REAL*8 ZR
      COMPLEX*16 ZC
      LOGICAL ZL,EXISDG
      CHARACTER*8 ZK8,K8BID
      CHARACTER*16 ZK16,NOMTE
      CHARACTER*24 ZK24,NOMOLO
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
C ---------------- FIN COMMUNS NORMALISES  JEVEUX  --------------------
C
C
C
      CALL JEMARQ()
      CALL JELIRA('&CATA.TE.NOMTE','NOMMAX',NBTE,K8BID)
      CALL WKVECT('&CATA.TE.DIM_GEOM','G V I',NBTE,IADIGE)
      CALL JENONU(JEXNOM('&CATA.GD.NOMGD','GEOM_R'),IGDGEO)
      CALL JEVEUO(JEXNOM('&CATA.GD.NOMCMP','GEOM_R'),'L',INOCMP)
      CALL JELIRA(JEXNOM('&CATA.GD.NOMCMP','GEOM_R'),'LONMAX',NBCMP,
     &            K8BID)
      IX=INDIK8(ZK8(INOCMP),'X',1,NBCMP)
      IY=INDIK8(ZK8(INOCMP),'Y',1,NBCMP)
      IZ=INDIK8(ZK8(INOCMP),'Z',1,NBCMP)
      CALL DISMOI('F','NB_EC','GEOM_R','GRANDEUR',NBEC,K8BID,IER)
      IF (NBEC.GT.1) CALL UTMESS('F','LCTEL3', 'NB_EC > 1')
C
C     - BOUCLE SUR TOUS LES MODES LOCAUX DES CATALOGUES :
      CALL JELIRA('&CATA.TE.NOMMOLOC','NOMMAX',NBML,K8BID)
      DO 1, IML=1,NBML
         CALL JEVEUO(JEXNUM('&CATA.TE.MODELOC',IML),'L',IAMOLO)
         ICODE=ZI(IAMOLO-1+1)
         IGD=ZI(IAMOLO-1+2)
         IF (IGD.NE.IGDGEO) GO TO 1
         IF (ICODE.GT.3) GO TO 1

         CALL JENUNO(JEXNUM('&CATA.TE.NOMMOLOC',IML),NOMOLO)
         NOMTE=NOMOLO(1:16)
         CALL JENONU(JEXNOM('&CATA.TE.NOMTE',NOMTE),ITE)

         NBPT=ZI(IAMOLO-1+4)
         IF (NBPT.GE.10000) THEN
           NBDG=NBPT-10000
         ELSE
           NBDG=1
         END IF

         DO 2, K=1,NBDG
           DG=ZI(IAMOLO-1+4+K)
           IF (EXISDG(DG,IX)) ZI(IADIGE-1+ITE)=MAX(1,ZI(IADIGE-1+ITE))
           IF (EXISDG(DG,IY)) ZI(IADIGE-1+ITE)=MAX(2,ZI(IADIGE-1+ITE))
           IF (EXISDG(DG,IZ)) ZI(IADIGE-1+ITE)=MAX(3,ZI(IADIGE-1+ITE))
 2       CONTINUE
 1     CONTINUE

C
 9999 CONTINUE
      CALL JEDEMA()
      END
