/* File parser.mly */
        %token <string> INT
	%token <string> FLOAT
	%token <string> INTOFFLOAT
	%token <string> FLOATOFINT
        %token PLUS MINUS MUL DIV MOD FPLUS FMINUS FMUL EOF
        %token LPAR RPAR
        %left PLUS MINUS FPLUS FMINUS       		   /* lowest precedence */
        %left MUL FMUL       			  /* medium precedence */
        %nonassoc UPLUS FUMINUS UMINUS MOD INTOFFLOAT FLOATOFINT DIV      /* highest precedence */
        %start parse             /* the entry point */
        %type <Asyntax.sexp> parse
        %%
        parse:
            expr                { $1 }
        ;
        expr:
            expri                     { $1 }
	  | exprf		      { $1 }
          | LPAR expr RPAR            { $2 }
        ;
	expri:
	    INT	                    { Asyntax.AtomI $1 }
	  | INTOFFLOAT exprf	    { Asyntax.IntOfFloat $2 }
	  | LPAR expri RPAR           { $2 }
          | expri PLUS expri          { Asyntax.Add($1,$3) }
          | expri MINUS expri         { Asyntax.Sub($1,$3) }
          | expri MUL expri           { Asyntax.Mul($1,$3) }
          | expri DIV expri           { Asyntax.Div($1,$3) }
	  | expri MOD expri           { Asyntax.Mod($1,$3) }
          | MINUS expri %prec UMINUS  { Asyntax.Minu $2 }
          | PLUS expri %prec UPLUS  { $2 }
	;
	exprf:
	    FLOAT		    { Asyntax.AtomF $1 }
	  | FLOATOFINT expri	    { Asyntax.FloatOfInt $2 }
	  | LPAR exprf RPAR            { $2 }
          | exprf FPLUS exprf          { Asyntax.FAdd($1,$3) }
          | exprf FMINUS exprf         { Asyntax.FSub($1,$3) }
          | exprf FMUL exprf           { Asyntax.FMul($1,$3) }
          | FMINUS exprf %prec FUMINUS { Asyntax.FMinu $2 }
	  | PLUS exprf %prec UPLUS  { $2 }
	;

