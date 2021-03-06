subroutine xalgo2(ndim, elrefp, it, nnose,&
                  cnset, typma, ndime, geom, lsnelp,&
                  pmilie, ninter, ainter, ar, npts,&
                  nptm, pmmax, nmilie, mfis, lonref,&
                  pinref, pintt, pmitt, jonc, exit)
    implicit none
!
#include "asterf_types.h"
#include "jeveux.h"
#include "asterfort/assert.h"
#include "asterfort/detefa.h"
#include "asterfort/vecini.h"
#include "asterfort/xajpmi.h"
#include "asterfort/xmilar.h"
#include "asterfort/xmilfa.h"
#include "asterfort/xmifis.h"
#include "asterfort/xstudo.h"
#include "asterfort/xxmmvd.h"
    character(len=8) :: typma, elrefp
    integer :: ndim, ndime, it, nnose, cnset(*), exit(2)
    integer :: ninter, pmmax, npts, nptm, nmilie, mfis, ar(12, 3)
    real(kind=8) :: lonref, ainter(*), pmilie(*), lsnelp(27)
    real(kind=8) :: pinref(*), pintt(*), pmitt(*), geom(81)
    aster_logical :: jonc
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
!   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
! ======================================================================
!            BUT :  TROUVER LES PTS MILIEUX DANS L ELEMENT COUPE EN 2D
!
!     ENTREE
!       NDIM     : DIMENSION DE L ELEMENT
!       TYPMA    : TYPE DE MAILLE
!       TABCO    : COORDONNES DES NOEUDS DE LE ELEMENT PARENT
!       PINTER   : COORDONNES DES POINTS D INTERSECTION
!       PMILIE   : COORDONNES DES POINTS MILIEUX
!       NINTER   : NOMBRE DE POINTS D INTERSECTION
!       AINTER   : INFOS ARETE ASSOCIÉE AU POINTS D'INTERSECTION
!       AR       : CONNECTIVITE DU TETRA
!       PMMAX    : NOMBRE DE POINTS MILIEUX MAXIMAL DETECTABLE
!       NPTS     : NB DE PTS D'INTERSECTION COINCIDANT AVEC UN NOEUD SOMMET
!       LSNELP   : LSN AUX NOEUDS DE L'ELEMENT PARENT POUR LA FISSURE COURANTE
!       PINTT    : COORDONNEES REELLES DES POINTS D'INTERSECTION
!       PMITT    : COORDONNEES REELLES DES POINTS MILIEUX
!       JONC     : L'ELEMENT PARENT EST-IL TRAVERSE PAR PLUSIEURS FISSURES
!
!     SORTIE
!       NMILIE   : NOMBRE DE POINTS MILIEUX
!       PMILIE   : COORDONNES DES POINS MILIEUX
!       NMILIE   : NOMBRE DE POINTS MILIEUX SUR LA FISSURE
!     ----------------------------------------------------------------
!
    real(kind=8) :: milfi(3), milara(3), milarb(3)
    real(kind=8) :: milfa(3)
    real(kind=8) :: pmiref(6*ndime), ksia(ndime), ksib(ndime)
    integer :: n(3)
    integer :: i, ipm, k
    integer :: noeua
    integer :: j, r, ip, a1, a2, a3, ip1(4), ip2(4), nbpi
    integer :: pm1a(4), pm1b(4), pm2(4)
    integer :: nm, ia, ib, im, inm
    integer :: zxain
    aster_logical :: ispm3, ispm2, ajout
!
! --------------------------------------------------------------------
!
!
    zxain = xxmmvd('ZXAIN')
!     COMPTEUR DES POINTS INTERSECTION NON CONFONDUS AVEC ND SOMMET
    ip=0
!     COMPTEUR DE POINTS MILIEUX
    ipm=0
    inm=0
    mfis=0
!
    call vecini(51, 0.d0, pmilie)
!
    do 204 i = 1, 4
        ip1(i)=0
        ip2(i)=0
        pm1a(i)=0
        pm1b(i)=0
        pm2(i)=0
204 continue
    call xstudo(ndime, ninter, npts, nptm, ainter,&
                nbpi, ip1, ip2, pm1a, pm1b,&
                pm2)
!    RECHERCHE DU NOEUD A 
    noeua=0
    if (ninter .eq. 2 .and. npts .eq. 0) then
        a1=nint(ainter(zxain*(1-1)+1))
        a2=nint(ainter(zxain*(2-1)+1))
        do 205 i = 1, 2
            do 206 j = 1, 2
                if (ar(a1,i) .eq. ar(a2,j)) noeua=ar(a1,i)
206         continue
205     continue
    else if (ninter.eq.3 .and. npts.eq.1) then
        a2=nint(ainter(zxain*(2-1)+1))
        a3=nint(ainter(zxain*(3-1)+1))
        do 207 i = 1, 2
            do 208 j = 1, 2
                if (ar(a2,i) .eq. ar(a3,j)) noeua=ar(a2,i)
208         continue
207     continue
    else if (ninter.eq.2 .and. npts.eq.1) then
        a2=nint(ainter(zxain*(2-1)+1))
        noeua=ar(a2,1)
    else if (ndime .eq. 1) then
        a1=nint(ainter(zxain*(1-1)+1))
        noeua=ar(a1,1)  
    else
        ASSERT(.false.)
    endif
    ASSERT(noeua.gt.0)
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!    RECHERCHE DU PREMIER TYPE DE POINT MILIEU    !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    do 300 r = 1, ninter
        a2=nint(ainter(zxain*(r-1)+1))
        if (a2 .eq. 0) goto 300
        ip = ip+1
        nm=ar(a2,3)
        ia=0
        ib=0
!    ORDONANCEMENT DES NOEUDS MILIEUX SUR L ARETE : RECHERCHE DU NOEUD A SUR L ARETE A2
        do 320 i = 1, 2
            if (ar(a2,i) .eq. noeua) then
                ia=cnset(nnose*(it-1)+ar(a2,3-i))
                ib=cnset(nnose*(it-1)+ar(a2,i))
                im=cnset(nnose*(it-1)+ar(a2,3))
            endif
320     continue
        ASSERT((ia*ib*im) .gt. 0)
        call vecini(ndim, 0.d0, milara)
        call vecini(ndim, 0.d0, milarb)
        call xmilar(ndim, ndime, elrefp, geom, pinref,&
                    ia, ib, im, r, ksia, ksib,&
                    milara, milarb, pintt, pmitt)
!         STOCKAGE PMILIE
        call xajpmi(ndim, pmilie, pmmax, ipm, inm, milara,&
                    lonref, ajout)
        if (ajout) then
            do j = 1, ndime
                pmiref(ndime*(ipm-1)+j)=ksia(j)
            enddo
        endif
        call xajpmi(ndim, pmilie, pmmax, ipm, inm, milarb,&
                    lonref, ajout)
        if (ajout) then
            do j = 1, ndime
                pmiref(ndime*(ipm-1)+j)=ksib(j)
            enddo
        endif
300 continue
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!    RECHERCHE DU DEUXIEME TYPE DE POINT MILIEU    !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    do 400 k = 1, nbpi
!      POINT MILIEU ENTRE IP1(R) ET IP2(R)
!
!      on ne calcule pas le premier type de point milieu si la
!      fissure coincide avec une arete
        ispm2=(nint(ainter(zxain*(ip1(k)-1)+1)).ne.0).or. &
           (nint(ainter(zxain*(ip2(k)-1)+1)).ne.0)
!
        if (ispm2) then
!        DETECTER LA COTE PORTANT LES DEUX POINTS D'INTERSECTIONS
            call detefa(nnose, ip1(k), ip2(k), it, typma,&
                        ainter, cnset, n)
!
!        CALCUL DU POINT MILIEU DE 101-102
!
            call xmifis(ndim, ndime, elrefp, geom, lsnelp,&
                        n, ip1(k), ip2(k), pinref, ksia,&
                        milfi, pintt, exit, jonc)
!
!        STOCKAGE PMILIE
            mfis=mfis+1
            call xajpmi(ndim, pmilie, pmmax, ipm, inm, milfi,&
                        lonref, ajout)
            if (ajout) then
                do j = 1, ndime
                    pmiref(ndime*(ipm-1)+j)=ksia(j)
                enddo
            endif
        endif
400 continue
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!    RECHERCHE DU TROISIEME TYPE DE POINT MILIEU   !
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    do 500 k = 1, nbpi
!      POINT MILIEU ENTRE IP1(R) ET IP2(R)
!
!      on calcule le troisieme type de point milieu seulement si
!      aucun des deux points d'intersection n'est confondu avec
!      un noeud sommet
        ispm3=((nint(ainter(zxain*(ip1(k)-1)+1)) .ne. 0) .and. &
           (nint(ainter(zxain*(ip2(k)-1)+1)) .ne. 0))
!
!
        if (ispm3) then
!
            call xmilfa(elrefp, ndim, ndime, geom, cnset,&
                        nnose, it, ainter, ip1(k), ip2(k),&
                        pm2(k), typma, pinref, pmiref, ksia,&
                        milfa, pintt, pmitt)
!
            call xajpmi(ndim, pmilie, pmmax, ipm, inm, milfa,&
                        lonref, ajout)
            if (ajout) then
                do j = 1, ndime
                    pmiref(ndime*(ipm-1)+j)=ksia(j)
                enddo
            endif
        endif
500 continue
!
    nmilie = ipm
!
end subroutine
