subroutine rc32r8(nomres, mater, lfat)
    implicit none
#include "jeveux.h"
#include "asterc/r8vide.h"
#include "asterfort/jeveuo.h"
#include "asterfort/rcmcrt.h"
#include "asterfort/rcvale.h"
#include "asterfort/tbajli.h"
#include "asterfort/tbajpa.h"
#include "asterfort/utmess.h"
#include "asterfort/getvr8.h"
    character(len=8) :: nomres, mater
    aster_logical :: lfat
!     ------------------------------------------------------------------
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
!     ------------------------------------------------------------------
!     OPERATEUR POST_RCCM, TRAITEMENT DE FATIGUE_B3200
!     STOCKAGE DES RESULTATS DANS LA TABLE DE SORTIE
!     CALCUL DU ROCHET THERMIQUE
!
!     ------------------------------------------------------------------
!
    integer :: ibid, npar1, im, jresu, n1
    parameter    ( npar1 = 8 )
    real(kind=8) :: rbid, valer(npar1), valres(1), symax
    complex(kind=8) :: c16b
    integer :: icodre(1)
    character(len=4) :: lieu(2)
    character(len=8) :: k8b, typar1(npar1), valek(2)
    character(len=16) :: nopar1(npar1)
!     ------------------------------------------------------------------
    data lieu   / 'ORIG' , 'EXTR' /
!
    data nopar1 / 'TYPE', 'LIEU', 'SY', 'SIGM_M_PRES','SN_THER_MAX',&
     &              'VALE_MAXI_LINE', 'SP_THER_MAX', 'VALE_MAXI_PARAB' /
    data typar1 / 'K8', 'K8', 'R', 'R', 'R', 'R', 'R', 'R' /
! DEB ------------------------------------------------------------------
!
    symax = r8vide()
    call getvr8(' ', 'SY_MAX', scal=symax, nbret=n1)
!
    rbid = 0.d0
    ibid=0
    c16b=(0.d0,0.d0)
    call tbajpa(nomres, npar1-2, nopar1(3), typar1(3))
!
    if (symax .eq. r8vide()) then
        call rcvale(mater, 'RCCM', 0, k8b, [rbid],&
                    1, 'SY_02   ', valres(1), icodre(1), 0)
        if (icodre(1) .eq. 0) then
            symax = valres(1)
        else
            call utmess('A', 'POSTRCCM_4')
            goto 999
        endif
    endif
!
    valer(1) = symax
    valek(1) = 'ROCHET'
!
    do 10 im = 1, 2
!
        valek(2) = lieu(im)
!
        call jeveuo('&&RC3200.RESU.'//lieu(im), 'L', jresu)
!
        valer(2) = zr(jresu+9)
        if (lfat) then
            valer(5) = zr(jresu+10)
        else
            valer(5) = r8vide()
        endif
        valer(3) = zr(jresu+11)
!
        call rcmcrt(symax, valer(2), valer(4), valer(6))
!
        if (.not. lfat) valer(6) = r8vide()
!
        call tbajli(nomres, npar1, nopar1, [ibid], valer,&
                    [c16b], valek, 0)
!
10  continue
!
999  continue
!
end subroutine
