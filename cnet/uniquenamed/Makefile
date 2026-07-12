
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -DUSE_LOGCLIENT -O0
INCLUDES += -I../storage -I../include

OBJS = accessdb.o uniquenamed.o uniquenameserver.o storage.o storagetool.o state.o stubs.o

all: uniquenamed

uniquenamed: $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	$(LD) $(LDFLAGS) -rdynamic -o $@ $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB) $(SHARE_SOBJ) $(LICENSE_SOBJ) -lxml2 -lpthread -ldl

storage.o: ../storage/storage.cpp
	$(CC) -c $(DEFINES) $(INCLUDES) $(CFLAGS) $< -o $@

storagetool.o: ../storage/storagetool.cpp
	$(CC) -c $(DEFINES) $(INCLUDES) $(CFLAGS) $< -o $@

clean:
	rm -f $(OBJS) uniquenamed

include ../mk/gcc.rules.mk
