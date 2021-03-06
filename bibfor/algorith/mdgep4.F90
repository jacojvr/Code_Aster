subroutine mdgep4(neq, nbexci, psidel, temps, nomfon,&
                  iddl, rep)
    implicit none
#include "asterfort/fointe.h"
#include "asterfort/utmess.h"
    integer :: neq
    real(kind=8) :: psidel(neq, *), temps, rep
    character(len=8) :: nomfon(*)
! ======================================================================
! COPYRIGHT (C) 1991 - 2016  EDF R&D                  WWW.CODE-ASTER.ORG
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
!    MULTI-APPUIS :
!    CONVERSION LES DDL GENERALISES EN BASE PHYSIQUE : CONTRIBUTION
!    DES DEPLACEMENTS DIFFERENTIELS DES ANCRAGES
!-----------------------------------------------------------------------
! IN  : NEQ    : NB D'EQUATIONS DU SYSTEME ASSEMBLE
! IN  : NBEXCI : NOMBRE D'ACCELERO DIFFERENTS
! IN  : PSIDEL : VALEUR DU VECTEUR PSI*DELTA
! IN  : TEMPS  : INSTANT DE CALCUL DES DEPL_IMPO
! IN  : NOMFON : NOM DE LA FONCTION DEPL_IMPO
! IN  : IDDL   : NUMERO DU DDL TRAITE
! OUT : REP    : VALEUR DE PSIDEL*VALE_NOMFOM(TEMPS)
! .________________.____.______________________________________________.
    character(len=8) :: nompar, blanc
    real(kind=8) :: coef
!
!-----------------------------------------------------------------------
    integer :: iddl, ier, iex, nbexci, cntr
!-----------------------------------------------------------------------
    blanc = '        '
    nompar = 'INST'
    rep = 0.d0
    cntr = 0
    do 10 iex = 1, nbexci
        if (nomfon(iex) .eq. blanc) goto 10

        cntr = cntr + 1
        call fointe('F ', nomfon(iex), 1, [nompar], [temps],&
                    coef, ier)
        rep = rep + psidel(iddl,iex)*coef
        
10  end do

    if (cntr.eq.0) then
        call utmess('A', 'ALGORITH13_44')
    end if
end subroutine
