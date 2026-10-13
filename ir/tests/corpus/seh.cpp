struct S { ~S(); };
void may_throw();
int f() { S s; try { may_throw(); } catch (int) { return 1; } return 0; }
