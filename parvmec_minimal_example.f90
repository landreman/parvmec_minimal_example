program parvmec_minimal_example

  use parallel_vmec_module, only: InitRunVmec, FinalizeRunVmec, RUNVMEC_COMM_WORLD
  use vmec_params, only: restart_flag, readin_flag, timestep_flag, output_flag, cleanup_flag, reset_jacdt_flag

  implicit none

  include 'mpif.h'

  integer :: ierr, rank, num_procs, ictrl(5), myseq=0, iteration, iunit=12
  logical :: master, lfreeb=.false.
  character(len=*), parameter :: file_str = 'lpku_A6_lowiota_5.min_newP'
  character(len = 128)    :: reset_str

  call MPI_INIT(ierr)
  call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, num_procs, ierr)
  CALL MPI_ERRHANDLER_SET(MPI_COMM_WORLD,MPI_ERRORS_RETURN,ierr) ! This line is used in stellopt_main(). If not included, the first call to runvmec dies at the end of fileout_par().
  master = (rank==0)
  if (master) print *,"Detected",num_procs,"procs."

  ! Set ictrl array as done in stellopt_init.f90, to just read in the input file.
  ictrl(1) = restart_flag + readin_flag + reset_jacdt_flag
  ictrl(2) = 0; ictrl(3) = 50; ictrl(4) = 0; ictrl(5) = myseq
  call runvmec(ictrl,file_str,.false.,MPI_COMM_SELF,'')

  if (master) print *,"Done reading input file."

  do iteration = 1,5
     if (master) print *,"Beginning call",iteration," to parvmec."
     call stellopt_bcast_vmec(0,MPI_COMM_WORLD,ierr)
     call stellopt_reinit_vmec()

     ! Now set ICTRL Array as done in stellopt_paraexe.f90
     ictrl(1) = restart_flag + timestep_flag + output_flag + reset_jacdt_flag
     ictrl(2) = 0; ictrl(3) = -1; ictrl(4) = -1; ictrl(5) = myseq
     reset_str = ''
     call MPI_BARRIER(MPI_COMM_WORLD, ierr)
     call InitRunVmec(MPI_COMM_WORLD,lfreeb)
     call runvmec(ictrl,file_str,.true.,RUNVMEC_COMM_WORLD,reset_str)
     call FinalizeRunVmec(RUNVMEC_COMM_WORLD)
  end do

  call MPI_FINALIZE(ierr)

  if (master) print *,"Done."

end program parvmec_minimal_example
