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
    subroutine xmvep2(ndim, nno, nnos, nnol, pla,&
                      ffc, ffp, reac, jac, nfh,&
                      saut, singu, fk, nd, cpenco,&
                      ddls, ddlm, jheavn, ncompn, nfiss, ifiss,&
                      jheafa, ncomph, ifa, vtmp)
        integer :: ndim
        integer :: nno
        integer :: nnos
        integer :: nnol
        integer :: pla(27)
        real(kind=8) :: ffc(8)
        real(kind=8) :: ffp(27)
        real(kind=8) :: reac
        real(kind=8) :: jac
        integer :: nfh
        real(kind=8) :: saut(3)
        integer :: singu
        real(kind=8) :: nd(3)
        real(kind=8) :: fk(27,3,3)
        real(kind=8) :: cpenco
        integer :: ddls
        integer :: ddlm
        integer :: jheavn
        integer :: ncompn
        integer :: nfiss
        integer :: ifiss
        integer :: jheafa
        integer :: ncomph
        integer :: ifa
        real(kind=8) :: vtmp(400)
    end subroutine xmvep2
end interface
