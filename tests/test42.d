//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T dependency:test42_import.d

//T retval:8
import test42_import;

int main()
{
    auto foo = new Foo();
    foo.bar();
    return 8;
}

