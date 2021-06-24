# Colors

All color related functions can accept color in one of two ways:

1. As an instance of the `NoRainbows.Color` structure
2. As a string of the form `"<color>:<modifier1>:<modifier2>..."`

## Color string format

Color string consists of color and modifiers in any order, written after semicolon. For example

1. `"red"`
2. `"red:bold"`
3. `"red:bold:underline"`
4. `"23:reverse"`
etc.

### Color values

Possible colors are defined in `Base.text_colors` and can be either text strings or integer numbers. Standard text color names are
```
default
normal
white
black
green
blue
cyan
yellow
magenta
red
light_black
light_green
light_blue
light_cyan
light_yellow
light_magenta
light_red
```

These names are only color tags, actual colors depends on your colorscheme.

### Modifiers

Possible modifiers are

```
bold
underline
blink
reverse
hidden
```

Their effect depends on your terminal and colorscheme.
