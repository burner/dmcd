//T Name collision
//T compiles:no
//T lexer:yes
//T parser:yes
//T semantic:no
//T dependency:test58_import1.d

//T dependency:test58_import2.d

import test58_import1;
import test58_import2;

int main()
{
    int a = importedFunction();
    return a;
}
