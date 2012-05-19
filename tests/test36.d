//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42


struct S
{
    int i;
    int j;
    long k;
    int f() { return i + j; }
    alias f this;
    version (SDC) alias k this;  // DMD doesn't yet implement multiple alias this declarations.
}

int foo(int i)
{
    return i;
}

int main()
{
    S s;
    s.i = 21;
    s.j = 21;
    return foo(s);
}
