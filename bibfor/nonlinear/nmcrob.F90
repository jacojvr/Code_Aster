subroutine nmcrob(meshz     , modelz         , sddisc   , ds_inout , cara_elemz,&
                  matez     , ds_constitutive, disp_curr, strx_curr, varc_curr ,&
                  varc_refe , time           , sd_obsv  )
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterc/getfac.h"
#include "asterfort/assert.h"
#include "asterfort/jeveuo.h"
#include "asterfort/nmcroi.h"
#include "asterfort/nmcrot.h"
#include "asterfort/nmextr.h"
#include "asterfort/nmobno.h"
#include "asterfort/utmess.h"
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
! person_in_charge: mickael.abbas at edf.fr
!
    character(len=*), intent(in) :: meshz
    character(len=*), intent(in) :: modelz
    character(len=19), intent(in) :: sddisc
    type(NL_DS_InOut), intent(in) :: ds_inout
    character(len=*), intent(in) :: cara_elemz
    character(len=*), intent(in) :: matez
    type(NL_DS_Constitutive), intent(in) :: ds_constitutive
    character(len=*), intent(in) :: disp_curr
    character(len=*), intent(in) :: strx_curr
    character(len=*), intent(in) :: varc_curr
    character(len=*), intent(in) :: varc_refe
    real(kind=8),  intent(in) :: time
    character(len=19), intent(out) :: sd_obsv
!
! --------------------------------------------------------------------------------------------------
!
! MECA_NON_LINE - Observation
!
! Create observation datastructure
!
! --------------------------------------------------------------------------------------------------
!
! In  mesh             : name of mesh
! In  model            : name of model
! In  result           : name of results datastructure
! In  ds_inout         : datastructure for input/output management
! In  cara_elem        : name of datastructure for elementary parameters (CARTE)
! In  mate             : name of material characteristics (field)
! In  ds_constitutive  : datastructure for constitutive laws management
! In  disp_curr        : current displacements
! In  varc_curr        : command variable for current time
! In  varc_refe        : command variable for reference
! In  time             : current time
! In  strx_curr        : fibers information for current time
! Out sd_obsv          : datastructure for observation parameters
!
! --------------------------------------------------------------------------------------------------
!
    integer :: nb_obsv, nb_keyw_fact, nume_reuse
    character(len=19) :: sdarch
    character(len=8) :: result
    character(len=14) :: sdextr_obsv
    character(len=16) :: keyw_fact
    character(len=24) :: arch_info
    integer, pointer :: v_arch_info(:) => null()
    character(len=24) :: extr_info
    integer, pointer :: v_extr_info(:) => null()
!
! --------------------------------------------------------------------------------------------------
!
    nb_obsv   = 0
    sd_obsv   = '&&NMCROB.OBSV'
    keyw_fact = 'OBSERVATION'
    call getfac(keyw_fact, nb_keyw_fact)
    ASSERT(nb_keyw_fact.le.99)
    result    = ds_inout%result
!
! - Access to storage datastructure
!
    sdarch    = sddisc(1:14)//'.ARCH'
    arch_info = sdarch(1:19)//'.AINF'
    call jeveuo(arch_info, 'L', vi = v_arch_info)
!
! - Read datas for extraction
!
    sdextr_obsv = sd_obsv(1:14)
    call nmextr(meshz       , modelz    , sdextr_obsv, ds_inout, keyw_fact,&
                nb_keyw_fact, nb_obsv   ,&
                cara_elemz  , matez     , ds_constitutive, disp_curr, strx_curr,&
                varc_curr   , varc_refe , time       )
!
! - Set reuse index in OBSERVATION table
!
    nume_reuse = v_arch_info(3)
    extr_info  = sdextr_obsv(1:14)//'     .INFO'
    call jeveuo(extr_info, 'E', vi = v_extr_info)
    v_extr_info(4) = nume_reuse
!
! - Read parameters
!
    if (nb_obsv .ne. 0) then
!
        call utmess('I', 'OBSERVATION_3', si=nb_obsv)   
!
! ----- Read time list
!
        call nmcroi(sd_obsv, keyw_fact, nb_keyw_fact)
!
! ----- Read name of columns
!
        call nmobno(sd_obsv, keyw_fact, nb_keyw_fact)
!
! ----- Create table
!
        call nmcrot(result, sd_obsv)
    endif
!
end subroutine
