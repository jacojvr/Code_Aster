subroutine cafono(char, ligrcz, mesh, ligrmz, vale_type)
    implicit none
#include "asterf_types.h"
#include "jeveux.h"
#include "asterc/getfac.h"
#include "asterc/r8dgrd.h"
#include "asterfort/affono.h"
#include "asterfort/alcart.h"
#include "asterfort/assert.h"
#include "asterfort/char_nb_ligf.h"
#include "asterfort/char_crea_ligf.h"
#include "asterfort/dismoi.h"
#include "asterfort/exisdg.h"
#include "asterfort/getvid.h"
#include "asterfort/getvr8.h"
#include "asterfort/jedema.h"
#include "asterfort/jedetr.h"
#include "asterfort/jeexin.h"
#include "asterfort/jelira.h"
#include "asterfort/jemarq.h"
#include "asterfort/jenonu.h"
#include "asterfort/jenuno.h"
#include "asterfort/jeveuo.h"
#include "asterfort/jexnom.h"
#include "asterfort/jexnum.h"
#include "asterfort/nocart.h"
#include "asterfort/noligr.h"
#include "asterfort/reliem.h"
#include "asterfort/utmess.h"
#include "asterfort/wkvect.h"
#include "asterfort/as_deallocate.h"
#include "asterfort/as_allocate.h"
!
    character(len=4) :: vale_type
    character(len=8) :: char, mesh
    character(len=*) :: ligrcz, ligrmz
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
!     REMPLIR LA CARTE .FORNO, ET LE LIGREL POUR FORC_NO
!     -----------------------------------------------------------------
!   ARGUMENTS D'ENTREE:
!      CHAR  : NOM UTILISATEUR DU RESULTAT DE CHARGE
!      LIGRCZ: NOM DU LIGREL DE CHARGE
!      IGREL : NUMERO DU GREL DE CHARGE
!      INEMA : NUMERO  DE LA DERNIERE MAILLE TARDIVE DANS LIGRCH
!      NBTOUT: NOMBRE TOTAL DE GROUPES, NOEUDS,.. DANS LES OCCURENCES
!      mesh  : NOM DU MAILLAGE
!      LIGRMZ: NOM DU LIGREL DE MODELE
!      vale_type  : 'FONC' OU 'REEL'
!     -----------------------------------------------------------------
!     ------------------------------------------------------------------
    integer :: nmocl, nfono, n2dl, n3dl, n6dl, ncoq2d, nbcomp
!-----------------------------------------------------------------------
    integer :: i, idgex, ii, in, ino, iret
    integer :: j, jj, jl, jnbno, jno
    integer :: jprnm, jval, jvalv, nangl, nbec, nbecf
    integer :: nbno, nbnoeu, nsurch, numel
    integer :: igrel, inema
!-----------------------------------------------------------------------
    parameter     (nmocl=10)
    integer :: ntypel(nmocl), forimp(nmocl)
    real(kind=8) :: dgrd, valfor(nmocl)
    aster_logical :: verif, l_occu_void
    character(len=8) :: nomn, typmcl(2), typlag, valfof(nmocl)
    character(len=16) :: motcle(nmocl), keywordfact, motcls(2)
    character(len=19) :: carte, ligrmo, ligrch
    character(len=24) :: liel, nomnoe, nomele, mesnoe
    integer :: nb_elem_late, nb_noel_maxi, jlgns, iexi
    integer, pointer :: desgi(:) => null()
    character(len=8), pointer :: noms_noeuds(:) => null()
    character(len=8), pointer :: ncmp(:) => null()
!     ------------------------------------------------------------------
    call jemarq()
!
    keywordfact = 'FORCE_NODALE'
    call getfac(keywordfact, nfono)
    if (nfono .eq. 0) goto 999
!
    ligrch = ligrcz
    typlag(1:2) = '12'
    igrel = 0
    inema = 0
    motcls(1) = 'GROUP_NO'
    motcls(2) = 'NOEUD'
    typmcl(1) = 'GROUP_NO'
    typmcl(2) = 'NOEUD'
!
    verif = .true.
!
! - Count number of late elements
!
    call char_nb_ligf(mesh, keywordfact, 'Node', nb_elem_late, nb_noel_maxi)
!
! - Create <LIGREL> on late elements
!
    call char_crea_ligf(mesh, ligrch, nb_elem_late, nb_noel_maxi)
!
    call jenonu(jexnom('&CATA.TE.NOMTE', 'FORCE_NOD_2DDL' ), n2dl)
    call jenonu(jexnom('&CATA.TE.NOMTE', 'FORCE_NOD_3DDL' ), n3dl)
    call jenonu(jexnom('&CATA.TE.NOMTE', 'FORCE_NOD_6DDL' ), n6dl)
    call jenonu(jexnom('&CATA.TE.NOMTE', 'FORCE_NOD_COQ2D'), ncoq2d)
    ntypel(1) = n2dl
    ntypel(2) = n2dl
    ntypel(3) = n3dl
    ntypel(4) = n6dl
    ntypel(5) = n6dl
    ntypel(6) = n6dl
!
! ---------------------------------------------------
!     RECUPERATION DES MOTS-CLES DDL POSSIBLES SOUS FORCE_NODALE
! ---------------------------------------------------
    motcle(1) = 'FX'
    motcle(2) = 'FY'
    motcle(3) = 'FZ'
    motcle(4) = 'MX'
    motcle(5) = 'MY'
    motcle(6) = 'MZ'
    motcle(7) = 'REP'
    motcle(8) = 'ALPHA'
    motcle(9) = 'BETA'
    motcle(10) = 'GAMMA'
    nbcomp = 10
!
! ---------------------------------------------------
! *** RECUPERATION DU DESCRIPTEUR GRANDEUR .PRNM
! *** DU MODELE
! ---------------------------------------------------
!
    call dismoi('NB_EC', 'FORC_R', 'GRANDEUR', repi=nbecf)
    if (nbecf .gt. 10) then
        call utmess('F', 'MODELISA2_65')
    else
        ligrmo = ligrmz
        call jeveuo(ligrmo//'.PRNM', 'L', jprnm)
    endif
!
    call dismoi('NB_EC', 'DEPL_R', 'GRANDEUR', repi=nbec)
    if (nbec .gt. 10) then
        call utmess('F', 'MODELISA_94')
    endif
!
    call jeveuo(ligrch//'.NBNO', 'E', jnbno)
    nomnoe = mesh//'.NOMNOE'
    call jelira(nomnoe, 'NOMMAX', nbnoeu)
!
    mesnoe = '&&CAFONO.MES_NOEUDS'
    motcls(1) = 'GROUP_NO'
    motcls(2) = 'NOEUD'
    typmcl(1) = 'GROUP_NO'
    typmcl(2) = 'NOEUD'
!
! ---------------------------------------------------
!     ALLOCATION DE TABLEAUX DE TRAVAIL
! ---------------------------------------------------
!   OBJETS INTERMEDIAIRES PERMETTANT D'APPLIQUER LA REGLE DE SURCHARGE
!        -  VECTEUR (K8) CONTENANT LES NOMS DES NOEUDS
!        -  TABLEAU DES VALEURS DES DDLS DES FORCES IMPOSEES
!                         DIM NBNOEU * NBCOMP
!        -  VECTEUR (IS) CONTENANT LE DESCRIPTEUR GRANDEUR ASSOCIE AUX
!                         FORCES IMPOSEES PAR NOEUD
!
    AS_ALLOCATE(vk8=noms_noeuds, size=nbnoeu)
    if (vale_type .eq. 'REEL') then
        call wkvect('&&CAFONO.VALDDLR', 'V V R', nbcomp*nbnoeu, jval)
    else
        call wkvect('&&CAFONO.VALDDLF', 'V V K8', nbcomp*nbnoeu, jval)
    endif
    AS_ALLOCATE(vi=desgi, size=nbnoeu)
!
    dgrd = r8dgrd()
    if (vale_type .eq. 'FONC') then
        do i = 1, nbcomp*nbnoeu
            zk8(jval-1+i) = '&FOZERO'
        end do
    endif
    nsurch = 0
!
! --------------------------------------------------------------
!     BOUCLE SUR LES OCCURENCES DU MOT-CLE FACTEUR FORCE_NODALE
! --------------------------------------------------------------
!
    do i = 1, nfono
        do ii = 1, nbcomp
            forimp(ii) = 0
        end do
!
        if (vale_type .eq. 'REEL') then
            do j = 1, 6
                call getvr8(keywordfact, motcle(j), iocc=i, scal=valfor(j), nbret=forimp(j))
            end do
!
            call getvr8(keywordfact, 'ANGL_NAUT', iocc=i, nbval=3, vect=valfor(8),&
                        nbret=nangl)
            if (nangl .ne. 0) then
!              --- REPERE UTILISATEUR ---
                valfor(7) = -1.d0
                forimp(7) = 1
                do ii = 1, min(3, abs(nangl))
                    valfor(7+ii) = valfor(7+ii)*dgrd
                    forimp(7+ii) = 1
                end do
            else
!              --- REPERE GLOBAL ---
                valfor(7) = 0.d0
            endif
!
        else if (vale_type.eq.'FONC') then
            do ii = 1, nbcomp
                valfof(ii) = '&FOZERO'
            end do
            do j = 1, 6
                call getvid(keywordfact, motcle(j), iocc=i, scal=valfof(j), nbret=forimp(j))
            end do
!
            call getvid(keywordfact, 'ANGL_NAUT', iocc=i, nbval=3, vect=valfof(8),&
                        nbret=nangl)
            if (nangl .ne. 0) then
!              --- REPERE UTILISATEUR ---
                valfof(7) = 'UTILISAT'
                forimp(7) = 1
                do ii = 1, min(3, abs(nangl))
                    forimp(7+ii) = 1
                end do
            else
!              --- REPERE GLOBAL ---
                valfof(7) = 'GLOBAL'
            endif
        endif
        if (nangl .lt. 0) then
            call utmess('A', 'MODELISA2_66')
        endif
!
!       ---------------------------
!       CAS DE GROUP_NO ET DE NOEUD
!       ---------------------------
!
        call reliem(' ', mesh, 'NO_NOEUD', keywordfact, i,&
                    2, motcls, typmcl, mesnoe, nbno)
        if (nbno .eq. 0) goto 110
        call jeveuo(mesnoe, 'L', jno)
!
        l_occu_void = .true.
        do jj = 1, nbno
            call jenonu(jexnom(nomnoe, zk8(jno-1+jj)), ino)
            noms_noeuds(ino) = zk8(jno-1+jj)
            call affono(zr(jval), zk8(jval), desgi(ino), zi(jprnm- 1+(ino-1)*nbec+1), nbcomp,&
                        vale_type, zk8(jno-1+jj), ino, nsurch, forimp,&
                        valfor, valfof, motcle, verif, nbec)
            
            if (desgi(ino) .ne. 0) l_occu_void = .false.
        end do
        
        if (l_occu_void) then
            do ii =1, 6
                if (forimp(ii) .ne. 0) then
                    call utmess('F', 'CHARGES2_46', sk=motcle(ii))
                endif
            enddo
        endif
!
        call jedetr(mesnoe)
110     continue
    end do
!
!     -----------------------------------------------
!     AFFECTATION DU LIGREL ET STOCKAGE DANS LA CARTE
!              DIMENSIONS AUX VRAIES VALEURS
!     -----------------------------------------------
!
    liel = ligrch//'.LIEL'
    carte = char//'.CHME.FORNO'
!
    call jeexin(carte//'.DESC', iret)
!
    if (iret .eq. 0) then
        if (vale_type .eq. 'REEL') then
            call alcart('G', carte, mesh, 'FORC_R')
        else if (vale_type.eq.'FONC') then
            call alcart('G', carte, mesh, 'FORC_F')
        else
            ASSERT(.false.)
        endif
    endif
!
    call jeveuo(carte//'.NCMP', 'E', vk8=ncmp)
    call jeveuo(carte//'.VALV', 'E', jvalv)
!
    ncmp(1) = 'FX'
    ncmp(2) = 'FY'
    ncmp(3) = 'FZ'
    ncmp(4) = 'MX'
    ncmp(5) = 'MY'
    ncmp(6) = 'MZ'
    ncmp(7) = 'REP'
    ncmp(8) = 'ALPHA'
    ncmp(9) = 'BETA'
    ncmp(10) = 'GAMMA'
!
    call jeveuo(ligrch//'.NBNO', 'E', jnbno)
    call jeexin(ligrch//'.LGNS', iexi)
    if (iexi .gt. 0) then
        call jeveuo(ligrch//'.LGNS', 'E', jlgns)
    else
        jlgns=1
    endif
!
!     -----------------------------------------------
!     BOUCLE SUR TOUS LES NOEUDS DU MAILLAGE
!     -----------------------------------------------
!
    do ino = 1, nbnoeu
!
        if (desgi(ino) .ne. 0) then
!
            nomn = noms_noeuds(ino)
            call jenonu(jexnom(nomnoe, nomn), in)
            idgex = jprnm - 1 + (in-1)*nbec + 1
!
            do i = 1, 6
                if (exisdg(zi(idgex),i)) then
                    numel = ntypel(i)
                endif
            end do
            if ((exisdg(zi(idgex),6)) .and. (.not. (exisdg(zi(idgex), 4)))) then
                numel = ncoq2d
            endif
!
            igrel = igrel + 1
            call jenuno(jexnum('&CATA.TE.NOMTE', numel), nomele)
            call noligr(ligrch, igrel, numel, in,&
                        1, inema, zi(jnbno), typlag, jlgns)
!
            call jeveuo(jexnum(liel, igrel), 'E', jl)
            if (vale_type .eq. 'REEL') then
                do i = 1, nbcomp
                    zr(jvalv-1+i) = zr(jval-1+nbcomp* (ino-1)+i)
                end do
            else
                do i = 1, nbcomp
                    zk8(jvalv-1+i) = zk8(jval-1+nbcomp* (ino-1)+i)
                end do
            endif
!
!   ON CREE UNE CARTE POUR CHAQUE NOEUD AFFECTE ET ON NOTE TOUTES
!   LES COMPOSANTES (NBCOMP)
!
            call nocart(carte, -3, nbcomp, ligrel=liel, nma=1,&
                        limanu=[zi(jl)])
!
        endif
!
    end do
!
    AS_DEALLOCATE(vk8=noms_noeuds)
    AS_DEALLOCATE(vi=desgi)
    if (vale_type .eq. 'REEL') then
        call jedetr('&&CAFONO.VALDDLR')
    else if (vale_type.eq.'FONC') then
        call jedetr('&&CAFONO.VALDDLF')
    endif
999 continue
    call jedema()
end subroutine
