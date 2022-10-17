# AmbleScrayLite
## Scramble data by way of a password.

Version a.01.

AmbleScray Lite is basically a simple way to re-arrange data in a reliably repeatable way. All it needs to know is how many bytes of data need to be scrambled and a password. Changing the password, even in the smallest way, will wildly change the order of the bytes. 

"Scrambled", in the case of this code, means that all of the same byte values are still in the string, but they're just really really mixed up. 

![ScreenShot](./Images/AmbleScray.gif)

In this release, there is a Clarion demo & class. 

There is also an example of how this could be written in javaScript, but it is just a basic example. It needs a bit of work to use as a library.
