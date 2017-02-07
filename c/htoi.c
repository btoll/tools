#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define HEX_UPPER(N) ((N) >= 'A' && (N) <= 'F')
#define HEX_LOWER(N) ((N) >= 'a' && (N) <= 'f')
#define HEX_DIGIT(N) ((N) >= '0' && (N) <= '9')

// echo "ibase=16; 7F" | bc

// The groupings aren't strictly necessary when assigning to `n`, I'm only doing it for readability and understanding.
unsigned long htoi(char *s) {
    unsigned long n = 0;
    int i;

    for (i = 0; i < strlen(s); i++) {
        if (HEX_DIGIT(s[i]))
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

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <hexadecimal string>\n", argv[0]);
        exit(1);
    }

    char *s = argv[1];

    if (s[0] == '0' && (s[1] == 'x' || s[1] == 'X'))
        s += 2;

    printf("%lu\n", htoi(s));

    return 0;
}

