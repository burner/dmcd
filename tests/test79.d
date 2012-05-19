//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:0


int main()
{
    int a;
    auto b = &a;
    auto c = b;
    bool d = b == c;
    return 0;
}

