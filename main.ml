open Parser
open Lexer
open Asyntax

let exempl = open_in Sys.argv.(1)
let lexbuf = Lexing.from_channel exempl 
let ast = Parser.parse Lexer.token lexbuf
(* code servant à afficher l'arbre syntaxique pour tester le lexer et le parser*)
let print_sexp a =
	let rec aux b = match b with
		|AtomI s -> s
		|AtomF s -> s
		|IntOfFloat sexp -> "IntOfFloat ("^(aux sexp)^")"
		|FloatOfInt sexp -> "FloatOfInt ("^(aux sexp)^")"
		|FMinu sexp -> "Moins ("^(aux sexp)^")"
		|Minu sexp -> "Moins ("^(aux sexp)^")"
		|Add(se,seb) -> "("^(aux se)^"Plus"^(aux seb)^")"
		|Sub(se,seb) -> "("^(aux se)^"Moins"^(aux seb)^")"
		|Mul(se,seb) -> "("^(aux se)^"Fois"^(aux seb)^")"
		|Div(se,seb) -> "("^(aux se)^"divisé par"^(aux seb)^")"
		|Mod(se,seb) -> "("^(aux se)^"Modulo"^(aux seb)^")"
		|FAdd(se,seb) -> "("^(aux se)^"Plus"^(aux seb)^")"
		|FSub(se,seb) -> "("^(aux se)^"Moins"^(aux seb)^")"
		|FMul(se,seb) -> "("^(aux se)^"Fois"^(aux seb)^")"
	in print_string(aux a);;

(*invariant pour les opérations : les valeurs soumises aux opérations en cours se situent toujours sur le haut de la pile*)
let entier x="
movq $"^x^", %r15
pushq %r15\n"

let addition_i="
popq %rbx
popq %rbp
addq %rbx, %rbp
pushq %rbp\n"

let soustraction_i="
popq %rbx
popq %rbp
subq %rbx, %rbp
pushq %rbp\n"

let multiplication_i="
popq %rbx
popq %rbp
imulq %rbx, %rbp
pushq %rbp\n"

let division="
popq %rbx
popq %rax
idivq %rbx
pushq %rax
movq $0, %rax
movq $0, %rax\n"

let modulo="
popq %rbx
popq %rax
idivq %rbx
pushq %rdx
movq $0, %rax
movq $0, %rdx\n"

let minu_i="
movq $0, %r10
popq %rbp
subq %rbp, %r10
pushq %r10\n
"

let flottant i="
movsd .FLOAT"^string_of_int(i)^"(%rip), %xmm0
movsd %xmm0, -8(%rsp)
subq $8, %rsp\n"

let addition_f="
movsd (%rsp), %xmm0
movsd 8(%rsp), %xmm1
addq $16, %rsp
addsd %xmm0, %xmm1
movsd %xmm1, -8(%rsp)
subq $8, %rsp\n"

let soustraction_f="
movsd (%rsp), %xmm0
movsd 8(%rsp), %xmm1
addq $16, %rsp
subsd %xmm0, %xmm1
movsd %xmm1, -8(%rsp)
subq $8, %rsp\n"

let multiplication_f="
movsd (%rsp), %xmm0
movsd 8(%rsp), %xmm1
addq $16, %rsp
mulsd %xmm0, %xmm1
movsd %xmm1, -8(%rsp)
subq $8, %rsp\n"

let minu_f="
movsd (%rsp), %xmm0
movsd .FLM1(%rip), %xmm1
addq $8, %rsp
mulsd %xmm0, %xmm1
movsd %xmm1, -8(%rsp)
subq $8, %rsp\n"

let compilation a =
	let s = ".text\n.globl main\n\nmain:\nmovq $0, %rdx\nmovq $0, %rax\n" in
	let varfloat = ".FLM1:\n.double -1.0\n" in(* il faut au moins encoder le flottant -1.0 pour minu_f *)
	let rec aux b j = match b,j with (* renvois le code et un booléen déterminant si l'expression en entrée est évaluée en un flottant ou en un entier *)
		|(AtomI(s)),i -> entier s,true
		|(AtomF s),i -> flottant(i), false
		|(IntOfFloat sexp),i -> failwith "conversions non faites :/"
		|(FloatOfInt sexp),i -> failwith "conversions non faites :/"
		|(FMinu sexp),i -> (fst (aux sexp (i+1)))^minu_f, false
		|(Minu sexp),i -> (fst (aux sexp (i+1)))^minu_i, true
		|(Add(se,seb)),i ->(fst (aux se (i+1)))^(fst (aux seb (i+20)))^(addition_i), true (*le +20 sert ici à assurer que deux flottants ne soient pas associés à la même instruction assembleur pour de petites expressions*)
		|(Sub(se,seb)),i ->(fst (aux se (i+1)))^(fst (aux seb (i+20)))^(soustraction_i), true
		|(Mul(se,seb)),i ->(fst (aux se (i+1)))^(fst (aux seb (i+20)))^(multiplication_i), true
		|(Div(se,seb)),i ->(fst (aux se (i+1)))^(fst (aux seb (i+20)))^(division), true
		|(Mod(se,seb)),i ->(fst (aux se (i+1)))^(fst (aux seb (i+20)))^(modulo), true
		|(FAdd(se,seb)),i -> (fst (aux se (i+1)))^(fst (aux seb (i+20)))^(addition_f), false
		|(FSub(se,seb)),i -> (fst (aux se (i+1)))^(fst (aux seb (i+20)))^(soustraction_f), false
		|(FMul(se,seb)),i -> (fst (aux se (i+1)))^(fst (aux seb (i+20)))^(multiplication_f), false
	in
	let rec variables b j = match b,j with
		|(AtomI(s)),_ -> ""
		|(AtomF s),i -> (".FLOAT")^(string_of_int(i))^(":\n.double ")^s^("\n") (*on ajoute toutes les variables flottantes en les numérotant de la même façon*)
		|(IntOfFloat sexp),i -> failwith "conversions non faites :/"
		|(FloatOfInt sexp),i -> failwith "conversions non faites :/"
		|(FMinu sexp),i -> variables sexp (i+1)
		|(Minu sexp),i -> variables sexp (i+1)
		|(Add(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(Sub(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(Mul(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(Div(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(Mod(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(FAdd(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(FSub(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
		|(FMul(se,seb)),i -> (variables se (i+1))^(variables seb (i+20))
	in
	let fs,sn = (aux a 0) in 
	if sn then s^(fs)^("popq %rsi\nmovq $message, %rdi\ncall printf\nret\n\n.data\n\nmessage:\n.string \"%d\"")^("\n\n") else
 s^(fs)^("movsd (%rsp), %xmm0\naddq $8, %rsp\n")^("call print_float\nret\n\nprint_float:\nmovq $message, %rdi\nmovq $1, %rax\ncall printf\nret\n\n.data\n\nmessage:\n.string \"%f\"")^("\n\n")^(variables a 0)^(varfloat);;

let ecrire_texte s file=
    let oc = open_out file in
    output_string oc (s^"\n");
    close_out oc
;;

ecrire_texte (compilation ast) "file.s";;
