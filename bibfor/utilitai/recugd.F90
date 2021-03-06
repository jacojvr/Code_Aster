subroutine recugd(caelem, nomcmp, valres, nbgd, iassef,&
                  iassmx)
    implicit none
!
#include "jeveux.h"
#include "asterc/indik8.h"
#include "asterfort/dismoi.h"
#include "asterfort/exisdg.h"
#include "asterfort/jedema.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/utmess.h"
    integer :: nbgd, iassef, iassmx
    real(kind=8) :: valres(nbgd*iassef)
    character(len=8) :: nomcmp(nbgd)
    character(len=19) :: caelem
!
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
!-----------------------------------------------------------------------
!     PERMET D'EXTRAIRE D'UNE STRUCTURE "CARTE", LES VALEURS DES
!     COMPOSANTES POUR CHAQUE ASSOCIATION.
!-----------------------------------------------------------------------
! IN : CAELEM  : NOM DE LA CARTE.
! IN : NOMCMP  : NOM DES COMPOSANTES DE LA GRANDEUR RECHERCHEE
!                VECTEUR DE LONG. NBGD
! IN  : NBGD   : NOMBRE DE COMPOSANTES RECHERCHEES.
! IN  : IASSEF : NOMBRE D'ASSOCIATIONS DE LA STRUCTURE CARTE.
! IN  : IASSMX : NOMBRE MAX. D'ASSOCIATIONS DE LA STRUCTURE CARTE.
! OUT : VALRES : VALEURS DES COMPOSANTES.
!-----------------------------------------------------------------------
!
!
    integer :: icard, icarv, icmp, icode, nbec
    integer :: ii, irang, iranv, jj, ll, nbcmp
!
!
    character(len=24) :: carav, carad
    character(len=32) :: kexnom
!
!-----------------------------------------------------------------------
    call jemarq()
!
    carav = caelem(1:19)//'.VALE'
    carad = caelem(1:19)//'.DESC'
    call jeveuo(carav, 'L', icarv)
    call jeveuo(carad, 'L', icard)
!
    kexnom = jexnom('&CATA.GD.NOMCMP','CAGEPO')
    call jelira(kexnom, 'LONMAX', nbcmp)
    call jeveuo(kexnom, 'L', icmp)
!     NOMBRE D'ENTIERS CODES DANS LA CARTE
    call dismoi('NB_EC', 'CAGEPO', 'GRANDEUR', repi=nbec)
!     TOUTES LES COMPOSANTES DOIVENT ETRE DANS LA GRANDEUR
    do jj = 1, nbgd
        irang = indik8( zk8(icmp) , nomcmp(jj) , 1 , nbcmp )
        if (irang .eq. 0) then
            call utmess('E', 'UTILITAI4_8', sk=nomcmp(jj))
        endif
    end do
!
    do ii = 1, iassef
        icode = zi(icard-1+3+2*iassmx+nbec*(ii-1)+1)
!
        do jj = 1, nbgd
!           RANG DANS LA GRANDEUR
            irang = indik8( zk8(icmp) , nomcmp(jj) , 1 , nbcmp )
!           RANG DANS LA CARTE
            iranv = 0
            do ll = 1, irang
                if (exisdg([icode],ll)) iranv = iranv + 1
            end do
!           ON MET A ZERO SI INEXISTANT
            if (iranv .eq. 0) then
                valres(nbgd*(ii-1)+jj) = 0.0d0
            else
                valres(nbgd*(ii-1)+jj) = zr(icarv-1+nbcmp*(ii-1)+ iranv)
            endif
        end do
    end do
!
    call jedema()
end subroutine
