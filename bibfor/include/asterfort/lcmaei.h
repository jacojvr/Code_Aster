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
    subroutine lcmaei(fami, kpg, ksp, poum, nmater,&
                      imat, necris, necoul, nbval, valres,&
                      nmat, itbint, nfs, nsg, hsri,&
                      ifa, nomfam, nbsys)
        integer :: nsg
        integer :: nmat
        character(len=*) :: fami
        integer :: kpg
        integer :: ksp
        character(len=*) :: poum
        character(len=16) :: nmater
        integer :: imat
        character(len=16) :: necris
        character(len=16) :: necoul
        integer :: nbval
        real(kind=8) :: valres(nmat)
        integer :: itbint
        integer :: nfs
        real(kind=8) :: hsri(nsg, nsg)
        integer :: ifa
        character(len=16) :: nomfam
        integer :: nbsys
    end subroutine lcmaei
end interface
