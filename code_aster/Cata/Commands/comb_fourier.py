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
# person_in_charge: ayaovi-dzifa.kudawoo at edf.fr
from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


COMB_FOURIER=OPER(nom="COMB_FOURIER",op= 161,sd_prod=comb_fourier,
                  reentrant='n',fr=tr("Recombiner les modes de Fourier d'une SD Résultat dans des directions particulières"),
         RESULTAT        =SIMP(statut='o',typ=(fourier_elas,fourier_ther),),
         ANGLE           =SIMP(statut='o',typ='R',max='**'),
         NOM_CHAM        =SIMP(statut='o',typ='TXM',validators=NoRepeat(),max=6,into=("DEPL","REAC_NODA",
                               "SIEF_ELGA","EPSI_ELNO","SIGM_ELNO","TEMP","FLUX_ELNO"),),
) ;
