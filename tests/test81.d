//T compiles:no
//T lexer:yes
//T parser:yes
//T semantic:no
//T retval:0

module hello.world.gggg; 

int func(int a, int b) {
	return a + b;
}

private class Gen(T) {
	public:
		this(T foo) {
			this.foo = foo;
		}

		T get() const {
			return this.foo;
		}
	
	private T foo;
}

void main() {
	Gen!(int) g = new Gen!(int)();
}
