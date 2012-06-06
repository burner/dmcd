OBJS=main.o token.o lexer.o parsetable.o lextable.o parser.o ast.o parserutil.o\
exceptions.o util.o

GEN=src/parsetable.d src/lextable.d

DFLAGS=-unittest -I../libhurt -Isrc -m64 -gc -debug
#DFLAGS=-I../libhurt -Isrc -m64

all: build

run: build
	./dmcd

parsetable: d4.dlr
	#../dalr/Dalr -g ambiGraph -i d4.dlr -r src/parsetable.d -rm parsetable --glr true -z prodTree -k true
	../dalr/Dalr -g ambiGraph -i d4.dlr -r src/parsetabletmp.d -rm parsetable --glr true -z prodTree -e true

build: $(GEN) $(OBJS) 
	sh IncreBuildId.sh
	dmd $(OBJS) buildinfo.d -ofdmcd -L../libhurt/libhurt.a $(DFLAGS)

src/parsetable.d: d4.dlr 
	../dalr/Dalr -g ambiGraph -i d4.dlr -r src/parsetable.d -rm parsetable --glr true -z prodTree -t ableitungen.dot

src/lextable.d: d.dex 
	../dex/fsm -i d.dex -n src/lextable.d -nm lextable -mdg lexgraph.dot -v

parser.o: src/parser.d src/parsetable.d src/lextable.d src/lexer.d src/ast.d\
src/token.d 
	dmd -c $(DFLAGS) src/parser.d

lextable.o: src/lextable.d 
	dmd -c $(DFLAGS) src/lextable.d

exceptions.o: src/exceptions.d 
	dmd -c $(DFLAGS) src/exceptions.d

util.o: src/util.d 
	dmd -c $(DFLAGS) src/util.d

ast.o: src/ast.d src/token.d 
	dmd -c $(DFLAGS) src/ast.d

parserutil.o: src/parserutil.d src/parsetable.d 
	dmd -c $(DFLAGS) src/parserutil.d

lexer.o: src/lexer.d src/lextable.d src/token.d src/exceptions.d 
	dmd -c $(DFLAGS) src/lexer.d

main.o: src/main.d src/lexer.d src/lextable.d src/token.d src/util.d
	dmd -c $(DFLAGS) src/main.d

token.o: src/token.d src/lextable.d 
	dmd -c $(DFLAGS) src/token.d

parsetable.o: src/parsetable.d 
	dmd -c $(DFLAGS) src/parsetable.d

opts.o: src/opts.d 
	dmd -c $(DFLAGS) src/opts.d

clean:
	rm ambiGraph*.dot&
	rm ambiGraph*.png&
	rm itemset*.dot&
	rm src/lextable.d&
	rm src/parsetable.d&
	rm *.o&
	rm dmcd&

cleanobjs:
	rm *.o&
	rm dmcd&

test: $(GEN) $(OBJS) 
	sh IncreBuildId.sh
	dmd $(OBJS) buildinfo.d -ofdmcd -L../libhurt/libhurt.a -I../libhurt -Isrc -m64 -gc -debug
	./tester.py

count:
	wc -l src/main.d src/token.d src/lextable.d src/parser.d src/ast.d src/parserutil.d src/exceptions.d src/util.d
