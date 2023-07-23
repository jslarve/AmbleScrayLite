 MEMBER

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
 
   INCLUDE('JS_HexTools.inc'),ONCE
 
   MAP
   END  

!=========================================================================================================================================================
JSHexToolsClass.Construct PROCEDURE
!=========================================================================================================================================================
Ndx LONG

  CODE
  
  !A lookup table based on the VAL() of a hex digit. Returns the actual value of a hex digit from 0 to F
  SELF.HexValueString     &= NEW STRING(256)
  SELF.HexValueString     = '<0>{47}<0,1,2,3,4,5,6,7,8,9><0>{7}<10,11,12,13,14,15><0>{26}<10,11,12,13,14,15><0>{153}'

  !A boolean lookup table based on the VAL() of a character. A "1" means it's a valid hex digit
  SELF.ValidCharString    &= NEW STRING(256)
  SELF.ValidCharString    = '<0>{47}<1,1,1,1,1,1,1,1,1,1><0>{7}<1,1,1,1,1,1><0>{26}<1,1,1,1,1,1><0>{153}'

  !All of the characters that never need to be URI encoded
  SELF.LegalURICharString &= NEW STRING(62)
  SELF.LegalURICharString = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
  
  !Setting up the URI encoding table.
  !First, we'll just loop through all of the possible values and assign their %xx encoding.
  LOOP Ndx = 0 TO 255
    SELF.URICharTable[Ndx + 1] = '%' & SELF.ByteToHex(Ndx)
  END
  !Then go fix up the legal characters
  LOOP Ndx = 1 TO SIZE(SELF.LegalURICharString)
    SELF.URICharTable[VAL(SELF.LegalURICharString[Ndx]) + 1] = SELF.LegalURICharString[Ndx] & '<000>'
  END

!=========================================================================================================================================================
JSHexToolsClass.Destruct PROCEDURE
!=========================================================================================================================================================

  CODE
  
  DISPOSE(SELF.HexValueString)
  DISPOSE(SELF.ValidCharString)
  DISPOSE(SELF.LegalURICharString)
  
!=========================================================================================================================================================
JSHexToolsClass.HexToInt PROCEDURE(STRING pVal)!,LONG
!=========================================================================================================================================================
ReturnVal  LONG
Ndx        LONG,AUTO
Shift      LONG,AUTO
Limit      LONG,AUTO

  CODE
    
  Limit = CHOOSE(SIZE(pVal) > 8,SIZE(pVal)-8,1) !To ensure we don't exceed 8 nibbles (32 bits) 
  Shift = 0  
  LOOP Ndx = SIZE(pVal) TO Limit BY -1
    ReturnVal += BSHIFT(VAL(SELF.HexValueString[VAL(pVal[Ndx])]),Shift)
    Shift += 4    
  END
  RETURN ReturnVal
  
!=========================================================================================================================================================
JSHexToolsClass.HexToString PROCEDURE(STRING pHex)!,STRING
!=========================================================================================================================================================
ReturnString JSDumbString
ThisByte     &BYTE
ThisAddr     LONG
Ndx          LONG,AUTO

  CODE

  ReturnString.SetSize(SIZE(pHex) / 2)
  CLEAR(ReturnString.S,-1)    
  ThisAddr = ADDRESS(ReturnString.S)
  ThisByte &= (ThisAddr)
  LOOP Ndx = 1 TO SIZE(pHex) 
    IF NOT VAL(SELF.ValidCharString[VAL(pHex[Ndx])])
      CYCLE
    END
    ThisByte = BSHIFT(VAL(SELF.HexValueString[VAL(pHex[Ndx])]),4)
    IF Ndx < SIZE(pHex)
      LOOP Ndx = Ndx + 1 TO SIZE(pHex) 
        IF NOT VAL(SELF.ValidCharString[VAL(pHex[Ndx])])
          CYCLE
        END
        ThisByte = BOR(ThisByte,VAL(SELF.HexValueString[VAL(pHex[Ndx])]))
        IF X# = 0
        END
        BREAK
      END
    END  
    IF ThisAddr < ADDRESS(ReturnString.S) + SIZE(ReturnString.S)
      ThisAddr += 1
      ThisByte &= (ThisAddr)
    END  
  END
  RETURN ReturnString.S[1 : ThisAddr - ADDRESS(ReturnString.S)]  

!=========================================================================================================================================================
JSHexToolsClass.StringToHex PROCEDURE(STRING pText)!,STRING
!=========================================================================================================================================================
ReturnString JSDumbString
Ndx          LONG
ReturnNdx    LONG
 
  CODE

  ReturnString.SetSize(SIZE(pText) * 2)
  ReturnNdx = 1
  LOOP Ndx = 1 TO SIZE(pText)
    ReturnString.S[ReturnNdx : ReturnNdx+1] = SELF.ByteToHex(VAL(pText[Ndx]))
    ReturnNdx += 2
  END
  RETURN ReturnString.S
   
!=========================================================================================================================================================
JSHexToolsClass.URI_Decode   PROCEDURE(STRING pText)!,STRING
!=========================================================================================================================================================
Ndx          LONG
ReturnNdx    LONG
TextSize     LONG
ReturnString JSDumbString

  CODE

  TextSize = SIZE(pText)
  IF NOT TextSize
    RETURN ''
  END
  ReturnString.SetSize(TextSize)
  ReturnNdx = 0
  LOOP Ndx = 1 TO TextSize
    ReturnNdx += 1
    IF pText[Ndx] = '%' AND Ndx + 2 <= TextSize
      ReturnString.S[ReturnNdx] = CHR(SELF.HexToInt(pText[Ndx+1:Ndx+2]))
      Ndx += 2
    ELSE
      ReturnString.S[ReturnNdx] = pText[Ndx]
    END
  END
  
  RETURN ReturnString.S[1 : CHOOSE(ReturnNdx > 0, ReturnNdx, 1)]
  
!=========================================================================================================================================================
JSHexToolsClass.URI_Encode   PROCEDURE(STRING pText)!,STRING
!=========================================================================================================================================================
Ndx          LONG
ReturnNdx1   LONG
ReturnNdx2   LONG
ReturnString JSDumbString

  CODE
  
  ReturnString.SetSize(SIZE(pText) * 3)
  ReturnNdx1 = 1
  ReturnNdx2 = 0
  LOOP Ndx = 1 TO SIZE(pText)
    ReturnNdx1 = ReturnNdx2 + 1
    ReturnNdx2 += LEN(SELF.URICharTable[VAL(pText[Ndx])+1]) 
    ReturnString.S[ReturnNdx1 : ReturnNdx2] = SELF.URICharTable[VAL(pText[Ndx])+1]
  END

  RETURN ReturnString.S[1 : CHOOSE(ReturnNdx2 > 0,ReturnNdx2,1)]
  
!=========================================================================================================================================================
JSHexToolsClass.ByteToHex PROCEDURE(BYTE pByte)!,STRING
!=========================================================================================================================================================
HexString STRING('0123456789ABCDEF')

  CODE
  
 RETURN HexString[ BSHIFT(BAND(pByte,0F0h),-4) + 1 ] & HexString[ BAND(pByte,0Fh) + 1 ]
 
!=========================================================================================================================================================
JSDumbString.Construct PROCEDURE
!=========================================================================================================================================================

  CODE
  
  SELF.S &= NEW STRING(1)
  
!=========================================================================================================================================================
JSDumbString.Destruct PROCEDURE
!=========================================================================================================================================================

  CODE
  
  DISPOSE(SELF.S)
  
!=========================================================================================================================================================
JSDumbString.SetSize PROCEDURE(LONG pSize)  
!=========================================================================================================================================================

  CODE

  IF pSize < 1
    pSize = 1
  END
  
  IF (SELF.S &= NULL) OR (SIZE(SELF.S) <> pSize)
    DISPOSE(SELF.S)
    SELF.S &= NEW STRING(pSize)
  END  