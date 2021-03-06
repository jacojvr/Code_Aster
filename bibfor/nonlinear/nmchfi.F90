subroutine nmchfi(ds_algopara, fonact    , sddisc, sddyna, numins,&
                  iterat     , ds_contact, lcfint, lcdiri, lcbudi,&
                  lcrigi     , option)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/isfonc.h"
#include "asterfort/ndynlo.h"
#include "asterfort/nmchrm.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2015  EDF R&D                  WWW.CODE-ASTER.ORG
! THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY
! IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
! THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR
! (AT YOUR OPTION) ANY LATER VERSION.
!
! THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
! WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
! MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
! GENERAL PUBLIC LICENSE FOR MORE DETAILS.
!
! YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
! ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mickael.abbas at edf.fr
!
    type(NL_DS_AlgoPara), intent(in) :: ds_algopara
    integer :: fonact(*)
    character(len=16) :: option
    character(len=19) :: sddisc, sddyna
    integer :: numins, iterat
    type(NL_DS_Contact), intent(in) :: ds_contact
    aster_logical :: lcfint, lcrigi, lcdiri, lcbudi
!
! ----------------------------------------------------------------------
!
! ROUTINE MECA_NON_LINE (CALCUL)
!
! CHOIX DE L'OPTION POUR CALCUL DES FORCES INTERNES
!
! ----------------------------------------------------------------------
!
! In  ds_algopara      : datastructure for algorithm parameters
! IN  FONACT : FONCTIONNALITES ACTIVEES (VOIR NMFONC)
! IN  SDDISC : SD DISC_INST
! IN  SDDYNA : SD DYNAMIQUE
! IN  NUMINS : NUMERO D'INSTANT
! IN  ITERAT : NUMERO D'ITERATION
! In  ds_contact       : datastructure for contact management
! OUT LCFINT  : .TRUE. SI CALCUL DES VECT_ELEM DES FORCES INTERIEURS
! OUT LCDIRI  : .TRUE. SI CALCUL DES VECT_ELEM DES REACTIONS D'APPUI
! OUT LCRIGI  : .TRUE. SI CALCUL DES MATR_ELEM DES MATRICES DE RIGIDITE
! OUT OPTION : NOM D'OPTION PASSE A MERIMO POUR FORCES INTERNES
!
!
!
!
    aster_logical :: reasma
    character(len=16) :: metcor, metpre
    aster_logical :: lunil, lctcd, lreli, lexpl
!
! ----------------------------------------------------------------------
!
    lunil = isfonc(fonact,'LIAISON_UNILATER')
    lctcd = isfonc(fonact,'CONT_DISCRET')
    lreli = isfonc(fonact,'RECH_LINE')
    lexpl = ndynlo(sddyna,'EXPLICITE')
!
! --- CHOIX DE REASSEMBLAGE DE LA MATRICE GLOBALE
!
    call nmchrm('FORCES_INT', ds_algopara, fonact, sddisc, sddyna,&
                numins, iterat, ds_contact, metpre, metcor,&
                reasma)
!
! --- OPTION DE CALCUL
!
    if (reasma) then
        if (metcor .eq. 'TANGENTE') then
            option = 'FULL_MECA'
        else
            option = 'FULL_MECA_ELAS'
        endif
    else
        option = 'RAPH_MECA'
    endif
!
! --- DOIT-ON CALCULER LES VECT_ELEM DES FORCES INTERNES ?
! --- INUTILE SI FULL_MECA (DEJA FAIT)
!
    if (.not.lreli .or. iterat .eq. 0) then
        lcfint = .true.
    else
        if (option .eq. 'FULL_MECA') then
            lcfint = .true.
        else
            lcfint = .false.
        endif
    endif
!
    if (lctcd .or. lunil) then
        lcfint = .true.
    endif
!
    if (lexpl) then
        lcfint = .false.
    endif
!
! --- DOIT-ON CALCULER LES MATR_ELEM DE RIGIDITE ?
!
    if (option .ne. 'RAPH_MECA') then
        lcrigi = .true.
    else
        lcrigi = .false.
    endif
!
! --- DOIT-ON CALCULER LES VECT_ELEM DES REACTIONS D'APPUI ?
!    -> NON SI DEJA CALCULE DANS RECHERCHE LINEAIRE
    lcdiri = lcfint
    lcbudi = lcfint
!
end subroutine
