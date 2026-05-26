
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -DUSE_LOGCLIENT -O0
INCLUDES += -I../storage -I../include

OBJS = adapterinfo.o asmcodelibrary.o cheater.o codepiece.o codepiecelibrary.o \
       codeprovider.o codesender.o configmanager.o cpuinfo.o debugcode.o \
       debugcodelibrary.o debugitem.o forbidcode.o forbiditem.o forbidlibrary.o \
       gaccontrolserver.o gacd.o ganticheaterserver.o logmanager.o meminfo.o \
       mempatterncode.o mempatternitem.o mempatternlibrary.o mouseinfo.o \
       patternmanager.o platform.o preparedcode.o preparedcodefragment.o \
       preparedcodelibrary.o protostat.o punisher.o punishmanager.o queryproxy.o \
       reportinfo.o stackpattern.o strinfo.o stringcache.o stringhelper.o \
       threadtime.o timermanager.o usercodemanager.o userdata.o userdatamanager.o \
       usersessiondata.o xmlconfig.o state.o stubs.o

all: gacd

gacd: $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB)
	$(LD) $(LDFLAGS) -rdynamic -o $@ $(OBJS) $(SHAREOBJ) $(LOGOBJ) $(LOGSTUB) $(SHARE_SOBJ) $(LICENSE_SOBJ) -lxml2 -lpthread -ldl

clean:
	rm -f $(OBJS) gacd

include ../mk/gcc.rules.mk
