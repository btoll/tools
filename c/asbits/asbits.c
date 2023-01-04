#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "asbits.h"

// echo "ibase=16; 7F" | bc
// echo "ibase=8; 0177" | bc

unsigned long htoi(char *s) {
    unsigned long n = 0;
    int i;

    for (i = 0; i < strlen(s); i++) {
        if (IS_DIGIT(s[i]))
            n = (n * 16) + (s[i] - '0');

        else if (HEX_UPPER(s[i]))
            n = (n * 16) + (10 + s[i] - 'A');

        else if (HEX_LOWER(s[i]))
            n = (n * 16) + (10 + s[i] - 'a');

        else {
            printf("[ERROR] Non-hexadecimal character %c\n", s[i]);
            exit(1);
        }
    }

    return n;
}

unsigned long otoi(char *s) {
    unsigned long n = 0;
    int i;

    for (i = 0; s[i] >= '0' && s[i] <= '7'; i++)
        n = (n * 8) + (s[i] - '0');

    return n;
}

/*
 * Start at the first bit and move out.
 * For each shift, only the bit in the first position is considered.
 *
 * For example:
 *
 *      asbits 203 2
 *
 *          (valueToConvert >> numBitsToRightShift) & 1
 *
 *              203 >> 7 == 1              1 & 1
 *              203 >> 6 == 3             11 & 1
 *              203 >> 5 == 6            110 & 1
 *              203 >> 4 == 12          1100 & 1
 *              203 >> 3 == 25         11001 & 1
 *              203 >> 2 == 50        110010 & 1
 *              203 >> 1 == 101      1100101 & 1
 *              203 >> 0 == 203     11001011 & 1
 *
 *      returns => 1100 1011
 *
 */
void asbits(short numDisplayBytes) {
    int numBitsToRightShift = numDisplayBytes * sizeof(unsigned) - 1;

    for (; numBitsToRightShift >= 0; --numBitsToRightShift) {
        (valueToConvert >> numBitsToRightShift) & 1
            ? putchar('1')
            : putchar('0');

        if (numBitsToRightShift % 4 == 0)
            putchar(' ');
    }

    putchar('\n');
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <base-10 | hex | octal> [num nibbles=4]\n", argv[0]);
        exit(1);
    }

    char *s = argv[1];

    // Hex.
    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X')) {
        s += 2;
        valueToConvert = htoi(s);
    // Octal.
    } else if (s[0] == '0' && IS_OCTAL_DIGIT(s[1])) {
        valueToConvert = otoi(s++);
    // Base-10.
    } else {
        valueToConvert = atoi(argv[1]);
    }

    int numDisplayBytes = !argv[2] ? 4 : atoi(argv[2]);

    if (numDisplayBytes > 8) {
        numDisplayBytes = 8;
        printf("Max number of display nibbles is 8\n");
    }

    asbits(numDisplayBytes);

    return 0;
}

