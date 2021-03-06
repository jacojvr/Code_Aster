!
! COPYRIGHT (C) 1991 - 2016  EDF R&D                WWW.CODE-ASTER.ORG
!
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
! 1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.
!
interface
    subroutine nmarc0(result, modele        , mate  , carele         , fonact,&
                      sdcrit, sddyna        , sdpost, ds_constitutive, sdcriq,&
                      sdpilo, list_load_resu, numarc, time_curr)
        use NonLin_Datastructure_type
        character(len=8) :: result
        character(len=24) :: modele
        character(len=24) :: mate
        character(len=24) :: carele
        integer :: fonact(*)
        character(len=19) :: sdcrit
        character(len=19) :: sddyna
        character(len=19) :: sdpost
        type(NL_DS_Constitutive), intent(in) :: ds_constitutive
        character(len=24) :: sdcriq
        character(len=19) :: sdpilo
        character(len=19) :: list_load_resu
        integer :: numarc
        real(kind=8) :: time_curr
    end subroutine nmarc0
end interface
