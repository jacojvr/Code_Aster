subroutine op0105()
    implicit none
!-----------------------------------------------------------------------
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
!     OPERATEUR: ASSE_MAILLAGE
!
!-----------------------------------------------------------------------
!
#include "jeveux.h"
#include "asterc/getres.h"
#include "asterfort/asmaco.h"
#include "asterfort/asmael.h"
#include "asterfort/asmasu.h"
#include "asterfort/cargeo.h"
#include "asterfort/getvid.h"
#include "asterfort/getvtx.h"
#include "asterfort/infmaj.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/utmess.h"
#include "asterfort/wkvect.h"
    character(len=8) :: mag, dm(2)
    character(len=16) :: kbi1, kbi2
    character(len=8) :: oper
    integer :: n1,   ibid
    integer, pointer :: dim1(:) => null()
    integer, pointer :: dim2(:) => null()
!     ------------------------------------------------------------------
!
    call jemarq()
    call infmaj()
!
    call getvtx(' ', 'OPERATION', scal=oper, nbret=n1)
!
    call getres(mag, kbi1, kbi2)
    call getvid(' ', 'MAILLAGE_1', scal=dm(1), nbret=n1)
    call getvid(' ', 'MAILLAGE_2', scal=dm(2), nbret=n1)
!
!     --OBJET .TITR:
!     ---------------
    call wkvect(mag//'           .TITR', 'G V K80', 2, ibid)
    zk80(ibid)=' MAILLAGE OBTENU PAR CONCATENATION DES MAILLAGES : '
    zk80(ibid+1)='  '//dm(1)//' ET '//dm(2)
!
!
!     -- TRAITEMENT DU TYPE D OPERATION :
!     -----------------------------------
    if (oper(1:8) .eq. 'SOUS_STR') then
        call asmael(dm(1), dm(2), mag)
    else
!
        call jeveuo(dm(1)//'.DIME', 'L', vi=dim1)
        call jeveuo(dm(2)//'.DIME', 'L', vi=dim2)
        if ((dim1(4).ne.0) .or. (dim2(4).ne.0)) then
            call utmess('F', 'SOUSTRUC_16')
        endif
        if (oper(1:7) .eq. 'COLLAGE') then
            call asmaco(dm(1), dm(2), mag)
        else if (oper(1:7).eq.'SUPERPO') then
            call asmasu(dm(1), dm(2), mag)
        endif
    endif
!
!
!     --ON CALCULE LES CARACTERISTIQUES DU MAILLAGE:
!     ----------------------------------------------
!
    call cargeo(mag)
!
    call jedema()
end subroutine
