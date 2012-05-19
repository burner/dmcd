//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:42

//T dependency:test20_import.d
//T dependency:test20_import2.d
//T Basic import testing

import test20_import;
import test20_import2;

int main()
{
    int a = importedFunction();
    int b = anotherImportedFunction();
    return a + b;
}

