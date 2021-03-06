subroutine lcdetf(ndim, fr, det)
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
! ----------------------------------------------------------------------
!     BUT:  CALCUL DU DETERMINANT DU GRADIENT DE TRANSFORMATION FR
! ----------------------------------------------------------------------
! IN  NDIM    : DIMENSION DU PROBLEME : 2 OU 3
! IN  FR      : GRADIENT TRANSFORMATION
! OUT DETF    : DETERMINANT
!
    implicit none
#include "asterfort/assert.h"
    integer :: ndim
    real(kind=8) :: fr(3, 3), det
!
    if (ndim .eq. 3) then
        det = fr(1,1)*(fr(2,2)*fr(3,3)-fr(2,3)*fr(3,2)) - fr(2,1)*(fr( 1,2)*fr(3,3)-fr(1,3)*fr(3,&
              &2)) + fr(3,1)*(fr(1,2)*fr(2,3)-fr(1, 3)*fr(2,2))
    else if (ndim.eq.2) then
        det = fr(3,3)*(fr(1,1)*fr(2,2)-fr(1,2)*fr(2,1))
    else
        ASSERT(.false.)
    endif
!
end subroutine
