# Lua 5.4.4 build for 176source

CC = gcc
CFLAGS = -O2 -Wall -DLUA_COMPAT_5_3 -DLUA_USE_LINUX

# Core library objects (exclude lua.o and luac.o which have main())
CORE_OBJS = lapi.o lcode.o lctype.o ldebug.o ldo.o ldump.o lfunc.o lgc.o \
            llex.o lmem.o lobject.o lopcodes.o lparser.o lstate.o lstring.o \
            lstrlib.o ltable.o ltm.o lundump.o lvm.o lzio.o

LIB_OBJS = lauxlib.o lbaselib.o lcorolib.o ldblib.o liolib.o lmathlib.o \
           loadlib.o loslib.o ltablib.o lutf8lib.o linit.o lfs.o

all: liblua.a

liblua.a: $(CORE_OBJS) $(LIB_OBJS)
	$(AR) rcs $@ $(CORE_OBJS) $(LIB_OBJS)

.c.o:
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(CORE_OBJS) $(LIB_OBJS) liblua.a
