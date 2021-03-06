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
# person_in_charge: harinaivo.andriambololona at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def crea_elem_ssd_prod(self,NUME_DDL,**args):
    if NUME_DDL:
        self.type_sdprod(NUME_DDL,nume_ddl_sdaster)
    return macr_elem_dyna

CREA_ELEM_SSD=MACRO(nom="CREA_ELEM_SSD",
                    op=OPS('Macro.crea_elem_ssd_ops.crea_elem_ssd_ops'),
                    sd_prod=crea_elem_ssd_prod,
                    reentrant='n',
                    fr=tr("Creation de macro-element dynamique en enchainant les commandes : "
                         "CALC_MATR_ELEM, NUME_DDL, ASSE_MATRICE, MODE_ITER_SIMULT, "
                         "DEFI_INTERF_DYNA, DEFI_BASE_MODALE et MACR_ELEM_DYNA"),

# pour CAL_MATR_ELEM + NUME_DDL + ASSE_MATRICE + MODE_ITER_SIMULT + MODE_STATIQUE
         MODELE          =SIMP(statut='o',typ=modele_sdaster),
         CHAM_MATER      =SIMP(statut='o',typ=cham_mater),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),
         NUME_DDL        =SIMP(statut='f',typ=CO,defaut=None),
         CHARGE          =SIMP(statut='f',typ=(char_meca,char_ther,char_acou),validators=NoRepeat(),max='**'),

# pour DEFI_INTERF_DYNA
         INTERFACE       =FACT(statut='o',max='**',
           regles=(ENSEMBLE('NOM','TYPE'),
                   UN_PARMI('NOEUD','GROUP_NO'),),
           NOM             =SIMP(statut='o',typ='TXM' ),
           TYPE            =SIMP(statut='o',typ='TXM',into=("MNEAL","CRAIGB","CB_HARMO",) ),
           NOEUD           =SIMP(statut='c',typ=no,max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,max='**'),
           FREQ            =SIMP(statut='f',typ='R',defaut= 1.),
           MASQUE          =SIMP(statut='f',typ='TXM',max='**'),
         ),

# pour DEFI_BASE_MODALE
         BASE_MODALE = FACT(statut='o',max = 1,
           TYPE   =SIMP(statut='o',typ='TXM',max=1,into=('CLASSIQUE','RITZ',),),
           b_ritz = BLOC(condition = """equal_to("TYPE", 'RITZ') """,fr=tr("Base de type Ritz"),
             TYPE_MODE  = SIMP(statut='f',typ='TXM',into=('STATIQUE','INTERFACE',),defaut='INTERFACE',),
             b_intf = BLOC(condition = """equal_to("TYPE_MODE", 'INTERFACE') """,
                      NMAX_MODE_INTF  =SIMP(statut='f',typ='I',defaut=10,val_min=1),),
           ),
         ),

         INFO          =SIMP(statut='f',typ='I',defaut= 1,into=(1,2) ),

#-------------------------------------------------------------------
# Catalogue commun SOLVEUR (pour MODE_ITER_SIMULT, MODE_STATIQUE, DEFI_BASE_MODALE)
         SOLVEUR         =C_SOLVEUR('CREA_ELEM_SSD'),
#-------------------------------------------------------------------

# pour le calcul modal
         CALC_FREQ       =FACT(statut='d',
             STOP_ERREUR     =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
             OPTION      =SIMP(statut='f',typ='TXM',defaut="PLUS_PETITE",into=("PLUS_PETITE","BANDE","CENTRE","SANS"),
                                   fr=tr("Choix de l option et par consequent du shift du probleme modal") ),
             b_plus_petite =BLOC(condition = """equal_to("OPTION", 'PLUS_PETITE')""",fr=tr("Recherche des plus petites valeurs propres"),
               NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
             ),
             b_centre       =BLOC(condition = """equal_to("OPTION", 'CENTRE')""",
                                  fr=tr("Recherche des valeurs propres les plus proches d une valeur donnee"),
               FREQ            =SIMP(statut='o',typ='R',
                                     fr=tr("Frequence autour de laquelle on cherche les frequences propres")),
               AMOR_REDUIT     =SIMP(statut='f',typ='R',),
               NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 10,val_min=0 ),
             ),
             b_bande         =BLOC(condition = """(equal_to("OPTION", 'BANDE'))""",
                                   fr=tr("Recherche des valeurs propres dans une bande donnee"),
               NMAX_FREQ       =SIMP(statut='f',typ='I',defaut= 9999,val_min=0 ),
               FREQ            =SIMP(statut='o',typ='R',min=2,validators=NoRepeat(),max='**',
                                     fr=tr("Valeurs des frequences delimitant les bandes de recherche")),
             ),
             APPROCHE        =SIMP(statut='f',typ='TXM',defaut="REEL",into=("REEL","IMAG","COMPLEXE"),
                                   fr=tr("Choix du pseudo-produit scalaire pour la resolution du probleme quadratique") ),
             DIM_SOUS_ESPACE =SIMP(statut='f',typ='I' ),
           ),


)  ;
