module util;

public pure @safe nothrow string removePath(string path) {
	size_t i = path.length-1;
	bool broke = false;
	for(; i > 0; i--) {
		if(path[i] == '/') {
			broke = true;
			break;
		}
	}
	return path[broke ? i+1 : i .. $];
}
