//T compiles:yes
//T retval:8

int main()
{
    int i;
    i = 7;
    goto _out;
    _out:
    i++;
    return i;
}

