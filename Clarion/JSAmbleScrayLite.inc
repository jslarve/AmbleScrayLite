!ABCIncludeFile

!MIT License
!
!Copyright (c) 2022 Jeff Slarve
!
!Permission is hereby granted, free of charge, to any person obtaining a copy
!of this software and associated documentation files (the "Software"), to deal
!in the Software without restriction, including without limitation the rights
!to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
!copies of the Software, and to permit persons to whom the Software is
!furnished to do so, subject to the following conditions:
!
!The above copyright notice and this permission notice shall be included in all
!copies or substantial portions of the Software.
!
!THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
!IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
!FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
!AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
!LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
!OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
!SOFTWARE.


 OMIT('_EndOfInclude_',_JSAmbleScrayLitePresent_)

_JSAmbleScrayLitePresent_ EQUATE(1)

  INCLUDE('SystemString.inc'),ONCE

JSAmbleScrayLiteQ  QUEUE,TYPE
Pos                  ULONG
Sort                 ULONG
                   END   
              
JSAmbleScrayLiteClass CLASS,TYPE,MODULE('JSAmbleScrayLite.clw'),LINK('JSAmbleScrayLite.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
Q                    &JSAmbleScrayLiteQ
Salt                  CSTRING(61)
Construct             PROCEDURE
Destruct              PROCEDURE,VIRTUAL
GenerateMap           PROCEDURE(STRING pPassword,LONG pCount),LONG,PROC,VIRTUAL
Scramble              PROCEDURE(STRING pPlainText,STRING pPassword,LONG pGenerate=TRUE),STRING
SetSalt               PROCEDURE(STRING pSalt)
UnScramble            PROCEDURE(STRING pScrambledText,STRING pPassword,LONG pGenerate=TRUE),STRING
                   END

!_EndOfInclude_