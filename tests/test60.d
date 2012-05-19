//T compiles:no
//T lexer:yes
//T parser:yes
//T semantic:no
//T Issue #25.


int func1() { return 2; }
int func2() { return 20; }
int func3() { return 20; }

int main()
{
    return func1() + func2() func3();
}
