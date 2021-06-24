var documenterSearchIndex = {"docs":
[{"location":"frameline/#Frameline-format","page":"Frameline format","title":"Frameline format","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"Main function to define format of the frameline is NoRainbows.format_frameline. It accepts a string, which encodes how final frameline will look like. This string usually has the following format: \"{token1} intermediate text {token2} intermediate text {token3}\", for example \"{frameno:lalign} {module}@:cyan{filepath}\\n  {function}\"","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"Following tokens are supported:","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"frameno: incremental number of the frame, goes from 1 to the number of lines in stackframe. Visually represented as [1], [2] etc. Can be aligned on the left or on the right, in this case one should use one of the modifiers :lalign or :ralign, for example {frameno:ralign}.\nmodule: name of the module, which produces this line. It automatically adds space after last symbol.\nfilepath: name of the file (together with the row number) which produces this line.\nfunction: function definition, which produces this line.","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"Intermediate text usually go as it is, but it can be enclosed in curly brackets (in this case they are ignored). Text can be anything other than 4 predefined words described above and it can have color modifiers. Also, one of the text tokens can have :lalign or :ralign modifier, in this case it is aligned with frameno.","category":"page"},{"location":"frameline/#Examples-of-frameline-format","page":"Frameline format","title":"Examples of frameline format","text":"","category":"section"},{"location":"frameline/#Filepath-based","page":"Frameline format","title":"Filepath based","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"NoRainbows.format_frameline(\"{frameno:lalign} {module}{filepath}\\n  {function}\")","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"(Image: filepath)","category":"page"},{"location":"frameline/#Julia-1.6","page":"Frameline format","title":"Julia 1.6","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"NoRainbows.format_frameline(\" {frameno:ralign} {function}\\n {@:ralign:light_black} {module}{filepath}\")","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"(Image: julia1_6)","category":"page"},{"location":"frameline/#Julia-1.5","page":"Frameline format","title":"Julia 1.5","text":"","category":"section"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"NoRainbows.format_frameline(\"{frameno} {function} at {filepath}\")","category":"page"},{"location":"frameline/","page":"Frameline format","title":"Frameline format","text":"(Image: julia1_5)","category":"page"},{"location":"colors/#Colors","page":"Colors","title":"Colors","text":"","category":"section"},{"location":"colors/","page":"Colors","title":"Colors","text":"All color related functions can accept color in one of two ways:","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"As an instance of the NoRainbows.Color structure\nAs a string of the form \"<color>:<modifier1>:<modifier2>...\"","category":"page"},{"location":"colors/#Color-string-format","page":"Colors","title":"Color string format","text":"","category":"section"},{"location":"colors/","page":"Colors","title":"Colors","text":"Color string consists of color and modifiers in any order, written after semicolon. For example","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"\"red\"\n\"red:bold\"\n\"red:bold:underline\"\n\"23:reverse\"","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"etc.","category":"page"},{"location":"colors/#Color-values","page":"Colors","title":"Color values","text":"","category":"section"},{"location":"colors/","page":"Colors","title":"Colors","text":"Possible colors are defined in Base.text_colors and can be either text strings or integer numbers. Standard text color names are","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"default\nnormal\nwhite\nblack\ngreen\nblue\ncyan\nyellow\nmagenta\nred\nlight_black\nlight_green\nlight_blue\nlight_cyan\nlight_yellow\nlight_magenta\nlight_red","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"These names are only color tags, actual colors depends on your colorscheme.","category":"page"},{"location":"colors/#Modifiers","page":"Colors","title":"Modifiers","text":"","category":"section"},{"location":"colors/","page":"Colors","title":"Colors","text":"Possible modifiers are","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"bold\nunderline\nblink\nreverse\nhidden","category":"page"},{"location":"colors/","page":"Colors","title":"Colors","text":"Their effect depends on your terminal and colorscheme.","category":"page"},{"location":"reverse/#Reverse-logging","page":"Reverse stacktrace","title":"Reverse logging","text":"","category":"section"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"By default Julia prints stacktraces in descending order: first element in the stack displayed as the last line of the print. Since it can be not convenient sometimes, one can use reverse argument of the NoRainbows.set_globals to change the print direction. By default it is false.","category":"page"},{"location":"reverse/#Examples-of-the-reverse-usage","page":"Reverse stacktrace","title":"Examples of the reverse usage","text":"","category":"section"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"This is standard printing of the stacktraces","category":"page"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"NoRainbows.set_globals(reverse = false)","category":"page"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"(Image: noreverse)","category":"page"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"Here is reversed version of the same stacktraces, where first element of the stack is printed at the top","category":"page"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"NoRainbows.set_globals(reverse = true)","category":"page"},{"location":"reverse/","page":"Reverse stacktrace","title":"Reverse stacktrace","text":"(Image: reverse)","category":"page"},{"location":"colorschemes/#Colorschemes","page":"Colorschemes","title":"Colorschemes","text":"","category":"section"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"There are four main elements of the frameline which can be colorized:","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"Frame number\nModule name\nFilepath of the file which generates corresponding frame line\nFunction and it's signature","category":"page"},{"location":"colorschemes/#Frame-number","page":"Colorschemes","title":"Frame number","text":"","category":"section"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"Frame number is an (optional) element, which is usually added at the beginning of the frame line and is represented as [<frameline number>]. It's colormap can be changed with the help of NoRainbows.set_framenumber(; frameno).","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"For example","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"NoRainbows.set_framenumber(frameno = \"red\")","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"(Image: frameno_red)","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"NoRainbows.set_framenumber(frameno = \"blue:underline\")","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"(Image: frameno_red)","category":"page"},{"location":"colorschemes/#Module-name","page":"Colorschemes","title":"Module name","text":"","category":"section"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"There are two possible ways to set color of the Module. They can either be fixed per module, which is useful, when you want to highlight any particular module. Or they can rotate cyclicaly through the predefined set of colors.","category":"page"},{"location":"colorschemes/#Fixed-module-colors","page":"Colorschemes","title":"Fixed module colors","text":"","category":"section"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"Dictionary of currently defined colors can be obtained and manipulated with the NoRainbows.get_module_fixed(). Additionaly to usual dictionary operations, one can redefine whole mapping with the help of NoRainbows.set_module_fixed(d::Dict), for example","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"using MyPkg\n\nNoRainbows.set_module_fixed(Dict(MyPkg => \"red:bold\", Base => \"yellow\"))","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"(Image: modules_fixed)","category":"page"},{"location":"colorschemes/#Filepath","page":"Colorschemes","title":"Filepath","text":"","category":"section"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"Filepaths (and some extra information) are set with the NoRainbows.set_filepath function.","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"For example","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"NoRainbows.set_filepath(filepath = \"red:underline\", colon = \"blue\", lineno = \"yellow\", inlined = \"magenta:bold\")","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"(Image: filepath_all)","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"As one can see, filepath is the color of the file path, colon is the color of the colon after file path, lineno is the color of the number after colon, and inlined is the color of the [inlined] keyword which appears if function is inlined.","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"Additionaly there is a special default argument, which, when it is set, applies to all arguments, if they are not listed explicitly.","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"NoRainbows.set_filepath(default = \"red:underline\", lineno = \"blue:bold\")","category":"page"},{"location":"colorschemes/","page":"Colorschemes","title":"Colorschemes","text":"(Image: filepath_default)","category":"page"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = NoRainbows","category":"page"},{"location":"#NoRainbows","page":"Home","title":"NoRainbows","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for NoRainbows.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [NoRainbows]","category":"page"},{"location":"#NoRainbows.set_filepath-Tuple{}","page":"Home","title":"NoRainbows.set_filepath","text":"set_filepath(;\n    default = nothing,\n    filepath = nothing,\n    colon = nothing,\n    lineno = nothing,\n    inlined = nothing\n)\n\nSet color attributes of the filepath which generate corresponding frameline.\n\n\n\n\n\n","category":"method"}]
}
