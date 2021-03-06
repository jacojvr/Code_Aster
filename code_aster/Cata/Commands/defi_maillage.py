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


DEFI_MAILLAGE=OPER(nom="DEFI_MAILLAGE",op=  88,sd_prod=maillage_sdaster,
                   fr=tr("Définition d'un nouveau maillage à partir de macro-éléments"),
                   reentrant='n',
         DEFI_SUPER_MAILLE =FACT(statut='o',max='**',
           MACR_ELEM       =SIMP(statut='o',typ=(macr_elem_stat,macr_elem_dyna),max='**' ),
           SUPER_MAILLE    =SIMP(statut='f',typ=ma,max='**'),
           TRAN            =SIMP(statut='f',typ='R',max=3),
           ANGL_NAUT       =SIMP(statut='f',typ='R',max=3),
           b_angl_naut     =BLOC(condition = """exists("ANGL_NAUT")""",
             CENTRE          =SIMP(statut='f',typ='R',max=3),
           ),
         ),
         RECO_GLOBAL     =FACT(statut='f',
           regles=(UN_PARMI('TOUT','SUPER_MAILLE'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",) ),
           SUPER_MAILLE    =SIMP(statut='f',typ=ma,max='**'),
           CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
           PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
         ),
         RECO_SUPER_MAILLE =FACT(statut='f',max='**',
           SUPER_MAILLE    =SIMP(statut='o',typ=ma,max='**'),
           GROUP_NO        =SIMP(statut='o',typ=grno,max='**'),
           OPTION          =SIMP(statut='f',typ='TXM',defaut="GEOMETRIQUE",into=("GEOMETRIQUE","NOEUD_A_NOEUD","INVERSE") ),
           geometrique     =BLOC(condition = """equal_to("OPTION", 'GEOMETRIQUE')""",
             CRITERE         =SIMP(statut='f',typ='TXM',defaut="RELATIF",into=("RELATIF","ABSOLU") ),
             PRECISION       =SIMP(statut='f',typ='R',defaut= 1.E-3 ),
           ),
         ),
         DEFI_NOEUD      =FACT(statut='c',max='**',
           regles=(UN_PARMI('TOUT','NOEUD_INIT'),),
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",),
                                 fr=tr("Renommage de tous les noeuds") ),
           NOEUD_INIT      =SIMP(statut='f',typ=no,
                                 fr=tr("Renommage d un seul noeud")),
           b_tout          =BLOC(condition = """exists("TOUT")""",
             PREFIXE         =SIMP(statut='f',typ='TXM' ),
             INDEX           =SIMP(statut='o',typ='I',max='**'),
           ),
           b_noeud_init    =BLOC(condition = """exists("NOEUD_INIT")""",
             SUPER_MAILLE    =SIMP(statut='o',typ=ma),
             NOEUD_FIN       =SIMP(statut='o',typ=no),
           ),
         ),
         DEFI_GROUP_NO   =FACT(statut='f',max='**',
           regles=(UN_PARMI('TOUT','SUPER_MAILLE'),
                AU_MOINS_UN('INDEX','GROUP_NO_FIN'),
                   ENSEMBLE('GROUP_NO_INIT','GROUP_NO_FIN'),),
#  la regle ancien catalogue AU_MOINS_UN__: ( INDEX , GROUP_NO_FIN ) incoherente avec doc U
           TOUT            =SIMP(statut='f',typ='TXM',into=("OUI",),
                                 fr=tr("Création de plusieurs groupes de noeuds") ),
           SUPER_MAILLE    =SIMP(statut='f',typ=ma,
                                 fr=tr("Création de plusieurs groupes de noeuds")),
           GROUP_NO_INIT   =SIMP(statut='f',typ=grno,
                                 fr=tr("Création d un seul groupe de noeuds")),
           PREFIXE         =SIMP(statut='f',typ='TXM' ),
           INDEX           =SIMP(statut='f',typ='I',max='**'),
           GROUP_NO_FIN    =SIMP(statut='f',typ=grno),
         ),
)  ;
