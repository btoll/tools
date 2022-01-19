#include <stdio.h>

#define LEN_YK 45
#define LEN_ID 13
#define LEN_OTP 33

struct YK {
    char key[LEN_YK];
    char id[LEN_ID];
    char otp[LEN_OTP];
};

void get_yk(struct YK *yk) {
    int i;

    printf("Touch YubiKey: ");
    scanf("%s", yk->key);

    for (i = 0; i < LEN_ID - 1; i++) {  // Subtract 1 to not include null char.
        yk->id[i] = yk->key[i];
    }
    yk->id[i] = '\0';

    int j;
    for (j = 0; yk->key[i] != '\0';) {
        yk->otp[j++] = yk->key[i++];
    }
    yk->otp[j] = '\0';
}

int main() {
    struct YK yk;
    get_yk(&yk);

    printf("\nYubiKey encoded string %s\n", yk.key);
    printf("YubiKey id %s\n", yk.id);
    printf("YubiKey OTP private id %s\n", yk.otp);

    return 0;
}

