
  PROGRAM

  INCLUDE('JSAmbleScrayLite.inc'),ONCE
  INCLUDE('SystemString.inc'),ONCE
  INCLUDE('JS_HexTools.inc'),ONCE

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

OMIT('***')
 * Created with Clarion 10.0
 * User: Jeff Slarve
 * 
 * A demo of using the AmbleScrayLite class
 * https://github.com/jslarve/AmbleScrayLite
 ***

PlainText             CSTRING(5001)         !Plain (original unscrambled) text
Scrambled             CSTRING(5001)         !Scrambled rendition of the plain text
Password              CSTRING(62)           !Password
Ndx                   LONG                  !Generic counter
EnDeCoding            BYTE                  !Used in radio to determine whether or not to encode/decode for a URI or full hex (such as space=%20)
CopyResultToClipboard BYTE                  !Used in checkbox to determine whether or not to copy the resulting encode/decode to clipboard.

SS                    SystemStringClass
Hexer                 JSHexToolsClass       !Used for URI encoding/decoding
AmbleScray            JSAmbleScrayLiteClass !Instance of the scramble class

Window WINDOW('AmbleScray Lite - Byte Scrambling Demo!'),AT(,,497,234),CENTER,GRAY, |
      SYSTEM,FONT('Segoe UI',10)
    PROMPT('Plain Text:'),AT(3,2,33,8),USE(?PROMPT1)
    TEXT,AT(4,13,419,98),USE(PlainText),VSCROLL,FONT('Consolas',12)
    PROMPT('Scrambled:'),AT(3,114,,8),USE(?PROMPT2)
    TEXT,AT(4,125,419,106),USE(Scrambled),VSCROLL,FONT('Consolas',12)
    PROMPT('Password:'),AT(427,2,33,8),USE(?PROMPT3)
    ENTRY(@s60),AT(427,13,67),USE(Password)
    OPTION,AT(426,26,69),USE(EnDeCoding)
      RADIO('En/De-code as Hex'),AT(426,27,73,8),USE(?EnDeCodeAsHex),FONT(,8), |
          TIP('When checked, encodes a characters to hex'), |
          VALUE('2')
      RADIO('En/De-code as URI'),AT(426,35,73,8),USE(?EnDeCodeAsURI),FONT(,8), |
          TIP('When checked, encodes special characters so it''s suitable for us' & |
          'e on URI. NOTE: This also encodes spaces, which is not always desireable.'), |
          VALUE('1')
      RADIO('As-Is'),AT(426,43,73,8),USE(?EnDeCodeAsIs),FONT(,8), |
          TIP('When checked, encodes special characters so it''s suitable for us' & |
          'e on URI. NOTE: This also encodes spaces, which is not always desireable.'), |
          VALUE('0')
    END
    CHECK('Copy to Clipboard'),AT(426,51),USE(CopyResultToClipboard),FONT(,8), |
        TIP('Copies to clipboard the Scrambled or Plaintext result of a scramble' & |
        ' or unscramble operation.')
    BUTTON('Scramble'),AT(427,60,68,14),USE(?ScrambleButton)
    BUTTON('Un-Scramble'),AT(427,130,68,14),USE(?UnScrambleButton)
    BUTTON('Close'),AT(427,216,68),USE(?CloseButton),STD(STD:Close)
    PROMPT('Try changing the password, even in the least significant way, to see' & |
        ' how wildy different the scrambled text looks.'),AT(426,74,70,55), |
        USE(?PROMPT4)
    LIST,AT(427,146,66,68),USE(?ScrambleOrderList),VSCROLL,FORMAT('20R(2)|M~Scra' & |
        'mble Order~C(0)@n20@')
  END

  MAP
  END

  CODE
  
  Password   = 'My Password'
  PlainText  = 'Now is the time for all good folks to come to the aid of their galaxy.'
  
  OPEN(Window)

  POST(EVENT:Accepted,?ScrambleButton)
  ?ScrambleOrderList{PROP:From} = AmbleScray.Q

  ACCEPT
    CASE ACCEPTED()
    OF ?ScrambleButton
      CASE EnDeCoding
      OF 0
        Scrambled = AmbleScray.Scramble(PlainText,Password)   
      OF 1
        Scrambled = AmbleScray.Scramble(Hexer.URI_Encode(PlainText),Password)   
      OF 2
        Scrambled = AmbleScray.Scramble(Hexer.StringToHex(PlainText),Password)   
      END
      DISPLAY(?Scrambled)
      IF CopyResultToClipboard
        SETCLIPBOARD(Scrambled)
      END
    OF ?UnScrambleButton
      PlainText = AmbleScray.UnScramble(Scrambled,Password)
      CASE EnDeCoding
      OF 1
        SS.DisposeIt()
        PlainText = Hexer.URI_Decode(PlainText)
        SS.Append(PlainText)
        SS.Split('<10>',TRUE)
        SS.FromLinesWithEOL()
        PlainText = SS.GetString()
      OF 2
        PlainText = Hexer.HexToString(PlainText)       
      END  
      DISPLAY(?PlainText)
      IF CopyResultToClipboard
        SETCLIPBOARD(PlainText)
      END
    END
  END
  
