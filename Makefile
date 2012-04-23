OBJS=main.o token.o lexer.o parsetable.o lextable.o parser.o ast.o
GEN=src/parsetable.d src/lextable.d

DFLAGS=-unittest -I../libhurt -Isrc -m64 -gc -debug

all: build

run: build
	./dmcd

parsetable: d4.dlr
	../dalr/Dalr -g ambiGraph -i d4.dlr -r src/parsetable.d -rm parsetable -glr true

build: $(GEN) $(OBJS) Makefile
	sh IncreBuildId.sh
	dmd $(OBJS) buildinfo.d -ofdmcd -L../libhurt/libhurt.a $(DFLAGS)

src/parsetable.d: d4.dlr Makefile
	../dalr/Dalr -i d4.dlr -r src/parsetable.d -rm parsetable --glr true -g ambiGraph

src/lextable.d: d4.dlr d.dex Makefile
	../dex/fsm -i d.dex -n src/lextable.d -nm lextable

parser.o: src/parser.d src/parsetable.d src/lextable.d src/lexer.d src/ast.d\
src/token.d Makefile
	dmd -c $(DFLAGS) src/parser.d

lextable.o: src/lextable.d Makefile
	dmd -c $(DFLAGS) src/lextable.d

ast.o: src/ast.d src/token.d Makefile
	dmd -c $(DFLAGS) src/ast.d

lexer.o: src/lexer.d src/lextable.d src/token.d Makefile
	dmd -c $(DFLAGS) src/lexer.d

main.o: src/main.d src/lexer.d src/lextable.d src/token.d Makefile
	dmd -c $(DFLAGS) src/main.d

token.o: src/token.d src/lextable.d Makefile
	dmd -c $(DFLAGS) src/token.d

parsetable.o: src/parsetable.d Makefile
	dmd -c $(DFLAGS) src/parsetable.d

clean:
	rm src/lextable.d
	rm src/parsetable.d
	rm *.o
	rm ambiGraph*.dot
	rm ambiGraph*.png
	rm dmcd
