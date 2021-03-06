subroutine rccome(nommat, pheno, icodre, iarret, k11_ind_nomrc)
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
    implicit none
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/codent.h"
#include "asterfort/jelira.h"
#include "asterfort/jeveuo.h"
#include "asterfort/utmess.h"
    character(len=*), intent(in) :: nommat, pheno
    integer, intent(out) :: icodre
    integer, intent(in), optional :: iarret
    character(len=11), intent(out), optional :: k11_ind_nomrc
! ----------------------------------------------------------------------
!     OBTENTION DU COMPORTEMENT COMPLET D'UN MATERIAU DONNE A PARTIR
!     D'UN PREMISSE (C'EST L'INDICE DU PREMIER NOM QUI CONTIENT LA CHAINE 
!     CHERCHEE EST RETOURNE) 
!
!     ARGUMENTS D'ENTREE:
!        NOMMAT : NOM DU MATERIAU
!        PHENO  : NOM DU PHENOMENE EVENTUELLEMENT INCOMPLET 
!     ARGUMENTS DE SORTIE:
!        ICODRE : 0 SI ON A TROUVE, 1 SINON
!        IARRET : 0 RETOURNE LE CODE RETOUR ICODRE SANS EMISSION DE MESSAGE (PAR DEFAUT)
!                 1 EMISSION D'UNE ERREUR FATALE
!        INDI   : INDICE DE PHENO DANS nommat//'.MATERIAU.NOMRC
!  
! DEB ------------------------------------------------------------------
    character(len=32) :: ncomp
    character(len=6) :: k6
    integer :: i, icomp, nbcomp, iarret_in
!-----------------------------------------------------------------------
!
    if (present(iarret)) then
        iarret_in = iarret
    else
        iarret_in = 0
    endif
!
    ASSERT((iarret_in.eq.0) .or. (iarret_in.eq.1))
!
    icodre = 1
    ncomp = nommat//'.MATERIAU.NOMRC         '
    call jelira(ncomp, 'LONUTI', nbcomp)
    call jeveuo(ncomp, 'L', icomp)
    do i = 1, nbcomp 
        if (pheno .eq. zk32(icomp+i-1)(1:len(pheno))) then
            if (present(k11_ind_nomrc)) then
               call codent(i,'D0',k6)  
               k11_ind_nomrc='.CPT.'//k6
            endif   
            icodre = 0
        endif
    end do
    if (( icodre .eq. 1 ) .and. ( iarret_in .eq. 1 )) then
        call utmess('F', 'ELEMENTS2_63', sk=pheno)
    endif
! FIN ------------------------------------------------------------------
end subroutine
