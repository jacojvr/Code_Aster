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


MODI_MODELE_XFEM=OPER(nom="MODI_MODELE_XFEM",op= 113,sd_prod=modele_sdaster,docu="U4.44.12-e",reentrant='f',
                           fr=tr("Engendrer ou enrichir une structure de donnees en affectant les cham_gd associes"),

    regles = (UN_PARMI('FISSURE','MODELE_THER')),

    reuse=SIMP(statut='c', typ=CO),
    MODELE_IN       =SIMP(statut='o',typ=modele_sdaster,min=1,max=1,),
    FISSURE         =SIMP(statut='f',typ=fiss_xfem,min=1,max=99,),
    MODELE_THER     =SIMP(statut='f',typ=modele_sdaster,min=1,max=1,),
    INFO            =SIMP(statut='f',typ='I',defaut= 1,into=(1,2,)),
    CONTACT
     =SIMP(statut='f',typ='TXM',defaut='SANS',into=("SANS","STANDARD","MORTAR"),min=1,max=1,),
    PRETRAITEMENTS  =SIMP(statut='f',typ='TXM',defaut='AUTO',into=('AUTO','SANS','FORCE')),
    DECOUPE_FACETTE =SIMP(statut='f',typ='TXM',defaut='DEFAUT',into=('DEFAUT','SOUS_ELEMENTS')),
)  ;
