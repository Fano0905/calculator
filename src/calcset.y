
%code requires {
  #include "set.h"
}

%union {
    Set *set;
    char *id;
    int val;
}

%{
#include "set.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

/* Variable table: only sets */
typedef struct {
    char name[64];
    int defined;
    Set set;
} Var;

Var vars[200];
int var_count = 0;

int get_var_index(const char *name);
void set_var_set(const char *name, const Set *s);
Set *set_copy(const Set *s);
Set *set_union(const Set *a, const Set *b);
Set *set_difference(const Set *a, const Set *b);
Set *set_intersection(const Set *a, const Set *b);
int set_equal(const Set *a, const Set *b);
void print_set(const Set *s);
void print_product(const Set *a, const Set *b);

%}

%token <id> ID
%token <val> NUMBER
%token LET IF DO ELSE
%token EQ NEQ

%type <set> set set_elements set_op

%left UNION
%left DIFF
%left INTER
%left PROD


%%

input:
    | input line
    ;
line:
    | LET ID '=' set '\n'         
        { set_var_set($2, $4); printf("Defined %s\n", $2); free($2); free($4); }
    | set_op '\n'                 
        { print_set($1); printf("\n"); free($1); }
    | prod_line '\n' 
      | ID EQ ID '\n'               
        { int i1 = get_var_index($1), i2 = get_var_index($3);
          if (i1 == -1 || i2 == -1) fprintf(stderr, "Undefined variable in equality test\n");
          else printf(set_equal(&vars[i1].set, &vars[i2].set) ? "true\n" : "false\n");
          free($1); free($3);
        }
  | ID NEQ ID '\n'              
        { int i1 = get_var_index($1), i2 = get_var_index($3);
          if (i1 == -1 || i2 == -1) fprintf(stderr, "Undefined variable in inequality test\n");
          else printf(set_equal(&vars[i1].set, &vars[i2].set) ? "false\n" : "true\n");
          free($1); free($3);
        }
  | IF '(' ID EQ ID ')' DO op ELSE op '\n'    
        {
          int i1 = get_var_index($3), i2 = get_var_index($5);
          if (i1 == -1 || i2 == -1) fprintf(stderr, "Undefined variable in if condition\n");
          else if (set_equal(&vars[i1].set, &vars[i2].set)) { /* DO branch */ }
          else { /* ELSE branch */ }
        }
  | IF '(' ID NEQ ID ')' DO op ELSE op '\n'   
        {
          int i1 = get_var_index($3), i2 = get_var_index($5);
          if (i1 == -1 || i2 == -1) fprintf(stderr, "Undefined variable in if condition\n");
          else if (!set_equal(&vars[i1].set, &vars[i2].set)) { /* DO branch */ }
          else { /* ELSE branch */ }
        }
    ;
op:
    ID { int i = get_var_index($1);
         if (i == -1) fprintf(stderr, "Undefined variable %s\n", $1);
         else { print_set(&vars[i].set); printf("\n"); }
         free($1);
       }
  | set_op { print_set($1); printf("\n"); free($1); }
  | prod_line
  ;
set_op:
    ID UNION ID  { int i1 = get_var_index($1), i2 = get_var_index($3);
                 if (i1 == -1 || i2 == -1) {
                    fprintf(stderr, "Undefined variable in union\n");
                    $$ = malloc(sizeof(Set)); $$->size = 0;
                 } else $$ = set_union(&vars[i1].set, &vars[i2].set);
                 free($1); free($3);
               }
    | ID DIFF ID  { int i1 = get_var_index($1), i2 = get_var_index($3);
                 if (i1 == -1 || i2 == -1) {
                    fprintf(stderr, "Undefined variable in difference\n");
                    $$ = malloc(sizeof(Set)); $$->size = 0;
                 } else $$ = set_difference(&vars[i1].set, &vars[i2].set);
                 free($1); free($3);
               }
    | ID INTER ID  { int i1 = get_var_index($1), i2 = get_var_index($3);
                 if (i1 == -1 || i2 == -1) {
                    fprintf(stderr, "Undefined variable in intersection\n");
                    $$ = malloc(sizeof(Set)); $$->size = 0;
                 } else $$ = set_intersection(&vars[i1].set, &vars[i2].set);
                 free($1); free($3);
               }
    ;

prod_line:
    ID PROD ID  { int i1 = get_var_index($1), i2 = get_var_index($3);
                 if (i1 == -1 || i2 == -1) fprintf(stderr, "Undefined variable in cartesian product\n");
                 else { print_product(&vars[i1].set, &vars[i2].set); printf("\n"); }
                 free($1); free($3);
               }
  ;

set:
    '{' set_elements '}'  { $$ = $2; }
  ;

set_elements:
    NUMBER { Set *s = malloc(sizeof(Set)); s->size = 1; s->values[0] = $1; $$ = s; }
  | set_elements ',' NUMBER
            { Set *prev = $1; int val = $3; int present = 0;
              for (int i = 0; i < prev->size; ++i) if (prev->values[i] == val) { present = 1; break; }
              if (!present) prev->values[prev->size++] = val;
              $$ = prev;
            }
  ;
%%

int get_var_index(const char *name) {
    for (int i = 0; i < var_count; ++i)
        if (strcmp(vars[i].name, name) == 0)
            return i;
    return -1;
}

void set_var_set(const char *name, const Set *s) {
    int idx = get_var_index(name);
    if (idx == -1) {
        strncpy(vars[var_count].name, name, sizeof(vars[var_count].name)-1);
        vars[var_count].set = *s;
        vars[var_count].defined = 1;
        var_count++;
    } else {
        vars[idx].set = *s;
        vars[idx].defined = 1;
    }
}

Set *set_copy(const Set *s) {
    Set *r = malloc(sizeof(Set));
    r->size = s->size;
    for (int i = 0; i < s->size; ++i) r->values[i] = s->values[i];
    return r;
}

Set *set_union(const Set *a, const Set *b) {
    Set *r = malloc(sizeof(Set));
    r->size = 0;
    for (int i = 0; i < a->size; ++i) r->values[r->size++] = a->values[i];
    for (int j = 0; j < b->size; ++j) {
        int v = b->values[j], present = 0;
        for (int k = 0; k < r->size; ++k) if (r->values[k] == v) { present = 1; break; }
        if (!present) r->values[r->size++] = v;
    }
    return r;
}

Set *set_difference(const Set *a, const Set *b) {
    Set *r = malloc(sizeof(Set));
    r->size = 0;
    for (int i = 0; i < a->size; ++i) {
        int v = a->values[i], present = 0;
        for (int j = 0; j < b->size; ++j) if (b->values[j] == v) { present = 1; break; }
        if (!present) r->values[r->size++] = v;
    }
    return r;
}

Set *set_intersection(const Set *a, const Set *b) {
    Set *r = malloc(sizeof(Set));
    r->size = 0;
    for (int i = 0; i < a->size; ++i) {
        int v = a->values[i];
        for (int j = 0; j < b->size; ++j)
            if (b->values[j] == v) {
                int present = 0;
                for (int k = 0; k < r->size; ++k) if (r->values[k] == v) { present = 1; break; }
                if (!present) r->values[r->size++] = v;
                break;
            }
    }
    return r;
}

int set_equal(const Set *a, const Set *b) {
    if (a->size != b->size) return 0;
    for (int i = 0; i < a->size; ++i) {
        int found = 0;
        for (int j = 0; j < b->size; ++j)
            if (a->values[i] == b->values[j]) { found = 1; break; }
        if (!found) return 0;
    }
    return 1;
}

void print_set(const Set *s) {
    printf("{");
    for (int i = 0; i < s->size; ++i) {
        printf("%d", s->values[i]);
        if (i + 1 < s->size) printf(", ");
    }
    printf("}");
}

void print_product(const Set *a, const Set *b) {
    printf("{");
    int first = 1;
    for (int i = 0; i < a->size; ++i)
        for (int j = 0; j < b->size; ++j) {
            if (!first) printf(", ");
            first = 0;
            printf("(%d, %d)", a->values[i], b->values[j]);
        }
    printf("}");
}

void yyerror(const char *s) {
    fprintf(stderr, "Parse error: %s\n", s);
}

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