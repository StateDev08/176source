
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -DUSE_LOGCLIENT -O0
INCLUDES += -I../storage -I../include

OBJS = db_if.o dbclient.o gamedbclient.o gdbclient.o state.o stubs.o

LIBOBJS = db_if.o gamedbclient.o state.o stubs.o

all: gdbclient

gdbclient: $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	$(LD) $(LDFLAGS) -rdynamic -o $@ $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB) $(SHARE_SOBJ) $(LICENSE_SOBJ) -lxml2 -lpthread -ldl

lib: $(LIBOBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	rm -f ./libdbCli.a
	$(AR) crs ./libdbCli.a $(LIBOBJS)

clean:
	rm -f $(OBJS) gdbclient libdbCli.a

include ../mk/gcc.rules.mk
