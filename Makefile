
# ------------------------------------------------------------------------------
# CTF build instructions
# ------------------------------------------------------------------------------
# 
# Copy the `Makefile.in.template` file to `Makefile.in`, and modify it for your
# system, then type `make`.
#
# ------------------------------------------------------------------------------

MAKEFILE_IN = $(PWD)/Makefile.in
include $(MAKEFILE_IN)

CFLAGS   ?= -Wall
CURL     ?= curl
UNTAR    ?= tar -xvf
CD       ?= cd
RM       ?= rm -f
OS       ?= generic

LUA_I ?= -I$(LUA_HOME)/include
LUA_L ?= -L$(LUA_HOME)/lib -llua
LUA_A ?=   $(LUA_HOME)/lib/liblua.a
FFT_L ?= -L$(FFT_HOME)/lib -lfftw3

LUA_COW    = cow/lua-cow.o
LUA_MARA   = Mara/mara.o
LUA_FISH   = fish/lua-fish.o
LUA_FLUIDS = fish/lua-fluids.o
LUA_MPI    = lua-mpi/lua-mpi.o
LUA_HDF5   = lua-hdf5/lua-hdf5.o
LUA_BUFFER = lua-buffer/lua-buffer.o
LUA_VIS    = visual/lua-visual.o
LUA_GLUT   = lua-glut

MODULES = $(LUA_BUFFER)
LOCLIBS = $(LUA_A)

ifeq ($(strip $(USE_MPI)), 1)
MODULES += $(LUA_MPI)
DEFINES += -DUSE_MPI
endif

ifeq ($(strip $(USE_HDF5)), 1)
MODULES += $(LUA_HDF5)
DEFINES += -DUSE_HDF5
LIBS += -L$(HDF_HOME)/lib -lz -lhdf5
endif

ifeq ($(strip $(USE_COW)), 1)
MODULES += $(LUA_COW)
DEFINES += -DUSE_COW
LOCLIBS += cow/libcow.a
endif

ifeq ($(strip $(USE_MARA)), 1)
MODULES += $(LUA_MARA)
DEFINES += -DUSE_MARA
LOCLIBS += Mara/libmara.a
endif

ifeq ($(strip $(USE_FISH)), 1)
MODULES += $(LUA_FISH) $(LUA_FLUIDS)
DEFINES += -DUSE_FISH -DUSE_FLUIDS
LOCLIBS += fish/libfish.a
endif

ifeq ($(strip $(USE_FFTW)), 1)
LIBS += $(FFT_L)
DEFINES += -DUSE_FFTW
endif

ifeq ($(strip $(USE_VIS)), 1)
MODULES += $(LUA_VIS)
DEFINES += -DUSE_VIS
LOCLIBS += visual/libvisual.a
endif

ifeq ($(strip $(USE_MPIO)), 1)
DEFINES += -DUSE_MPIO
endif


default : ctf

$(LUA_A) :
	$(CD) $(LVER); \
	$(MAKE) $(OS) CC=$(CC); \
	$(MAKE) install INSTALL_TOP=$(LUA_HOME)

visual/libvisual.a : $(LUA_A) .FORCE
	$(MAKE) -C visual libvisual.a MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_VIS) : $(LUA_A) .FORCE
	$(MAKE) -C visual lua-visual.o MAKEFILE_IN=$(MAKEFILE_IN)

cow/libcow.a : $(LUA_A) .FORCE
	$(MAKE) -C cow libcow.a MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_COW) : $(LUA_A) .FORCE
	$(MAKE) -C cow lua-cow.o MAKEFILE_IN=$(MAKEFILE_IN)

Mara/libmara.a : $(LUA_A) .FORCE
	$(MAKE) -C Mara libmara.a MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_MARA) : $(LUA_A) .FORCE
	$(MAKE) -C Mara mara.o MAKEFILE_IN=$(MAKEFILE_IN)

fish/libfish.a : $(LUA_A) .FORCE
	$(MAKE) -C fish libfish.a MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_FISH) : $(LUA_A) .FORCE
	$(MAKE) -C fish lua-fish.o MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_FLUIDS) : $(LUA_A) .FORCE
	$(MAKE) -C fish lua-fluids.o MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_MPI) : $(LUA_A) .FORCE
	$(MAKE) -C lua-mpi lua-mpi.o MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_HDF5) : $(LUA_A) .FORCE
	$(MAKE) -C lua-hdf5 lua-hdf5.o MAKEFILE_IN=$(MAKEFILE_IN)

$(LUA_BUFFER) : $(LUA_A) .FORCE
	$(MAKE) -C lua-buffer lua-buffer.o MAKEFILE_IN=$(MAKEFILE_IN)

ctf.o : ctf.c $(LUA_A) $(MAKEFILE_IN)
	$(CC) $(CFLAGS) -c -o $@ $< $(LUA_I) $(DEFINES) -DINSTALL_DIR=\"$(PWD)\"

ctf : ctf.o $(MODULES) $(LOCLIBS)
	$(CXX) $(CFLAGS) -o $@ $^ $(LIBS)

$(LUA_GLUT) :
	$(MAKE) -C lua-glut DEFS=$(LUA_I)

clean :
	$(MAKE) -C visual clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C cow clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C fish clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C Mara clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C lua-buffer clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C lua-mpi clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C lua-hdf5 clean MAKEFILE_IN=$(MAKEFILE_IN)
	$(MAKE) -C lua-glut clean
	$(MAKE) -C $(LVER) clean
	$(RM) *.o ctf

show :
	@echo $(MODULES)
	@echo $(LOCLIBS)
	@echo $(DEFINES)

# Also remove local Lua sources
realclean : clean
	$(RM) -r $(LVER)

.PHONY : lua-glut

.FORCE : 
