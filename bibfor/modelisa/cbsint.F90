subroutine cbsint(char, noma, ligrmo, fonree)
    implicit none
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterfort/alcart.h"
#include "asterfort/getvid.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/nocart.h"
!
    character(len=4) :: fonree
    character(len=8) :: char, noma
    character(len=*) :: ligrmo
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!     ------------------------------------------------------------------
!
! BUT : STOCKAGE DES CHARGES DE DEFORMATIONS INITIALES REPARTIES
!       DANS UNE CARTE ALLOUEE SUR LE LIGREL DU MODELE
!
! ARGUMENTS D'ENTREE:
!      CHAR   : NOM UTILISATEUR DU RESULTAT DE CHARGE
!      LIGRMO : NOM DU LIGREL DE MODELE
!      NOMA   : NOM DU MAILLAGE
!      FONREE : FONC OU REEL
!      PARAM  : NOM DU TROISIEME CHAMP DE LA CARTE (EPSIN)
!      MOTCL  : MOT-CLE FACTEUR
!
!-----------------------------------------------------------------------
!
    integer :: nbfac
    character(len=5) :: param
    integer :: ibid, nchei, ncmp
    character(len=16) :: motclf
    character(len=19) :: carte
    character(len=24) :: chsig
    character(len=8), pointer :: valv(:) => null()
    character(len=8), pointer :: vncmp(:) => null()
!     ------------------------------------------------------------------
    call jemarq()
!
    if (fonree .eq. 'REEL') then
        motclf = 'PRE_SIGM'
        call getfac('PRE_SIGM', nbfac)
!
        if (nbfac .ne. 0) then
            param = 'SIINT'
!
            call getfac('PRE_SIGM', nchei)
!
            carte = char//'.CHME.'//param
!
! ---        MODELE ASSOCIE AU LIGREL DE CHARGE
!
            call alcart('G', carte, noma, 'NEUT_K8')
            call jeveuo(carte//'.NCMP', 'E', vk8=vncmp)
            call jeveuo(carte//'.VALV', 'E', vk8=valv)
!
            ncmp = 1
            vncmp(1) = 'Z1'
            call getvid(motclf, 'SIGM', iocc=1, scal=chsig, nbret=ibid)
            valv(1) = chsig
            call nocart(carte, 1, ncmp)
!
        endif
    endif
    call jedema()
end subroutine
