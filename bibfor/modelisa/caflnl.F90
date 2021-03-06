subroutine caflnl(char, ligrmo, noma)
    implicit none
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterfort/alcart.h"
#include "asterfort/getvid.h"
#include "asterfort/getvtx.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/nocart.h"
#include "asterfort/reliem.h"
    character(len=8) :: char, noma
    character(len=*) :: ligrmo
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
!
! BUT : STOCKAGE DES FLUX NON LINEAIRE  DANS UNE CARTE ALLOUEE SUR LE
!       LIGREL DU MODELE
!
! ARGUMENTS D'ENTREE:
!      CHAR   : NOM UTILISATEUR DU RESULTAT DE CHARGE
!      LIGRMO : NOM DU LIGREL DE MODELE
!      NOMA   : NOM DU MAILLAGE
!      NDIM   : DIMENSION DU PROBLEME (2D OU 3D)
!      FONREE : FONC OU REEL
!
!-----------------------------------------------------------------------
    integer :: nflux, jvalv,  nf, iocc, nbtou, nbma, jma, ncmp
    character(len=8) :: k8b, typmcl(2)
    character(len=16) :: motclf, motcle(2)
    character(len=19) :: carte
    character(len=24) :: mesmai
    character(len=8), pointer :: vncmp(:) => null()
!     ------------------------------------------------------------------
    call jemarq()
!
    motclf = 'FLUX_NL'
    call getfac(motclf, nflux)
!
    carte = char//'.CHTH.FLUNL'
    call alcart('G', carte, noma, 'FLUN_F')
    call jeveuo(carte//'.NCMP', 'E', vk8=vncmp)
    call jeveuo(carte//'.VALV', 'E', jvalv)
!
! --- STOCKAGE DE FLUX NULS SUR TOUT LE MAILLAGE
!
    ncmp = 3
    vncmp(1) = 'FLUN'
    vncmp(2) = 'FLUN_INF'
    vncmp(3) = 'FLUN_SUP'
    zk8(jvalv-1+1) = '&FOZERO'
    zk8(jvalv-1+2) = '&FOZERO'
    zk8(jvalv-1+3) = '&FOZERO'
    call nocart(carte, 1, ncmp)
!
    mesmai = '&&CAFLNL.MES_MAILLES'
    motcle(1) = 'GROUP_MA'
    motcle(2) = 'MAILLE'
    typmcl(1) = 'GROUP_MA'
    typmcl(2) = 'MAILLE'
!
! --- STOCKAGE DANS LES CARTES
!
    do 10 iocc = 1, nflux
!
        call getvid(motclf, 'FLUN', iocc=iocc, scal=zk8(jvalv), nbret=nf)
!
        call getvtx(motclf, 'TOUT', iocc=iocc, scal=k8b, nbret=nbtou)
        if (nbtou .ne. 0) then
            call nocart(carte, 1, ncmp)
!
        else
            call reliem(ligrmo, noma, 'NU_MAILLE', motclf, iocc,&
                        2, motcle, typmcl, mesmai, nbma)
            if (nbma .eq. 0) goto 10
            call jeveuo(mesmai, 'L', jma)
            call nocart(carte, 3, ncmp, mode='NUM', nma=nbma,&
                        limanu=zi(jma))
            call jedetr(mesmai)
        endif
!
10  end do
!
    call jedema()
!
end subroutine
