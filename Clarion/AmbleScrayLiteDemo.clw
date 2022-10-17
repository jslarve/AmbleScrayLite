
  PROGRAM

  INCLUDE('JSAmbleScrayLite.inc'),ONCE
  INCLUDE('SystemString.inc'),ONCE

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
 * Date: 10/2/2022
 * Time: 9:05 AM
 * 
 * A demo of using the AmbleScrayLite class
 * https://github.com/jslarve/AmbleScrayLite
 ***
PlainText             CSTRING(5001)         !Plain (original unscrambled) text
Scrambled             CSTRING(5001)         !Scrambled rendition of the plain text
Password              CSTRING(62)           !Password
Ndx                   LONG                  !Generic counter
EnDeCodeAsURI         BYTE                  !Used in checkbox to determine whether or not to encode/decode for a URI (such as space=%20)
CopyResultToClipboard BYTE                  !Used in checkbox to determine whether or not to copy the resulting encode/decode to clipboard.

SS                    SystemStringClass     !Used for URI encoding/decoding
AmbleScray            JSAmbleScrayLiteClass !Instance of the scramble class

Window WINDOW('AmbleScray Lite - Byte Scrambling Demo!'),AT(,,497,224),CENTER,GRAY, |
      SYSTEM,FONT('Segoe UI',10)
    PROMPT('Plain Text:'),AT(3,2,33,8),USE(?PROMPT1)
    TEXT,AT(4,13,419,98),USE(PlainText),VSCROLL,FONT('Consolas',12)
    PROMPT('Scrambled:'),AT(3,114,,8),USE(?PROMPT2)
    TEXT,AT(4,125,419,96),USE(Scrambled),VSCROLL,FONT('Consolas',12)
    PROMPT('Password:'),AT(427,2,33,8),USE(?PROMPT3)
    ENTRY(@s60),AT(427,13,67),USE(Password)
    CHECK('En/De-code as URI'),AT(426,28,73,8),USE(EnDeCodeAsURI),FONT(,8), |
        TIP('When checked, encodes special characters so it''s suitable for use ' & |
        'on URI. NOTE: This also encodes spaces, which is not always desireable.')
    CHECK('Copy to Clipboard'),AT(426,38),USE(CopyResultToClipboard),FONT(,8), |
        TIP('Copies to clipboard the Scrambled or Plaintext result of a scramble' & |
        ' or unscramble operation.')
    BUTTON('Scramble'),AT(427,48,68),USE(?ScrambleButton)
    BUTTON('Un-Scramble'),AT(427,125,68),USE(?UnScrambleButton)
    BUTTON('Close'),AT(427,208,68),USE(?CloseButton),STD(STD:Close)
    PROMPT('Try changing the password, even in the least significant way, to see' & |
        ' how wildy different the scrambled text looks.'),AT(426,66,70,58), |
        USE(?PROMPT4)
    LIST,AT(427,141,66,65),USE(?ScrambleOrderList),VSCROLL,FORMAT('20R(2)|M~Scra' & |
        'mble Order~C(0)@n20@')
  END

  MAP
    ClearCstring(*CSTRING pCS) !Force all bytes to <0>
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
      Scrambled = AmbleScray.Scramble(CHOOSE(EnDeCodeAsURI=TRUE,SS.UrlEncode(PlainText),PlainText),Password)   
      !The methods for encoding in C10 SystemString are different than in C11.1, so I'll get back to making this work right at a later date.
      DISPLAY(?Scrambled)
      IF CopyResultToClipboard
        SETCLIPBOARD(Scrambled)
      END
    OF ?UnScrambleButton
      PlainText = AmbleScray.UnScramble(Scrambled,Password)
      IF EnDeCodeAsURI
        SS.DisposeIt()
        PlainText = SS.UrlDecode(PlainText)
        SS.Append(PlainText)
        SS.Split('<10>',TRUE)
        SS.FromLinesWithEOL()
        PlainText = SS.GetString()
      END  
      DISPLAY(?PlainText)
      IF CopyResultToClipboard
        SETCLIPBOARD(PlainText)
      END
    END
  END
  
ClearCString PROCEDURE(*CSTRING pCS)

  CODE
  
  CLEAR(pCS[1 : SIZE(pCS)],-1) ! The string slicing syntax casts the CSTRING to a STRING. CLEAR(STRING,-1) clears a STRING to all 0.
