subroutine elg_calcx0()
#include "asterf_types.h"
#include "asterf_petsc.h"
!
use elim_lagr_data_module
    implicit none
! person_in_charge: natacha.bereux at edf.fr
! aslint:disable=
! ======================================================================
! COPYRIGHT (C) 1991 - 2017  EDF R&D                  WWW.CODE-ASTER.ORG
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
#include "jeveux.h"
#include "asterc/asmpi_comm.h"
#include "asterfort/asmpi_info.h"
#include "asterfort/assert.h"
#include "asterfort/infniv.h"
#include "asterfort/jedema.h"
#include "asterfort/jemarq.h"
#include "asterfort/utmess.h"
!----------------------------------------------------------------
!
!     Résolution de x0 = A \ c
!     ========================
!     On suppose que le système est sous-déterminé
!     On calcule x0 comme le vecteur de norme minimale vérifiant la
!     contrainte A*x0 = c (i.e. x0 est solution du problème de minimisation
!     sous contrainte : min ||x||, Ax = c )
!     On procède en 3 étapes :
!     * calcul de A A' ( A' est ELIMLG/Ctrans )
!     * résolution de y0 = ( A A' ) \ c (appel du Gradient Conjugué de PETSc)
!     * calcul de x0 = A' * y0
!
!     Rq: La méthode originale de résolution est basée sur une
!         factorisation QR préalable de A. La solution x0
!         est obtenue par:
!       z   = (L'*L) \  c  (par descente / remontée)
!       x0  = A' * z
!       avec :
!     * Mat A'  : matrice des contraintes linéaires
!       A' utilisée est ELIMLG/Ctrans
!     * Mat L'  : matrice triangulaire supérieure
!       L' utilisée est ELIMLG/RCt
!       Remarque : L est telle que : A*A'=L'*L
!
!     * Vec VecC (second membre c)
!       VecC utilisé est ELIMLG/VecC
!     * Vec Vx0  (solution)
!       Vx0 utilisé est ELIMLG/Vx0
!----------------------------------------------------------------
#ifdef _HAVE_PETSC
    Vec :: vy, y0
    Mat :: cct
    KSP :: ksp
    PC  :: pc
    integer :: ifm, niv
    mpi_int :: mpicomm, rang, nbproc
    PetscInt :: its, reason
    PetscErrorCode :: ierr
    PetscInt :: mm, nn
    real(kind=8) :: norm
    PetscScalar, parameter ::  neg_rone = -1.d0
    aster_logical :: info
    PetscReal :: aster_petsc_real
!----------------------------------------------------------------
    call jemarq()
    call infniv(ifm, niv)
    info=niv.eq.2
#if PETSC_VERSION_LT(3,5,0)
    aster_petsc_real = PETSC_DEFAULT_DOUBLE_PRECISION
#else
    aster_petsc_real = PETSC_DEFAULT_REAL
#endif
    !
!   -- COMMUNICATEUR MPI DE TRAVAIL
    call asmpi_comm('GET_WORLD', mpicomm)
    call asmpi_info(rank=rang, size=nbproc)
!
!   -- Le système est-il bien sous-déterminé ?
    call MatGetSize( elg_context(ke)%ctrans, mm, nn , ierr)
    ASSERT( mm > nn )
!   -- Calcul de CCT = C * transpose(C)

#if PETSC_VERSION_LT(3,3,0)
!   TODO
    ASSERT(.false.)
#else
    call MatTransposeMatMult(elg_context(ke)%ctrans, elg_context(ke)%ctrans,&
        MAT_INITIAL_MATRIX, aster_petsc_real, cct, ierr)
#endif
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!         Create the linear solver and set options
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!
!  Create linear solver context
      call KSPCreate(mpicomm,ksp,ierr)
!  Set operators. Here the matrix that defines the linear system
!  also serves as the preconditioning matrix.
!
#if PETSC_VERSION_LT(3,5,0)
    call KSPSetOperators(ksp, cct, cct, SAME_PRECONDITIONER, ierr)
#else
    call KSPSetOperators(ksp, cct, cct, ierr)
#endif
!
!  Set linear solver options : here we choose CG solver
      call KSPSetType(ksp, KSPCG, ierr)
!
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!                      Solve the linear system
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

!
!    y0 = ( A * A' )  \ c
!
    call VecDuplicate( elg_context(ke)%vecc, y0, ierr)
    call KSPSolve( ksp, elg_context(ke)%vecc, y0, ierr)
!
!  Check the reason why KSP solver ended
    call KSPGetConvergedReason(ksp, reason, ierr)
!  Reason < 0 indicates a problem during the resolution
    if (reason<0) then
      call utmess('F','ELIMLAGR_8')
    endif
!
!   x0 = A' * y0
    call MatMult( elg_context(ke)%ctrans, y0, elg_context(ke)%vx0, ierr)
!
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
!                     Check solution and clean up
! - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

!  Check the error ||A*x0 - c||
!
      if (info) then
      call VecDuplicate(elg_context(ke)%vecc ,vy,ierr)
      call MatMultTranspose(elg_context(ke)%ctrans,  elg_context(ke)%vx0, vy, ierr)
      call VecAXPY(vy,neg_rone,elg_context(ke)%vecc ,ierr)
      call VecNorm(vy,norm_2,norm,ierr)
      call KSPGetIterationNumber(ksp,its,ierr)

      if (rang .eq. 0) then
           write(6,100) norm,its
      endif
  100 format('CALCX0: Norm of error = ',e11.4,', iterations = ',i5)
      call VecDestroy(vy,ierr)
      endif
!
!  Free work space.  All PETSc objects should be destroyed when they
!  are no longer needed.

      call KSPDestroy(ksp,ierr)
      call MatDestroy(cct,ierr)
      call VecDestroy(y0, ierr)
!
    call jedema()
!
#else
    ASSERT(.false.)
#endif
!
end subroutine
