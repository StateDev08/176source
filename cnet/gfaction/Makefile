
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -DUSE_LOGCLIENT -O0
INCLUDES += -I../storage -I../include

OBJS = factiondb.o gfaction.o gfactiondbclient.o gfactionserver.o gfs_io.o \
       gproviderserver.o luaman.o settings.o uniquenameclient.o state.o stubs.o

all: gfactiond

gfactiond: $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	$(LD) $(LDFLAGS) -rdynamic -o $@ $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB) $(SHARE_SOBJ) $(LICENSE_SOBJ) -lxml2 -lpthread -ldl

clean:
	rm -f $(OBJS) gfactiond

include ../mk/gcc.rules.mk
