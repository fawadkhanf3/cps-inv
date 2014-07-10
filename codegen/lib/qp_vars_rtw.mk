###########################################################################
## File : qp_vars_rtw.mk
## 
## Makefile generated for MATLAB file/project 'qp_vars'. 
## 
## Makefile Info:
## 
## Final product: $(RELATIVE_PATH_TO_ANCHOR)/qp_vars.a
## Product type : static-library
## 
## MATLAB Coder version: 2.4 (R2013a)
## 
###########################################################################

###########################################################################
## MACROS
###########################################################################

# Macro Descriptions:
# PRODUCT_NAME            Name of the system to build
# MAKEFILE                Name of this makefile
# COMPUTER                Computer type. See the MATLAB "computer" command.

PRODUCT_NAME              = qp_vars
MAKEFILE                  = qp_vars_rtw.mk
COMPUTER                  = MACI64
ARCH                      = maci64
MATLAB_ROOT               = /Applications/MATLAB_R2013a.app
START_DIR                 = /Users/petter/Dropbox/Research/Code/inv_set/codegen/lib
RELATIVE_PATH_TO_ANCHOR   = .
MATLAB_BIN                = $(MATLAB_ROOT)/bin
MATLAB_ARCH_BIN           = $(MATLAB_ROOT)/bin/maci64

###########################################################################
## TOOLCHAIN SPECIFICATIONS
###########################################################################

TOOLCHAIN_MAKEFILE = qp_vars_rtw_tools.mk

-include qp_vars_rtw_tools.mk


###########################################################################
## OUTPUT INFO
###########################################################################

PRODUCT = $(RELATIVE_PATH_TO_ANCHOR)/qp_vars.a
PRODUCT_TYPE = "static-library"
BUILD_TYPE = "Static Library"

###########################################################################
## INCLUDE PATHS
###########################################################################

INCLUDES_BUILDINFO = -I/Users/petter/Dropbox/Research/Code/inv_set/codegen -I$(START_DIR) -I$(MATLAB_ROOT)/extern/include -I$(MATLAB_ROOT)/simulink/include -I$(MATLAB_ROOT)/rtw/c/src -I$(MATLAB_ROOT)/rtw/c/src/ext_mode/common -I$(MATLAB_ROOT)/rtw/c/ert

INCLUDES = $(INCLUDES_BUILDINFO)

###########################################################################
## DEFINES
###########################################################################

DEFINES_STANDARD = -DMODEL=qp_vars -DHAVESTDIO -DUSE_RTMODEL -DUNIX

DEFINES = $(DEFINES_STANDARD)

###########################################################################
## SOURCE FILES
###########################################################################

SRCS = $(START_DIR)/qp_vars_initialize.c $(START_DIR)/qp_vars_terminate.c $(START_DIR)/qp_vars.c $(START_DIR)/all.c $(START_DIR)/eye.c $(START_DIR)/kron.c $(START_DIR)/repmat.c $(START_DIR)/sum.c $(START_DIR)/kalman.c $(START_DIR)/inv.c $(START_DIR)/kalman_4d.c $(START_DIR)/rt_nonfinite.c $(START_DIR)/rtGetNaN.c $(START_DIR)/rtGetInf.c

###########################################################################
## OBJECTS
###########################################################################

OBJS = qp_vars_initialize.o qp_vars_terminate.o qp_vars.o all.o eye.o kron.o repmat.o sum.o kalman.o inv.o kalman_4d.o rt_nonfinite.o rtGetNaN.o rtGetInf.o

###########################################################################
## LIBRARIES
###########################################################################

LIBS = 

###########################################################################
## SYSTEM LIBRARIES
###########################################################################

SYSTEM_LIBS = -lm

###########################################################################
## ADDITIONAL TOOLCHAIN FLAGS
###########################################################################

#---------------
# C Compiler
#---------------

CFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CFLAGS += $(CFLAGS_BASIC)

#-----------------
# C++ Compiler
#-----------------

CPPFLAGS_BASIC = $(DEFINES) $(INCLUDES)

CPPFLAGS += $(CPPFLAGS_BASIC)

###########################################################################
## PHONY TARGETS
###########################################################################

.PHONY : all build clean info prebuild download execute


all : build
	@echo "### Successfully generated all binary outputs."


build : prebuild $(PRODUCT)


prebuild : 


download : build


execute : download


###########################################################################
## FINAL TARGET
###########################################################################

#---------------------------------
# Create a static library         
#---------------------------------

$(PRODUCT) : $(OBJS)
	@echo "### Creating static library "$(PRODUCT)" ..."
	$(AR) $(ARFLAGS)  $(PRODUCT) $(OBJS)
	@echo "### Created: $(PRODUCT)"


###########################################################################
## INTERMEDIATE TARGETS
###########################################################################

#---------------------
# SOURCE-TO-OBJECT
#---------------------

%.o : %.c
	@echo "### Compiling "$<" ..."
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : %.cpp
	@echo "### Compiling "$<" ..."
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.c
	@echo "### Compiling "$<" ..."
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(RELATIVE_PATH_TO_ANCHOR)/%.cpp
	@echo "### Compiling "$<" ..."
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/rtw/c/src/%.c
	@echo "### Compiling "$<" ..."
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(MATLAB_ROOT)/rtw/c/src/%.cpp
	@echo "### Compiling "$<" ..."
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.c
	@echo "### Compiling "$<" ..."
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : $(START_DIR)/%.cpp
	@echo "### Compiling "$<" ..."
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


%.o : /Users/petter/Dropbox/Research/Code/inv_set/codegen/%.c
	@echo "### Compiling "$<" ..."
	$(CC) $(CFLAGS) -o "$@" "$<"


%.o : /Users/petter/Dropbox/Research/Code/inv_set/codegen/%.cpp
	@echo "### Compiling "$<" ..."
	$(CPP) $(CPPFLAGS) -o "$@" "$<"


###########################################################################
## DEPENDENCIES
###########################################################################

$(OBJS) : $(MAKEFILE) rtw_proj.tmw $(TOOLCHAIN_MAKEFILE)


###########################################################################
## MISCELLANEOUS TARGETS
###########################################################################

info : 
	@echo "###  PRODUCT = $(PRODUCT)"
	@echo "###  PRODUCT_TYPE = $(PRODUCT_TYPE)"
	@echo "###  BUILD_TYPE = $(BUILD_TYPE)"
	@echo "###  INCLUDES = $(INCLUDES)"
	@echo "###  DEFINES = $(DEFINES)"
	@echo "###  SRCS = $(SRCS)"
	@echo "###  OBJS = $(OBJS)"
	@echo "###  LIBS = $(LIBS)"
	@echo "###  MODELREF_LIBS = $(MODELREF_LIBS)"
	@echo "###  SYSTEM_LIBS = $(SYSTEM_LIBS)"
	@echo "###  TOOLCHAIN_LIBS = $(TOOLCHAIN_LIBS)"
	@echo "###  CFLAGS = $(CFLAGS)"
	@echo "###  CPPFLAGS = $(CPPFLAGS)"
	@echo "###  ARFLAGS = $(ARFLAGS)"
	@echo "###  LDFLAGS = $(LDFLAGS)"
	@echo "###  SHAREDLIB_LDFLAGS = $(SHAREDLIB_LDFLAGS)"
	@echo "###  MEX_CFLAGS = $(MEX_CFLAGS)"
	@echo "###  MEX_LDFLAGS = $(MEX_LDFLAGS)"
	@echo "###  DOWNLOAD_FLAGS = $(DOWNLOAD_FLAGS)"
	@echo "###  EXECUTE_FLAGS = $(EXECUTE_FLAGS)"
	@echo "###  MAKE_FLAGS = $(MAKE_FLAGS)"


clean : 
	$(ECHO) "###  Deleting $(PRODUCT) and all derived files..."
	$(RM) $(PRODUCT) $(OBJS)
	$(RM) *$(OBJ_EXT)
	$(RM) *$(SHAREDLIB_EXT)
	$(RM) *$(STATICLIB_EXT)
	$(ECHO) "###  Deleted: $(PRODUCT), all derived files"


