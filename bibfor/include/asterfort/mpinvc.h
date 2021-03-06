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
#include "asterf_types.h"
!
interface
    subroutine mpinvc(nbmesu, nbmode, nbabs, phi, cmesu,&
                      coef, xabs, lfonct, ceta, cetap,&
                      ceta2p)
        integer :: nbabs
        integer :: nbmode
        integer :: nbmesu
        real(kind=8) :: phi(nbmesu, nbmode)
        complex(kind=8) :: cmesu(nbmesu, nbabs)
        real(kind=8) :: coef(*)
        real(kind=8) :: xabs(nbabs)
        aster_logical :: lfonct
        complex(kind=8) :: ceta(nbmode, nbabs)
        complex(kind=8) :: cetap(nbmode, nbabs)
        complex(kind=8) :: ceta2p(nbmode, nbabs)
    end subroutine mpinvc
end interface
