module NoRainbows

import Base: print_stackframe, show_tuple_as_call, print_type_stacktrace, print_within_stacktrace, show_method_params, show_signature_function, show_full_backtrace, printstyled, with_output_color, showerror, show_backtrace
import Base.StackTraces: show_spec_linfo

using Core: MethodInstance, CodeInfo
using Base: StackFrame, stacktrace_expand_basepaths, stacktrace_contract_userdir, contractuser, unwrap_unionall, demangle_function_name, show_sym, parentmodule, empty_sym, text_colors, disable_text_style, is_exported_from_stdlib, process_backtrace, BIG_STACKTRACE_SIZE, stacktrace_linebreaks
using Base.StackTraces: top_level_scope_sym, is_top_level_frame

include("colors.jl")
include("pkg_colormap.jl")
include("frameline.jl")

@Base.kwdef struct ArgsTypesColorMap
    nonparamtypes::Color = Color()
    paramtypemain::Color = Color()
    paramtypearg::Color = Color()
    brackets::Color = Color()
end
const ARGTYPE_COLORS = Ref(ArgsTypesColorMap())
function set_argtype_map(;
    default = nothing,
    nonparamtypes = nothing,
    paramtypemain = nothing,
    paramtypearg = nothing,
    brackets = nothing,
)
    c = ARGTYPE_COLORS[]
    ARGTYPE_COLORS[] = ArgsTypesColorMap(;
        nonparamtypes = Color(coal(nonparamtypes, default, c.nonparamtypes)),
        paramtypemain = Color(coal(paramtypemain, default, c.paramtypemain)),
        paramtypearg = Color(coal(paramtypearg, default, c.paramtypearg)),
        brackets = Color(coal(brackets, default, c.brackets))
    )

    return nothing
end

@Base.kwdef struct TrackColorMap
    tin::Color = Color()
    tout::Color = Color()
end
const TRACK_COLORS = Ref(TrackColorMap())
function set_track_map(;
    default = nothing,
    trackin = nothing,
    trackout = nothing
)
    c = TRACK_COLORS[]
    TRACK_COLORS[] = TrackColorMap(;
        tin = Color(coal(trackin, default, c.tin)),
        tout = Color(coal(trackout, default, c.tout))
    )

    return nothing
end

@Base.kwdef struct MethodParamsColorMap
    brackets::Color = Color()
    comma::Color = Color()
    wher::Color = Color()
    types::Color = Color()
end
const METHODPARAMS_COLORS = Ref(MethodParamsColorMap())
function set_methodparams_map(;
    default = nothing,
    brackets = nothing,
    wher = nothing,
    types = nothing,
)
    c = METHODPARAMS_COLORS[]
    METHODPARAMS_COLORS[] = MethodParamsColorMap(;
        brackets = Color(coal(brackets, default, c.brackets)),
        wher = Color(coal(wher, default, c.wher)),
        types = Color(coal(types, default, c.types)),
    )

    return nothing
end

@Base.kwdef struct TupleCallColorMap
    tuple::Color = Color()
    brackets::Color = Color()
    doublecolon::Color = Color()
    comma::Color = Color()
    semicolon::Color = Color()
    args::Color = Color()
    kwargs::Color = Color()
end
const TUPLE_CALL_COLORS = Ref(TupleCallColorMap())
function set_tuplecall_map(;
    default = nothing,
    tuple = nothing,
    brackets = nothing,
    doublecolon = nothing,
    comma = nothing,
    semicolon = nothing,
    args = nothing,
    kwargs = nothing
)
    c = TUPLE_CALL_COLORS[]
    TUPLE_CALL_COLORS[] = TupleCallColorMap(
        tuple = Color(coal(tuple, default, c.tuple)),
        brackets = Color(coal(brackets, default, c.brackets)),
        doublecolon = Color(coal(doublecolon, default, c.doublecolon)),
        comma = Color(coal(comma, default, c.comma)),
        semicolon = Color(coal(semicolon, default, c.semicolon)),
        args = Color(coal(args, default, c.args)),
        kwargs = Color(coal(kwargs, default, c.kwargs))
    )

    return nothing
end

@Base.kwdef struct SpecLinfoColorMap
    ipx::Color = Color()
    toplevel::Color = Color()
    repeats::Color = Color()
    modulename::Color = Color()
    funcname::Color = Color()
    brackets::Color = Color()
    wrapper::Color = Color()
    functor::Color = Color()
end
const SPECLINFO_COLORS = Ref(SpecLinfoColorMap())
function set_speclinfo_map(;
    default = nothing,
    ipx = nothing,
    toplevel = nothing,
    repeats = nothing,
    modulename = nothing,
    funcname = nothing,
    brackets = nothing,
    wrapper = nothing,
    functor = nothing,
)
    c = SPECLINFO_COLORS[]
    SPECLINFO_COLORS[] = SpecLinfoColorMap(
        ipx = Color(coal(ipx, default, c.ipx)),
        toplevel = Color(coal(toplevel, default, c.toplevel)),
        repeats = Color(coal(repeats, default, c.repeats)),
        modulename = Color(coal(modulename, default, c.modulename)),
        funcname = Color(coal(funcname, default, c.funcname)),
        brackets = Color(coal(brackets, default, c.brackets)),
        wrapper = Color(coal(wrapper, default, c.wrapper)),
        functor = Color(coal(functor, default, c.functor))
    )

    return nothing
end

@Base.kwdef struct FrameNumberMap
    frameno::Color = Color()
    brackets::Color = Color()
end
const FRAME_NUMBER = Ref(FrameNumberMap())
"""
    set_framenumber(;
        default = nothing,
        frameno = nothing,
        brackets = nothing
    )

Set color attributes of the frame number where frameline was generated.
"""
function set_framenumber(;
        default = nothing,
        frameno = nothing,
        brackets = nothing,
    )
    c = FRAME_NUMBER[]
    FRAME_NUMBER[] = FrameNumberMap(
        frameno = Color(coal(frameno, default, c.frameno)),
        brackets = Color(coal(brackets, default, c.brackets))
    )

    return nothing
end

@Base.kwdef struct FilepathColorMap
    filepath::Color = Color()
    colon::Color = Color()
    lineno::Color = Color()
    inlined::Color = Color()
end
const FILEPATH_COLORS = Ref(FilepathColorMap())
"""
    set_filepath(;
        default = nothing,
        filepath = nothing,
        colon = nothing,
        lineno = nothing,
        inlined = nothing
    )

Set color attributes of the filepath which generate corresponding frameline.
"""
function set_filepath(;
    default = nothing,
    filepath = nothing,
    colon = nothing,
    lineno = nothing,
    inlined = nothing
)
    c = FILEPATH_COLORS[]
    filepath = Color(coal(filepath, default, c.filepath))
    colon = Color(coal(colon, default, c.colon))
    lineno = Color(coal(lineno, default, c.lineno))
    inlined = Color(coal(inlined, default, c.inlined))

    FILEPATH_COLORS[] = FilepathColorMap(
        filepath = filepath,
        colon = colon,
        lineno = lineno,
        inlined = inlined
    )
end

@Base.kwdef struct GlobalOptions
    reverse::Bool = false
    align_numbering::Bool = false
    stackcolor::Color = Color()
end
const GLOBAL = Ref(GlobalOptions())
function set_globals(;
    reverse = nothing,
    stackcolor = nothing,
    align_numbering = nothing,
)
    c = GLOBAL[]
    col = Color(stackcolor === nothing ? c.stackcolor : stackcolor)
    rev = reverse === nothing ? c.reverse : reverse
    align = align_numbering === nothing ? c.align_numbering : align_numbering

    GLOBAL[] = GlobalOptions(rev, align, col)

    return nothing
end

const STACKTRACE_MODULECOLORS = [Color(), Color(), Color(), Color()]
const STACKTRACE_FIXEDCOLORS = IdDict(Base => Color(), Core => Color())
const TRACK_MODUL = Module[]
function track_modules(moduls...)
    empty!(TRACK_MODUL)
    for modul in moduls
        push!(TRACK_MODUL, modul)
    end

    return nothing
end


get_module_fixed() = STACKTRACE_FIXEDCOLORS
function set_module_fixed(d)
    empty!(STACKTRACE_FIXEDCOLORS)
    for (k, v) in d
        STACKTRACE_FIXEDCOLORS[k] = Color(v)
    end
end

get_module_rotating() = STACKTRACE_MODULECOLORS
function set_module_rotating(v)
    empty!(STACKTRACE_MODULECOLORS)
    for x in v
        push!(STACKTRACE_MODULECOLORS, Color(x))
    end

    nothing
end

function set_solarized()
    set_filepath(default = "normal", lineno = "cyan")
    set_framenumber(frameno = "cyan")
    set_speclinfo_map(default = "blue", repeats = "normal")
    set_tuplecall_map(default = "normal", doublecolon = "green")
    set_argtype_map(default = "yellow", brackets = "normal")

    set_track_map(trackin = "cyan:reverse", trackout = "red:reverse")
    set_globals(stackcolor = "underline")

    format_frameline("{frameno:lalign} {module}{filepath}\n  {function}")
end

function set_theme(theme)
    if theme == "solarized"
        set_solarized()
    elseif theme == "solarized_reversed"
        set_solarized()
        set_globals(reverse = true, align_numbering = true)
    else
        @warn "Unknown theme $theme"
    end
    return nothing
end

printstyled(io::IO, color::Color, msg...) = printstyled(io, msg...; color = color.color, bold = color.bold, underline = color.underline, blink = color.blink, reverse = color.reverse, hidden = color.hidden)

showstyled(io::IO, color::Color, msg...) = with_output_color(show, color.color, io, msg...; bold = color.bold, underline = color.underline, blink = color.blink, reverse = color.reverse, hidden = color.hidden)

function showerror(io::IO, ex::MethodError, bt; backtrace=true)
    try
        showerror(io, ex)
    finally
        f = ex.f
        ft = typeof(f)
        backtrace && show_backtrace(io, bt; modul = ft.name.module)
    end
end

function show_backtrace(io::IO, t::Vector; modul = nothing)
    if haskey(io, :last_shown_line_infos)
        empty!(io[:last_shown_line_infos])
    end

    # t is a pre-processed backtrace (ref #12856)
    if t isa Vector{Any}
        filtered = t
    else
        filtered = process_backtrace(t)
    end
    isempty(filtered) && return

    if length(filtered) == 1 && StackTraces.is_top_level_frame(filtered[1][1])
        f = filtered[1][1]::StackFrame
        if f.line == 0 && f.file === Symbol("")
            # don't show a single top-level frame with no location info
            return
        end
    end

    if length(filtered) > BIG_STACKTRACE_SIZE
        show_reduced_backtrace(IOContext(io, :backtrace => true), filtered)
        return
    end

    try invokelatest(update_stackframes_callback[], filtered) catch end
    # process_backtrace returns a Vector{Tuple{Frame, Int}}
    frames = map(x->first(x)::StackFrame, filtered)
    show_full_backtrace(io, frames; print_linebreaks = stacktrace_linebreaks(), modul = modul)
    return
end

function show_full_backtrace(io::IO, trace::Vector; print_linebreaks::Bool = true, modul = nothing)
    n = length(trace)
    ndigits_max = ndigits(n)

    modulecolordict = copy(STACKTRACE_FIXEDCOLORS)
    modulecolorcycler = Iterators.Stateful(Iterators.cycle(STACKTRACE_MODULECOLORS))

    printstyled(io, GLOBAL[].stackcolor, "\nStacktrace:\n")

    moduls = similar(trace, Int)
    state = 0 # are we inside tracked module or not
    tracks = modul === nothing ? TRACK_MODUL : [modul]
    for (i, frame) in pairs(trace)
        m = parentmodule(frame)
        if i == 1
            moduls[i] = m in tracks ? -1 : 0
            state = moduls[i] == 0 ? 0 : 1
        else
            if state == 0
                if m in tracks
                    moduls[i] = -1
                    state = 1
                else
                    moduls[i] = 0
                end
            else
                if m in tracks
                    moduls[i] = 0
                else
                    moduls[i - 1] = 1
                    moduls[i] = 0
                    state = 0
                end
            end
        end
    end

    if GLOBAL[].reverse
        trace = reverse(trace)
        moduls = reverse(moduls)
    end

    for (i, (frame, modultrack)) in enumerate(zip(trace, moduls))
        if (GLOBAL[].align_numbering && GLOBAL[].reverse) || (!GLOBAL[].align_numbering && !GLOBAL[].reverse)
            print_stackframe(io, i, frame, 1, ndigits_max, modulecolordict, modulecolorcycler, modultrack)
        else
            print_stackframe(io, n - i + 1, frame, 1, ndigits_max, modulecolordict, modulecolorcycler, modultrack)
        end
        if i < n
            println(io)
        end
    end
end

# Print a stack frame where the module color is determined by looking up the parent module in
# `modulecolordict`. If the module does not have a color, yet, a new one can be drawn
# from `modulecolorcycler`.
function print_stackframe(io, i, frame::StackFrame, n::Int, digit_align_width, modulecolordict, modulecolorcycler, modultrack)
    m = Base.parentmodule(frame)
    if m !== nothing
        while parentmodule(m) !== m
            pm = parentmodule(m)
            pm == Main && break
            m = pm
        end
        if !haskey(modulecolordict, m)
            modulecolordict[m] = popfirst!(modulecolorcycler)
        end
        modulecolor = modulecolordict[m]
    else
        modulecolor = Color()
    end
    print_stackframe(io, i, frame, n, digit_align_width, modulecolor, modultrack)
end

function print_stackframe(io, i, frame::StackFrame, n::Int, digit_align_width, modulecolor, modultrack)
    file, line = string(frame.file), frame.line
    stacktrace_expand_basepaths() && (file = something(find_source_file(file), file))
    stacktrace_contract_userdir() && (file = contractuser(file))

    # Used by the REPL to make it possible to open
    # the location of a stackframe/method in the editor.
    if haskey(io, :last_shown_line_infos)
        push!(io[:last_shown_line_infos], (string(frame.file), frame.line))
    end

    inlined = getfield(frame, :inlined)
    modul = parentmodule(frame)

    for token in FRAME_LINE
        if !token.special
            if token.align == 0
                printstyled(io, token.color, token.val)
            else
                if token.align == -1
                    printstyled(io, token.color, rpad(token.val, digit_align_width + 2))
                else
                    printstyled(io, token.color, lpad(token.val, digit_align_width + 2))
                end
            end
        elseif token.val == "frameno"
            # frame number
            frameno = if modultrack == 1
                TRACK_COLORS[].tin
            elseif modultrack == -1
                TRACK_COLORS[].tout
            else
                FRAME_NUMBER[].frameno
            end
            brackno = if modultrack == 1
                TRACK_COLORS[].tin
            elseif modultrack == -1
                TRACK_COLORS[].tout
            else
                FRAME_NUMBER[].brackets
            end

            num = string(i)

            if token.align == 1
                k = digit_align_width - length(num)
                if k > 0
                    print(io, " "^k)
                end
            end
            printstyled(io, brackno, "[")
            printstyled(io, frameno, num)
            printstyled(io, brackno, "]")
            if token.align == -1
                k = digit_align_width - length(num)
                if k > 0
                    print(io, " "^k)
                end
            end
        elseif token.val == "function"
            show_spec_linfo(IOContext(io, :backtrace=>true), frame)
            if n > 1
                printstyled(io, SPECLINFO_COLORS[].repeats, " (repeats $n times)")
            end
        elseif token.val == "filepath"
            # filepath
            pathparts = splitpath(file)
            folderparts = pathparts[1:end-1]
            if !isempty(folderparts)
                printstyled(io, FILEPATH_COLORS[].filepath, joinpath(folderparts...) * (Sys.iswindows() ? "\\" : "/"))
            end

            # filename, separator, line
            # use escape codes for formatting, printstyled can't do underlined and color
            # codes are bright black (90) and underlined (4)
            printstyled(io, FILEPATH_COLORS[].filepath, pathparts[end])
            printstyled(io, FILEPATH_COLORS[].colon, ":")
            printstyled(io, FILEPATH_COLORS[].lineno, line)

            # inlined
            printstyled(io, FILEPATH_COLORS[].inlined, inlined ? " [inlined]" : "")
        elseif token.val == "module"
            # module
            if modul !== nothing
                printstyled(io, modulecolor, modul, " ")
            end
        end
    end
end

function show_spec_linfo(io::IO, frame::StackFrame)
    linfo = frame.linfo
    if linfo === nothing
        if frame.func === empty_sym
            printstyled(io, SPECLINFO_COLORS[].ipx, "ip:0x", string(frame.pointer, base=16))
        elseif frame.func === top_level_scope_sym
            printstyled(io, SPECLINFO_COLORS[].toplevel, "top-level scope")
        else
            print_within_stacktrace(io, SPECLINFO_COLORS[].funcname, Base.demangle_function_name(string(frame.func)))
        end
    elseif linfo isa MethodInstance
        def = linfo.def
        if isa(def, Method)
            sig = linfo.specTypes
            argnames = Base.method_argnames(def)
            if def.nkw > 0
                # rearrange call kw_impl(kw_args..., func, pos_args...) to func(pos_args...)
                kwarg_types = Any[ fieldtype(sig, i) for i = 2:(1+def.nkw) ]
                uw = Base.unwrap_unionall(sig)::DataType
                pos_sig = Base.rewrap_unionall(Tuple{uw.parameters[(def.nkw+2):end]...}, sig)
                kwnames = argnames[2:(def.nkw+1)]
                for i = 1:length(kwnames)
                    str = string(kwnames[i])::String
                    if endswith(str, "...")
                        kwnames[i] = Symbol(str[1:end-3])
                    end
                end
                show_tuple_as_call(io, def.name, pos_sig;
                                        demangle=true,
                                        kwargs=zip(kwnames, kwarg_types),
                                        argnames=argnames[def.nkw+2:end])
            else
                show_tuple_as_call(io, def.name, sig; demangle=true, argnames)
            end
        else
            show_mi(io, linfo, true)
        end
    elseif linfo isa CodeInfo
        printstyled(io, SPECLINFO_COLORS[].toplevel, "top-level scope")
    end
end

function show_tuple_as_call(io::IO, name::Symbol, sig::Type;
                            demangle=false, kwargs=nothing, argnames=nothing,
                            qualified=false, hasfirst=true)
    # print a method signature tuple for a lambda definition
    if sig === Tuple
        printstyled(io, TUPLE_CALL_COLORS[].tuple, demangle ? demangle_function_name(name) : name, "(...)")
        return
    end
    tv = Any[]
    env_io = io
    while isa(sig, UnionAll)
        push!(tv, sig.var)
        env_io = IOContext(env_io, :unionall_env => sig.var)
        sig = sig.body
    end
    n = 1
    sig = (sig::DataType).parameters
    if hasfirst
        show_signature_function(env_io, sig[1], demangle, "", false, qualified)
        n += 1
    end
    first = true
    print_within_stacktrace(io, TUPLE_CALL_COLORS[].brackets, "(")
    show_argnames = argnames !== nothing && length(argnames) == length(sig)
    for i = n:length(sig)  # fixme (iter): `eachindex` with offset?
        first || printstyled(io, TUPLE_CALL_COLORS[].comma, ", ")
        first = false
        if show_argnames
            print_within_stacktrace(io, TUPLE_CALL_COLORS[].args, argnames[i])
        end
        printstyled(io, TUPLE_CALL_COLORS[].doublecolon, "::")
        print_type_stacktrace(env_io, sig[i])
    end
    if kwargs !== nothing
        printstyled(io, TUPLE_CALL_COLORS[].semicolon, "; ")
        first = true
        for (k, t) in kwargs
            first || printstyled(io, TUPLE_CALL_COLORS[].comma, ", ")
            first = false
            print_within_stacktrace(io, TUPLE_CALL_COLORS[].kwargs, k)
            printstyled(io, TUPLE_CALL_COLORS[].doublecolon, "::")
            print_type_stacktrace(io, t)
        end
    end
    print_within_stacktrace(io, TUPLE_CALL_COLORS[].brackets, ")")
    show_method_params(io, tv)
    nothing
end

# show the called object in a signature, given its type `ft`
# `io` should contain the UnionAll env of the signature
function show_signature_function(io::IO, @nospecialize(ft), demangle=false, fargname="", html=false, qualified=false)
    uw = unwrap_unionall(ft)
    if ft <: Function && isa(uw, DataType) && isempty(uw.parameters) &&
        isdefined(uw.name.module, uw.name.mt.name) &&
        ft == typeof(getfield(uw.name.module, uw.name.mt.name))
        if qualified && !is_exported_from_stdlib(uw.name.mt.name, uw.name.module) && uw.name.module !== Main
            print_within_stacktrace(io, SPECLINFO_COLORS[].modulename, uw.name.module)
        end
        s = sprint(show_sym, (demangle ? demangle_function_name : identity)(uw.name.mt.name), context=io)
        print_within_stacktrace(io, SPECLINFO_COLORS[].funcname, s)
    elseif isa(ft, DataType) && ft.name === Type.body.name &&
        (f = ft.parameters[1]; !isa(f, TypeVar))
        uwf = unwrap_unionall(f)
        parens = isa(f, UnionAll) && !(isa(uwf, DataType) && f === uwf.name.wrapper)
        parens && printstyled(io, SPECLINFO_COLORS[].brackets, "(")
        showstyled(io, SPECLINFO_COLORS[].wrapper, f)
        parens && printstyled(io, SPECLINFO_COLORS[].brackets, ")")
    else
        if html
            print(io, "($fargname::<b>", ft, "</b>)")
        else
            print_within_stacktrace(io, SPECLINFO_COLORS[].functor, "($fargname::", ft, ")")
        end
    end
    nothing
end

function print_type_stacktrace(io, type; color=:normal)
    str = sprint(show, type, context=io)
    i = findfirst('{', str)
    if isnothing(i) || !get(io, :backtrace, false)::Bool
        printstyled(io, ARGTYPE_COLORS[].nonparamtypes, str)
    else
        printstyled(io, ARGTYPE_COLORS[].paramtypemain, str[1:prevind(str,i)])
        printstyled(io, ARGTYPE_COLORS[].brackets, "{")
        printstyled(io, ARGTYPE_COLORS[].paramtypearg, str[i+1:end-1])
        printstyled(io, ARGTYPE_COLORS[].brackets, "}")
    end
end

function print_within_stacktrace(io, color::Color, s...)
    if get(io, :backtrace, false)::Bool
        printstyled(io, color, s...)
    else
        print(io, s...)
    end
end

function show_method_params(io::IO, tv)
    if !isempty(tv)
        printstyled(io, METHODPARAMS_COLORS[].wher, " where ")
        if length(tv) == 1
            showstyled(io, METHODPARAMS_COLORS[].types, tv[1])
        else
            printstyled(io, METHODPARAMS_COLORS[].brackets, "{")
            for i = 1:length(tv)
                if i > 1
                    printstyled(io, METHODPARAMS_COLORS[].comma, ", ")
                end
                x = tv[i]
                showstyled(io, METHODPARAMS_COLORS[].types, x)
                io = IOContext(io, :unionall_env => x)
            end
            printstyled(io, METHODPARAMS_COLORS[].brackets, "}")
        end
    end
end

function with_output_color(@nospecialize(f::Function), color::Union{Int, Symbol}, io::IO, args...;
        bold::Bool = false, underline::Bool = false, blink::Bool = false,
        reverse::Bool = false, hidden::Bool = false)
    buf = IOBuffer()
    iscolor = get(io, :color, false)::Bool
    try f(IOContext(buf, io), args...)
    finally
        str = String(take!(buf))
        if !iscolor
            print(io, str)
        else
            bold && color === :bold && (color = :nothing)
            underline && color === :underline && (color = :nothing)
            blink && color === :blink && (color = :nothing)
            reverse && color === :reverse && (color = :nothing)
            hidden && color === :hidden && (color = :nothing)
            enable_ansi  = get(text_colors, color, text_colors[:default]) *
                               (bold ? text_colors[:bold] : "") *
                               (underline ? text_colors[:underline] : "") *
                               (blink ? text_colors[:blink] : "") *
                               (reverse ? text_colors[:reverse] : "") *
                               (hidden ? text_colors[:hidden] : "")

            disable_ansi = (hidden ? disable_text_style[:hidden] : "") *
                           (reverse ? disable_text_style[:reverse] : "") *
                           (blink ? disable_text_style[:blink] : "") *
                           (underline ? disable_text_style[:underline] : "") *
                           (bold ? disable_text_style[:bold] : "") *
                               get(disable_text_style, color, text_colors[:default])
            first = true
            for line in split(str, '\n')
                first || print(buf, '\n')
                first = false
                isempty(line) && continue
                print(buf, enable_ansi, line, disable_ansi)
            end
            print(io, String(take!(buf)))
        end
    end
end

"""
    printstyled([io], xs...; bold::Bool=false, underline::Bool=false, blink::Bool=false, reverse::Bool=false, hidden::Bool=false, color::Union{Symbol,Int}=:normal)

Print `xs` in a color specified as a symbol or integer, optionally in bold.

`color` may take any of the values $(Base.available_text_colors_docstring)
or an integer between 0 and 255 inclusive. Note that not all terminals support 256 colors.
If the keyword `bold` is given as `true`, the result will be printed in bold.
If the keyword `underline` is given as `true`, the result will be printed underlined.
If the keyword `blink` is given as `true`, the result will blink.
If the keyword `reverse` is given as `true`, the result will have foreground and background colors inversed.
If the keyword `hidden` is given as `true`, the result will be hidden.
Keywords can be given in any combination.
"""
printstyled(io::IO, msg...; bold::Bool=false, underline::Bool=false, blink::Bool=false, reverse::Bool=false, hidden::Bool=false, color::Union{Int,Symbol}=:normal) =
    with_output_color(print, color, io, msg...; bold=bold, underline=underline, blink=blink, reverse=reverse, hidden=hidden)
printstyled(msg...; bold::Bool=false, underline::Bool=false, blink::Bool=false, reverse::Bool=false, hidden::Bool=false, color::Union{Int,Symbol}=:normal) =
    printstyled(stdout, msg...; bold=bold, underline=underline, blink=blink, reverse=reverse, hidden=hidden, color=color)

end # module
