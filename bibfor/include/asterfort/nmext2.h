!
! COPYRIGHT (C) 1991 - 2015  EDF R&D                WWW.CODE-ASTER.ORG
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
    subroutine nmext2(mesh         , field    , nb_cmp  , nb_node  , type_extr,&
                      type_extr_cmp, list_node, list_cmp, work_node)
        character(len=8), intent(in) :: mesh
        integer, intent(in) :: nb_node
        integer, intent(in) :: nb_cmp
        character(len=8), intent(in) :: type_extr
        character(len=8), intent(in) :: type_extr_cmp
        character(len=24), intent(in) :: list_node
        character(len=24), intent(in) :: list_cmp
        character(len=19), intent(in) :: field
        character(len=19), intent(in) :: work_node
    end subroutine nmext2
end interface
