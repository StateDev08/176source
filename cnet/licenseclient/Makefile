# Build LicenseCli.a from source (replaces missing pre-compiled library)

CC = gcc
CPP = g++ -w -std=gnu++20 -fpermissive
AR = ar

CFLAGS = -O0 -g -I. -Ivm -pthread
OBJS = liblicense.o base64.o buffer.o crypt.o protocol.o md5.o

all: vm/LicenseCli.a

vm/LicenseCli.a: $(OBJS)
	$(AR) rcs $@ $(OBJS)

liblicense.o: liblicense.cpp
	$(CPP) $(CFLAGS) -c $< -o $@

base64.o: base64.cpp
	$(CPP) $(CFLAGS) -c $< -o $@

buffer.o: buffer.cpp
	$(CPP) $(CFLAGS) -c $< -o $@

crypt.o: crypt.cpp
	$(CPP) $(CFLAGS) -c $< -o $@

protocol.o: protocol.cpp
	$(CPP) $(CFLAGS) -c $< -o $@

md5.o: md5.c
	$(CPP) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(OBJS) vm/LicenseCli.a
