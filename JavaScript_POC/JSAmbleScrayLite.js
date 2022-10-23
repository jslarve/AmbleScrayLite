/*
MIT License

Copyright (c) 2022 Jeff Slarve

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

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

// Version a.001
// Likely to change for re-usability's sake, as I am not well versed in javaScript :)

let ambleScrayDiv = document.getElementById("AmbleScray");
let ambleScrayButtonsDiv = document.getElementById("AmbleScrayButtons");

const encodeButton = document.createElement("input");
encodeButton.setAttribute("type", "button");
encodeButton.value = "Scramble";
encodeButton.className = "amble-scray-encodebutton";
encodeButton.onclick = function (event) {
  scrambleData("scramble");
};
ambleScrayButtonsDiv.appendChild(encodeButton);

const decodeButton = document.createElement("input");
decodeButton.setAttribute("type", "button");
decodeButton.value = "UnScramble";
decodeButton.className = "amble-scray-encodebutton";
decodeButton.onclick = function (event) {
  scrambleData("unscramble");
};
ambleScrayButtonsDiv.appendChild(decodeButton);

ambleScrayButtonsDiv.appendChild(document.createElement("br"));

const encodeAsURICheck = document.createElement("input");
encodeAsURICheck.setAttribute("type", "checkbox");
encodeAsURICheck.id = "encodeAsURICheck";
encodeAsURICheck.checked = false;
ambleScrayButtonsDiv.appendChild(encodeAsURICheck);
const encodeLabel = document.createElement("label");
encodeLabel.for = "encodeAsURICheck";
encodeLabel.innerHTML = "Pre-Process Special Characters";
ambleScrayButtonsDiv.appendChild(encodeLabel);

ambleScrayButtonsDiv.appendChild(document.createElement("br"));

const copyResultToClipboard = document.createElement("input");
copyResultToClipboard.setAttribute("type", "checkbox");
copyResultToClipboard.id = "copyResultToClipboard";
copyResultToClipboard.checked = false;
ambleScrayButtonsDiv.appendChild(copyResultToClipboard);
const clipboardLabel = document.createElement("label");
clipboardLabel.for = "copyResultToClipboard";
clipboardLabel.innerHTML = "Copy Result to Clipboard";
ambleScrayButtonsDiv.appendChild(clipboardLabel);

const passwordLabel = document.createElement("label");
passwordLabel.for = "passWord";
passwordLabel.innerHTML = "Password:";
ambleScrayDiv.appendChild(passwordLabel);
ambleScrayDiv.appendChild(document.createElement("br"));

const passWordEntry = document.createElement("input");
passWordEntry.setAttribute("type", "text");
passWordEntry.id = "passWord";
passWordEntry.className = "amble-scray-password";
ambleScrayDiv.appendChild(passWordEntry);

ambleScrayDiv.appendChild(document.createElement("br"));

const plainTextLabel = document.createElement("label");
plainTextLabel.for = "plainTextEntry";
plainTextLabel.innerHTML = "Plain Text:";
ambleScrayDiv.appendChild(plainTextLabel);

ambleScrayDiv.appendChild(document.createElement("br"));

const plainTextEntry = document.createElement("textarea");
plainTextEntry.setAttribute("type", "textarea");
plainTextEntry.className = "amble-scray-text";
plainTextEntry.id = "plainTextEntry";
// plainTextEntry.value = "Now is the time for all good folks to come to the aid of their galaxy.";
ambleScrayDiv.appendChild(plainTextEntry);

ambleScrayDiv.appendChild(document.createElement("br"));

const scrambleTextLabel = document.createElement("label");
scrambleTextLabel.for = "scrambleTextEntry";
scrambleTextLabel.innerHTML = "Scrambled Text:";
ambleScrayDiv.appendChild(scrambleTextLabel);

ambleScrayDiv.appendChild(document.createElement("br"));

const scrambleTextEntry = document.createElement("textarea");
scrambleTextEntry.setAttribute("type", "textarea");
scrambleTextEntry.className = "amble-scray-text";
ambleScrayDiv.appendChild(scrambleTextEntry);

function scrambleData(pAction) {
  crc32 = new Checksum("crc32");
  let scrambleList = new Array();
  let passWord = passWordEntry.value;
  //passWordEntry.value = passWord;
  let salt = "Moderation";
  if (pAction == "scramble") {
    var plainText = plainTextEntry.value;
    if (encodeAsURICheck.checked == true) {
      plainText = encodeURIComponent(plainText);
    }
    var scrambleText = "";
    var byteCount = plainText.length;
  } else {
    var plainText = "";
    plainTextEntry.value = "";
    var scrambleText = scrambleTextEntry.value;
    var byteCount = scrambleText.length;
  }

  var byteDigits = byteCount.toString().length;
  let padSize = byteDigits * 2 + 1 + salt.length + passWord.length;
  console.log("byteDigits=" + byteDigits + "  padSize=" + padSize);
  for (let ndx = 1; ndx < byteCount + 1; ndx++) {
    crc32.result = 0;
    crc32.updateStringly(
      ndx + "x" + ndx + salt + passWord + getPadding(ndx, byteDigits)
    );
    scrambleList.push([ndx, crc32.result]);
  }

  scrambleList.sort(function (a, b) {
    return a[1] - b[1];
  });
  let curPos = 0;
  scrambleArray = scrambleText.split();
  plainArray = plainText.split();
  scrambleList.forEach(scrambleTheText);
  scrambleText = scrambleArray.join("");
  plainText = plainArray.join("");
  if (pAction === "scramble") {
    scrambleTextEntry.value = scrambleText;
    if (copyResultToClipboard.checked == true) {
      navigator.clipboard.writeText(scrambleText);
    }
  } else {
    if (encodeAsURICheck.checked == true) {
      plainTextEntry.value = decodeURIComponent(plainText);
    } else {
      plainTextEntry.value = plainText;
    }
    if (copyResultToClipboard.checked == true) {
      navigator.clipboard.writeText(plainTextEntry.value);
    }
  }
  function scrambleTheText(item) {
    if (pAction === "scramble") {
      scrambleArray[item[0] - 1] = plainText[curPos];
    } else {
      plainArray[curPos] = scrambleText[item[0] - 1];
      //console.log(scrambleText[item[0] - 1] );  // x
    }
    curPos += 1;
  }

  function getPadding(pNdx, pByteDigits) {
    let returnString = "";
    if (pByteDigits > pNdx.toString().length) {
      returnString = " ".repeat((pByteDigits - pNdx.toString().length) * 2);
    }
    return returnString;
  }
  console.log(scrambleText);
}