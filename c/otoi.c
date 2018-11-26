#include <stdio.h>
#include <stdlib.h>

// echo "ibase=8; 0177" | bc

// The groupings aren't strictly necessary when assigning to `n`, I'm only doing it for readability and understanding.
unsigned long otoi(char *s) {
    unsigned long n = 0;
    int i;

    if (s[0] == '0')
        s++;

    for (i = 0; s[i] >= '0' && s[i] <= '7'; i++)
        n = (n * 8) + (s[i] - '0');

    return n;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s <octal string>\n", argv[0]);
        exit(1);
    }

    char *s = argv[1];

    printf("%lu\n", otoi(s));

    return 0;
}

