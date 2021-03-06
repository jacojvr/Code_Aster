subroutine te0054(option, nomte)
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
!.......................................................................
    implicit none
!
!     BUT: CALCUL DES MATRICES DE MASSE ELEMENTAIRE EN THERMIQUE
!          ELEMENTS ISOPARAMETRIQUES 3D
!
!          OPTION : 'MASS_THER'
!
!     ENTREES  ---> OPTION : OPTION DE CALCUL
!              ---> NOMTE  : NOM DU TYPE ELEMENT
!.......................................................................
!
!
#include "jeveux.h"
#include "asterfort/dfdm3d.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/lteatt.h"
#include "asterfort/rccoma.h"
#include "asterfort/rcvalb.h"
#include "asterfort/utmess.h"
!
    integer :: icodre(1)
    character(len=8) :: fami, poum
    character(len=16) :: nomte, option, phenom
    real(kind=8) :: valpar, poids
    real(kind=8) :: cp(1), deltat
    integer :: ipoids, ivf, idfde, igeom, imate, ll, ndim
    integer :: jgano, nno, kp, npg2, ij, i, j, imattt, itemps
    integer :: nnos, kpg, spt
!
    if (lteatt('LUMPE','OUI')) then
        call elrefe_info(fami='NOEU',ndim=ndim,nno=nno,nnos=nnos,&
  npg=npg2,jpoids=ipoids,jvf=ivf,jdfde=idfde,jgano=jgano)
    else
        call elrefe_info(fami='MASS',ndim=ndim,nno=nno,nnos=nnos,&
  npg=npg2,jpoids=ipoids,jvf=ivf,jdfde=idfde,jgano=jgano)
    endif
!
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PMATERC', 'L', imate)
    call jevech('PTEMPSR', 'L', itemps)
    call jevech('PMATTTR', 'E', imattt)
!
    call rccoma(zi(imate), 'THER', 1, phenom, icodre(1))
    if (icodre(1) .ne. 0) then
        call utmess('A', 'ELEMENTS2_63')
    endif
    fami='FPG1'
    kpg=1
    spt=1
    poum='+'
!
    valpar = zr(itemps)
    deltat = zr(itemps+1)
    call rcvalb(fami, kpg, spt, poum, zi(imate),&
                ' ', phenom, 1, 'INST', [valpar],&
                1, 'RHO_CP', cp, icodre(1), 1)
!
!    BOUCLE SUR LES POINTS DE GAUSS
!
    do kp = 1, npg2
!
        ll = (kp-1)*nno
        call dfdm3d(nno, kp, ipoids, idfde, zr(igeom),&
                    poids)
!
        do i = 1, nno
!
            do j = 1, i
                ij = (i-1)*i/2 + j
                zr(imattt+ij-1)=zr(imattt+ij-1) + cp(1)/deltat*poids* zr(ivf+ll+i-1)* zr(ivf+ll+j-1)
!
            end do
        end do
!
    end do
!
end subroutine
