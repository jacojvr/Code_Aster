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
# person_in_charge: j-pierre.lefebvre at edf.fr

from code_aster.Cata.Syntax import *
from code_aster.Cata.DataStructure import *
from code_aster.Cata.Commons import *


def exec_logiciel_prod(self, SALOME, MAILLAGE, **args):
    if SALOME != None:
        if len(SALOME['NOM_PARA'] or []) != len(SALOME['VALE'] or []):
            raise AsException(tr("SALOME: NOM_PARA et VALE doivent avoir le "
                                 "même cardinal"))
    if MAILLAGE != None:
        return maillage_sdaster
    return None

EXEC_LOGICIEL = MACRO(nom="EXEC_LOGICIEL",
                      op=OPS('Macro.exec_logiciel_ops.exec_logiciel_ops'),
                      sd_prod=exec_logiciel_prod,
                      fr=tr("Exécute un logiciel ou une commande système depuis Aster"),

      regles = ( AU_MOINS_UN('LOGICIEL', 'MAILLAGE', 'SALOME'),
                 EXCLUS('MAILLAGE','SALOME'),
                 ),

      LOGICIEL = SIMP(statut='f', typ='TXM',
                      fr=tr("Programme ou script à exécuter")),
      ARGUMENT = SIMP(statut='f', max='**', typ='TXM',
                      fr=tr("Arguments à transmettre à LOGICIEL")),
      SHELL = SIMP(statut='f', typ='TXM', into=('OUI', 'NON'), defaut='NON',
                   fr=tr("Execution dans un shell, nécessaire si LOGICIEL n'est pas "
                         "un exécutable mais une ligne de commande complète utilisant "
                         "des redirections ou des caractères de completions")),

      MAILLAGE = FACT(statut='f',
         FORMAT     = SIMP(statut='o', typ='TXM', into=("GMSH", "GIBI", "SALOME")),
         UNITE_GEOM = SIMP(statut='f', typ=UnitType(), val_min=10, val_max=90, defaut=16, inout='in',
                           fr=tr("Unité logique définissant le fichier (fort.N) "
                                 "contenant les données géométriques (datg)")),
      ),

      SALOME = FACT(statut='f',
           regles=(PRESENT_PRESENT('NOM_PARA','VALE'),),
         CHEMIN_SCRIPT     = SIMP(statut='o', typ='TXM',
                               fr=tr("Chemin du script Salome")),
         MACHINE           = SIMP(statut='f', typ='TXM',defaut='',
                               fr=tr("Machine sur laquelle tourne Salome")),
         b_remote = BLOC(condition="""not is_in("MACHINE", (None, ''))""",
            UTILISATEUR = SIMP(statut='o', typ='TXM',
                               fr=tr("Utilisateur sur la machine distante")),
         ),
         PORT              = SIMP(statut='f', typ='I',
                              defaut=2810, val_min=2810, val_max=2910,
                              fr=tr("Port de l'instance Salome (2810 ou supérieur)")),
         FICHIERS_ENTREE   = SIMP(statut='f', typ='TXM', validators=NoRepeat(),max='**',
                               fr=tr("Liste des fichiers d'entrée du script Salome")),
         FICHIERS_SORTIE   = SIMP(statut='f', typ='TXM', validators=NoRepeat(),max='**',
                               fr=tr("Liste des fichiers générés par le script Salome")),
         NOM_PARA          = SIMP(statut='f',typ='TXM',max='**',validators=NoRepeat(),
                               fr=tr("Liste des noms des paramètres à modifier "
                                     "dans le script Salome")),
         VALE              = SIMP(statut='f',typ='TXM',max='**',
                               fr=tr("Valeur des paramètres à) modifier dans le "
                                      "script Salome")),
      ),

      CODE_RETOUR_MAXI = SIMP(statut='f', typ='I', defaut=0, val_min=-1,
                              fr=tr("Valeur maximale du code retour toléré "
                                    "(-1 pour l'ignorer)")),

      INFO     = SIMP(statut='f', typ='I', defaut=2, into=(1,2),),
)
