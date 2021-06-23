var documenterSearchIndex = {"docs":
[{"location":"frameline/#Frameline-format","page":"Frameline format","title":"Frameline format","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"Main function to define format of the frameline is NoRainbows.format_frameline. It accepts a string, which encodes how final frameline will look like. This string usually has the following format: \"{token1} intermediate text {token2} intermediate text {token3}\", for example \"{frameno:lalign} {module}@:cyan{filepath}\\n  {function}\"","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"Following tokens are supported:","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"frameno: incremental number of the frame, goes from 1 to the number of lines in stackframe. Visually represented as [1], [2] etc. Can be aligned on the left or on the right, in this case one should use one of the modifiers :lalign or :ralign, for example {frameno:ralign}.\nmodule: name of the module, which produces this line. It automatically adds space after last symbol.\nfilepath: name of the file (together with the row number) which produces this line.\nfunction: function definition, which produces this line.","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"Intermediate text usually go as it is, but it can be enclosed in curly brackets (in this case they are ignored). Text can be anything other than 4 predefined words described above and it can have color modifiers. Also, one of the text tokens can have :lalign or :ralign modifier, in this case it is aligned with frameno.","category":"page"},{"location":"frameline/#Examples-of-frameline-format","page":"Frameline format","title":"Examples of frameline format","text":"","category":"section"},{"location":"frameline/#Filepath-based","page":"Frameline format","title":"Filepath based","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"NoRainbows.format_frameline(\"{frameno:lalign} {module}{filepath}\\n  {function}\")","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"(Image: filepath)","category":"page"},{"location":"frameline/#Julia-1.6","page":"Frameline format","title":"Julia 1.6","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"NoRainbows.format_frameline(\" {frameno:ralign} {function}\\n {@:ralign:light_black} {module}{filepath}\")","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"(Image: julia1_6)","category":"page"},{"location":"frameline/#Julia-1.5","page":"Frameline format","title":"Julia 1.5","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"NoRainbows.format_frameline(\"{frameno} {function} at {filepath}\")","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"(Image: julia1_5)","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = NoRainbows","category":"page"},{"location":"#NoRainbows","page":"Home","title":"NoRainbows","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for NoRainbows.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [NoRainbows]","category":"page"}]
}
