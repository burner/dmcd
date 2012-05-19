//T compiles:yes
//T retval:0
//? desc:Test aggregate foreach.

int main()
{
	string str = "foobar";
	string str2 = "raboof";
	foreach(i, c; str)
	{
		assert(c == str2[(str2.length - i) - 1]);
	}
	
	int count;
	foreach(char c; str)
	{
		if (c == 'o')
			count++;
	}
	assert(count == 2);
	
	char* mem = cast(char*)malloc(str.length);
	foreach(size_t i, c; str)
	{
		mem[i] = c;
	}
	
	foreach(size_t i; 0..str.length)
	{
		assert(mem[i] == str[i]);
	}
	
	foreach(i, ref char c; mem[0..3])
	{
		c = 'o';
	}
	
	foreach(i; 0..3)
	{
		assert(mem[i] == 'o');
	}
	
	char last;
	foreach(ref i, c; mem[0..1337])
	{
		last = c;
		if (i == 5)
			i = 1337;
	}
	assert(last == 'r');
	
	// Break.
	foreach(ref c; mem[0..str.length])
	{
		if(c == 'o')
			c = 'a';
		else
			break;
	}
	foreach(i; 0..3)
		assert(mem[i] == 'a');
	assert(mem[3] == 'b');
	
	// Continue.
	count = 0;
	foreach(c; str)
	{
		if (c != 'o')
			continue;
		
		count++;
	}
	assert(count == 2);
	return 0;
}
