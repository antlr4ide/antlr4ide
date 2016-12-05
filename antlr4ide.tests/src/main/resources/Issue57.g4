grammar Issue57;
      
main:;
      
LINE_COMMENT
: '--'
	(	// error (required (...)+ loop did not match anything at input '|')
		| '[' '='*
		| '[' '='* ~('='|'['|'\r'|'\n') ~('\r'|'\n')*
		| ~('['|'\r'|'\n') ~('\r'|'\n')*
	) ('\r\n'|'\r'|'\n'|EOF)
		-> channel(HIDDEN)
;
