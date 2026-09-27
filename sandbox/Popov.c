#include <stdio.h>
int main() {
    unsigned long n = 5277616985UL;
    unsigned long sum = 0;
    while (n > 0) { sum += n % 10; n /= 10; }
    printf("%lu\n", sum);
    return 0;
}
