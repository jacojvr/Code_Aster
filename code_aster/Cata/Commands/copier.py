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
# person_in_charge: jacques.pellet at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def copier_prod(CONCEPT,**args):
   return AsType(CONCEPT)

# liste des types de concept acceptes par la commande :
copier_ltyp=(
  cabl_precont,
  listr8_sdaster,
  listis_sdaster,
  fonction_sdaster,
  nappe_sdaster,
  table_sdaster,
  maillage_sdaster,
  modele_sdaster,
  evol_elas,
  evol_noli,
  evol_ther,
)

COPIER=OPER(nom="COPIER",op= 185,sd_prod=copier_prod,reentrant='f',
            fr=tr("Copier un concept utilisateur sous un autre nom"),

            reuse=SIMP(statut='c', typ=CO),
            CONCEPT = SIMP(statut='o',typ=copier_ltyp,),
            INFO   = SIMP(statut='f', typ='I', into=(1, 2), defaut=1, ),
)
