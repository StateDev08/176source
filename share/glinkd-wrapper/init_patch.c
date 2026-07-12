#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <sys/syscall.h>

static unsigned long find_glinkd_base(void) {
    int fd = syscall(SYS_open, "/proc/self/maps", O_RDONLY, 0);
    if (fd < 0) return 0;

    char buf[8192];
    size_t total = 0;
    ssize_t n;
    while (total < sizeof(buf) - 1 && (n = syscall(SYS_read, fd, buf + total, sizeof(buf) - 1 - total)) > 0) {
        total += (size_t)n;
    }
    syscall(SYS_close, fd);
    buf[total] = '\0';

    char *line = buf;
    while (line && *line) {
        char *end = strchr(line, '\n');
        if (end) *end = '\0';

        unsigned long start = 0, finish = 0, off = 0;
        char perm[8] = {0};
        char path[256] = {0};
        if (sscanf(line, "%lx-%lx %7s %lx %*s %*s %255s", &start, &finish, perm, &off, path) >= 4) {
            if (strchr(perm, 'x') && path[0] != '\0' && strstr(path, "glinkd")) {
                return start - off;
            }
        }
        if (!end) break;
        line = end + 1;
    }
    return 0;
}

__attribute__((constructor))
static void init_glinkd_patch(void) {
    unsigned long base = find_glinkd_base();
    if (!base) return;

    unsigned long init_addr = base + 0x16ff40;
    unsigned long lic_ptr_addr = base + 0x946268;
    unsigned long success_addr = base + 0x946270;
    unsigned long flag_addr = base + 0x946220;

    void *lic = calloc(1, 0x220);
    if (!lic) return;

    *(void **)lic_ptr_addr = lic;
    *(int *)success_addr = 0;
    *(char *)flag_addr = 1;
    *(int *)(base + 0x946274) = 0;

    unsigned long page = init_addr & ~0xfffUL;
    size_t len = 4096;
    if (init_addr + 6 > page + len) len = 8192;
    syscall(SYS_mprotect, page, len, PROT_READ | PROT_WRITE | PROT_EXEC);

    unsigned char *p = (unsigned char *)init_addr;
    p[0] = 0xb8;
    p[1] = 0x01;
    p[2] = 0x00;
    p[3] = 0x00;
    p[4] = 0x00;
    p[5] = 0xc3;
}
