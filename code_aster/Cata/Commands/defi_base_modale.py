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


DEFI_BASE_MODALE=OPER(nom="DEFI_BASE_MODALE",op=  99,sd_prod=mode_meca,
                     reentrant='f',
                     fr=tr("Définit la base d'une sous-structuration dynamique ou d'une recombinaison modale"),
         regles=(UN_PARMI('CLASSIQUE','RITZ','DIAG_MASS','ORTHO_BASE'),),
         reuse=SIMP(statut='c', typ=CO),
         CLASSIQUE       =FACT(statut='f',
           INTERF_DYNA     =SIMP(statut='o',typ=interf_dyna_clas ),
           MODE_MECA       =SIMP(statut='o',typ=mode_meca,max='**' ),
           NMAX_MODE       =SIMP(statut='f',typ='I',max='**' ),
         ),
         RITZ            =FACT(statut='f', max=2,
           regles=(UN_PARMI('MODE_MECA','BASE_MODALE','MODE_INTF'),),
           MODE_MECA       =SIMP(statut='f',typ=mode_meca,max='**'  ),
           NMAX_MODE       =SIMP(statut='f',typ='I',max='**'),
           BASE_MODALE     =SIMP(statut='f',typ=mode_meca ),
           MODE_INTF       =SIMP(statut='f',typ=(mode_meca,mult_elas),),
         ),
         b_ritz          =BLOC(condition = """exists("RITZ")""",
           INTERF_DYNA     =SIMP(statut='f',typ=interf_dyna_clas ),
           NUME_REF        =SIMP(statut='f',typ=nume_ddl_sdaster ),
           ORTHO           =SIMP(statut='f',typ='TXM',defaut="NON",into=("OUI","NON"),
                               fr=tr("Reorthonormalisation de la base de Ritz") ),
           LIST_AMOR       =SIMP(statut='f',typ=listr8_sdaster ),
           b_ortho          =BLOC(condition = """equal_to("ORTHO", 'OUI') """,
             MATRICE          =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_gene_r,matr_asse_pres_r ) ),
               ),
         ),
        DIAG_MASS        =FACT(statut='f',
           MODE_MECA       =SIMP(statut='o',typ=mode_meca,max='**'  ),
           MODE_STAT       =SIMP(statut='o',typ=mode_meca ),
         ),
        ORTHO_BASE        =FACT(statut='f',
           BASE       =SIMP(statut='o',typ=(mode_meca,mult_elas)),
           MATRICE    =SIMP(statut='o',typ=(matr_asse_depl_r,matr_asse_depl_c,matr_asse_gene_r,matr_asse_pres_r ) ),
         ),

#-------------------------------------------------------------------
#       Catalogue commun SOLVEUR
        SOLVEUR         =C_SOLVEUR('DEFI_BASE_MODALE'),
#-------------------------------------------------------------------



        TITRE           =SIMP(statut='f',typ='TXM'),
        INFO            =SIMP(statut='f',typ='I',defaut= 1,into=( 1 , 2) ),
)  ;
