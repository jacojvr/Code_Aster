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
# person_in_charge: mathieu.corus at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


DEFI_INTERF_DYNA=OPER(nom="DEFI_INTERF_DYNA",op=  98,sd_prod=interf_dyna_clas,
                      reentrant='n',
            fr=tr("Définir les interfaces d'une structure et leur affecter un type"),
         NUME_DDL        =SIMP(statut='o',typ=nume_ddl_sdaster ),
         INTERFACE       =FACT(statut='o',max='**',
           regles=(ENSEMBLE('NOM','TYPE'),
#  erreur doc U sur la condition qui suit
                   UN_PARMI('NOEUD','GROUP_NO'),),
           NOM             =SIMP(statut='o',typ='TXM' ),
           TYPE            =SIMP(statut='o',typ='TXM',into=("MNEAL","CRAIGB","CB_HARMO","AUCUN") ),
           NOEUD           =SIMP(statut='c',typ=no,validators=NoRepeat(),max='**'),
           GROUP_NO        =SIMP(statut='f',typ=grno,max='**'),
#           DDL_ACTIF       =SIMP(statut='f',typ='TXM',max='**'),
           MASQUE          =SIMP(statut='f',typ='TXM',max='**'),
         ),
         FREQ            =SIMP(statut='f',typ='R',defaut= 1.),
         INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
