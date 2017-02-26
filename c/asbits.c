#include <stdio.h>
#include <stdlib.h>

unsigned getbits(unsigned x, int offset, int n) {
    return x >> (offset + 1 - n) & ~(~0 << n);
}

void asbits(unsigned n, short b) {
    int i;

    for (i = b * sizeof(n) - 1; i >= 0; i--) {
        getbits(n, i, 1) ? putchar('1') : putchar('0');

        if (i % 4 == 0)
            putchar(' ');
    }

    putchar('\n');
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <hex or chars> [num bytes=4]\n", argv[0]);
        exit(1);
    }

    int b = !argv[2] ? 4 : atoi(argv[2]);

    if (b > 8) {
        b = 8;
        printf("Max number of display bytes is 8\n");
    }

    asbits(atoi(argv[1]), b);

    return 0;
}

