subroutine dfdm3j(nno, ipg, idfde, coor, jac)
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
    implicit none
#include "jeveux.h"
    integer :: ipg, idfde, nno
    real(kind=8) :: coor(1), jac
! ......................................................................
!    - FONCTION REALISEE:  CALCUL DU JACOBIEN (AVEC SIGNE)
!               POUR LES ELEMENTS 3D
!
!    - ARGUMENTS:
!        DONNEES:     NNO           -->  NOMBRE DE NOEUDS
!              DFDRDE,DFRDN,DFRDK   -->  DERIVEES FONCTIONS DE FORME
!                     COOR          -->  COORDONNEES DES NOEUDS
!
!        RESULTATS:  JAC           <--  JACOBIEN AU POINT DE GAUSS
! ......................................................................
!
    integer :: i, j, ii, k
    real(kind=8) :: g(3, 3)
    real(kind=8) :: de, dn, dk, j11, j21, j31
!
!
    do 1 i = 1, 3
        do 1 j = 1, 3
            g(i,j) = 0.d0
 1      continue
!
    do 100 i = 1, nno
        k = 3*nno*(ipg-1)
        ii = 3*(i-1)
        de = zr(idfde-1+k+ii+1)
        dn = zr(idfde-1+k+ii+2)
        dk = zr(idfde-1+k+ii+3)
        do 101 j = 1, 3
            g(1,j) = g(1,j) + coor(ii+j) * de
            g(2,j) = g(2,j) + coor(ii+j) * dn
            g(3,j) = g(3,j) + coor(ii+j) * dk
101      continue
100  end do
!
    j11 = g(2,2) * g(3,3) - g(2,3) * g(3,2)
    j21 = g(3,1) * g(2,3) - g(2,1) * g(3,3)
    j31 = g(2,1) * g(3,2) - g(3,1) * g(2,2)
!
    jac = g(1,1) * j11 + g(1,2) * j21 + g(1,3) * j31
end subroutine
