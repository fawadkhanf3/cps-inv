###########################################################################
## File : qp_vars_rtw_tools.mk
## 
## Makefile generated for MATLAB file/project 'qp_vars'. 
## 
## Makefile Info:
## 
## Toolchain Name:          Clang v3.1 | gmake (64-bit Mac)
## Supported Version(s):    3.1
## ToolchainInfo Version:   R2013a
## Specification Revision:  1.0
## 
## MATLAB Coder version: 2.4 (R2013a)
## 
###########################################################################




#-----------
# MACROS
#-----------

ANSI_OPTS     = -fno-common -fexceptions
CPP_ANSI_OPTS = -fno-common -fexceptions
ARCHS         = x86_64

TOOLCHAIN_SRCS = 
TOOLCHAIN_INCS = 
TOOLCHAIN_LIBS = 

#------------------------
# BUILD TOOL COMMANDS
#------------------------

# C Compiler: Clang C Compiler
CC = xcrun clang

# C++ Compiler: Clang C++ Compiler
CPP = xcrun clang++

# Archiver: Clang Archiver
AR = ar

# Linker: Clang Linker
LD = xcrun clang

# MEX Tool: MEX Tool
MEX_PATH = $(MATLAB_BIN)
MEX = $(MEX_PATH)/mex

# Download: Download
DOWNLOAD =

# Execute: Execute
EXECUTE = $(PRODUCT)

# Builder Application: GMAKE Utility
MAKE_PATH = %MATLAB%/bin/maci64
MAKE = $(MAKE_PATH)/gmake


#-------------------------
# Directives/Utilities
#-------------------------

CDEBUG              = -g
C_OUTPUT_FLAG       = -o
CPPDEBUG            = -g
CPP_OUTPUT_FLAG     = -o
ARDEBUG             =
STATICLIB_OUTPUT_FLAG =
LDDEBUG             = -g
OUTPUT_FLAG         = -o
MEX_DEBUG           = -g
RM                  = @rm -f
ECHO                = @echo
MV                  = @mv
RUN                 = @cmd /C

#----------------------------------------
# "Faster Builds" Build Configuration
#----------------------------------------

ARFLAGS              = ruvs
CFLAGS               = -c -arch $(ARCHS) $(ANSI_OPTS) \
                       -O0
CPPFLAGS             = -c -arch $(ARCHS) $(CPP_ANSI_OPTS) \
                       -O0
DOWNLOAD_FLAGS       =
EXECUTE_FLAGS        =
LDFLAGS              = -arch $(ARCHS) -L"$(MATLAB_ARCH_BIN)"
MEX_CFLAGS           = -MATLAB_ARCH=$(ARCH) $(INCLUDES) \
                         \
                       COPTIMFLAGS="$(ANSI_OPTS)  \
                       -O0 \
                        $(DEFINES)" \
                         \
                       -silent
MEX_LDFLAGS          = LDFLAGS=='$$LDFLAGS'
MAKE_FLAGS           = -f $(MAKEFILE)
SHAREDLIB_LDFLAGS    = -dynamiclib -L"$(MATLAB_ARCH_BIN)" \
                       -Wl,$(LD_NAMESPACE) $(LD_UNDEFS)

#--------------------
# File extensions
#--------------------

H_EXT               = .h
OBJ_EXT             = .o
C_EXT               = .c
HPP_EXT             = .hpp
OBJ_EXT             = .o
CPP_EXT             = .cpp
STATICLIB_EXT       = .a
EXE_EXT             =
SHAREDLIB_EXT       = .so
MEX_EXT             = .mexmaci64
MAKE_EXT            = .mk

