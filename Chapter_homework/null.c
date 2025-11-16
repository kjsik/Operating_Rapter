#include <stdio.h>

int main(void) {
    int *p = NULL;
    printf("About to dereference NULL...\n");
    *p = 42;                  // 여기서 크래시(세그폴트)가 납니다.
    printf("Should not reach here: %d\n", *p);
    return 0;
}


