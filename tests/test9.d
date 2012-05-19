//T compiles:yes
//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:0
//T Tests strings and character literals, and string/pointer casts.

extern(C) size_t strlen(const char* s);

int main()
{
    string str = "test";  
    if (str.length != 4) {
        return 1;
    }
    if (str[2] != 's') {
        return 2;
    }
    auto p = str.ptr;
    if(strlen(p) != str.length) {
        return 3;
    }
    return 0;
}

