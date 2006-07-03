#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#  Copyright (C) 2003 - The Authors
#
#  Author : Richard GAYRAUD - 04 Nov 2003
#           From Hewlett Packard Company.
#

# Output binary to be built
OUTPUT=sipp

# C & C++ object files to be built
OBJ= xp_parser.o scenario.o screen.o call.o comp.o sipp.o stat.o \
     actions.o variables.o

# Libraries directories
LIBDIR_linux=
LIBDIR_FreeBSD=
LIBDIR_hpux=
LIBDIR_tru64=
LIBDIR_SunOS=
LIBDIR_Cygwin=

# Archive file created in your home directory when building the archive target
# ARCHIVE= $(HOME)/$(OUTPUT).tgz
ARCHIVE= $(OUTPUT).tgz

# Files to be erased by 'make clean' in addition to the output 
# binaries and object files:
TOCLEAN= *.log $(ARCHIVE) \
         *.csv *.exe

###################################################################
# Generic Rules

#OSNAME=`uname`
#MODELNAME=`uname -m`

# SYSTEM nickname
SYSTEM_HP-UX=hpux
SYSTEM_Linux=linux
SYSTEM_FreeBSD=freebsd
SYSTEM_OSF1=tru64
SYSTEM_SunOS=SunOS
SYSTEM_CYGWIN=Cygwin
SYSTEM=$(SYSTEM_$(OSNAME))

# C compiler
CC_hpux=aCC
CC_linux=cc  
CC_freebsd=cc  
CC_tru64=cc  
CC_SunOS=gcc
CC_Cygwin=cc  
CC=$(CC_$(SYSTEM))

# C++ compiler mapping
CPP_hpux=aCC  
CPP_linux=gcc  
CPP_freebsd=g++  
CPP_tru64=cxx  
CPP_SunOS=g++
CPP_Cygwin=g++  
CPP=$(CPP_$(SYSTEM))

#Model specific flags
MFLAGS_ia64=+DD64
MFLAGS_9000/800=+DAportable
MFLAGS_9000/785=+DAportable
MFLAGS_i686=
MFLAGS_i586=
MFLAGS_i486=
MFLAGS_i386=
MFLAGS=$(MFLAGS_$(MODELNAME))

#C Compiler Flags
# supress warning #829 (Implicit conversion of string literal to
#'char *' is deprecated) since this is both common and harmless
CFLAGS_hpux=-D__HPUX -DPROTOTYPES +W829
CFLAGS_linux=-D__LINUX -pthread
CFLAGS_freebsd=-D__LINUX -pthread
CFLAGS_tru64=-D__OSF1 -pthread
CFLAGS_SunOS=-g
CFLAGS_Cygwin=-D__CYGWIN -Dsocklen_t=int
CFLAGS=$(CFLAGS_$(SYSTEM)) -D__3PCC__ $(TLS) $(PCAPPLAY)

#C++ Compiler Flags
CPPFLAGS_hpux=-AA -mt -D__HPUX +W829 
CPPFLAGS_linux=-D__LINUX -pthread
CPPFLAGS_freebsd=-D__LINUX -pthread
CPPFLAGS_tru64=-D__OSF1 -pthread
CPPFLAGS_SunOS=-g
CPPFLAGS_Cygwin=-D__CYGWIN -Dsocklen_t=int
CPPFLAGS=$(CPPFLAGS_$(SYSTEM)) -D__3PCC__ $(TLS) $(PCAPPLAY)

#Linker mapping
CCLINK_hpux=aCC
CCLINK_linux=gcc
CCLINK_freebsd=g++
CCLINK_tru64=cxx
CCLINK_SunOS=gcc
CCLINK_Cygwin=g++
CCLINK=$(CCLINK_$(SYSTEM))

#Linker Flags
LFLAGS_hpux=-AA -mt
LFLAGS_linux=
LFLAGS_freebsd=
LFLAGS_tru64=
LFLAGS_SunOS=
LFLAGS_Cygwin=
LFLAGS=$(LFLAGS_$(SYSTEM))

#Link Libraries
LIBS_linux= -ldl -lpthread -lncurses -lstdc++ -lm -L /usr/local/lib -L /usr/lib -L /usr/lib64
LIBS_hpux= -lcurses -lpthread -L /opt/openssl/lib -L /usr/local/lib
LIBS_tru64= -lcurses -lpthread
LIBS_freebsd= -lcurses -pthread
LIBS_SunOS= -lcurses -lpthread -lnsl -lsocket -lstdc++ -lm -ldl -L /usr/local/ssl/lib/
LIBS_Cygwin= -lcurses -lpthread -lstdc++ 
LIBS=$(LIBS_$(SYSTEM))

# Include directories
INCDIR_linux=-I. -I/opt/openssl/include
INCDIR_freebsd=-I. -I/opt/openssl/include
INCDIR_hpux=-I. -I/usr/local/include -I/opt/openssl/include
INCDIR_tru64=-I. -I/opt/openssl/include
INCDIR_SunOS=-I. -I/usr/local/ssl/include/
INCDIR_Cygwin=-I. -I/usr/include/openssl -I/usr/include
INCDIR=$(INCDIR_$(SYSTEM)) 

# Building without TLS and authentication (no openssl pre-requisite)
all:
	make OSNAME=`uname|sed -e "s/CYGWIN.*/CYGWIN/"` MODELNAME=`uname -m` $(OUTPUT)

# Building with TLS and authentication
ossl:
	make OSNAME=`uname|sed -e "s/CYGWIN.*/CYGWIN/"` MODELNAME=`uname -m` OBJ_TLS="auth.o sslinit.o sslthreadsafe.o" TLS_LIBS="-lssl -lcrypto" TLS="-D_USE_OPENSSL -DOPENSSL_NO_KRB5" $(OUTPUT)

#Building with PCAP play
pcapplay:
	make OSNAME=`uname|sed -e "s/CYGWIN.*/CYGWIN/"` MODELNAME=`uname -m` OBJ_PCAPPLAY="send_packets.o prepare_pcap.o" PCAPPLAY_LIBS="-lpcap" PCAPPLAY="-DPCAPPLAY" $(OUTPUT)

pcapplay_ossl:
	make OSNAME=`uname|sed -e "s/CYGWIN.*/CYGWIN/"` MODELNAME=`uname -m` OBJ_TLS="auth.o sslinit.o sslthreadsafe.o" TLS_LIBS="-lssl -lcrypto" TLS="-D_USE_OPENSSL -DOPENSSL_NO_KRB5"  OBJ_PCAPPLAY="send_packets.o prepare_pcap.o" PCAPPLAY_LIBS="-lpcap" PCAPPLAY="-DPCAPPLAY" $(OUTPUT)

$(OUTPUT): $(OBJ_TLS) $(OBJ_PCAPPLAY) $(OBJ)
	$(CCLINK) $(LFLAGS) $(MFLAGS) $(LIBDIR_$(SYSTEM)) \
	$(DEBUG_FLAGS) -o $@ $(OBJ_TLS) $(OBJ_PCAPPLAY) $(OBJ) $(LIBS) $(TLS_LIBS) $(PCAPPLAY_LIBS)

debug:
	DEBUG_FLAGS="-g -pg" ; export DEBUG_FLAGS ; make all

debug_tls:
	@DEBUG_FLAGS=-g ; export DEBUG_FLAGS ; make tls

clean:
	rm -f *.o $(OUTPUT) *~ $(TOCLEAN) 
	rm -rf cxx_repository

archive:
	rm -f TMP_TAR_FILE.* $(ARCHIVE)
	make clean
	tar cf TMP_TAR_FILE.tar .
	gzip TMP_TAR_FILE.tar
	cp TMP_TAR_FILE.tar.gz $(ARCHIVE)
	rm -f TMP_TAR_FILE.*


# Files types rules
.SUFFIXES: .o .cpp .c .h .hpp

*.o: *.h *.hpp

.C.o:
	$(CPP) $(CPPFLAGS) $(MFLAGS) $(DEBUG_FLAGS) $(INCDIR) -c -o $*.o $<

.cpp.o:
	$(CPP) $(CPPFLAGS) $(MFLAGS) $(DEBUG_FLAGS) $(INCDIR) -c -o $*.o $<

.c.o:
	$(CC) $(CFLAGS) $(MFLAGS) $(DEBUG_FLAGS) $(INCDIR) -c -o $*.o $<
