#include <stdio.h>
#include <stdlib.h>

// gcc -o phi eulers_totient_function.c

int phi(int n) {
	int res = n;

//	for (int p = 2; p <= sqrt(n); ++p) {
	for (int p = 2; p * p <= n; ++p) {
		if (n % p == 0) {
			while (n % p == 0)
				n /= p;

//            res *= (1.0 - (1.0 / (float) p));
			res -= res / p;
		}
	}

	if (n > 1)
//        res *= (1.0 - (1.0 / (float) n));
		res -= res / n;

	return res;
}

void main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s [n]\n", argv[0]);
        exit(1);
    }

    int n = atoi(argv[1]);
    printf("phi(%d) = %d\n", n, phi(n));
}

