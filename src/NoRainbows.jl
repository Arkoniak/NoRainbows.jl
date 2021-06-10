module NoRainbows

import Base: print_stackframe, show_tuple_as_call, print_type_stacktrace, printstyled, print_within_stacktrace, show_method_params, show_signature_function, show_full_backtrace, with_output_color
import Base.StackTraces: show_spec_linfo

using Core: MethodInstance, CodeInfo
using Base: StackFrame, stacktrace_expand_basepaths, stacktrace_contract_userdir, contractuser, unwrap_unionall, demangle_function_name, show_sym, parentmodule, empty_sym, text_colors, disable_text_style
using Base.StackTraces: top_level_scope_sym

@Base.kwdef struct Color
    color::Union{Symbol, Int} = :normal
    bold::Bool = false
    underline::Bool = false
    blink::Bool = false
    reverse::Bool = false
    hidden::Bool = false
end

function Color(s::AbstractString)
    bold = false
    underline = false
    blink = false
    reverse = false
    hidden = false
    color = :normal
    for item in split(s, ":")
        if item == "bold"
            bold = true
        elseif item == "underline"
            underline = true
        elseif item == "blink"
            blink = true
        elseif item == "reverse"
            reverse = true
        elseif item == "hidden"
            hidden = true
        elseif !isempty(item)
            val = tryparse(Int, item)
            if val === nothing
                color = Symbol(item)
            else
                color = val
            end
        end
    end

    return Color(color, bold, underline, blink, reverse, hidden)
end

function coal(a, b, c)
    a === nothing ? b === nothing ? c : b : a
end

@Base.kwdef struct Token
    special::Bool = false
    val::String = ""
    color::Color = Color()
end
Token(special::Bool, val::String) = Token(special, val, Color())
const FRAME_LINE = [
    Token(true, "frameno"),
    Token(false, " "),
    Token(true, "function"),
    Token(false, " at "),
    Token(true, "filepath"),
]

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
        nonparamtypes = coal(nonparamtypes, default, c.nonparamtypes),
        paramtypemain = coal(paramtypemain, default, c.paramtypemain),
        paramtypearg = coal(paramtypearg, default, c.paramtypearg),
        brackets = coal(brackets, default, c.brackets)
    )

    return nothing
end

@Base.kwdef struct TraceColorMap
    tin::Color = Color()
    tout::Color = Color()
end
const TRACE_COLORS = Ref(TraceColorMap())

@Base.kwdef struct MethodParamsColorMap
    brackets::Color = Color()
    comma::Color = Color()
    wher::Color = Color()
    types::Color = Color()
end
const METHODPARAMS_COLORS = Ref(MethodParamsColorMap())

@Base.kwdef struct SignatureFunctionColorMap
    modulename::Color = Color()
    funcname::Color = Color()
    brackets::Color = Color()
    wrapper::Color = Color()
    fallback::Color = Color()
end
const SIGNATURE_FUNCTION_COLORS = Ref(SignatureFunctionColorMap())
function set_signature_map(;
    default = nothing,
    modulename = nothing,
    funcname = nothing,
    brackets = nothing,
    wrapper = nothing,
    fallback = nothing
)
    c = SIGNATURE_FUNCTION_COLORS[]
    SIGNATURE_FUNCTION_COLORS[] = SignatureFunctionColorMap(
        modulename = coal(modulename, default, c.modulename),
        funcname = coal(funcname, default, c.funcname),
        brackets = coal(brackets, default, c.brackets),
        wrapper = coal(wrapper, default, c.wrapper),
        fallback = coal(fallback, default, c.fallback)
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
        tuple = coal(tuple, default, c.tuple),
        brackets = coal(brackets, default, c.brackets),
        doublecolon = coal(doublecolon, default, c.doublecolon),
        comma = coal(comma, default, c.comma),
        semicolon = coal(semicolon, default, c.semicolon),
        args = coal(args, default, c.args),
        kwargs = coal(kwargs, default, c.kwargs)
    )

    return nothing
end

@Base.kwdef struct SpecLinfoColorMap
    ipx::Color = Color()
    toplevel::Color = Color()
    framefunc::Color = Color()
end
const SPECLINFO_COLORS = Ref(SpecLinfoColorMap())
function set_speclinfo_map(;
    default = nothing,
    ipx = nothing,
    toplevel = nothing,
    framefunc = nothing
)
    c = SPECLINFO_COLORS[]
    SPECLINFO_COLORS[] = SpecLinfoColorMap(
        ipx = coal(ipx, default, c.ipx),
        toplevel = coal(toplevel, default, c.toplevel),
        framefunc = coal(framefunc, default, c.framefunc)
    )

    return nothing
end

@Base.kwdef struct FrameColorMap
    frameno::Color = Color()
    repeats::Color = Color()
    dog::Color = Color()
    filepath::Color = Color()
    colon::Color = Color()
    lineno::Color = Color()
    inlined::Color = Color()
end
const FRAME_COLORS = Ref(FrameColorMap())
function set_framecolor_map(;
    default = nothing,
    frameno = nothing,
    repeats = nothing,
    dog = nothing,
    filepath = nothing,
    colon = nothing,
    lineno = nothing,
    inlined = nothing
)
    c = FRAME_COLORS[]
    FRAME_COLORS[] = FrameColorMap(
        frameno = coal(frameno, default, c.frameno),
        repeats = coal(repeats, default, c.repeats),
        dog = coal(dog, default, c.dog),
        filepath = coal(filepath, default, c.filepath),
        colon = coal(colon, default, c.colon),
        lineno = coal(lineno, default, c.lineno),
        inlined = coal(inlined, default, c.inlined)
    )
    return nothing
end

@Base.kwdef struct GlobalOptions
    reverse::Bool = false
    stackcolor::Color = Color()
end
const GLOBAL = Ref(GlobalOptions())

const STACKTRACE_MODULECOLORS = [Color(), Color(), Color(), Color()]
const STACKTRACE_FIXEDCOLORS = IdDict(Base => Color(), Core => Color())
const TRACE_MODUL = Module[]

printstyled(io::IO, color::Color, msg...) = printstyled(io, msg...; color = color.color, bold = color.bold, underline = color.underline, blink = color.blink, reverse = color.reverse, hidden = color.hidden)

showstyled(io::IO, color::Color, msg...) = with_output_color(show, color.color, io, msg...; bold = color.bold, underline = color.underline, blink = color.blink, reverse = color.reverse, hidden = color.hidden)


function show_full_backtrace(io::IO, trace::Vector; print_linebreaks::Bool = true)
    n = length(trace)
    ndigits_max = ndigits(n)

    modulecolordict = copy(STACKTRACE_FIXEDCOLORS)
    modulecolorcycler = Iterators.Stateful(Iterators.cycle(STACKTRACE_MODULECOLORS))

    printstyled(io, GLOBAL[].stackcolor, "\nStacktrace:\n")

    moduls = similar(trace, Int)
    state = 0
    for (i, frame) in pairs(trace)
        m = parentmodule(frame)
        if i == 1
            moduls[i] = m in TRACE_MODUL ? -1 : 0
            state = moduls[i] == 0 ? 0 : 1
        else
            if state == 0
                if m in TRACE_MODUL
                    moduls[i] = -1
                    state = 1
                else
                    moduls[i] = 0
                end
            else
                if m in TRACE_MODUL
                    moduls[i] = 0
                else
                    moduls[i - 1] = 1
                    state = 0
                end
            end
        end
    end

    if GLOBAL[].reverse
        trace = reverse(trace)
        moduls = reverse(moduls)
    end

    for (i, (frame, modultrace)) in enumerate(zip(trace, moduls))
        print_stackframe(io, i, frame, 1, ndigits_max, modulecolordict, modulecolorcycler, modultrace)
        if i < n
            println(io)
            # GLOBAL[].linebreaks && println(io)
        end
    end
end

# Print a stack frame where the module color is determined by looking up the parent module in
# `modulecolordict`. If the module does not have a color, yet, a new one can be drawn
# from `modulecolorcycler`.
function print_stackframe(io, i, frame::StackFrame, n::Int, digit_align_width, modulecolordict, modulecolorcycler, modultrace)
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
    print_stackframe(io, i, frame, n, digit_align_width, modulecolor, modultrace)
end

function print_stackframe(io, i, frame::StackFrame, n::Int, digit_align_width, modulecolor, modultrace)
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
            printstyled(io, token.color, token.val)
        elseif token.val == "frameno"
            # frame number
            color = if modultrace == 1
                TRACE_COLORS[].tin
            elseif modultrace == -1
                TRACE_COLORS[].tout
            else
                FRAME_COLORS[].frameno
            end
            printstyled(io, color, " ", lpad("[" * string(i) * "]", digit_align_width + 2))
        elseif token.val == "function"
            show_spec_linfo(IOContext(io, :backtrace=>true), frame)
            if n > 1
                printstyled(io, FRAME_COLORS[].repeats, " (repeats $n times)")
            end
        elseif token.val == "filepath"
            # filepath
            pathparts = splitpath(file)
            folderparts = pathparts[1:end-1]
            if !isempty(folderparts)
                printstyled(io, FRAME_COLORS[].filepath, joinpath(folderparts...) * (Sys.iswindows() ? "\\" : "/"))
            end

            # filename, separator, line
            # use escape codes for formatting, printstyled can't do underlined and color
            # codes are bright black (90) and underlined (4)
            printstyled(io, FRAME_COLORS[].filepath, pathparts[end])
            printstyled(io, FRAME_COLORS[].colon, ":")
            printstyled(io, FRAME_COLORS[].lineno, line)

            # inlined
            printstyled(io, FRAME_COLORS[].inlined, inlined ? " [inlined]" : "")
        elseif token.val == "module"
            # module
            if modul !== nothing
                printstyled(io, modulecolor, modul, " ")
            end
        end
    end
    # # @
    # printstyled(io, FRAME_COLORS[].dog, " " ^ (digit_align_width + 2) * "@ ")
end

function show_spec_linfo(io::IO, frame::StackFrame)
    linfo = frame.linfo
    if linfo === nothing
        if frame.func === empty_sym
            printstyled(io, SPECLINFO_COLORS[].ipx, "ip:0x", string(frame.pointer, base=16))
        elseif frame.func === top_level_scope_sym
            printstyled(io, SPECLINFO_COLORS[].toplevel, "top-level scope")
        else
            print_within_stacktrace(io, SPECLINFO_COLORS[].framefunc, Base.demangle_function_name(string(frame.func)))
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
            print_within_stacktrace(io, SIGNATURE_FUNCTION_COLORS[].modulename, uw.name.module)
        end
        s = sprint(show_sym, (demangle ? demangle_function_name : identity)(uw.name.mt.name), context=io)
        print_within_stacktrace(io, SIGNATURE_FUNCTION_COLORS[].funcname, s)
    elseif isa(ft, DataType) && ft.name === Type.body.name &&
        (f = ft.parameters[1]; !isa(f, TypeVar))
        uwf = unwrap_unionall(f)
        parens = isa(f, UnionAll) && !(isa(uwf, DataType) && f === uwf.name.wrapper)
        parens && printstyled(io, SIGNATURE_FUNCTION_COLORS[].brackets, "(")
        showstyled(io, SIGNATURE_FUNCTION_COLORS[].wrapper, f)
        parens && printstyled(io, SIGNATURE_FUNCTION_COLORS[].brackets, ")")
    else
        if html
            print(io, "($fargname::<b>", ft, "</b>)")
        else
            print_within_stacktrace(io, SIGNATURE_FUNCTION_COLORS[].fallback, "($fargname::", ft, ")")
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

end # module
