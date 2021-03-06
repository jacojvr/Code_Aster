subroutine ntnoli(model, mate  , cara_elem, l_stat  , l_evol,&
                  para , sddisc, ds_inout)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/assert.h"
#include "asterfort/infniv.h"
#include "asterfort/jeveuo.h"
#include "asterfort/ntarch.h"
#include "asterfort/rscrsd.h"
#include "asterfort/rsrusd.h"
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
    character(len=24), intent(in) :: model
    character(len=24), intent(in) :: mate
    character(len=24), intent(in) :: cara_elem
    aster_logical, intent(in) :: l_stat
    aster_logical, intent(in) :: l_evol
    real(kind=8), intent(in) :: para(*)
    character(len=19), intent(in) :: sddisc
    type(NL_DS_InOut), intent(inout) :: ds_inout
!
! --------------------------------------------------------------------------------------------------
!
! THER_LINEAIRE - Init
!
! Prepare storing
!
! --------------------------------------------------------------------------------------------------
!
! In  model            : name of model
! In  mate             : name of material characteristics (field)
! In  cara_elem        : name of elementary characteristics (field)
! In  l_stat           : .true. is stationnary
! In  l_evol           : .true. if transient
! In  para             : parameters for time
!                            (1) THETA
!                            (2) DELTAT
! In  sddisc           : datastructure for time discretization
! IO  ds_inout         : datastructure for input/output management
!
! --------------------------------------------------------------------------------------------------
!
    integer :: ifm, niv
    character(len=19) :: sdarch
    character(len=24) :: sdarch_ainf
    integer, pointer :: v_sdarch_ainf(:) => null()
    integer :: nume_store, nume_inst
    aster_logical :: force, lreuse
    character(len=8) :: result
!
! --------------------------------------------------------------------------------------------------
!
    call infniv(ifm, niv)
    if (niv .ge. 2) then
        write (ifm,*) '<THERMIQUE> PREPARATION DE LA SD EVOL_THER'
    endif
!
! - INSTANT INITIAL
!
    nume_inst = 0
    force     = .true.
!
! - Get parameters in input/ouput management datastructure
!
    result = ds_inout%result
    lreuse = ds_inout%l_reuse
!
! --- ACCES SD ARCHIVAGE
!
    sdarch      = sddisc(1:14)//'.ARCH'
    sdarch_ainf = sdarch(1:19)//'.AINF'
!
! - Current storing index
!
    call jeveuo(sdarch_ainf, 'L', vi = v_sdarch_ainf)
    nume_store = v_sdarch_ainf(1)
!
! --- CREATION DE LA SD EVOL_THER OU NETTOYAGE DES ANCIENS NUMEROS
!
    if (lreuse) then
        ASSERT(nume_store.ne.0)
        call rsrusd(result, nume_store)
    else
        ASSERT(nume_store.eq.0)
        call rscrsd('G', result, 'EVOL_THER', 100)
    endif
!
! - Stroing initial state
!
    if ((.not.lreuse) .and. (.not.l_stat) .and. l_evol) then
        call utmess('I', 'ARCHIVAGE_4')
        call ntarch(nume_inst, model   , mate , cara_elem, para,&
                    sddisc   , ds_inout, force)
    endif
!
end subroutine
