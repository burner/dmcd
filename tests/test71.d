//T lexer:yes
//T parser:yes
//T semantic:yes
//T retval:0

//T Test the while loop.

int main()
{
	int i = 0;
	while(i < 10)
		i++;
	
	assert(i == 10);
	
	// Break.
	i = 0;
	while(i < 10)
	{
		i++;
		if(i == 5)
			break;
	}
	assert(i == 5);
	
	// Continue.
	i = 0;
	int j = 0;
	while(i < 10)
	{
		i++;
		if(i > 5)
			continue;
		j++;
	}
	assert(j == 5);
	return 0;
}
