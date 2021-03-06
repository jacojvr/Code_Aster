subroutine te0181(option, nomte)
    implicit none
#include "jeveux.h"
#include "asterfort/dfdm3d.h"
#include "asterfort/elrefe_info.h"
#include "asterfort/jevech.h"
#include "asterfort/rcvalc.h"
!
    character(len=16) :: option, nomte
!.......................................................................
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
!     BUT: CALCUL DES MATRICES DE MASSE ELEMENTAIRE EN ACOUSTIQUE
!          ELEMENTS ISOPARAMETRIQUES 3D
!
!          OPTION : 'MASS_ACOU '
!
!     ENTREES  ---> OPTION : OPTION DE CALCUL
!          ---> NOMTE  : NOM DU TYPE ELEMENT
!.......................................................................
!
!
    integer :: ipoids, ivf, idfde, igeom, imate
    integer :: jgano, nno, kp, npg, ij, i, j, imattt
    real(kind=8) :: poids
    integer :: icodre(1)
!
    complex(kind=8) :: valres(1)
!
!
!-----------------------------------------------------------------------
    integer :: l, ndi, ndim, nnos
!-----------------------------------------------------------------------
    call elrefe_info(fami='MASS',ndim=ndim,nno=nno,nnos=nnos,&
  npg=npg,jpoids=ipoids,jvf=ivf,jdfde=idfde,jgano=jgano)
    ndi = nno* (nno+1)/2
!
    call jevech('PGEOMER', 'L', igeom)
    call jevech('PMATERC', 'L', imate)
    call jevech('PMATTTC', 'E', imattt)
!
    call rcvalc(zi(imate), 'FLUIDE', 1, 'CELE_C', valres,&
                icodre, 1)
!
    do i = 1, ndi
        zc(imattt-1+i) = (0.0d0,0.0d0)
    end do
!
!    BOUCLE SUR LES POINTS DE GAUSS
!
    do kp = 1, npg
        l = (kp-1)*nno
!
        call dfdm3d(nno, kp, ipoids, idfde, zr(igeom),&
                    poids)
!
        do i = 1, nno
            do j = 1, i
                ij = (i-1)*i/2 + j
                zc(imattt+ij-1) = zc(imattt+ij-1) + ((1.0d0,0.0d0)/ ( valres(1)**2))*poids*zr(ivf&
                                  &+l+i-1)*zr(ivf+l+j-1)
            end do
        end do
    end do
!
end subroutine
