subroutine tbexip(nomta, para, exist, typpar)
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/jedema.h"
#include "asterfort/jeexin.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/utmess.h"
    character(len=*) :: nomta, para, typpar
    aster_logical :: exist
! ----------------------------------------------------------------------
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
!      EXISTENCE D'UN PARAMETRE DANS UNE TABLE.
! ----------------------------------------------------------------------
! IN  : NOMTA  : NOM DE LA STRUCTURE "TABLE".
! IN  : PARA   : PARAMETRE A CHERCHER
! OUT : EXIST  : LE PARAMETRE EXISTE OU N'EXISTE PAS
! OUT : TYPPAR : TYPE DU PARAMETRE (S'IL EXISTE) : I/R/C/K8/K16,...
! ----------------------------------------------------------------------
! ----------------------------------------------------------------------
    integer :: iret, nbpara, ipar
    character(len=19) :: nomtab
    character(len=24) :: inpar, jnpar
    character(len=24), pointer :: tblp(:) => null()
    integer, pointer :: tbnp(:) => null()
! DEB------------------------------------------------------------------
!
    call jemarq()
!
    nomtab = nomta
    inpar = para
    exist = .false.
    typpar = '????'
!
!     --- VERIFICATION DE LA TABLE ---
!
    call jeexin(nomtab//'.TBBA', iret)
    if (iret .eq. 0) then
        call utmess('F', 'UTILITAI4_79', sk=nomtab)
    endif
!
    call jeveuo(nomtab//'.TBNP', 'L', vi=tbnp)
    nbpara = tbnp(1)
    if (nbpara .eq. 0) then
        call utmess('F', 'UTILITAI4_80', sk=nomtab)
    endif
!
!     --- VERIFICATION QUE LE PARAMETRE EXISTE DANS LA TABLE ---
!
    call jeveuo(nomtab//'.TBLP', 'L', vk24=tblp)
    do 10 ipar = 1, nbpara
        jnpar = tblp(1+4*(ipar-1))
        if (inpar .eq. jnpar) then
            exist = .true.
            typpar = tblp(4*(ipar-1)+2)
            goto 12
        endif
 10 end do
 12 continue
!
    call jedema()
end subroutine
