/*
Copyright (c) 2006 Daniel Keep, Tomasz Stachowiak

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/**
 * This module contains templates for inferring the number of arguments,
 * the return type, and argument types of an arbitrary function pointer.
 * 
 * Portions of this module were automatically generated by Python modules.
 *
 * Authors: Daniel Keep, Tomasz Stachowiak
 * Date: $(DATETIME)
 */
module pyd.ftype;
private:

/* *** NumberOfArgs(Tf) *** */

typedef uint Arglen0 = 0;
typedef uint Arglen1 = 1;
typedef uint Arglen2 = 2;
typedef uint Arglen3 = 3;
typedef uint Arglen4 = 4;
typedef uint Arglen5 = 5;
typedef uint Arglen6 = 6;
typedef uint Arglen7 = 7;
typedef uint Arglen8 = 8;
typedef uint Arglen9 = 9;
typedef uint Arglen10 = 10;

template
ArglenT(Tr)
{
    Arglen0
    ArglenT(Tr function() fn) { assert(false); }
}

template
ArglenT(Tr, Ta1)
{
    Arglen1
    ArglenT(Tr function(Ta1) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2)
{
    Arglen2
    ArglenT(Tr function(Ta1, Ta2) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3)
{
    Arglen3
    ArglenT(Tr function(Ta1, Ta2, Ta3) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4)
{
    Arglen4
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5)
{
    Arglen5
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Arglen6
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Arglen7
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Arglen8
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Arglen9
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
ArglenT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Arglen10
    ArglenT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
ArglenConvT(T)
{
    const uint ArglenConvT = T.init;
}

template
NumberOfArgsT(Tf)
{
    private Tf fptr;
    alias typeof(ArglenT(fptr)) type;
}

/**
 * Derives the number of arguments the passed function type accepts. It only
 * works on functions with 10 or fewer arguments.
 */
public
template
NumberOfArgs(Tf)
{
    const uint NumberOfArgs = ArglenConvT!(NumberOfArgsT!(Tf).type);
}

// Thanks to Tomasz Stachowiak for the Deref and ReturnType templates!
template Deref(T) {
    alias typeof(*T) Deref;
}

/**
 * Derives the return type of the passed function type.
 */
public
template ReturnType(T) {
    static if (is(Deref!(T) U == function)) {
        alias U ReturnType;
    } else static if (is(Deref!(T) U == delegate)) {
        alias ReturnType!(U) ReturnType;
    } else static assert (false);
}

/* *** ArgType(Tf, n) *** */

template
Arg1TypeT(Tr, Ta1)
{
    Ta1 Arg1TypeT(Tr function(Ta1) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg1TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta1 Arg1TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg2TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta2 Arg2TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg3TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta3 Arg3TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg4TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta4 Arg4TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg5TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5)
{
    Ta5 Arg5TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5) fn) { assert(false); }
}

template
Arg5TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Ta5 Arg5TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
Arg5TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta5 Arg5TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg5TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta5 Arg5TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg5TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta5 Arg5TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg5TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta5 Arg5TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg6TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6)
{
    Ta6 Arg6TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6) fn) { assert(false); }
}

template
Arg6TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta6 Arg6TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg6TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta6 Arg6TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg6TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta6 Arg6TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg6TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta6 Arg6TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg7TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7)
{
    Ta7 Arg7TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7) fn) { assert(false); }
}

template
Arg7TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta7 Arg7TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg7TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta7 Arg7TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg7TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta7 Arg7TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg8TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8)
{
    Ta8 Arg8TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8) fn) { assert(false); }
}

template
Arg8TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta8 Arg8TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg8TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta8 Arg8TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg9TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9)
{
    Ta9 Arg9TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9) fn) { assert(false); }
}

template
Arg9TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta9 Arg9TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
Arg10TypeT(Tr, Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10)
{
    Ta10 Arg10TypeT(Tr function(Ta1, Ta2, Ta3, Ta4, Ta5, Ta6, Ta7, Ta8, Ta9, Ta10) fn) { assert(false); }
}

template
ArgTypeT(Tf, uint n)
{
    private Tf fptr;
    static if( n == 1 )
        alias typeof(Arg1TypeT(Tf)) type;
    else static if( n == 2 )
        alias typeof(Arg2TypeT(Tf)) type;
    else static if( n == 3 )
        alias typeof(Arg3TypeT(Tf)) type;
    else static if( n == 4 )
        alias typeof(Arg4TypeT(Tf)) type;
    else static if( n == 5 )
        alias typeof(Arg5TypeT(Tf)) type;
    else static if( n == 6 )
        alias typeof(Arg6TypeT(Tf)) type;
    else static if( n == 7 )
        alias typeof(Arg7TypeT(Tf)) type;
    else static if( n == 8 )
        alias typeof(Arg8TypeT(Tf)) type;
    else static if( n == 9 )
        alias typeof(Arg9TypeT(Tf)) type;
    else static if( n == 10 )
        alias typeof(Arg10TypeT(Tf)) type;
    else
        { static assert(false); }
}

/**
 * Derives the type of an individual argument of function Tf.
 * Params:
 *      Tf = A function pointer type
 *      n = The 1-indexed function argument to get the type of, e.g.:
 *          $(D_CODE int func(int, char, real);
 *static assert( is(char == _ArgType(&func, 2)) );)
 */
public
template
ArgType(Tf, uint n)
{
    alias ArgTypeT!(Tf, n).type ArgType;
}

