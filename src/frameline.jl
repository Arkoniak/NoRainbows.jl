@Base.kwdef struct Token
    special::Bool = false
    val::String = ""
    color::Color = Color()
    align::Int = 0
end
Token(special::Bool, val::AbstractString) = Token(special, val, Color(), 0)
Token(special::Bool, val::AbstractString, color::Color) = Token(special, val, color, 0)
function Token(s::AbstractString)
    if s in ["function", "filepath", "module"]
        return Token(true, s)
    end
    v = split(s, r"(?<!\\):")
    if v[1] == "frameno"
        if length(v) == 1
            return Token(true, s)
        else
            align = v[2] == "lalign" ? -1 : 1
            return Token(true, v[1], Color(), align)
        end
    end
    if length(v) == 1
        return Token(false, v[1])
    elseif v[2] in ["lalign", "ralign"]
        align = v[2] == "lalign" ? -1 : 1
        return Token(false, v[1], Color(v[3:end]), align)
    else
        return Token(false, v[1], Color(v[2:end]))
    end
end

const FRAME_LINE = [
    Token(false, " "),
    Token(true, "frameno", Color(), 1),
    Token(false, " "),
    Token(true, "function"),
    Token(false, "\n "),
    Token(false, "@", Color(), 1),
    Token(false, " "),
    Token(true, "module"),
    Token(true, "filepath")
]
function format_frameline(s::AbstractString, level = 0, tokens = Token[])
    i = 0
    while i < ncodeunits(s)
        i = nextind(s, i)
        c = s[i]
        if c == '{' && level == 0
            i > 1 && push!(tokens, Token(s[1:prevind(s, i)]))
            format_frameline(s[nextind(s, i):end], 1, tokens)
            break
        end

        if c == '}' && level == 1
            push!(tokens, Token(s[1:prevind(s, i)]))
            format_frameline(s[nextind(s, i):end], 0, tokens)
            break
        end
    end

    isempty(tokens) && return nothing
    empty!(FRAME_LINE)
    for token in tokens
        push!(FRAME_LINE, token)
    end

    return nothing
end

