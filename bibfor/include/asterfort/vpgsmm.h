!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
interface
    subroutine vpgsmm(nbeq, nconv, vect, alpha, lmatb, typeps, vaux, ddlexc, delta, dsor, omecor)
        integer :: nconv
        integer :: nbeq
        real(kind=8) :: vect(nbeq, nconv)
        real(kind=8) :: alpha
        integer :: lmatb
        integer :: typeps
        real(kind=8) :: vaux(nbeq)
        integer :: ddlexc(nbeq)
        real(kind=8) :: delta(nconv)
        real(kind=8) :: dsor(nconv,2)
        real(kind=8) :: omecor
    end subroutine vpgsmm
end interface
