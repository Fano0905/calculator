
#include <stdio.h>

int yyparse(void);

int main(void) {

    printf("CalcSet — set-only language\n");
    printf("Type commands like:\n");
    printf("  let A = {1,2}\n");
    printf("  let B = {2,3}\n");
    printf("  A + B\n");
    printf("  A x B\n");
    printf("  A == B\n");
    printf("  if (A != B) DO A + B ELSE A ^ B\n\n");
    yyparse();
    return 0;
    
}
