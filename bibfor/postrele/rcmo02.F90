subroutine rcmo02(etat, numsit, vale)
    implicit   none
#include "jeveux.h"
!
#include "asterfort/codent.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
    integer :: numsit
    real(kind=8) :: vale(*)
    character(len=1) :: etat
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
!     RECUPERATION DES MOMENTS POUR UN ETAT STABILISE
!
! IN  : TRANSIF: SI OUI B3200
! IN  : ETAT   : ETAT STABILISE "A" OU "B"
!              : OU "S" SI SEISME
! IN  : NUMSIT : NUMERO DE LA SITUATION
! OUT : VALE   : ON SOMME LES CHARGEMENTS
!                VALE(1)  = FX  OU _TUBU
!                VALE(2)  = FY  OU _TUBU
!                VALE(3)  = FZ  OU _TUBU
!                VALE(4)  = MX  OU _TUBU
!                VALE(5)  = MY  OU _TUBU
!                VALE(6)  = MZ  OU _TUBU
!                VALE(7)  = FX_CORP
!                VALE(8)  = FY_CORP
!                VALE(9)  = FZ_CORP
!                VALE(10) = MX_CORP
!                VALE(11) = MY_CORP
!                VALE(12) = MZ_CORP
!     ------------------------------------------------------------------
!
    integer :: i, j, numcha, jlcha, nbchar, jchar, iret
    character(len=1) :: etats
    character(len=8) ::  knumes, knumec
! DEB ------------------------------------------------------------------
!
    do 10 i = 1, 12
        vale(i) = 0.d0
10  continue
!
    knumes = 'S       '
    call codent(numsit, 'D0', knumes(2:8))
!
! --- LISTE DES CHARGEMENTS POUR LE NUMERO DE SITUATION
!
    if ((etat.eq.'S') .or. (etat.eq.'A')) then
        etats = 'A'
    else
        etats = 'B'
    endif
!
    call jeexin(jexnom('&&RC3200.SITU_ETAT_'//etats, knumes), iret)
    if (iret .eq. 0) goto 999
!
    call jelira(jexnom('&&RC3200.SITU_ETAT_'//etats, knumes), 'LONUTI', nbchar)
    call jeveuo(jexnom('&&RC3200.SITU_ETAT_'//etats, knumes), 'L', jlcha)
!
!
    if(nbchar .ne. 0) then
        numcha = zi(jlcha)
        knumec = 'C       '
        call codent(numcha, 'D0', knumec(2:8))
        call jeveuo(jexnom('&&RC3200.VALE_CHAR', knumec), 'L', jchar)
!
        do 102 j = 1, 12
            vale(j) = zr(jchar-1+j)
102     continue
!
    endif
!
999    continue
!
end subroutine
