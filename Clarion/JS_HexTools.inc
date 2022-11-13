!ABCIncludeFile

!***Change Log
! 2022.11.13 Created Class

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


 OMIT('_EndOfInclude_',_JSHexToolsPresent_)

_JSHexToolsPresent_ EQUATE(1)

JSDumbString     CLASS,TYPE,MODULE('JS_HexTools.clw'),LINK('JS_HexTools.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
S                  &STRING
Construct          PROCEDURE
Destruct           PROCEDURE
SetSize            PROCEDURE(LONG pSize)
                 END

JSHexToolsClass  CLASS,TYPE,MODULE('JS_HexTools.clw'),LINK('JS_HexTools.clw',_ABCLinkMode_),DLL(_ABCDllMode_)
URICharTable       CSTRING(4),DIM(256) !Stores the valid URI representations of characters
HexValueString     &STRING             !A lookup table based on the VAL() of a hex digit. Returns the actual value of a hex digit from 0 to F
ValidCharString    &STRING             !A boolean lookup table based on the VAL() of a character. A "1" means it's a valid hex digit
LegalURICharString &STRING             !All of the characters that never need to be URI encoded
Construct          PROCEDURE
Destruct           PROCEDURE
ByteToHex          PROCEDURE(BYTE pByte),STRING
StringToHex        PROCEDURE(STRING pText),STRING
HexToInt           PROCEDURE(STRING pVal),LONG
HexToString        PROCEDURE(STRING pHex),STRING
URI_Decode         PROCEDURE(STRING pText),STRING  
URI_Encode         PROCEDURE(STRING pText),STRING  
                 END

_EndOfInclude_