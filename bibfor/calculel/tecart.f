      SUBROUTINE TECART(CARTE)
C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF CALCULEL  DATE 29/09/95   AUTEUR GIBHHAY A.Y.PORTABILITE 
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
C ----------------------------------------------------------------------
      IMPLICIT REAL*8 (A-H,O-Z)
      CHARACTER*(*)CARTE
C ----------------------------------------------------------------------
C     IN : CARTE (K19) : NOM DE LA CARTE A MODIFIER
C
C     OUT: CARTE: LA CARTE EST MODIFIEE.
C ---------------------------------------------------------------------
C     BUT : CETTE ROUTINE  PERMET UNE SURCHARGE "FINE"
C           DES GRANDEURS AFFECTEES SUR UNE CARTE:
C
C         1) PAR DEFAUT (SI ON N'APPELLE PAS "TECART") UNE MAILLE SERA
C            AFFECTEE PAR LA DERNIERE GRANDEUR QU'ON LUI AURA ASSIGNEE
C            (DERNIER "NOCART" LA CONCERNANT)
C             LA GRANDEUR EST ICI A CONSIDERER DANS SON ENSEMBLE :
C             C'EST L'ENSEMBLE DES CMPS NOTES PAR "NOCART".
C             LA NOUVELLE GRANDEUR ECRASE COMPLETEMENT UNE EVENTUELLE
C             ANCIENNE GRANDEUR SUR TOUTES LES MAILLES AFFECTEES.
C
C         2) SI ON APPELLE "TECART", LA NOUVELLE GRANDEUR AFFECTEE
C            N'ECRASE QUE LES CMPS QUE L'ON AFFECTE VRAIMENT :
C           LES CMPS NON AFFECTEES PAR "NOCART" SONT ALORS TRANSPARENTES
C
C         REMARQUE :
C           SI L'ON VEUT DONNER UNE VALEUR PAR DEFAUT SUR LES CMPS
C           IL SUFFIT DE FAIRE UN "NOCART" DES LE DEBUT EN NOTANT
C           TOUTES LES CMPS SUR "TOUT" LE MAILLAGE.
C
C
C
C ---------------------------------------------------------------------
C    EXEMPLE :
C
C      GMA1 = (MA1,MA2)
C      GMA2 = (MA2,MA3)
C
C      CALL ALCART()
C      CALL NOCART(GMA1,('DX','DY'),(1.,2.))
C      CALL NOCART(GMA2,('DX','DZ'),(4.,5.))
C
C    1) ON NE FAIT PAS TECART() :
C          MAILLE   'DX'   'DY'  'DZ'  ("X" VEUT DIRE "N'EXISTE PAS")
C           MA1      1.     2.    X
C           MA2      X      4.    5.
C           MA3      X      4.    5.
C
C    2) ON FAIT TECART()
C          MAILLE   'DX'   'DY'  'DZ'
C           MA1      1.     2.    X
C           MA2      1.     4.    5.
C           MA3      X      4.    5.
C
C ----------------------------------------------------------------------
      CHARACTER*24 CARTE2
C DEB --
      CARTE2= CARTE
C
C     -- ON ETEND LA CARTE:
      CALL EXPCAR(CARTE2)
C
C     -- ON COMPRIME LA CARTE:
      CALL CMPCAR(CARTE2)
C
      END
