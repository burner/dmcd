//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:33

//T dependency:test22_import.d

import test22_import;

int begin()
{
    return 1 + tenptr()() + addOne(&twelve) + 8;
}

int twelve()
{
    return 12;
}

int main()
{
    return start();
}
