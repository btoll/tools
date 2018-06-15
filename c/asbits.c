#include <stdio.h>
#include <stdlib.h>

unsigned valueToConvert;

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
    int numBitsToRightShift = numDisplayBytes * sizeof(valueToConvert) - 1;

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
        printf("Usage: %s <hex or chars> [num bytes=4]\n", argv[0]);
        exit(1);
    }

    int numDisplayBytes = !argv[2] ? 4 : atoi(argv[2]);

    if (numDisplayBytes > 8) {
        numDisplayBytes = 8;
        printf("Max number of display bytes is 8\n");
    }

    valueToConvert = atoi(argv[1]);
    asbits(numDisplayBytes);

    return 0;
}

