  MEMBER

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
  
  INCLUDE('JSAmbleScrayLite.inc'),ONCE
  
  MAP
    VitCRC(*STRING pStr),ULONG !by Geoff Robinson - A CRC32 that's compatible with other languages. https://clarionhub.com/t/crc32-document/4485/9
    ScrambleDataServer(JSAmbleScrayLiteClass pSelf,*STRING pData, STRING pPassword,BYTE pIsDecode),STRING,PRIVATE
  END

!=========================================================================================================================================================
JSAmbleScrayLiteClass.Construct    PROCEDURE
!=========================================================================================================================================================

  CODE
  
  SELF.Q &= NEW JSAmbleScrayLiteQ
  SELF.SetSalt('Moderation')

!=========================================================================================================================================================
JSAmbleScrayLiteClass.Destruct     PROCEDURE
!=========================================================================================================================================================

  CODE
  
  DISPOSE(SELF.Q)
  
!---------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>Generate a seemingly random sort order based on a password and an item count</summary>
!!! <param name="pKey">Key/Password to use in generation</param>
!!! <param name="pCount">The total number of items in list</param>
!!! <returns>Number of items that were generated</returns>
!=========================================================================================================================================================
JSAmbleScrayLiteClass.GenerateMap  PROCEDURE(STRING pKey,LONG pCount)  
!=========================================================================================================================================================
!This procedure is where half of the magic happens.
!Based on the number of items (bytes, or any collection of items) that need scrambling, 
!this method generates the list and sorts it in a repeatable
!yet random seeming way.

ThisKey   &STRING !A concatenation of various elements, including password, salt, and current iteration.
KeySize   LONG    !Size of the key
Ndx       LONG    !Iteration

  CODE

  IF (SIZE(pKey) < 1) OR (pCount < 1)
    RETURN -1
  END
  
  KeySize = (LEN(pCount) * 2) + 1 + SIZE(pKey) + LEN(SELF.Salt) !Using double the number of digits for pCount because we're using it twice.
  
  IF KeySize < 2
    RETURN -1
  END
  
  ThisKey &= NEW STRING(KeySize) 
  
  FREE(SELF.Q)
  
  LOOP Ndx = 1 TO pCount
    ThisKey     = Ndx & 'x' & Ndx & SELF.Salt & pKey !Creating a recreatable string from which we can get the CRC
    SELF.Q.Pos  = Ndx                                !The original position of this item
    SELF.Q.Sort = VitCRC(ThisKey)                    !CRC32 of the key gives us a predictable, but "apparently random" value that we can sort on.
    ADD(SELF.Q)
  END
  
  DISPOSE(ThisKey)
  
  SORT(SELF.Q,SELF.Q.Sort,SELF.Q.Pos)                !Now that we have all of these CRC32 results, we'll sort by them. 
                                                     !If there are any collisions, we then sort by the original position. 
  RETURN RECORDS(SELF.Q)

!---------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>LEGACY - Scramble all of the bits in a buffer to the point that the data is unrecognizable</summary>
!!! <param name="pPlainTextST">A string containing the data to be scrambled</param>
!!! <param name="pPassword">The password to be used to encode this data</param>
!!! <param name="pGenerate">Optionally regenerate scramble map</param>
!!! <returns>String containing Scrambled data</returns>
!=========================================================================================================================================================
JSAmbleScrayLiteClass.Scramble    PROCEDURE(STRING pPlainText,STRING pPassword,LONG pGenerate=TRUE) !LEGACY
!=========================================================================================================================================================
!Scramble the plain text
ReturnString JSDumbString
Ndx          LONG

  CODE  

  IF NOT SIZE(pPlainText)                !Nothing to scramble
    RETURN ''
  END

  ReturnString.SetSize(SIZE(pPlainText))

  IF pGenerate
    SELF.GenerateMap(pPassword, SIZE(pPlainText))
  END  

  LOOP Ndx = 1 TO RECORDS(SELF.Q)
    GET(SELF.Q,Ndx)
    ReturnString.S[SELF.Q.Pos] = pPlainText[Ndx]
  END       
  
  RETURN ReturnString.S


!---------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>Scramble all of the bits in a buffer to the point that the data is unrecognizable</summary>
!!! <param name="pPlainTextST">A string containing the data to be scrambled</param>
!!! <param name="pPassword">The password to be used to encode this data</param>
!!! <param name="pCount">The number of times to scramble the data</param>
!!! <returns>String containing Scrambled data</returns>
!=========================================================================================================================================================
JSAmbleScrayLiteClass.ScrambleData            PROCEDURE(STRING pData,STRING pPassword,LONG pCount=1)!,STRING
!=========================================================================================================================================================
lPassword  JSDumbString
lScrambled JSDumbString
Ndx        LONG

  CODE

  IF NOT SIZE(pData)
    RETURN ''
  END
  IF pCount < 1
    pCount = 1
  END
  lScrambled.SetSize(SIZE(pData))
  lScrambled.S = pData
  LOOP Ndx = 0 TO pCount - 1
    lPassword.SetSize((LEN(pPassword) * 3) + (LEN(Ndx) * 2))
    lPassword.S = pPassword & Ndx & pPassword & Ndx & pPassword
    lScrambled.S = SELF.ScrambleDataServer(lScrambled.S,lPassword.S,FALSE)
  END  
  RETURN lScrambled.S
  
!---------------------------------------------------------------------------------------------------------------------------------------------------------
!=========================================================================================================================================================
JSAmbleScrayLiteClass.ScrambleDataServer      PROCEDURE(*STRING pData, STRING pPassword,BYTE pIsDecode)!,STRING,PRIVATE
!=========================================================================================================================================================
!Scramble the plain text
ReturnString JSDumbString
Ndx          ULONG
SrcNdx       &ULONG
TarNdx       &ULONG

  CODE  

  IF NOT SIZE(pData)                !Nothing to scramble
    RETURN ''
  END

  ReturnString.SetSize(SIZE(pData))
  
  IF pIsDecode
    SrcNdx &= SELF.Q.Pos
    TarNdx &= Ndx
  ELSE
    SrcNdx &= Ndx
    TarNdx &= SELF.Q.Pos
  END

  SELF.GenerateMap(pPassword, SIZE(pData))

  LOOP Ndx = 1 TO RECORDS(SELF.Q)
    GET(SELF.Q,Ndx)
    ReturnString.S[TarNdx] = pData[SrcNdx]
  END       
  
  RETURN ReturnString.S

!---------------------------------------------------------------------------------------------------------------------------------------------------------
!=========================================================================================================================================================
JSAmbleScrayLiteClass.SetSalt PROCEDURE(STRING pSalt)
!=========================================================================================================================================================

  CODE
  
  SELF.Salt = pSalt

!---------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>Un-Scramble all of the bits in a buffer</summary>
!!! <param name="pOutPlainTextST">A String that will receive the un-Scrambled data</param>
!!! <param name="pInScrambledST">A String that contains the scrambled data to be unscrambled</param>
!!! <param name="pPassword">The password to be used to encode this data</param>
!!! <param name="pIterations">The number of times to un-scramble the data</param>
!!! <returns>Number of bits that were scrambled</returns>
!=========================================================================================================================================================
JSAmbleScrayLiteClass.UnScramble    PROCEDURE(STRING pScrambledText,STRING pPassword,LONG pGenerate=TRUE) !LEGACY
!=========================================================================================================================================================
!Scramble the plain text
ReturnString JSDumbString
Ndx          LONG           

  CODE  

  IF NOT SIZE(pScrambledText)                !Nothing to scramble
    RETURN ''
  END

  ReturnString.SetSize(SIZE(pScrambledText))

  IF pGenerate
    SELF.GenerateMap(pPassword, SIZE(pScrambledText))
  END  

  LOOP Ndx = 1 TO RECORDS(SELF.Q)
    GET(SELF.Q,Ndx)
    ReturnString.S[Ndx] = pScrambledText[SELF.Q.Pos]
  END       

  RETURN ReturnString.S

!---------------------------------------------------------------------------------------------------------------------------------------------------------
!---------------------------------------------------------------------------------------------------------------------------------------------------------
!!! <summary>Un-Scramble all of the bits in a buffer to the point that the data is unrecognizable</summary>
!!! <param name="pPlainTextST">A string containing the data to be scrambled</param>
!!! <param name="pPassword">The password to be used to encode this data</param>
!!! <param name="pCount">The number of times to scramble the data</param>
!!! <returns>String containing Scrambled data</returns>
!=========================================================================================================================================================
JSAmbleScrayLiteClass.UnScrambleData            PROCEDURE(STRING pData,STRING pPassword,LONG pCount=1)!,STRING
!=========================================================================================================================================================
lPassword    JSDumbString
lUnScrambled JSDumbString
Ndx        LONG

  CODE

  IF NOT SIZE(pData)
    RETURN ''
  END
  IF pCount < 1
    pCount = 1
  END
  lUnScrambled.SetSize(SIZE(pData))
  lUnScrambled.S = pData
  LOOP Ndx = pCount-1 TO 0 BY -1
    lPassword.SetSize((LEN(pPassword) * 3) + (LEN(Ndx) * 2))
    lPassword.S = pPassword & Ndx & pPassword & Ndx & pPassword
    lUnScrambled.S = SELF.ScrambleDataServer(lUnScrambled.S,lPassword.S,TRUE)
  END  
  RETURN lUnScrambled.S

!=========================================================================================================================================================
VitCRC         PROCEDURE  (*STRING pStr)!,ULONG  
!=========================================================================================================================================================
!Written by Geoff Robinson 
!Using this vs the internal CRC32 for compatibility porpoises

i    LONG,AUTO
crc  ULONG,AUTO

  CODE
  
  IF ~ADDRESS(pStr) 
    RETURN 0 ! just in case
  END  
  crc = 0FFFFFFFFh
  LOOP i = 1 TO SIZE(pStr)
    crc = BXOR(crc,VAL(pStr[i]))
    LOOP 8 TIMES
      crc = BXOR(BSHIFT(crc, -1), BAND(0EDB88320h, -(BAND(crc,1))))
    END 
  END 
  RETURN BXOR(crc,0FFFFFFFFh)  
