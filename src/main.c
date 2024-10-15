#include <other.h>
#include <stdio.h>
#include <mul.h>
#include <divide.h>

int main()
{
    int a = 1;
    int b = 1;
    int c = add(a, b);
    int d = mul(a, b);
    int e = divide(a, b);
    printf("c: %d, d: %d\n", c, d);
    return 0;
}