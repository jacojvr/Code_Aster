subroutine nmimci(ds_print, col_name_, vali, l_affe)
!
use NonLin_Datastructure_type
!
implicit none
!
#include "asterf_types.h"
#include "asterfort/SetTableColumn.h"
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
    type(NL_DS_Print), intent(inout) :: ds_print
    character(len=*), intent(in) :: col_name_
    integer, intent(in) :: vali
    aster_logical, intent(in) :: l_affe
!
! --------------------------------------------------------------------------------------------------
!
! MECA_NON_LINE - Print management
!
! Set value in column of convergence table - Integer
!
! --------------------------------------------------------------------------------------------------
!
! IO  ds_print         : datastructure for printing parameters
! In  col_name         : name of column 
! In  flag             : .true. for activation of column
! In  vali             : value (integer) for column
!
! --------------------------------------------------------------------------------------------------
!
    type(NL_DS_Table) :: table_cvg
!
! --------------------------------------------------------------------------------------------------
!
!
! - Get convergence table
!
    table_cvg = ds_print%table_cvg
!
! - Set and activate value
!
    call SetTableColumn(table_cvg, name_ = col_name_,&
                        flag_affe_ = l_affe, valei_ = vali)
!
! - Set convergence table
!
    ds_print%table_cvg = table_cvg
!
end subroutine
