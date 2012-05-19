//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:0


int main()
{
    assert(0b0010 == 2);
    assert(0xF_F == 25_5);
    assert(0x0FL == 15L);
    return 0;
}

