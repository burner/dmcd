module util;

public pure @safe nothrow string removePath(string path) {
	size_t i = path.length-1;
	for(; i > 0; i--) {
		if(path[i] == '/') {
			break;
		}
	}
	return path[i .. $];
}
