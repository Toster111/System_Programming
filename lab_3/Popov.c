#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {

    int a = atol(argv[1]);
    int b = atol(argv[2]);
    int c = atol(argv[3]);

    int result = (((b / c) * b) + b);

    printf("%d\n", result);
    return 0;
}
