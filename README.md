# echoparser

After messing with an Amazon Echo I think that it could use some work. The problem is their skills api really 
won't let me do what I want (no `ask bla to ...`).

So, I'm trying to see if I can implement the same algorithms myself. After analyzing both the skills api and 
querying the echo I think I've cracked it.

Still a few unanswered questions though:
- How does the echo do maths? (`alexa, one plus one`)
  - (We can probably pipe through wolframalpha)
- Home automation-y stuff
  - We don't really need this in a proof of concept

## License
Copyright (c) 2015 Ryan Gaus (1egoman)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
