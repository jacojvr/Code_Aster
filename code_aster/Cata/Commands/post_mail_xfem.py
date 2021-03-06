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
# person_in_charge: sam.cuvilliez at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


POST_MAIL_XFEM=OPER(nom="POST_MAIL_XFEM",op= 187,sd_prod=maillage_sdaster,
                    reentrant='n',
            fr=tr("Crée un maillage se conformant à la fissure pour le post-traitement des éléments XFEM"),
    MODELE        = SIMP(statut='o',typ=modele_sdaster),
    PREF_NOEUD_X   =SIMP(statut='f',typ='TXM',defaut="NX",validators=LongStr(1,2),),
    PREF_NOEUD_M   =SIMP(statut='f',typ='TXM',defaut="NM",validators=LongStr(1,2),),
    PREF_NOEUD_P   =SIMP(statut='f',typ='TXM',defaut="NP",validators=LongStr(1,2),),
    PREF_MAILLE_X  =SIMP(statut='f',typ='TXM',defaut="MX",validators=LongStr(1,2),),
    PREF_GROUP_CO  =SIMP(statut='f',typ=grno ,defaut="NFISSU",),
    TITRE         = SIMP(statut='f',typ='TXM'),
    INFO           =SIMP(statut='f',typ='I',defaut= 1,into=(1,2,) ),
);
