//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42

//T Tests struct member functions, implicit and explicit this.

struct S
{
    int c, d;
    int add(int a, int b)
    {
        return a + b + c + this.d;
    }
}

int main()
{
    S s;
    s.c = s.d = 1;
    return s.add(38, 2);
}
