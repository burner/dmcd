//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:12
//T Tests typeof and evaluation of expressions with no side-effects.

int main()
{
    int i = 12;
    typeof(i++) j;
    return i;
}
