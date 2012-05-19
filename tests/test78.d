//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:4


class Foo
{
    void func1()
    {}

    void func2()
    body {}

    void func3()
    in {}
    body {}

    void func4()
    out {}
    body {}

    void func5()
    out {}
    in {}
    body {}

    void func6()
    in {}
    out {}
    body {}
}

void func1()
{}

void func2()
body {}

void func3()
in {}
body {}

void func4()
out {}
body {}

void func5()
out {}
in {}
body {}

void func6()
in {}
out {}
body {}

int main()
{
    return 4;
}

