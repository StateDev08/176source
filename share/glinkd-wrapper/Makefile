CC = gcc
CFLAGS = -shared -fPIC -O2 -Wall

all: glinkd glinkd_init_patch.so

glinkd: glinkd-wrapper.sh
	cp -f glinkd-wrapper.sh glinkd
	chmod +x glinkd

glinkd_init_patch.so: init_patch.c
	$(CC) $(CFLAGS) -o $@ $<

clean:
	rm -f glinkd glinkd_init_patch.so
