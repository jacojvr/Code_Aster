      SUBROUTINE RC36SN ( NBM, ADRM, IPT, C, CARA, MATI, PI, MI, MATJ,
     +       PJ, MJ, MSE, NBTHP, NBTHQ,IOC1,IOC2,  SNIJ )
      IMPLICIT   NONE
      INTEGER             NBM,ADRM(*),IPT,NBTHP,NBTHQ
      REAL*8              C(*), CARA(*), MATI(*), MATJ(*), PI, MI(*),
     +                    PJ, MJ(*), MSE(*), SNIJ
C     ------------------------------------------------------------------
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF POSTRELE  DATE 06/04/2004   AUTEUR DURAND C.DURAND 
C ======================================================================
C COPYRIGHT (C) 1991 - 2002  EDF R&D                  WWW.CODE-ASTER.ORG
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
C     ------------------------------------------------------------------
C
C     OPERATEUR POST_RCCM, TRAITEMENT DE FATIGUE_B3600
C     CALCUL DU SN
C
C IN  : ADRM   : NUMEROS DE LA MAILLE TRAITEE 
C                ET DE LA MAILLE CONNEXE EN IPT
C IN  : IPT    : NUMERO DU NOEUD TRAITE
C IN  : C      : INDICES DE CONTRAINTES
C IN  : CARA   : CARACTERISTIQUES ELEMENTAIRES
C IN  : MATI   : MATERIAU ASSOCIE A L'ETAT STABILISE I
C IN  : PI     : PRESSION ASSOCIEE A L'ETAT STABILISE I
C IN  : MI     : MOMENTS ASSOCIEES A L'ETAT STABILISE I
C IN  : MATJ   : MATERIAU ASSOCIE A L'ETAT STABILISE J
C IN  : PJ     : PRESSION ASSOCIEE A L'ETAT STABILISE J
C IN  : MJ     : MOMENTS ASSOCIEES A L'ETAT STABILISE J
C IN  : PJ     : PRESSION ASSOCIEE A L'ETAT STABILISE J
C IN  : MSE    : MOMENTS DUS AU SEISME
C IN  : NBTHP  : NOMBRE DE CALCULS THERMIQUE POUR L'ETAT STABILISE P
C IN  : NBTHQ  : NOMBRE DE CALCULS THERMIQUE POUR L'ETAT STABILISE Q
C IN  : IOC1   : NUMERO OCCURRENCE SITUATION DE L'ETAT STABILISE P
C IN  : IOC2   : NUMERO OCCURRENCE SITUATION DE L'ETAT STABILISE Q
C OUT : SNIJ   : AMPLITUDE DE VARIATION DES CONTRAINTES LINEARISEES
C     ------------------------------------------------------------------
C
      INTEGER    ICMP,IOC1,IOC2
      REAL*8     PIJ, D0, EP, INERT, NU, E, ALPHA, MIJ, EAB, XX, 
     +           ALPHAA, ALPHAB, SN1, SN2, SN3, SN4, SN6, SNP, SNQ
C DEB ------------------------------------------------------------------
      CALL JEMARQ()
C
C --- DIFFERENCE DE PRESSION ENTRE LES ETATS I ET J
C
      PIJ = ABS( PI - PJ )
C
C --- VARIATION DE MOMENT RESULTANT
C
      MIJ = 0.D0
      DO 10 ICMP = 1 , 3
         XX = MSE(ICMP) + ABS( MI(ICMP) - MJ(ICMP) )
         MIJ = MIJ + XX**2
 10   CONTINUE
      MIJ = SQRT( MIJ ) 
C
C --- LE MATERIAU
C
      E      = MAX ( MATI(2) , MATJ(2) )
      NU     = MAX ( MATI(3) , MATJ(3) )
      ALPHA  = MAX ( MATI(4) , MATJ(4) )
      ALPHAA = MAX ( MATI(7) , MATJ(7) )
      ALPHAB = MAX ( MATI(8) , MATJ(8) )
      EAB    = MAX ( MATI(9) , MATJ(9) )
C
C --- LES CARACTERISTIQUES
C
      INERT = CARA(1)
      D0    = CARA(2)
      EP    = CARA(3)
C
C --- CALCUL DU SN:
C     ------------- 
C
      SN1 = C(1)*PIJ*D0 / 2 / EP
      SN2 = C(2)*D0*MIJ / 2 / INERT
      SN3 = E*ALPHA / 2 / (1.D0-NU)
      SN4 = C(3)*EAB
C
C --- ON BOUCLE SUR LES INSTANTS DU THERMIQUE DE P
C
      CALL RCSN01 ( NBM, ADRM, IPT, SN3, SN4, ALPHAA, ALPHAB, 
     +              NBTHP, IOC1, SN6 )
C
      SNP = SN1 + SN2 + SN6
C
      SNIJ = MAX ( SNIJ, SNP )
C
C --- ON BOUCLE SUR LES INSTANTS DU THERMIQUE DE Q
C
      CALL RCSN01 ( NBM, ADRM, IPT, SN3, SN4, ALPHAA, ALPHAB, 
     +              NBTHQ, IOC2, SN6 )
C
      SNQ = SN1 + SN2 + SN6
C
      SNIJ = MAX ( SNIJ, SNQ )
C
      CALL JEDEMA( )
      END
