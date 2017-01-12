#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#define MAX 10

int main (int argc, char *argv[])
{
    int i,
        size = argc > 1 ? atoi(argv[1]) : MAX;

    char bucket[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.,<>'/\\\"?;:!@#$%&*()-+[]^`=";
    char generated[size + 1];
    // Account for the ending nul character.
    int len = sizeof(bucket) - 1;

    srand(time(NULL));

    for (i = 0; i < size; i++) {
//        *(generated + i) = bucket[(0 + rand() % len)];
        generated[i] = bucket[(0 + rand() % len)];
    }

    generated[size] = '\0';
    puts(generated);

    return 0;
}

