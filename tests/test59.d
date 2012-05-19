//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42

//T Tests UTF-8 characters.

int åäö() { return 2; }
int aäo() { return 20; }
int åäo() { return 20; }

int main()
{
    return åäö() + aäo() + åäo();
}
