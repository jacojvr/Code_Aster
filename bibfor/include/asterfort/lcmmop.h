!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine lcmmop(fami, kpg, ksp, rela_comp, nbcomm,&
                      cpmono, nmat, nvi, vini, x,&
                      dtime, mod, coeft, epsd, detot,&
                      coel, nbphas, nfs, nsg, toutms,&
                      dvin, nhsr, numhsr, hsr, itmax,&
                      toler, iret)
        integer :: nhsr
        integer :: nsg
        integer :: nfs
        integer :: nbphas
        integer :: nmat
        character(len=*) :: fami
        integer :: kpg
        integer :: ksp
        character(len=16) :: rela_comp
        integer :: nbcomm(nmat, 3)
        character(len=24) :: cpmono(5*nmat+1)
        integer :: nvi
        real(kind=8) :: vini(*)
        real(kind=8) :: x
        real(kind=8) :: dtime
        character(len=8) :: mod
        real(kind=8) :: coeft(nmat)
        real(kind=8) :: epsd(6)
        real(kind=8) :: detot(6)
        real(kind=8) :: coel(nmat)
        real(kind=8) :: toutms(nbphas, nfs, nsg, 7)
        real(kind=8) :: dvin(*)
        integer :: numhsr(*)
        real(kind=8) :: hsr(nsg, nsg, nhsr)
        integer :: itmax
        real(kind=8) :: toler
        integer :: iret
    end subroutine lcmmop
end interface
