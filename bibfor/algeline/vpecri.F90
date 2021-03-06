subroutine vpecri(eigsol, ktype, indice,&
                  valk, valr, vali)

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
! -------------------------------------------------------------------------------------------------
! ROUTINE UTILITAIRE ECRIVANT UNE VALEUR DE LA SD_EIGENSOLVER POUR UN INDICE ET UN TYPE DONNE.
! LA VALEUR A ECRIRE EST DONNEE DANS VALK, VALI OU VALR.
! CF VPINIS, VPLECS, VPLECI, VPECRI.
! -------------------------------------------------------------------------------------------------
! person_in_charge: olivier.boiteau at edf.fr
    implicit none

#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/jeveuo.h"
!
! --- INPUT
!
    integer           , intent(in) :: indice, vali
    real(kind=8)      , intent(in) :: valr
    character(len=1)  , intent(in) :: ktype
    character(len=19) , intent(in) :: eigsol
    character(len=24) , intent(in) :: valk
!
! --- OUTPUT
! None
!
! --- INPUT/OUTPUT
! None
!
! --- VARIABLES LOCALES
!
    integer           :: eislvi, eislvk, eislvr
!
! -----------------------
! --- CORPS DE LA ROUTINE
! -----------------------
!

    call jemarq()

! --   TEST DES PARAMETRES
    ASSERT((ktype.eq.'K').or.(ktype.eq.'R').or.(ktype.eq.'I'))
    ASSERT((indice.ge.1).and.(indice.le.20))

! --  LECTURE PARAMETRES SOLVEURS MODAUX
    select case(ktype)
    case('K')
        ASSERT(indice.le.20)
        call jeveuo(eigsol//'.ESVK', 'E', eislvk)
        zk24(eislvk-1+indice)=''
        zk24(eislvk-1+indice)=trim(valk)
    case('I')
        ASSERT(indice.le.15)
        call jeveuo(eigsol//'.ESVI', 'E', eislvi)
        zi(eislvi-1+indice)=vali
    case('R')
        ASSERT(indice.le.15)
        call jeveuo(eigsol//'.ESVR', 'E', eislvr)
        zr(eislvr-1+indice)=valr
    case default
        ASSERT(.false.)
    end select

    call jedema()
!
!     FIN DE VPECRI
!
end subroutine
