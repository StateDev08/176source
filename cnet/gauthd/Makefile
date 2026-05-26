
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -DUSE_LOGCLIENT -O0
INCLUDES += -I/usr/include/mysql -I../storage -I../include

OBJS = authmanager.o gauthd.o gauthserver.o gmysqlclient.o gpanelserver.o luaman.o \
       state.o stubs.o

all: gauthd

gauthd: $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	$(LD) $(LDFLAGS) -rdynamic -o $@ $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB) $(SHARE_SOBJ) $(LICENSE_SOBJ) -lxml2 -lpthread -ldl -lmysqlclient

clean:
	rm -f $(OBJS) gauthd

include ../mk/gcc.rules.mk
