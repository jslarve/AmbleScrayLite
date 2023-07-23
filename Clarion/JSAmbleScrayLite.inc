!ABCIncludeFile

!***Change Log
! 2023.07.22 Added new ScrambleData/UnScrambleData methods to make compatible with other AmbleScray libraries. Existing methods left intact for backward compatibility.
! 2022.11.13 Added hex class to support HEX/URI conversion without version discrepancies in the SystemString Class between versions
! 2022.10.24 Some cleanup as suggested by Geoff Robinson
! 2022.10.22 Initial Release

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

  INCLUDE('JS_HexTools.inc'),ONCE 

JSAmbleScrayLiteQ     QUEUE,TYPE
Pos                     ULONG
Sort                    ULONG
                      END   
              
JSAmbleScrayLiteClass CLASS,TYPE,MODULE('JSAmbleScrayLite.clw'),LINK('JSAmbleScrayLite.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
Q                       &JSAmbleScrayLiteQ
Salt                    CSTRING(61)
Construct               PROCEDURE
Destruct                PROCEDURE,VIRTUAL
GenerateMap             PROCEDURE(STRING pPassword,LONG pCount),LONG,PROC,VIRTUAL
Scramble                PROCEDURE(STRING pPlainText,STRING pPassword,LONG pGenerate=TRUE),STRING     !Original method for backwards compatibility
ScrambleData            PROCEDURE(STRING pData,STRING pPassword,LONG pCount=1),STRING
SetSalt                 PROCEDURE(STRING pSalt)
UnScramble              PROCEDURE(STRING pScrambledText,STRING pPassword,LONG pGenerate=TRUE),STRING !Original method for backwards compatibility
UnScrambleData          PROCEDURE(STRING pData,STRING pPassword,LONG pCount=1),STRING
                      END

!_EndOfInclude_