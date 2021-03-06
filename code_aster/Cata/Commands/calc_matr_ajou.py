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
# person_in_charge: nicolas.greffet at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_MATR_AJOU=OPER(nom="CALC_MATR_AJOU",op= 152,sd_prod=matr_asse_gene_r,
                    fr=tr("Calcul des matrices de masse, d'amortissement ou de rigidité ajoutés"),
                    reentrant='n',
         regles=(EXCLUS('MODE_MECA','CHAM_NO','MODELE_GENE'),
                 PRESENT_ABSENT('NUME_DDL_GENE','CHAM_NO'),
                 PRESENT_PRESENT('MODELE_GENE','NUME_DDL_GENE'),),
         MODELE_FLUIDE   =SIMP(statut='o',typ=modele_sdaster ),
         MODELE_INTERFACE=SIMP(statut='o',typ=modele_sdaster ),
         CHAM_MATER      =SIMP(statut='o',typ=cham_mater ),
         CHARGE          =SIMP(statut='o',typ=char_ther ),
         MODE_MECA       =SIMP(statut='f',typ=mode_meca ),
         CHAM_NO         =SIMP(statut='f',typ=cham_no_sdaster ),
         MODELE_GENE     =SIMP(statut='f',typ=modele_gene ),
         NUME_DDL_GENE   =SIMP(statut='f',typ=nume_ddl_gene ),
         DIST_REFE       =SIMP(statut='f',typ='R',defaut= 1.E-2 ),
         AVEC_MODE_STAT  =SIMP(statut='f',typ='TXM',defaut="OUI",into=("OUI","NON") ),
         NUME_MODE_MECA  =SIMP(statut='f',typ='I',validators=NoRepeat(),max='**'),
         OPTION          =SIMP(statut='o',typ='TXM',into=("MASS_AJOU","AMOR_AJOU","RIGI_AJOU") ),
         POTENTIEL       =SIMP(statut='f',typ=evol_ther ),
         NOEUD_DOUBLE    =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON") ),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2 ) ),
#-------------------------------------------------------------------
#        Catalogue commun SOLVEUR
         SOLVEUR         =C_SOLVEUR('CALC_MATR_AJOU'),
#-------------------------------------------------------------------
)  ;
