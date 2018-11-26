#define HEX_UPPER(N) ((N) >= 'A' && (N) <= 'F')
#define HEX_LOWER(N) ((N) >= 'a' && (N) <= 'f')
#define IS_DIGIT(N) ((N) >= '0' && (N) <= '9')
#define IS_OCTAL_DIGIT(N) ((N) >= '0' && (N) <= '7')

unsigned valueToConvert;

void asbits(short numDisplayBytes);
unsigned long htoi(char *s);
unsigned long otoi(char *s);

