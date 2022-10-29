OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep
INCLUDES=
OCAMLFLAGS=$(INCLUDES) -g
OCAMLOPTFLAGS=$(INCLUDES) 

# The list of object files for prog1
MAIN_OBJS=asyntax.cmo parser.cmo lexer.cmo main.cmo

aritha: .depend $(MAIN_OBJS)
	$(OCAMLC) -o aritha $(OCAMLFLAGS) $(MAIN_OBJS)

rapport:
	pdflatex -shell-escape RAPPORT.tex

# Common rules
.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly

.mll.ml:
	ocamllex $<
.mly.ml:
	ocamlyacc $<
.ml.cmo:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.mli.cmi:
	$(OCAMLC) $(OCAMLFLAGS) -c $<

.ml.cmx:
	$(OCAMLOPT) $(OCAMLOPTFLAGS) -c $<

clean:
	rm -f aritha
	rm -f *~
	rm -f *.cm[iox]
	rm -f *.o
	rm -f parser.ml parser.mli
	rm -f lexer.ml
	rm -f RAPPORT.pyg
	rm -f RAPPORT.pdf
	rm -f RAPPORT.aux
	rm -f RAPPORT.log
	rm -r -f _minted-RAPPORT

# Dependencies - have to do the
# parser.* dependencies by hand
# since they're not seen by 
# make depend 

parser.cmo : parser.cmi
parser.mli : parser.mly
parser.ml : parser.mly


.depend:
	$(OCAMLDEP) $(INCLUDES) *.mli *.ml *.mly *.mll > .depend

include .depend

