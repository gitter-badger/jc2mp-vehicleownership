# JC2-MP Vehicle Ownership System

## Installation

* Fistly make sure you have mysql installed.

1. Create a folder under 'scripts' folder.
2. Put 'client' and 'server' folder into the folder that you has created just now.
3. Open 'config.lua' of your server and find the following text:
    ```IKnowWhatImDoing = false
    ```
	and change it to:
    ```IKnowWhatImDoing = true
    ```
4. Import 'jc2mp_vehicle.sql' to your mysql database
5. Change mysql connection details at 18 line in server/mysql_test.lua
6. Finished!

## Contribute

  Because of this script is still need develop, fork and pull-requests are welcome.

## License

The MIT License (MIT)

Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
