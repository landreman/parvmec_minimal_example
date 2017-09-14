ifdef NERSC_HOST
        HOSTNAME = $(NERSC_HOST)
else ifeq ($(CLUSTER),DRACO)
	HOSTNAME="draco"
else
        HOSTNAME="laptop"
endif


ifeq ($(HOSTNAME),cori)
        FC = ftn
	LIBSTELL_DIR = /global/homes/l/landrema/stellopt/LIBSTELL/Release
        PARVMEC_DIR = /global/homes/l/landrema/stellopt/PARVMEC/Release
        EXTRA_COMPILE_FLAGS =
        EXTRA_LINK_FLAGS =
else ifeq ($(HOSTNAME),draco)
        FC =  mpiifort
	LIBSTELL_DIR = /u/mlan/stellopt/LIBSTELL/Release
        PARVMEC_DIR = /u/mlan/stellopt/PARVMEC/Release
        EXTRA_COMPILE_FLAGS = -I${NETCDF_HOME}/include
        EXTRA_LINK_FLAGS = -L${NETCDF_HOME}/lib -lnetcdf -lnetcdff -L${HDF5_HOME}/lib -lhdf5_fortran -lhdf5 -lhdf5_hl -lhdf5hl_fortran
else
	FC = mpif90
	LIBSTELL_DIR = /Users/mattland/stellopt/LIBSTELL/Release
	PARVMEC_DIR = /Users/mattland/stellopt/PARVMEC/Release
	EXTRA_COMPILE_FLAGS = -I/opt/local/include -ffree-line-length-none -g -O0
	EXTRA_LINK_FLAGS =  -L/opt/local/lib -lnetcdff  -lnetcdf -framework Accelerate -lscalapack -g -O0
endif

# End of system-dependent variable assignments

.PHONY: all clean

all: parvmec_minimal_example

%.o: %.f90
	$(FC) $(EXTRA_COMPILE_FLAGS) -I $(LIBSTELL_DIR) -I $(PARVMEC_DIR) -c $<

libparvmec.a:
	ar -cru libparvmec.a $(PARVMEC_DIR)/*.o

parvmec_minimal_example: parvmec_minimal_example.o libparvmec.a stellopt_reinit_vmec.o stellopt_bcast_vmec.o
	$(FC) -o parvmec_minimal_example parvmec_minimal_example.o stellopt_reinit_vmec.o stellopt_bcast_vmec.o libparvmec.a $(LIBSTELL_DIR)/libstell.a $(EXTRA_LINK_FLAGS)

clean:
	rm -f *.o *.mod *.MOD *~ parvmec_minimal_example libparvmec.a

test_make:
	@echo HOSTNAME is $(HOSTNAME)
	@echo FC is $(FC)
	@echo EXTRA_COMPILE_FLAGS is $(EXTRA_COMPILE_FLAGS)
	@echo EXTRA_LINK_FLAGS is $(EXTRA_LINK_FLAGS)
	@echo LIBSTELL_DIR is $(LIBSTELL_DIR)
	@echo PARVMEC_DIR is $(PARVMEC_DIR)
