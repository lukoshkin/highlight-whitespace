# Highlight Whitespace

Highlight unwanted whitespace across you project files. The fun part is that
you can come up with your own palette of colors used for a specific pattern
per a filetype!

---

Читать на [русском :ru:](/README.ru.md)

![demo](./demo.gif)

Go to the [Current Colorscheme](#current-colorscheme) section
to see what each color stands for.  
<sub><sup>(Unfortunately placing it here breaks syntax
highlighting for all multi-line code blocks below it)</sup></sub>

## Installation

With [**lazy.nvim**](https://github.com/folke/lazy.nvim)

```lua
{
  "lukoshkin/highlight-whitespace",
  config=true,
}
```

With [**packer.nvim**](https://github.com/wbthomason/packer.nvim)

```lua
use "lukoshkin/highlight-whitespace"
```

<!--
With [**vim-plug**](https://github.com/junegunn/vim-plug)

```vim
Plug 'lukoshkin/highlight-whitespace', { 'branch': 'vimscript' }
```

One can adapt the installation code for other plugin managers!
-->

## Implementation Details

The plugin implements an efficient and flexible approach to "undesired" patterns highlighting:

- **Smart Window Rendering** - Scans only the visible part of the buffer to minimize performance impact
- **Regex-Based Pattern Matching** - Uses Neovim's regex engine as a compromise between Lua regex and pure regex
- **Extmarks for Highlighting** - Leverages Neovim's extmark API for efficient, non-intrusive highlighting
- **Context-Aware Highlighting** - Disables highlighting in insert mode at cursor position for better UX
- **Namespace-Based Management** - Uses separate highlight namespace to avoid conflicts with other plugins
- **Filetype-Specific Customization** - Allows different highlighting patterns and colors per filetype

Highlighting priorities are organized hierarchically:

- Trailing whitespace - 10
- Trailing whitespace override (till cursor position) - 11
- Other pattern highlighting - 12

The core implementation uses Neovim's API for all operations, making it performant even in large files.

## Customization

<!--
Two ways to configure depending on the selected branch

<details>
<summary><Big><b>vimscript</b> (obsolete)</Big></summary>
Note you must specify both <code>ctermbg</code> and <code>guibg</code> values,
even if you don't care about one of them. <br> Specifying other than
<code>bg</code> keys has no effect.

```vim
let g:tws_pattern = '\s\+$'
let g:tws_color_md = { 'ctermbg': 138, 'guibg': 'RosyBrown' }
let g:tws_color_any = { 'ctermbg': 211, 'guibg': 'PaleVioletRed' }
```

</details>

<details open>
<summary><Big><b>master (Lua)</b></Big></summary>
For the Lua implementation, the functionality is much wider.<br>One can
specify a color for each pattern and per filetype. It can be a regular color
name or hex code.
-->

`tws` keyword - "main" pattern for trailing whitespace highlighting  
`clear_on_bufleave` - boolean opt to clear highlighting in the current buffer
before switching to another

<details open>
<summary>lazy.nvim</summary>

```lua
{
  "lukoshkin/highlight-whitespace",
  opts = {
    tws = "\\s\\+$",
    clear_on_bufleave = false,
    palette = {
      markdown = {
        tws = 'RosyBrown',
        ['\\S\\@<=\\s\\(\\.\\|,\\)\\@='] = 'CadetBlue3',
        ['\\S\\@<= \\{2,\\}\\S\\@='] = 'SkyBlue1',
        ['\\t\\+'] = 'plum4',
      },
      other = {
        tws = 'PaleVioletRed',
        ['\\S\\@<=\\s,\\@='] = 'coral1',
        ['\\S\\@<=\\(#\\|--\\)\\@<! \\{2,3\\}\\S\\@=\\(#\\|--\\)\\@!'] = 'LightGoldenrod3',
        ['\\(#\\|--\\)\\@<= \\{2,\\}\\S\\@='] = '#3B3B3B',
        ['\\S\\@<= \\{3,\\}\\(#\\|--\\)\\@='] = '#3B3B3B',
        ['\\t\\+'] = 'plum4',
      }
    }
  }
}
```

</details>
<details>
<summary>packer.nvim</summary>

```lua
use {
  'lukoshkin/highlight-whitespace',
  config = function ()
    require'highlight-whitespace'.setup {
      tws = '\\s\\+$',
      clear_on_bufleave = false,
      palette = {
        markdown = {
          tws = 'RosyBrown',
          ['\\S\\@<=\\s\\(\\.\\|,\\)\\@='] = 'CadetBlue3',
          ['\\S\\@<= \\{2,\\}\\S\\@='] = 'SkyBlue1',
          ['\\t\\+'] = 'plum4',
        },
        other = {
          tws = 'PaleVioletRed',
          ['\\S\\@<=\\s,\\@='] = 'coral1',
          ['\\S\\@<=\\(#\\|--\\)\\@<! \\{2,3\\}\\S\\@=\\(#\\|--\\)\\@!'] = 'LightGoldenrod3',
          ['\\(#\\|--\\)\\@<= \\{2,\\}\\S\\@='] = '#3B3B3B',
          ['\\S\\@<= \\{3,\\}\\(#\\|--\\)\\@='] = '#3B3B3B',
          ['\\t\\+'] = 'plum4',
        }
      }
    }
  end
}
```

</details>

### Ignoring filetypes

Ignoring specific filetypes is possible by setting an empty table next to a
filetype in the `palette`.

To highlight only python and markdown filetypes

```lua
      palette = {
        python = {
          -- some patterns
        },
        markdown = {
          -- some patterns
        },
        other = {},
      }
```

To ignore highlighting only in javascript

```lua
      palette = {
        javascript = {},
        other = {
          -- some patterns
        },
      }
```

## Current Colorscheme

This section refers to the GIF at the README beginning

---

$$
{\color{PaleVioletRed}red}\text{ color
─ trailing whitespace in Python (other than md)}
$$

$$
{\color{#3B3B3B}dark\ gray}\text{
─ leading and trailing whitespace in comment sections}
$$

$${\color{RosyBrown}brown}\text{ ─ in markdown}$$

---

$$
{\color{#CDBE70}yellow}\text{ color
─ redundant (multiple) spaces in Python}
$$

$${\color{#87CEFF}blue}\text{ ─ in markdown}$$

---

$${\color{#FF7256}orange}\text{ color ─ a space before a comma in Python}$$

$${\color{#7AC5CD}"green"}\text{ ─ in markdown}$$

---

$${\color{#8B668B}purple}\text{ color ─ tab indents instead of spaces}$$
