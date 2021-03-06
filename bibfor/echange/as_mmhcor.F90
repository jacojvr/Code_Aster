subroutine as_mmhcor(fid, maa, coo, modcoo, cret)
! person_in_charge: nicolas.sellenet at edf.fr
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
    implicit none
#include "asterf_types.h"
#include "asterf.h"
#include "asterfort/utmess.h"
#include "med/mmhcor.h"
    character(len=*) :: maa
    aster_int :: fid, modcoo, cret
    aster_int :: mdnont, mdnoit
    real(kind=8) :: coo(*)
#ifdef _DISABLE_MED
    call utmess('F', 'FERMETUR_2')
#else
!
#if med_int_kind != aster_int_kind
    med_int :: fid4, modco4, cret4
    med_int :: mdnon4, mdnoi4
    mdnont = -1
    mdnoit = -1
    fid4 = fid
    modco4 = modcoo
    mdnon4 = mdnont
    mdnoi4 = mdnoit
    call mmhcor(fid4, maa, mdnon4, mdnoi4, modco4,&
                coo, cret4)
    cret = cret4
#else
    mdnont = -1
    mdnoit = -1
    call mmhcor(fid, maa, mdnont, mdnoit, modcoo,&
                coo, cret)
#endif
!
#endif
end subroutine
