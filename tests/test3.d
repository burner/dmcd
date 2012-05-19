//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42

//T Tests casting.

int main()
{
    long a = 21; // int -> long, implicit
    int c = 21;
    if (a > c) {
        return 17;
    }
    return cast(int) a + c;
}
