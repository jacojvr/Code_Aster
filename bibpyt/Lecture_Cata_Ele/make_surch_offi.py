#@ MODIF make_surch_offi Lecture_Cata_Ele  DATE 22/02/2011   AUTEUR LEFEBVRE J-P.LEFEBVRE 
# -*- coding: iso-8859-1 -*-
#            CONFIGURATION MANAGEMENT OF EDF VERSION
# ======================================================================
# COPYRIGHT (C) 1991 - 2011  EDF R&D                  WWW.CODE-ASTER.ORG
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


####################################################################################################
# script pour surcharger les catalogues officiels
#
# ce script fabrique un fichier .ojb  contenant l'info pr�sente dans l'ENSEMBLE des catalogues (+surcharge)
####################################################################################################
usage= '''
   usage :
     python   make_surch_offi.py  rep_scripts  rep_trav  surch  unigest  nom_capy_offi   resu_ojb

     rep_scripts  : nom du r�pertoire principal o� se trouvent les scripts python d'aster (r�pertoire Eficas en g�n�ral)

     rep_trav     : r�pertoire de travail  : ce r�pertoire NE DOIT PAS exister au pr�alable

     surch        : fichier (concat�n�) contenant tous les catalogues (*.cata) � surcharger
                    (si il n'y a pas de fichier surch : il faut donner un nom de fichier inexistant)

     unigest      : fichier unigest : on ne prend en copte que les lignes : CATSUPPR
                    (si il n'y a pas de fichier unigest : il faut donner un nom de fichier inexistant)

     nom_capy_offi: nom du fichier offi.capy � surcharger : /VERS/catobj/elem.capy

     resu_ojb      : nom du fichier ".ojb" contenant le r�sultat de la surcharge
'''
####################################################################################################

import sys
import os
import glob
import string
import traceback


def main(rep_trav, surch, unigest, nom_capy_offi, resu_ojb):
    """Script pour surcharger les catalogues officiels"""
    from Lecture_Cata_Ele.lecture import lire_cata
    from Lecture_Cata_Ele.imprime import impr_cata
    import Lecture_Cata_Ele.utilit as utilit

    # surch :
    #----------------
    surch=os.path.abspath(surch)


    # unigest :
    #--------------
    unigest=os.path.abspath(unigest)

    # nom_capy_offi :
    #----------------
    nom_capy_offi=os.path.abspath(nom_capy_offi)


    # resu_ojb :
    #----------------
    resu_ojb=os.path.abspath(resu_ojb)


    # rep_trav :
    #--------------
    trav=os.path.abspath(rep_trav)
    dirav=os.getcwd()
    if os.path.isdir(trav) :
        print trav+" ne doit pas exister."; raise StandardError
    else:
        os.mkdir(trav)
        os.chdir(trav)

    try :
        try :
            # surcharge des capy et �criture du r�sultat au format .ojb :
            #-------------------------------------------------------------
            if os.path.isfile(surch) :
               # pour ne pas utiliser trop de m�moire, on splite le fichier pour la lecture :
               liste_morceaux=utilit.cata_split(surch,"morceau",5000)

               capy_surch =lire_cata(liste_morceaux[0])
               for k in range(len(liste_morceaux)-1) :
                  capy_surc2 =lire_cata(liste_morceaux[k+1])
                  utilit.concat_capy(capy_surch,capy_surc2)

            else:
               capy_surch =None

            capy_offi  =utilit.read_capy(nom_capy_offi)

            # prise en compte des destructions demand�es via unigest :
            utilit.detruire_cata(capy_offi,unigest)

            utilit.surch_capy(capy_offi,capy_surch)
            impr_cata(capy_offi,resu_ojb,'ojb')

        except  :
            print 60*'-'+' debut trace back'
            traceback.print_exc(file=sys.stdout)
            print 60*'-'+' fin   trace back'
            raise Exception

    finally:
          # m�nage :
          #------------------------
          os.chdir(dirav)
          import shutil
          shutil.rmtree(trav)


if __name__ == '__main__':
    if len(sys.argv) !=7 :
        print usage
        raise StandardError

    # rep_scripts :
    #--------------
    scripts=os.path.abspath(sys.argv[1])
    if os.path.isdir(scripts) :
        sys.path[:0]=[scripts]
    else:
        print scripts+" doit etre le r�pertoire principal des sources *.py (Eficas en g�n�ral)" ; raise StandardError

    main(*sys.argv[2:])


