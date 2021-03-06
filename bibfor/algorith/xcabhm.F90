subroutine xcabhm(nddls, nddlm, nnop, nnops, nnopm,&
                  dimuel, ndim, kpi, ff, ff2,&
                  dfdi, dfdi2, b, nmec, yamec,&
                  addeme, yap1, addep1, np1, axi,&
                  ivf, ipoids, idfde, poids, coorse,&
                  nno, geom, yaenrm, adenme, dimenr,&
                  he, heavn, yaenrh, adenhy, nfiss, nfh)
!
    implicit none
! ======================================================================
! person_in_charge: daniele.colombo at ifpen.fr
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
! ======================================================================
!     BUT:  CALCUL  DE LA MATRICE B EN MODE D'INTEGRATION MIXTE
!           AVEC ELEMENTS P2P1 EN MECANIQUE DES MILIEUX POREUX
!           AVEC COUPLAGE HM EN XFEM
! ======================================================================
! AXI       AXISYMETRIQUE?
! TYPMOD    MODELISATION (D_PLAN, AXI, 3D ?)
! MODINT    METHODE D'INTEGRATION (CLASSIQUE,LUMPEE(D),REDUITE(R) ?)
! NNOP      NB DE NOEUDS DE L'ELEMENT PARENT
! NNOPS     NB DE NOEUDS SOMMETS DE L'ELEMENT PARENT
! NNOPM     NB DE NOEUDS MILIEUX DE L'ELEMENT PARENT
! NDDLS     NB DE DDL SUR LES SOMMETS
! NDDLM     NB DE DDL SUR LES MILIEUX
! NPI       NB DE POINTS D'INTEGRATION DE L'ELEMENT
! NPG       NB DE POINTS DE GAUSS     POUR CLASSIQUE(=NPI)
!                 SOMMETS             POUR LUMPEE   (=NPI=NNOS)
!                 POINTS DE GAUSS     POUR REDUITE  (<NPI)
! NDIM      DIMENSION DE L'ESPACE
! DIMUEL    NB DE DDL TOTAL DE L'ELEMENT
! DIMCON    DIMENSION DES CONTRAINTES GENERALISEES ELEMENTAIRES
! DIMENR    DIMENSION DES DEFORMATIONS GENERALISEES ELEMENTAIRES ENRICHI
! NFISS     NOMBRE DE FISSURES
! NFH       NOMBRE DE DDL HEAVISIDE PAR NOEUD
!
!                              sommets                    |            milieux
!           u v w p H1X H1Y H1Z H1PRE1 H2X H2Y H2Z H2PRE1  u v w H1X H1Y H1Z H2X H2Y H2Z
!          -----------------------------------------------------------------------------
!        u|                                               |                             |
!        v|               Fonctions de forme              |                             |
!        w|                                               |                             |
!        E|                       P2                      |              P2             |
!          -----------------------------------------------------------------------------
!        P|                                               |                             |
!       DP|                       P1                      |               0             |
!          -----------------------------------------------------------------------------
!      H1X|                                               |                             |
!      H1Y|                       P2                      |              P2             |
!      H1Z|                                               |                             |
!          -----------------------------------------------------------------------------
!   H1PRE1|                       P1                      |                             |
!          -----------------------------------------------------------------------------
!      H2X|                                               |                             |
!      H2Y|                       P2                      |              P2             |
!      H2Z|                                               |                             |
!          -----------------------------------------------------------------------------
!   H2PRE1|                       P1                      |                             |
!          -----------------------------------------------------------------------------

!
! =====================================================================================
! =====================================================================================
#include "asterf_types.h"
#include "asterfort/dfdm2d.h"
#include "asterfort/dfdm3d.h"
#include "asterfort/matini.h"
#include "asterfort/assert.h"
#include "asterfort/xcalc_code.h"
#include "asterfort/xcalc_heav.h"
#include "jeveux.h"
    aster_logical :: axi
    integer :: nddls, nddlm, nmec, np1, ndim, nnop, i, n, kk, yamec
    integer :: nnops, nnopm, kpi, dimuel, heavn(nnop,5)
    integer :: addeme, yap1, addep1
    integer :: yaenrm, adenme, dimenr
    integer :: yaenrh, adenhy, nfiss, nfh, ifh
    integer :: ipoids, idfde, ivf, nno, hea_se
    real(kind=8) :: dfdi(nnop, ndim), dfdi2(nnops, ndim)
    real(kind=8) :: ff(nnop), ff2(nnops)
    real(kind=8) :: b(dimenr, dimuel), rac, r, geom(ndim, nnop)
    real(kind=8) :: rbid1(nno), rbid2(nno), rbid3(nno)
    real(kind=8) :: he(nfiss) , poids, coorse(81)
! ======================================================================
! --- CALCUL DE CONSTANTES UTILES --------------------------------------
! ======================================================================
    rac= sqrt(2.d0)
    hea_se=xcalc_code(nfiss, he_real=[he])
! ======================================================================
! --- INITIALISATION DE LA MATRICE B -----------------------------------
! ======================================================================
    call matini(dimenr, dimuel, 0.d0, b)
! ======================================================================
! --- CALCUL DU JACOBIEN DE LA TRANSFORMATION SSTET-> SSTET REF --------
! --- AVEC LES COORDONNEES DES SOUS-ELEMENTS ---------------------------
! ======================================================================
    ASSERT((ndim .eq. 2) .or. (ndim .eq. 3))
    if (ndim .eq. 2) then
        call dfdm2d(nno, kpi, ipoids, idfde, coorse,&
                    poids, rbid1, rbid2)
    else if (ndim .eq. 3) then
        call dfdm3d(nno, kpi, ipoids, idfde, coorse,&
                    poids, rbid1, rbid2, rbid3)
    endif
! ======================================================================
! --- MODIFICATION DU POIDS POUR LES MODELISATIONS AXIS ----------------
! ======================================================================
    if (axi) then
        kk = (kpi-1)*nnop
        r = 0.d0
        do 10 n = 1, nnop
            r = r + zr(ivf+n+kk-1)*geom(1,n)
 10     continue
! ======================================================================
! --- DANS LE CAS OU R EGAL 0, ON A UN JACOBIEN NUL --------------------
! --- EN UN POINT DE GAUSS, ON PREND LE MAX DU RAYON -------------------
! --- SUR L ELEMENT MULTIPLIE PAR 1E-3 ---------------------------------
! ======================================================================
!        if (r .eq. 0.d0) then
!            rmax=geom(1,1)
!            do 15 n = 2, nnop
!                rmax=max(geom(1,n),rmax)
! 15         continue
!            poids = poids*1.d-03*rmax
!        else
!            poids = poids*r
!        endif
    endif
! ======================================================================
! --- REMPLISSAGE DE L OPERATEUR B -------------------------------------
! ======================================================================
! --- ON COMMENCE PAR LA PARTIE GAUCHE DE B CORRESPONDANT --------------
! --- AUX NOEUDS SOMMETS -----------------------------------------------
! ======================================================================
    do 102 n = 1, nnops
! ======================================================================
        if (yamec .eq. 1) then
            do 103 i = 1, ndim
                b(addeme-1+i,(n-1)*nddls+i)= b(addeme-1+i,(n-1)*nddls+&
                i)+ff(n)
103         continue
! ======================================================================
! --- CALCUL DE DEPSX, DEPSY, DEPSZ (DEPSZ INITIALISE A 0 EN 2D) -------
! ======================================================================
            do 104 i = 1, ndim
                b(addeme+ndim-1+i,(n-1)*nddls+i)= b(addeme+ndim-1+i,(&
                n-1)*nddls+i)+dfdi(n,i)
104         continue
! ======================================================================
! --- TERME U/R DANS EPSZ EN AXI ---------------------------------------
! ======================================================================
            if (axi) then
!                if (r .eq. 0.d0) then
!                    b(addeme+4,(n-1)*nddls+1)=dfdi(n,1)
!                else
                    b(addeme+4,(n-1)*nddls+1)=ff(n)/r
!                endif
            endif
! ======================================================================
! --- CALCUL DE EPSXY --------------------------------------------------
! ======================================================================
            b(addeme+ndim+3,(n-1)*nddls+1)= b(addeme+ndim+3,(n-1)*&
            nddls+1)+dfdi(n,2)/rac
!
            b(addeme+ndim+3,(n-1)*nddls+2)= b(addeme+ndim+3,(n-1)*&
            nddls+2)+dfdi(n,1)/rac
!
            if (ndim .eq. 3) then
! ======================================================================
! --- CALCUL DE EPSXZ --------------------------------------------------
! ======================================================================
               b(addeme+ndim+4,(n-1)*nddls+1)= b(addeme+ndim+4,(n-1)*&
               nddls+1)+dfdi(n,3)/rac
!
               b(addeme+ndim+4,(n-1)*nddls+3)= b(addeme+ndim+4,(n-1)*&
               nddls+3)+dfdi(n,1)/rac
! ======================================================================
! --- CALCUL DE EPSYZ --------------------------------------------------
! ======================================================================
               b(addeme+ndim+5,(n-1)*nddls+2)= b(addeme+ndim+5,(n-1)*&
               nddls+2)+dfdi(n,3)/rac
!
               b(addeme+ndim+5,(n-1)*nddls+3)= b(addeme+ndim+5,(n-1)*&
               nddls+3)+dfdi(n,2)/rac
            endif
        endif
! ======================================================================
! --- TERMES HYDRAULIQUES (FONCTIONS DE FORMES P1) ---------------------
! ======================================================================
! --- SI PRESS1 --------------------------------------------------------
! ======================================================================
        if (yap1 .eq. 1) then
            b(addep1,(n-1)*nddls+nmec+1)= b(addep1,(n-1)*nddls+nmec+1)&
            +ff2(n)
            do 105 i = 1, ndim
                b(addep1+i,(n-1)*nddls+nmec+1)= b(addep1+i,(n-1)*&
                nddls+nmec+1)+dfdi2(n,i)
105         continue
        endif
! ======================================================================
! --- TERMES ENRICHIS PAR FONCTIONS HEAVISIDE (XFEM) -------------------
! ======================================================================
! --- SI ENRICHISSEMENT MECANIQUE (FONCTIONS DE FORME P2) --------------
! ======================================================================
        if (yaenrm .eq. 1) then
          do ifh = 1, nfh
            do 106 i = 1, ndim
                b(adenme-1+(ifh-1)*(ndim+1)+i,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+i)= &
                b(adenme-1+(ifh-1)*(ndim+1)+i,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+i)+&
                xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*ff(n)
106         continue
!
            do 107 i = 1, ndim
                b(addeme-1+ndim+i,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+i) = b(addeme-1+&
                ndim+i,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+i)+&
                xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,i)
107         continue
!
            if (axi) then
!                if (r .eq. 0.d0) then
!                   b(addeme+4,(n-1)*nddls+nmec+np1+1)=xcalc_heav(heavn(n,1),&
!                                                      hea_se,heavn(n,5))*dfdi(n,1)
!                else
                    b(addeme+4,(n-1)*nddls+nmec+np1+1)=xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))&
                                                       *ff(n)/r
!                endif
            endif
!
            b(addeme+ndim+3,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+1)= b(addeme+ndim+3,(&
            n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+1)+&
            xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,2)/rac
!
            b(addeme+ndim+3,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+2)= b(addeme+ndim+3,(&
            n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+2)+&
            xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,1)/rac
!
            if (ndim .eq. 3) then
                b(addeme+ndim+4,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+1)= b(addeme+ndim+4,(&
                n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+1)+&
                xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,3)/rac
!
                b(addeme+ndim+4,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+3)= b(addeme+ndim+4,(&
                n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+3)+&
                xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,1)/rac
!
                b(addeme+ndim+5,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+2)= b(addeme+ndim+5,(&
                n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+2)+&
                xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,3)/rac
!
                b(addeme+ndim+5,(n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+3)= b(addeme+ndim+5,(&
                n-1)*nddls+nmec+np1+(ifh-1)*(ndim+1)+3)+&
                xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi(n,2)/rac
            endif
          end do
        endif
! ======================================================================
! --- SI ENRICHISSEMENT HYDRAULIQUE (FONCTIONS DE FORME P1) ------------
! ======================================================================
        if (yaenrh.eq.1) then
          do ifh = 1, nfh
            b(adenhy+(ifh-1)*(ndim+1),(n-1)*nddls+nmec+np1+ifh*(ndim+1))=&
            b(adenhy+(ifh-1)*(ndim+1),(n-1)*nddls+nmec+np1+ifh*(ndim+1))+&
            xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*ff2(n)
            do 108 i=1,ndim
               b(addep1+i,(n-1)*nddls+nmec+np1+ifh*(ndim+1))=&
               b(addep1+i,(n-1)*nddls+nmec+np1+ifh*(ndim+1))+&
               xcalc_heav(heavn(n,ifh),hea_se,heavn(n,5))*dfdi2(n,i)
 108        continue
          end do
        endif
102 continue
! ======================================================================
! --- ON REMPLIT MAINTENANT LE COIN SUPERIEUR DROIT DE B CORRESPONDANT -
! --- AUX NOEUDS MILIEUX (MECANIQUE - FONCTIONS DE FORMES P2) ----------
! ======================================================================
    do 300 n = 1, nnopm
        if (yamec .eq. 1) then
            do 301 i = 1, ndim
                b(addeme-1+i,nnops*nddls+(n-1)*nddlm+i)= b(addeme-1+i,&
                nnops*nddls+(n-1)*nddlm+i)+ff(n+nnops)
301         continue
! ======================================================================
! --- CALCUL DE DEPSX, DEPSY, DEPSZ (DEPSZ INITIALISE A 0 EN 2D) -------
! ======================================================================
            do 304 i = 1, ndim
                b(addeme+ndim-1+i,nnops*nddls+(n-1)*nddlm+i)= b(&
                addeme+ndim-1+i,nnops*nddls+(n-1)*nddlm+i) +dfdi(n+&
                nnops,i)
304         continue
! ======================================================================
! --- TERME U/R DANS EPSZ EN AXI ---------------------------------------
! ======================================================================
            if (axi) then
!                if (r .eq. 0.d0) then
!                    b(addeme+4,nnops*nddls+(n-1)*nddlm+1)=dfdi(n+&
!                    nnops,1)
!                else
                    b(addeme+4,nnops*nddls+(n-1)*nddlm+1)=ff(n+nnops)/&
                    r
!                endif
            endif
! ======================================================================
! --- CALCUL DE EPSXY POUR LES NOEUDS MILIEUX --------------------------
! ======================================================================
            b(addeme+ndim+3,nnops*nddls+(n-1)*nddlm+1)= b(addeme+ndim+&
            3,nnops*nddls+(n-1)*nddlm+1) +dfdi(n+nnops,2)/rac
!
            b(addeme+ndim+3,nnops*nddls+(n-1)*nddlm+2)= b(addeme+ndim+&
            3,nnops*nddls+(n-1)*nddlm+2) +dfdi(n+nnops,1)/rac
            if (ndim .eq. 3) then
! ======================================================================
! --- CALCUL DE EPSXZ POUR LES NOEUDS MILIEUX --------------------------
! ======================================================================
                b(addeme+ndim+4,nnops*nddls+(n-1)*nddlm+1)= b(addeme+ndim+&
                4,nnops*nddls+(n-1)*nddlm+1) +dfdi(n+nnops,3)/rac
!
                b(addeme+ndim+4,nnops*nddls+(n-1)*nddlm+3)= b(addeme+ndim+&
                4,nnops*nddls+(n-1)*nddlm+3) +dfdi(n+nnops,1)/rac
! ======================================================================
! --- CALCUL DE EPSYZ POUR LES NOEUDS MILIEUX --------------------------
! ======================================================================
                b(addeme+ndim+5,nnops*nddls+(n-1)*nddlm+2)= b(addeme+ndim+&
                5,nnops*nddls+(n-1)*nddlm+2) +dfdi(n+nnops,3)/rac
!
                b(addeme+ndim+5,nnops*nddls+(n-1)*nddlm+3)= b(addeme+ndim+&
                5,nnops*nddls+(n-1)*nddlm+3) +dfdi(n+nnops,2)/rac
            endif
        endif
! ======================================================================
! --- TERMES ENRICHIS PAR FONCTIONS HEAVISIDE (XFEM) -------------------
! ======================================================================
        if (yaenrm .eq. 1) then
          do ifh = 1, nfh
            do 306 i = 1, ndim
                b(adenme-1+(ifh-1)*(ndim+1)+i,nnops*nddls+(n-1)*nddlm+nmec*ifh+i)= &
                b(adenme-1+(ifh-1)*(ndim+1)+i,nnops*nddls+(n-1)*nddlm+nmec*ifh+i)+&
                xcalc_heav(heavn(n+nnops,ifh),hea_se,heavn(n+nnops,5))*ff(n+nnops)
306         continue
!
            do 307 i = 1, ndim
                b(addeme-1+ndim+i,nnops*nddls+(n-1)*nddlm+nmec*ifh+i)=&
                b(addeme-1+ndim+i,nnops*nddls+(n-1)*nddlm+nmec*ifh+i)+&
                xcalc_heav(heavn(n+nnops,ifh),hea_se,heavn(n+nnops,5))*dfdi(n+nnops,i)
307         continue
!
            if (axi) then
!                if (r .eq. 0.d0) then
!                    b(addeme+4,nnops*nddls+(n-1)*nddlm+nmec+1)=&
!                    xcalc_heav(heavn(n+nnops,1),hea_se,heavn(n+nnops,5))*dfdi(n+nnops,1)
!                else
                    b(addeme+4,nnops*nddls+(n-1)*nddlm+nmec*ifh+1)=&
                    xcalc_heav(heavn(n+nnops,ifh),hea_se,heavn(n+nnops,5))&
                    *ff(n+nnops)/r
!                endif
            endif
!
            b(addeme+ndim+3,nnops*nddls+(n-1)*nddlm+nmec*ifh+1)= b(addeme+&
          ndim+3,nnops*nddls+(n-1)*nddlm+nmec*ifh+1) +xcalc_heav(heavn(n+nnops,ifh),hea_se,&
          heavn(n+nnops,5))*dfdi(n+nnops,2)&
            /rac
!
            b(addeme+ndim+3,nnops*nddls+(n-1)*nddlm+nmec*ifh+2)= b(addeme+&
          ndim+3,nnops*nddls+(n-1)*nddlm+nmec*ifh+2) +xcalc_heav(heavn(n+nnops,ifh),hea_se,&
          heavn(n+nnops,5))*dfdi(n+nnops,1)&
            /rac
!
            if (ndim .eq. 3) then
                b(addeme+ndim+4,nnops*nddls+(n-1)*nddlm+nmec*ifh+1)= b(addeme+&
          ndim+4,nnops*nddls+(n-1)*nddlm+nmec*ifh+1) +xcalc_heav(heavn(n+nnops,ifh),hea_se,&
          heavn(n+nnops,5))*dfdi(n+nnops,3)/rac
!
                b(addeme+ndim+4,nnops*nddls+(n-1)*nddlm+nmec*ifh+3)= b(addeme+&
          ndim+4,nnops*nddls+(n-1)*nddlm+nmec*ifh+3) +xcalc_heav(heavn(n+nnops,ifh),hea_se,&
          heavn(n+nnops,5))*dfdi(n+nnops,1)/rac
!
                b(addeme+ndim+5,nnops*nddls+(n-1)*nddlm+nmec*ifh+2)= b(addeme+&
          ndim+5,nnops*nddls+(n-1)*nddlm+nmec*ifh+2) +xcalc_heav(heavn(n+nnops,ifh),hea_se,&
          heavn(n+nnops,5))*dfdi(n+nnops,3)/rac
!
                b(addeme+ndim+5,nnops*nddls+(n-1)*nddlm+nmec*ifh+3)= b(addeme+&
          ndim+5,nnops*nddls+(n-1)*nddlm+nmec*ifh+3) +xcalc_heav(heavn(n+nnops,ifh),hea_se,&
          heavn(n+nnops,5))*dfdi(n+nnops,2)/rac
            endif
          end do
        endif
300 continue
! ======================================================================
! --- LE COIN INFERIEUR DROIT EST NUL ----------------------------------
! ======================================================================
end subroutine
