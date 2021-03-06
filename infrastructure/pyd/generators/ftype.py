#!/usr/bin/env python
# -*- coding: utf-8 -*-

#
# ftype.py
# An evil hack in under 400 lines.
# Written by Daniel Keep
# Released to public domain—share and enjoy (just leave my name in it, pretty
# please).
#

# TODO:
# * Better error messages when you try to use a function with too many
#   arguments (it currently barfs with an unhelpful cascade of errors).

# This number controls the maximum number of arguments these templates will be
# able to process.  The higher you set this, the larger the output file
# becomes.
MAX_ARGS = 10

# This is the file the module will be output to.
OUT_FILE = "ftype.txt"

# This is the full name of the module.
MODULE_PATH = "pyd.ftype"

#
# Everything from here on isn't very interesting :)
#

# Redirect output to ftype.d
import sys
old_stdout = sys.stdout
sys.stdout = file(OUT_FILE, 'wt')

def typename(i):
    if i == 0:
        return "Tr"
    else:
        return "Ta%d" % i

def typenameinout(i):
    if i == 0:
        return "Tr"
    else:
        return "inout Ta%d" % i

def typeargs(n, omit_first=False):
    if omit_first:
        xs = range(1,n+1)
    else:
        xs = range(n+1)
        
    return ", ".join(typename(x) for x in xs)

def typeargsinout(n, omit_first=False):
    if omit_first:
        xs = range(1,n+1)
    else:
        xs = range(n+1)
        
    return ", ".join(typenameinout(x) for x in xs)

def typefptr(n):
    return "%s function(%s)" % (typename(0), typeargs(n, True))

def typefninout(n):
    return "%s function(%s)" % (typenameinout(0), typeargsinout(n, True))

def typedelegate(n):
    return "%s delegate(%s)" % (typename(0), typeargs(n, True))

typefn = typefptr

#callable_types = ('F',typefptr), ('D',typedelegate)

#
# Module header
#

print """/**
 * This module contains template for inferring the number of arguments,
 * the return type, and argument types of an arbitrary function pointer.
 * 
 * This module was automatically generated by ftype.py
 * 
 * Written by Daniel Keep.
 * Released to public domain—share and enjoy (just leave my name in it,
 * pretty please).
 */
module %s;
private:""" % MODULE_PATH

#
# Support templates
#

##print """
##/*
## * This template tests whether a particular type is a function pointer.
## *
## * Borrowed from the traits library.
## */
##template
##IsFunctionPtr(Tf)
##{
##    const bool IsFunctionPtr = is( typeof(*Tf) == function );
##}"""
##
##print """
##/*
## * This template tests whether a particular type is a delegate.
## *
## * Borrowed from the traits library.
## */
##template
##IsDelegate(Tf)
##{
##    const bool IsDelegate = is( Tf == delegate );
##}"""

#
# NumberOfArgs(Tf)
#

print """
/* *** NumberOfArgs(Tf) *** */
"""

for i in range(MAX_ARGS+1):
    print "typedef uint Arglen%d = %d;" % (i, i)

for i in range(MAX_ARGS+1):
    print ""
    print "template"
    print "ArglenT(%s)" % typeargs(i)
    print "{"
    print "    Arglen%d" % i
    print "    ArglenT(%s fn) { assert(false); }" % typefn(i)
    print "}"

print """
template
ArglenConvT(T)
{
    const uint ArglenConvT = T.init;
}"""

print """
template
NumberOfArgsT(Tf)
{
    private Tf fptr;
    alias typeof(ArglenT(fptr)) type;
}"""

print """
template
NumberOfArgsSwitchT(Tf)
{
    static if( is( typeof(*Tf) == function ) )
        alias NumberOfArgsT!(Tf).type type;
    else static if( is( Tf U == delegate ) )
        alias NumberOfArgsSwitchT!(U*).type type;
}"""

print """
/**
 * This template will attempt to determine the number of arguments the
 * supplied function pointer or delegate type takes.  It supports a maximum of
 * %d arguments.
 *
 * Example:
 * ----------------------------------------
 * void fnWithThreeArgs(byte a, short b, int c) {}
 * const uint numArgs = NumberOfArgs!(typeof(&fnWithThreeArgs));
 * ----------------------------------------
 */
public
template
NumberOfArgs(Tf)
{
    const uint NumberOfArgs = ArglenConvT!(NumberOfArgsSwitchT!(Tf).type);
}""" % MAX_ARGS

#
# NumberOfArgsInout
#
for i in range(MAX_ARGS+1):
    print ""
    print "template"
    print "ArgleninoutT(%s)" % typeargs(i)
    print "{"
    print "    Arglen%d" % i
    print "    ArgleninoutT(%s fn) { assert(false); }" % typefninout(i)
    print "}"

print """
template
NumberOfArgsInoutT(Tf)
{
    private Tf fptr;
    alias typeof(ArgleninoutT(fptr)) type;
}"""

print """
template
NumberOfArgsSwitchInoutT(Tf)
{
    static if( is( typeof(*Tf) == function ) )
        alias NumberOfArgsInoutT!(Tf).type type;
    else static if( is( Tf U == delegate ) )
        alias NumberOfArgsSwitchInoutT!(U*).type type;
}"""

print """
public
template
NumberOfArgsInout(Tf)
{
    const uint NumberOfArgsInout = ArglenConvT!(NumberOfArgsSwitchInoutT!(Tf).type);
}"""

#
# ReturnType(Tf)
#

##print """
##/* *** ReturnType(Tf) *** */"""
##
##for i in range(MAX_ARGS+1):
##    for typecode,typefn in callable_types:
##        print ""
##        print "template"
##        print "RetType%sT(%s)" % (typecode,typeargs(i))
##        print "{"
##        print "    %s" % typename(0)
##        print "    RetType%sT(%s fn) { assert(false); }" % (typecode,typefn(i))
##        print "}"

print """
template
ReturnTypeT(Tf)
{
    private Tf fptr;
    static if( is( typeof(*Tf) U == function ) )
        alias U type;
    else static if( is( Tf U == delegate ) )
        alias ReturnType!(U*) type;
    else
        static assert(false, "ReturnType argument must be function pointer"
                " or delegate.");
}"""

print """
/**
 * This template will attempt to discern the return type of the supplied
 * function pointer or delegate type.  It supports callables with a maximum of
 * %d arguments.
 *
 * Example:
 * ----------------------------------------
 * uint returnsANumber() { return 42; }
 * alias ReturnType!(typeof(&returnsANumber)) RType; // RType == uint
 * ----------------------------------------
 */
public
template
ReturnType(Tf)
{
    alias ReturnTypeT!(Tf).type ReturnType;
}""" % MAX_ARGS

#
# ArgType(Tf, n)
#

print """
/* *** ArgType(Tf, n) *** */"""

for n in range(1, MAX_ARGS+1):
    for i in range(n, MAX_ARGS+1):
        print ""
        print "template"
        print "Arg%dTypeT(%s)" % (n, typeargs(i))
        print "{"
        print "    %s Arg%dTypeT(%s fn) { assert(false); }" % (
            typename(n), n, typefn(i))
        print "}"

print """
template
ArgTypeT(Tf, uint n)
{
    private Tf fptr;"""

for n in range(1, MAX_ARGS+1):
    if n == 1:
        print "    static if( n == %d )" % n
    else:
        print "    else static if( n == %d )" % n
    print "        alias typeof(Arg%dTypeT(fptr)) type;" % n

print """    else
        static assert(false,
                \"Maximum of %d arguments supported.\");
}""" % MAX_ARGS

print """
template
ArgTypeSwitchT(Tf, uint n)
{
    static if( is( typeof(*Tf) == function ) )
        alias ArgTypeT!(Tf, n).type type;
    else static if( is( Tf U == delegate ) )
        alias ArgTypeSwitchT!(U*, n).type type;
    else
        static assert(false, "ArgType argument must be a function pointer"
                " or a delegate.");
}"""

print """
/**
 * This template will attempt to extract the type of the nth argument of the
 * given function pointer or delegate type.  It supports callables with up to
 * %d arguments.
 *
 * Example:
 * ----------------------------------------
 * void intShortBool(int a, short b, bool c) {}
 * alias ArgType!(typeof(&intShortBool), 2) TArg2; // TArg2 == short
 * ----------------------------------------
 */
public
template
ArgType(Tf, uint n)
{
    alias ArgTypeSwitchT!(Tf, n).type ArgType;
}""" % MAX_ARGS

#
# Unit tests
#

print """
/* *** Unit tests *** */"""

print """
unittest
{
    alias int function()                                    fn_0args;
    alias byte[] function(char)                             fn_1arg;
    alias float[dchar] function(int, int[])                 fn_2args;
    alias void function(int, float[char[]], ifloat[byte])   fn_3args;

    alias int[] delegate()                                  dg_0args;
    alias real delegate(uint[])                             dg_1arg;
    alias void delegate(char[][char[]], bool[short])        dg_2args;
    alias dchar[wchar] delegate(byte, short, int)           dg_3args;

    // ** Test NumberOfArgs(Tf) ** //

    static assert( NumberOfArgs!(fn_0args) == 0 );
    static assert( NumberOfArgs!(fn_1arg) == 1 );
    static assert( NumberOfArgs!(fn_2args) == 2 );
    static assert( NumberOfArgs!(fn_3args) == 3 );
    static assert( NumberOfArgs!(dg_0args) == 0 );
    static assert( NumberOfArgs!(dg_1arg) == 1 );
    static assert( NumberOfArgs!(dg_2args) == 2 );
    static assert( NumberOfArgs!(dg_3args) == 3 );

    // ** Test ReturnType(Tf) ** //

    static assert( is( ReturnType!(fn_0args) == int ) );
    static assert( is( ReturnType!(fn_1arg) == byte[] ) );
    static assert( is( ReturnType!(fn_2args) == float[dchar] ) );
    static assert( is( ReturnType!(fn_3args) == void ) );
    static assert( is( ReturnType!(dg_0args) == int[] ) );
    static assert( is( ReturnType!(dg_1arg) == real ) );
    static assert( is( ReturnType!(dg_2args) == void ) );
    static assert( is( ReturnType!(dg_3args) == dchar[wchar] ) );

    // ** Test ArgType(Tf, n) ** //

    static assert( is( ArgType!(fn_1arg, 1) == char ) );
    static assert( is( ArgType!(fn_2args, 2) == int[] ) );
    static assert( is( ArgType!(fn_3args, 3) == ifloat[byte] ) );
    static assert( is( ArgType!(dg_2args, 1) == char[][char[]] ) );
    static assert( is( ArgType!(dg_3args, 1) == byte ) );
    static assert( is( ArgType!(dg_3args, 2) == short ) );

    pragma(msg, "ftype: passed static unit tests.");
}
"""

# Restore stdout
sys.stdout = old_stdout
