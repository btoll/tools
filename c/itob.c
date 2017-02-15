#include <stdio.h>
#include <stdlib.h>

void reverse(char *s) {
    int c, i, j;

    // Let's pretend there's no strlen function.
    for (j = 0; s[j] != '\0'; j++)
        ;

    for (i = 0, j--; i < j; i++, j--)
        c = s[i], s[i] = s[j], s[j] = c;
}

void itob(int n, char *s, int b) {
    int i = 0, k;

    do {
        s[i++] = (k = n % b) > 9 ?
            k - 10 + 'a' :
            k + '0';
    } while (n /= b);

    s[i] = '\0';
    reverse(s);
}

int main(int argc, char **argv) {
    if (argc < 3) {
        printf("Usage: %s <int> <base>\n", argv[0]);
        exit(1);
    }

    int n = atoi(argv[1]);
    int b;
    char buf[255];

    if ((b = atoi(argv[2])) > 20) {
        printf("Base cannot be more than 20.\n");
        exit(1);
    }

    itob(n, buf, b);
    printf("Number %d, Base %d => %s\n", n, b, buf);

    return 0;
}

