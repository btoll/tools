#include <stdlib.h>
#include <stdio.h>

// gcc -o priv_key priv_key.c
// This finds the modulus multiplicative inverse.

int main(int argc, char **argv) {
    if (argc < 3) {
        printf("Finds the modulus multiplicative inverse:\n\n");
        printf("\tde = 1 mod n\n\n");
        printf("Defaults to searching the entire key length `n`.\n");
        printf("Usage: %s <e> <mod> <bound>\n", argv[0]);
        exit(1);
    }

    int e = atoi(argv[1]);
    int mod = atoi(argv[2]);
    int bound = argv[3] ? atoi(argv[3]) : mod;
    int found = 0;

    for (int i = 1; i <= bound; i++) {
        if (e*i%mod == 1) {
            printf("%d ", i);
            found = 1;
        }
    }

    found ?
        printf("\n") :
        printf("No results found.\n");

    return 0;
}

