# coding=utf-8
# person_in_charge: sylvie.granet at edf.fr


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

from cataelem.Tools.base_objects import InputParameter, OutputParameter, Option, CondCalcul
import cataelem.Commons.physical_quantities as PHY
import cataelem.Commons.parameters as SP
import cataelem.Commons.attributes as AT


PPINTTO = InputParameter(phys=PHY.N132_R)


PCNSETO = InputParameter(phys=PHY.N1280I, container='MODL!.TOPOSE.CNS',
                         comment="""  XFEM - CONNECTIVITE DES SOUS-ELEMENTS  """)


PHEAVTO = InputParameter(phys=PHY.N512_I)


PLONCHA = InputParameter(phys=PHY.N120_I, container='MODL!.TOPOSE.LON',
                         comment="""  XFEM - NBRE DE TETRAEDRES ET DE SOUS-ELEMENTS  """)


PLSN = InputParameter(phys=PHY.NEUT_R)


PSTANO = InputParameter(phys=PHY.N120_I)


PPMILTO = InputParameter(phys=PHY.N792_R)


PFISNO = InputParameter(phys=PHY.NEUT_I)


PHEA_NO = InputParameter(phys=PHY.N120_I)


PHEA_SE = InputParameter(phys=PHY.N512_I)


CHAR_MECA_FLUX_R = Option(
    para_in=(
        PCNSETO,
        PFISNO,
        SP.PFLUXR,
        SP.PGEOMER,
        PHEAVTO,
        PHEA_NO,
        PHEA_SE,
        PLONCHA,
        PLSN,
        PPINTTO,
        PPMILTO,
        PSTANO,
        SP.PTEMPSR,
    ),
    para_out=(
        SP.PVECTUR,
    ),
    condition=(
        CondCalcul('+', ((AT.PHENO, 'ME'), (AT.TYPMOD2, 'THM'), (AT.BORD, '-1'),)),
    ),
    comment=""" CHAR_MECA_FLUX_R (MOT-CLE FLUX_THM_REP) : CALCUL DU SECOND MEMBRE
           CORRESPONDANT A UN FLUX DE CHALEUR ET/OU UN APPORT DE MASSE FLUIDE
           (FLUX HYDRAULIQUE) APPLIQUER A UN DOMAINE DE MILIEU CONTINU 2D
           OU 3D""",
)
