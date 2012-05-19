//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:30

//T dependency:test37_import.d

import test37_import;

alias int Integer;
alias test37_import.S SS;
alias foo bar;
alias bar bas;

int bazoooooooom()
{
    return 2;
}

Integer main()
{
    SS s;
    s.i = 30;
    bas(&s.i);
    return s;
}

