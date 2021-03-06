subroutine get_elas_id(j_mater, elas_id, elas_keyword)
!
implicit none
!
#include "asterfort/rccoma.h"
#include "asterfort/utmess.h"
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
!    1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!
    integer, intent(in) :: j_mater
    integer, intent(out) :: elas_id
    character(len=*), optional, intent(out) :: elas_keyword
!
! --------------------------------------------------------------------------------------------------
!
! Comportment utility
!
! Get elasticity type
!
! --------------------------------------------------------------------------------------------------
!
! In  j_mater      : coded material address
! Out elas_id      : Type of elasticity
!                 1 - Isotropic
!                 2 - Orthotropic
!                 3 - Transverse isotropic
! Out elas_keyword : keyword factor linked to type of elasticity parameters
!
! --------------------------------------------------------------------------------------------------
!
    character(len=16) :: elas_keyword_in
!
! --------------------------------------------------------------------------------------------------
!
!
! - Keyword for elasticity parameters in material
!
    call rccoma(j_mater, 'ELAS', 1, elas_keyword_in)
!
! - Type of elasticity (Isotropic/Orthotropic/Transverse isotropic)
!
    if (elas_keyword_in.eq.'ELAS'.or.&
        elas_keyword_in.eq.'ELAS_HYPER'.or.&
        elas_keyword_in.eq.'ELAS_MEMBRANE'.or.&
        elas_keyword_in.eq.'ELAS_META'.or.&
        elas_keyword_in.eq.'ELAS_GLRC'.or.&
        elas_keyword_in.eq.'ELAS_DHRC'.or.&
        elas_keyword_in.eq.'ELAS_COQUE') then
        elas_id = 1
    elseif (elas_keyword_in.eq.'ELAS_ORTH') then
        elas_id = 2
    elseif (elas_keyword_in.eq.'ELAS_ISTR') then
        elas_id = 3
    else
        call utmess('F','COMPOR5_15', sk = elas_keyword_in)
    endif
!
    if (present(elas_keyword)) then
        elas_keyword = elas_keyword_in
    endif

end subroutine
