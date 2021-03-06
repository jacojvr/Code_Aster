subroutine ccchut(sdresu_in, sdresu_out, list_ordr, nb_ordr)
!
    implicit none
!
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterfort/assert.h"
#include "asterfort/ccchuc.h"
#include "asterfort/getvid.h"
#include "asterfort/getvis.h"
#include "asterfort/getvtx.h"
#include "asterfort/infmaj.h"
#include "asterfort/infniv.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jemarq.h"
#include "asterfort/wkvect.h"
!
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
! person_in_charge: mathieu.courtois at edf.fr
!
    character(len=8), intent(in) :: sdresu_in
    character(len=8), intent(in) :: sdresu_out
    character(len=19), intent(in) :: list_ordr
    integer, intent(in) :: nb_ordr
!
! --------------------------------------------------------------------------------------------------
!
! Command CALC_CHAMP
!
! Compute CHAM_UTIL
!
! --------------------------------------------------------------------------------------------------
!
! In  sdresu_in      : name of input results data-structure
! In  sdresu_out     : name of output results data-structure
! In  nb_ordr        : number of order index in list_ordr
! In  list_ordr      : name of list of order
!
! --------------------------------------------------------------------------------------------------
!
    character(len=16) :: keywordfact
    character(len=19) :: lform
    integer :: ioc, nuti, ibid
    integer :: nb_form, nb_crit, nb_norm
    integer :: jform, nume_field_out
    character(len=16) :: field_type, crit, norm, type_comp
!
! --------------------------------------------------------------------------------------------------
!
    call jemarq()
!
! - Initializations
!
    keywordfact = 'CHAM_UTIL'
    lform = '&&CCCHUT.FORMULE'
    call getfac(keywordfact, nuti)
!
! - Loop on occurrences
!
    do ioc = 1, nuti
        call getvtx(keywordfact, 'NOM_CHAM', iocc=ioc, scal=field_type, nbret=ibid)
        call getvis(keywordfact, 'NUME_CHAM_RESU', iocc=ioc, scal=nume_field_out, nbret=ibid)
        ASSERT(nume_field_out.ge.1 .and. nume_field_out.le.20)
!
! ----- Which kind of computation ?
!
        call getvid(keywordfact, 'FORMULE', iocc=ioc, nbval=0, nbret=nb_form)
        nb_form = -nb_form
        call getvtx(keywordfact, 'CRITERE', iocc=ioc, nbval=0, nbret=nb_crit)
        nb_crit = -nb_crit
        call getvtx(keywordfact, 'NORME', iocc=ioc, nbval=0, nbret=nb_norm)
        nb_norm = -nb_norm
!
! ----- Case NORME
!
        if (nb_form .eq. 1) then
!
        endif
!
! ----- Type of computation
!
        crit = ' '
        norm = ' '
        jform = 1
        if (nb_crit .ne. 0) then
            ASSERT(nb_crit.eq.1)
            ASSERT(nb_form.eq.0)
            ASSERT(nb_norm.eq.0)
            type_comp = 'CRITERE'
            call getvtx(keywordfact, type_comp, iocc=ioc, nbval=nb_crit, vect=crit,&
                        nbret=ibid)
!
        else if (nb_form .ne. 0) then
            ASSERT(nb_crit.eq.0)
            ASSERT(nb_norm.eq.0)
            type_comp = 'FORMULE'
            call wkvect(lform, 'V V K8', nb_form, jform)
            call getvid(keywordfact, type_comp, iocc=ioc, nbval=nb_form, vect=zk8(jform),&
                        nbret=ibid)
!
        else if (nb_norm .ne. 0) then
            ASSERT(nb_crit.eq.0)
            ASSERT(nb_form.eq.0)
            ASSERT(nb_norm.eq.1)
            type_comp = 'NORME'
            call getvtx(keywordfact, type_comp, iocc=ioc, nbval=nb_norm, vect=norm,&
                        nbret=ibid)
        else
            ASSERT(.false.)
        endif
!
! ----- Computation
!
        call ccchuc(sdresu_in, sdresu_out, field_type, nume_field_out, type_comp,&
                    crit, norm, nb_form, zk8(jform), list_ordr,&
                    nb_ordr)
!
        call jedetr(lform)
    enddo
!
    call jedema()
!
end subroutine
