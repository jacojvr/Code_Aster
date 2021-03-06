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
    subroutine nm1das(fami, kpg, ksp, e, syc,&
                      syt, etc, ett, cr, tmoins,&
                      tplus, icodma, sigm, deps, vim,&
                      sig, vip, dsdem, dsdep)
        character(len=*) :: fami
        integer :: kpg
        integer :: ksp
        real(kind=8) :: e
        real(kind=8) :: syc
        real(kind=8) :: syt
        real(kind=8) :: etc
        real(kind=8) :: ett
        real(kind=8) :: cr
        real(kind=8) :: tmoins
        real(kind=8) :: tplus
        integer :: icodma
        real(kind=8) :: sigm
        real(kind=8) :: deps
        real(kind=8) :: vim(4)
        real(kind=8) :: sig
        real(kind=8) :: vip(4)
        real(kind=8) :: dsdem
        real(kind=8) :: dsdep
    end subroutine nm1das
end interface
