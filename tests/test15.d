//T compiles:yes
//T retval:73
// Simple test of ref.

void change(ref int i, int to)
{
    i = to;
}

int main()
{
    int i = 0;
    change(i, 73);
    return i;
}
