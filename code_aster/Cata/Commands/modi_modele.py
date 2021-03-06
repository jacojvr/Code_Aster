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


MODI_MODELE=OPER(nom="MODI_MODELE",op= 103,sd_prod=modele_sdaster,reentrant='o',
         fr=tr("Modifier la partition d'un modèle (parallélisme) "),

         reuse=SIMP(statut='c', typ=CO),
         MODELE          =SIMP(statut='o',typ=modele_sdaster,min=1,max=1,),

         DISTRIBUTION  =FACT(statut='d',
             METHODE    =SIMP(statut='f',typ='TXM',defaut="SOUS_DOMAINE",
                                   into=("MAIL_CONTIGU","MAIL_DISPERSE","CENTRALISE",
                                         "SOUS_DOMAINE","GROUP_ELEM","SOUS_DOM.OLD")),
             # remarque : "GROUP_ELEM" et "SOUS_DOMAINE" ne servent à rien car on ne modifie la distribution des éléments.
             #            Mais on les acceptent pour simplifier la programmation de calc_modes_multi_bandes.py
             b_dist_maille          =BLOC(condition = """is_in("METHODE", ('MAIL_DISPERSE','MAIL_CONTIGU'))""",
                 CHARGE_PROC0_MA =SIMP(statut='f',typ='I',defaut=100,val_min=0),
             ),
             b_partition  =BLOC(condition = """equal_to("METHODE", 'SOUS_DOM.OLD') """,
                 NB_SOUS_DOMAINE    =SIMP(statut='f',typ='I'), # par defaut : le nombre de processeurs
                 PARTITIONNEUR      =SIMP(statut='f',typ='TXM',into=("METIS","SCOTCH",), defaut="METIS" ),
                 CHARGE_PROC0_SD =SIMP(statut='f',typ='I',defaut=0,val_min=0),
             ),
         ),
)  ;
