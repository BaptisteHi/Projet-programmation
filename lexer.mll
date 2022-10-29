 (* File lexer.mll *)
        {
        open Parser        (* The type token is defined in parser.mli *)
        exception Eof
        }
        rule token = parse
            [' ' '\t' '\n']     { token lexbuf }     (* skip blanks *)
          | ['0'-'9']+ as lxm { INT(lxm) }
	  | ['0'-'9']+ '.' ['0'-'9']* as lxm { FLOAT(lxm) }
          | '+'            { PLUS }
          | '-'            { MINUS }
          | '*'            { MUL }
          | '/'            { DIV }
	  | '%'      	   { MOD }
	  | "+."     	   { FPLUS }
	  | "-."     	   { FMINUS }
	  | "*."     	   { FMUL }
          | '('            { LPAR }
          | ')'            { RPAR }
	  | "int" '(' ['0'-'9']+ '.' ['0'-'9']+ ')'  as lxm { INTOFFLOAT(lxm) }
	  | "float" '(' ['0'-'9']+ ')' 		 as lxm { FLOATOFINT(lxm) }
          | eof            { EOF }
