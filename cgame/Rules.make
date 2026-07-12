# Determine project root relative to cgame/
PROJROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)

IOPATH=$(PROJROOT)/iolib
BASEPATH=$(PROJROOT)/cgame

INC=-I$(BASEPATH)/include -I$(BASEPATH) -I$(BASEPATH)/gs -I$(BASEPATH)/gs/template -I$(BASEPATH)/gs/instance -I$(IOPATH)/inc -I$(BASEPATH)/libcm -I$(PROJROOT)/cnet/io -I$(PROJROOT)/share/lua/src -I$(PROJROOT)/share/lua/LuaBridge -I$(PROJROOT)/share/lua/LuaBridge/detail -I$(PROJROOT)/cnet/licenseclient/vm -I/usr/include/mysql -I/usr/include/mysql++
IOLIB_OBJ=$(wildcard $(BASEPATH)/libgs/gs/*.o $(BASEPATH)/libgs/io/*.o $(BASEPATH)/libgs/db/*.o $(BASEPATH)/libgs/sk/*.o $(BASEPATH)/libgs/log/*.o $(BASEPATH)/libgs/common/*.o)
CMLIB=$(BASEPATH)/libcm.a $(wildcard $(BASEPATH)/libonline.a) $(IOLIB_OBJ) $(wildcard $(BASEPATH)/collision/libTrace.a) $(wildcard $(BASEPATH)/liblua.a)
DEF = -DLINUX -D_DEBUG  -D__THREAD_SPIN_LOCK__ -DUSE_LOGCLIENT -D_DEFAULT_SOURCE
DEF += -D__USER__=\"$(USER)\"

THREAD = -D_REENTRANT -D_THREAD_SAFE -D_PTHREADS
THREADLIB = -lpthread
PCRELIB = -lpcre
ALLLIB = $(THREADLIB) $(PCRELIB) -lssl -lcrypto -lstdc++ -ldl -lcurl -ljsoncpp -lmysqlpp -lmysqlclient -lz -lm

CSTD = -std=c18
STD = -w -std=c++20
OPTIMIZE = -O0 -g -ggdb
CC=gcc $(CSTD) $(DEF) $(THREAD) $(OPTIMIZE)
CPP=g++ $(STD) $(DEF) $(THREAD) $(OPTIMIZE) 
LD=g++ $(STD) -L/usr/local/ssl/lib $(OPTIMIZE) $(THREADLIB) 
AR=ar crs 
ARX=ar x

ifneq ($(wildcard .depend),)
include .depend
endif

ifeq ($(TERM),cygwin)
THREADLIB = -lpthread
CMLIB += /usr/lib/libgmon.a
DEF += -D__CYGWIN__
endif

dep:
	$(CC) -MM $(INC)  -c *.c* > .depend
