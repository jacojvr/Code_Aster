# coding=utf-8
# ======================================================================
# COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
# THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
# IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
# THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
# (AT YOUR OPTION) ANY LATER VERSION.
#
# THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
# WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
# GENERAL PUBLIC LICENSE FOR MORE DETAILS.
#
# YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
# ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
#    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
# ======================================================================
# person_in_charge: natacha.bereux at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def elim_lagr_prod(MATR_RIGI,**args):
  if AsType(MATR_RIGI) == matr_asse_depl_r : return matr_asse_depl_r
  raise AsException("type de concept resultat non prevu")

ELIM_LAGR=OPER(nom="ELIM_LAGR",op=69,sd_prod=elim_lagr_prod,
               fr=tr("Créer une matrice en ayant éliminé les condition cinématiques dualisées."),
               reentrant='f',

         reuse=SIMP(statut='c', typ=CO),
         # Matrice de "rigidité" (celle qui contient les équations dualisées) :
         MATR_RIGI       =SIMP(statut='o',typ=(matr_asse_depl_r,) ),

         # Matrice à réduire (si ce n'est pas la matrice de rigidité) :
         MATR_ASSE       =SIMP(statut='f',typ=(matr_asse_depl_r,) ),


         INFO            =SIMP(statut='f',typ='I',into=(1,2) ),
)  ;
