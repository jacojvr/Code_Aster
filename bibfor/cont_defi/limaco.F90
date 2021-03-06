subroutine limaco(sdcont      , keywf , mesh, model, model_ndim,&
                  nb_cont_zone, ligret)
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/cfdisi.h"
#include "asterfort/dfc_read_cont.h"
#include "asterfort/dfc_read_disc.h"
#include "asterfort/dfc_read_xfem.h"
#include "asterfort/dfc_read_lac.h"
!
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
! person_in_charge: ayaovi-dzifa.kudawoo at edf.fr
!
    character(len=8), intent(in) :: sdcont
    character(len=8), intent(in) :: mesh
    character(len=8), intent(in) :: model
    character(len=16), intent(in) :: keywf
    character(len=19), intent(in) :: ligret
    integer, intent(in) :: nb_cont_zone
    integer, intent(in) :: model_ndim
!
! --------------------------------------------------------------------------------------------------
!
! DEFI_CONTACT
!
! Get elements and nodes of contact, checkings
!
! --------------------------------------------------------------------------------------------------
!
! In  keywf            : factor keyword to read
! In  sdcont           : name of contact concept (DEFI_CONTACT)
! In  nb_cont_zone     : number of zones of contact
! In  model            : name of model
! In  mesh             : name of mesh
! In  model_ndim       : dimension of model
! In  ligret           : special LIGREL for slaves elements
!
! --------------------------------------------------------------------------------------------------
!
    integer :: cont_form
    character(len=24) :: sdcont_defi
!
! --------------------------------------------------------------------------------------------------
!
    sdcont_defi = sdcont(1:8)//'.CONTACT'
    cont_form   = cfdisi(sdcont_defi,'FORMULATION')
!
    if (cont_form .eq. 1) then
        call dfc_read_disc(sdcont      , keywf, mesh, model, model_ndim,&
                           nb_cont_zone)
    elseif (cont_form .eq. 2) then
        call dfc_read_cont(sdcont, keywf       , mesh, model, model_ndim  ,&
                           ligret, nb_cont_zone)
    elseif (cont_form .eq. 3) then
        call dfc_read_xfem(sdcont      , keywf, mesh, model, model_ndim,&
                           nb_cont_zone)
    elseif (cont_form .eq. 5) then
        call dfc_read_lac (sdcont, keywf       , mesh, model, model_ndim  ,&
                           ligret, nb_cont_zone)                      
    else
        ASSERT(.false.)
    endif
!
end subroutine
