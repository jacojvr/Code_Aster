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
# person_in_charge: mohamed-amine.hassini at edf.fr


from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_MODE_ROTATION=MACRO(nom="CALC_MODE_ROTATION",
                         op=OPS('Macro.calc_mode_rotation_ops.calc_mode_rotation_ops'),
                         sd_prod=table_container,
                         reentrant='n',
                         fr=tr("calculer les fréquences et modes d'un système en fonction des "
                              "vitesses de rotation"),

                  MATR_RIGI       =SIMP(statut='o',typ=matr_asse_depl_r ),
                  MATR_MASS       =SIMP(statut='o',typ=matr_asse_depl_r ),
                  MATR_AMOR       =SIMP(statut='f',typ=matr_asse_depl_r ),
                  MATR_GYRO       =SIMP(statut='f',typ=matr_asse_depl_r ),
                  VITE_ROTA       =SIMP(statut='f',typ='R',max='**'),

                  METHODE         =SIMP(statut='f',typ='TXM',defaut="QZ",
                                        into=("QZ","SORENSEN",) ),

                  CALC_FREQ       =FACT(statut='d',
                         OPTION      =SIMP(statut='f',typ='TXM',defaut="PLUS_PETITE",into=("PLUS_PETITE","CENTRE",),
                                           fr=tr("Choix de l option et par conséquent du shift du problème modal") ),
                  b_plus_petite =BLOC(condition = """equal_to("OPTION", 'PLUS_PETITE')""",fr=tr("Recherche des plus petites valeurs propres"),
                              NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                              SEUIL_FREQ      =SIMP(statut='f',typ='R' ,defaut= 1.E-2 ),
                              ),
                  b_centre       =BLOC(condition = """equal_to("OPTION", 'CENTRE')""",
                                fr=tr("Recherche des valeurs propres les plus proches d une valeur donnée"),
                              FREQ            =SIMP(statut='o',typ='R',
                                                     fr=tr("Fréquence autour de laquelle on cherche les fréquences propres")),
                              AMOR_REDUIT     =SIMP(statut='f',typ='R',),
                              NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
                              SEUIL_FREQ      =SIMP(statut='f',typ='R' ,defaut= 1.E-2 ),
                              ),
                             ),

                  VERI_MODE       =FACT(statut='d',
                  STOP_ERREUR     =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
                  SEUIL           =SIMP(statut='f',typ='R',defaut= 1.E-6 ),
                  PREC_SHIFT      =SIMP(statut='f',typ='R',defaut= 5.E-3 ),
                  STURM           =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),),
);
