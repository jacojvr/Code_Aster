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
# person_in_charge: josselin.delmas at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


CALC_CHAM_ELEM=OPER(nom="CALC_CHAM_ELEM",op=38,sd_prod=cham_elem,
                    fr=tr("Calculer un champ élémentaire en thermique et en accoustique à partir de champs déjà calculés"),
                    reentrant='n',
         MODELE          =SIMP(statut='o',typ=modele_sdaster),
         CARA_ELEM       =SIMP(statut='f',typ=cara_elem),

         regles=(EXCLUS('TOUT','GROUP_MA',),EXCLUS('TOUT','MAILLE',),),
         TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
         GROUP_MA        =SIMP(statut='f',typ=grma,validators=NoRepeat(),max='**'),
         MAILLE          =SIMP(statut='c',typ=ma  ,validators=NoRepeat(),max='**'),

         INST            =SIMP(statut='f',typ='R',defaut= 0.E+0),
         ACCE            =SIMP(statut='f',typ=cham_no_sdaster),
         MODE_FOURIER    =SIMP(statut='f',typ='I',),

         OPTION          =SIMP(statut='o',typ='TXM',
                               into=("FLUX_ELGA","FLUX_ELNO",
                                                 "PRAC_ELNO",
                                     "COOR_ELGA"), ),

         b_thermique  =BLOC(condition="""is_in("OPTION", ('FLUX_ELNO','FLUX_ELGA',))""",
           TEMP            =SIMP(statut='o',typ=(cham_no_sdaster,)),
           CHAM_MATER      =SIMP(statut='o',typ=cham_mater),
         ),

         b_acoustique  =BLOC(condition="""is_in("OPTION", ('PRAC_ELNO',))""",
           PRES            =SIMP(statut='o',typ=(cham_no_sdaster,)),
         ),

)  ;
