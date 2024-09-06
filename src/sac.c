/* sac.c -- simple S-Algol Compiler */

#include <string.h>
#include <stdio.h>
#include <ctype.h>


#define TRUE 1
#define FALSE 0

#define TOKEN_SIZE 256

#define string_eq(s1, s2) (strcmp(s1, s2) == 0)

#define digit(ch) isdigit(ch)
#define letter(ch) isalpha(ch)



/*
 * Simple-minded i/o routines, to be fleshed out later.
 */

int
get_char ()
{
  int ch = getc (stdin);
  return ch;
}

int
peek ()
{
  int ch = getc (stdin);
  ungetc (ch, stdin);
  return ch;
}


put_char (int ch)
{
  fputc (ch, stdout);
}


int
eof ()
{
  return feof (stdin);
}



/*
 * Lexical Analysier
 */

char buf[TOKEN_SIZE];
char *symbol;
char *string_literal, *the_name, *boolean_literal;

#define set_buf_to_char(ch) (buf[0] = ch, buf[1] = 0, buf)
#define add_char_to_buf(i, ch) (buf[i++] = ch)


int
next_ch ()
{
  int ch = get_char ();
  return ch;
}


try (char *s)
{
  if (s[1] == peek ())
    {
      next_ch ();
      symbol = s;
    }
}


char
next_char ()
{
  int discard, ch = next_ch ();
  if (ch == '\'')
    {
      switch (peek ())
	{
	case 'n':
	  discard = next_ch ();
	  return '\n';
	  break;
	case 't':
	  discard = next_ch ();
	  return '\t';
	  break;
	case 'b':
	  discard = next_ch ();
	  return '\b';
	  break;
	case 'f':
	  discard = next_ch ();
	  return '\f';
	  break;
	case '"':
	  discard = next_ch ();
	  return '"';
	  break;
	case '\'':
	  discard = next_ch ();
	  return '\'';
	  break;
	default:
	  return next_ch ();
	  break;
	}
    }
  else
    return ch;
}


char *
read_string ()
{
  int i = 0, discard;
  while (peek () != '"')
    {
      add_char_to_buf (i, next_char ());
    }
  discard = next_ch ();
  return buf;
}



int
ok ()
{
  return letter (peek ()) || digit (peek ()) || (peek () == '.');
}



try_name ()
{
  int i = 0, ch;
  add_char_to_buf (i, next_ch ());
  while (ok ())
    add_char_to_buf (i, next_ch ());
  if (string_eq (buf, "true"))
    {
      boolean_literal = buf;
      symbol = "literal";
    }
  else if (string_eq (buf, "false"))
    {
      boolean_literal = buf;
      symbol = "literal";
    }
  else if (reserved_word (buf))
    {
      symbol = buf;
    }
  else
    {
      the_name = buf;
      symbol = "identifier";
    }
}


next_symbol ()
{
  int ch;

  if (digit (peek ()))
    number ();
  else if (letter (peek ()))
    try_name ();
  else
    {
      switch (peek ())
	{
	case ':':
	  ch = next_ch ();
	  if (peek () == ':')
	    {
	      ch = next_ch ();
	      symbol = "::";
	    }
	  else
	    try (":=");
	  break;
	case '<':
	  symbol = set_buf_to_char (next_ch ());
	  try ("<=");
	  break;
	case '>':
	  symbol = set_buf_to_char (next_ch ());
	  try (">=");
	  break;
	case '~':
	  symbol = set_buf_to_char (next_ch ());
	  try (">=");
	  break;
	case '-':
	  symbol = set_buf_to_char (next_ch ());
	  try ("->");
	  break;
	case '+':
	  symbol = set_buf_to_char (next_ch ());
	  try ("++");
	case '"':
	  ch = next_ch ();
	  symbol = "literal";
	  string_literal = read_string ();
	  break;
	default:
	  symbol = set_buf_to_char (next_ch ());
	  break;
	}
    }
}


char *keywords[] = {
  "abort",
  "and",
  "begin",
  "bool",
  "by",
  "case",
  "default",
  "div",
  "do",
  "end",
  "eof",
  "external",
  "file",
  "float",
  "for",
  "forward",
  "if",
  "int",
  "is",
  "isnt",
  "let",
  "lwb",
  "of",
  "or",
  "out.byte",
  "output",
  "peek",
  "pntr",
  "procedure",
  "read",
  "read.byte",
  "read.name",
  "readb",
  "readi",
  "readr",
  "reads",
  "real",
  "rem",
  "repeat",
  "string",
  "structure",
  "then",
  "to",
  "upb",
  "vector",
  "while",
  "write",
  0,
};

int
reserved_word (char *s)
{
  char **p;
  for (p = keywords; *p; p++)
    {
      if (string_eq (*p, s))
	return TRUE;
    }
  return FALSE;
}



/*
 * Parser
 */

int
have (char *s)
{
  if (string_eq (s, symbol))
    {
      next_symbol ();
      return TRUE;
    }
  else
    return FALSE;
}


int recovering = FALSE;

error_message (char *s, char *found, char *s2, char *expected, char *s3)
{
  fprintf(stderr, "%s%s%s%s%s", s, found, s2, expected, s3);
}


syntax (char *s)
{
  if (!recovering)
    {
      error_message ("** Syntax Error **", s, " found where ", symbol,
		     " expected");
      recovering = TRUE;
    }
}


mustbe (char *s)
{
  if (recovering)
    {
      while (!eof () && !string_eq (symbol, s))
	next_symbol ();
      recovering = FALSE;
    }
  else
    {
      if (string_eq (s, symbol))
	next_symbol ();
      else
	syntax (s);
    }
}


expression ()
{
  do
    {
      exp1 ();
    }
  while (have ("or"));
}


exp1 ()
{
  do
    {
      exp2 ();
    }
  while (have ("and"));
}


exp2 ()
{
  int not = have ("~");

  exp3 ();
  if (string_eq ("is", symbol)
      || string_eq ("isnt", symbol)
      || string_eq ("=", symbol)
      || string_eq ("~=", symbol)
      || string_eq (">=", symbol)
      || string_eq (">", symbol)
      || string_eq ("<=", symbol)
      || string_eq ("<", symbol))
    {
      next_symbol ();
      exp3 ();
    }
  else
    {
    }
}


exp3 ()
{
  do
    {
      exp4 ();
    }
  while (have ("+") || have ("-"));
}


exp4 ()
{
  int addop = have ("+") || have ("-");

  do
    {
      exp5 ();
    }
  while (have ("*") || have ("/") || have ("div")
	 || have ("rem") || have ("++"));
}


exp5 ()
{
  if (string_eq ("identifier", symbol))
    next_symbol ();
  else if (string_eq ("literal", symbol))
    next_symbol ();
  else if (string_eq ("begin", symbol)
	   || string_eq ("{", symbol))
    block ();
  else if (string_eq ("vector", symbol))
    {
      next_symbol ();
      do
	{
	  clause ();
	  mustbe ("::");
	  clause ();
	}
      while (have (","));
      mustbe ("of");
      clause ();
    }
  else if (string_eq ("@", symbol))
    {
      next_symbol ();
      clause ();
      mustbe ("of");
      type1 ();
      mustbe ("[");
      do
	{
	  clause ();
	}
      while (have (","));
      mustbe ("]");
    }
  else if (string_eq ("(", symbol))
    {
      next_symbol ();
      clause ();
      mustbe (")");
    }
  else
    {
    }

  if (have ("("))
    compile_bracket ();
  if (have (":="))
    {
      next_symbol ();
      clause ();
    }
}


block ()
{
  char *last;;

  if (string_eq ("{", symbol))
    last = "}";
  else
    last = "end";
  next_symbol ();
  if (!have (last))
    {
      sequence ();
      mustbe (last);
    }
}



write_clause ()
{
  next_symbol ();
  do
    {
      clause ();
      if (have (":"))
	clause ();
  } while (have (","));
}


if_clause ()
{
  next_symbol ();
  clause ();
  if (have ("do"))
    clause ();
  else
    {
      mustbe ("then");
      clause ();
      mustbe ("else");
      clause ();
    }
}


abort_clause ()
{
  next_symbol ();
}


clause_list ()
{
  do
    {
      clause ();
    }
  while (have (","));
}


case_list ()
{
  do
    {
      clause_list ();
      mustbe (":");
      clause ();
      mustbe (";");
    }
  while (!have ("default"));
}


case_clause ()
{
  next_symbol ();
  clause ();
  mustbe ("of");
  case_list ();
  mustbe ("default");
  mustbe (":");
  clause ();
}


for_clause ()
{
  next_symbol ();
  mustbe ("identifier");
  mustbe ("=");
  clause ();
  mustbe ("to");
  clause ();
  if (have ("by"))
    {
      clause ();
    }
  mustbe ("do");
  clause ();
}


repeat_clause ()
{
  next_symbol ();
  clause ();
  mustbe ("while");
  clause ();
  if (have ("do"))
    {
      clause ();
    }
}


while_clause ()
{
  next_symbol ();
  clause ();
  mustbe ("do");
  clause ();
}


clause ()
{
  if (string_eq ("if", symbol))
    if_clause ();
  else if (string_eq ("repeat", symbol))
    repeat_clause ();
  else if (string_eq ("while", symbol))
    while_clause ();
  else if (string_eq ("for", symbol))
    for_clause ();
  else if (string_eq ("case", symbol))
    case_clause ();
  else if (string_eq ("abort", symbol))
    abort_clause ();
  else if (string_eq ("write", symbol))
    write_clause ();
  else
    expression ();
}


bounds ()
{
  do
    {
      clause ();
      mustbe ("::");
      clause ();
    }
  while (have (","));
}


field_list ()
{
  do
    {
      type1 ();
      identifier_list ();
    }
  while (have (";"));
}



    

let_decl ()
{
  next_symbol ();
  mustbe ("identifier");
  if (!have ("="))
    mustbe (":=");
  clause ();
}


forward_decl ()
{
  next_symbol ();
  mustbe ("identifier");
  if (have ("("))
    {
      proc_type ();
    }
}


external_decl ()
{
  next_symbol ();
  mustbe ("identifier");
  if (have ("("))
    {
      proc_type ();
    }
}


structure_decl ()
{
  next_symbol ();
  mustbe ("identifier");
  mustbe ("(");
  field_list ();
  mustbe (")");
}


procedure_decl ()
{
  next_symbol ();
  mustbe ("identifier");
  if (have ("("))
    {
      t_spec ();
    }
  mustbe (";");
  clause ();
}


sequence ()
{
  int more = TRUE;

  do
    {
      if (string_eq ("let", symbol))
	let_decl ();
      else if (string_eq ("procedure", symbol))
	procedure_decl ();
      else if (string_eq ("structure", symbol))
	structure_decl ();
      else if (string_eq ("forward", symbol))
	forward_decl ();
      else if (string_eq ("external", symbol))
	external_decl ();
      else
	clause ();

      if (!have (";"))
	{
	  if (recovering)
	    {
	      while (!string_eq (";", symbol) && !eof ())
		next_symbol ();
	      recovering = FALSE;
	    }
	  else
	    more = FALSE;
	}
  } while (more);
}


program ()
{
  next_symbol ();
  sequence ();
  mustbe ("?");

}


main ()
{
  program ();
  exit (0);
}
