#include <stdlib.h>
#include <stdio.h>

int factorial(int num) {
    int i = 1;
    int k = 1;

    while (i <= num) {
        k *= i++;
    }

    return k;
}

void main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s %s\n", argv[0], "<num>");
        exit(1);
    }

    printf("%d\n", factorial(atoi(argv[1])));
}

