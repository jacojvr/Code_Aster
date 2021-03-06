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
# person_in_charge: alexandre-externe.martin at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_ERREUR=MACRO(nom="POST_ERREUR",
                  op=OPS('Macro.post_erreur_ops.post_erreur_ops'),
                  sd_prod=table_sdaster,
                  reentrant='f',
                  reuse=SIMP(statut='c', typ=CO),
                  OPTION       = SIMP(statut='o',typ='TXM',into=("DEPL_RELA","ENER_RELA","LAGR_RELA") ),
                  MODELE       = SIMP(statut='o',typ=modele_sdaster),
                  GROUP_MA     = SIMP(statut='o',typ=grma,max='**'),
                  b_depl =BLOC(condition = """equal_to("OPTION", 'DEPL_RELA') """,
                               fr="Paramètres pour l'erreur en deplacement en norme l2",
                               CHAM_MATER=SIMP(statut='f',typ=cham_mater),
                               CHAM_GD      = SIMP(statut='o',typ=cham_no_sdaster),
                               DX= SIMP(statut='f',typ=(formule),max='**' ),
                               DY= SIMP(statut='f',typ=(formule),max='**' ),
                               DZ= SIMP(statut='f',typ=(formule),max='**' ),
                               ),
                  b_ener =BLOC(condition = """equal_to("OPTION", 'ENER_RELA') """,
                               fr="Paramètres pour l'erreur en energie elastique",
                               CHAM_MATER=SIMP(statut='o',typ=cham_mater),
                               DEFORMATION  = SIMP(statut='o',typ='TXM',into=("PETIT",),),
                               CHAM_GD      = SIMP(statut='o',typ=cham_elem),
                               SIXX= SIMP(statut='f',typ=(formule),max='**' ),
                               SIYY= SIMP(statut='f',typ=(formule),max='**' ),
                               SIZZ= SIMP(statut='f',typ=(formule),max='**' ),
                               SIXY= SIMP(statut='f',typ=(formule),max='**' ),
                               SIXZ= SIMP(statut='f',typ=(formule),max='**' ),
                               SIYZ= SIMP(statut='f',typ=(formule),max='**' ),
                               ),
                  b_lag =BLOC(condition = """equal_to("OPTION", 'LAGR_RELA') """,
                               fr="Paramètres pour l'erreur en pression en norme l2",
                               CHAM_GD      = SIMP(statut='o',typ=cham_no_sdaster),
                               LAGS_C= SIMP(statut='f',typ=(formule),max='**' ),
                               ),
)  ;
