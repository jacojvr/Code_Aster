subroutine deprecated_model(model)
!
implicit none
#include "asterfort/assert.h"
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
! person_in_charge: josselin.delmas at edf.fr
!
    character(len=*), intent(in) :: model
!
! --------------------------------------------------------------------------------------------------
!
! DEPRECATED FEATURES
!
! Warning for deprecated modelling
!
! --------------------------------------------------------------------------------------------------
!
! In  model : name of deprecated modelling
!
! --------------------------------------------------------------------------------------------------
!
    integer :: vali
    character(len=32) :: valk
!
! --------------------------------------------------------------------------------------------------
!
    if (model .eq. '3D_GRAD_EPSI') then
        vali = 13
        valk    = "MODELISATION='3D_GRAD_EPSI'"
!
    else if (model .eq. 'C_PLAN_GRAD_EPSI') then
        vali = 13
        valk    = "MODELISATION='C_PLAN_GRAD_EPSI'"
!
    else if (model .eq. 'D_PLAN_GRAD_EPSI') then
        vali = 13
        valk    = "MODELISATION='D_PLAN_GRAD_EPSI'"
!
    else if (model .eq. 'POU_C_T') then
        vali = 13
        valk    = "MODELISATION='POU_C_T'"
!
    else
        goto 999
!
    endif
!
    call utmess('A', 'SUPERVIS_9', sk = valk, si = vali)
!
999 continue
!
end subroutine
