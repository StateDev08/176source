
TOP_SRCDIR = ..

SINGLE_THREAD = false
DEBUG_VERSION = false

include ../mk/gcc.defs.mk

DEFINES += -O0

LIBOBJS = pollio.o protocol.o security.o rpc.o proxyrpc.o base64.o utf.o \
          beaktrace.o crypt.o luabase.o coordinate.o

all: lib

lib: $(LIBOBJS)
	rm -f ./libgsio.a
	$(AR) crs ./libgsio.a $(LIBOBJS)

clean:
	rm -f $(LIBOBJS) libgsio.a

include ../mk/gcc.rules.mk
