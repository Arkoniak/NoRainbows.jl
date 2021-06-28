@Base.kwdef struct Color
    color::Union{Symbol, Int} = :normal
    bold::Bool = false
    underline::Bool = false
    blink::Bool = false
    reverse::Bool = false
    hidden::Bool = false
end

function Color(s::AbstractString)
    return Color(split(s, ":"))
end

Color(c::Color) = c

function Color(v::Vector)
    bold = false
    underline = false
    blink = false
    reverse = false
    hidden = false
    color = :normal
    for item in v
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
