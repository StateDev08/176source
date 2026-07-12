
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -DUSE_LOGCLIENT -O0
INCLUDES += -I../storage -I../include -I../gdbclient \
            -I$(TOP_SRCDIR)/common \
            -I$(TOP_SRCDIR)/../cgame \
            -I$(TOP_SRCDIR)/../cgame/gs \
            -I$(TOP_SRCDIR)/../cgame/include \
            -I$(TOP_SRCDIR)/../cgame/libcm

OBJS = auctionsyslib.o factionlib.o gamed.o gmattr.o gproviderclient.o gsp_if.o \
       kingelectionsyslib.o mailsyslib.o pshopsyslib.o sellpointlib.o stocklib.o \
       sysauctionlib.o webtradesyslib.o state.o stubs.o

LIBOBJS = auctionsyslib.o factionlib.o gmattr.o gproviderclient.o gsp_if.o \
          kingelectionsyslib.o mailsyslib.o pshopsyslib.o sellpointlib.o stocklib.o \
          sysauctionlib.o webtradesyslib.o state.o stubs.o

all: gamed

gamed: $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	$(LD) $(LDFLAGS) -rdynamic -o $@ $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB) $(SHARE_SOBJ) $(LICENSE_SOBJ) -lxml2 -lpthread -ldl

lib: $(LIBOBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	rm -f ./libgsPro2.a
	$(AR) crs ./libgsPro2.a $(LIBOBJS)

clean:
	rm -f $(OBJS) gamed libgsPro2.a

include ../mk/gcc.rules.mk
