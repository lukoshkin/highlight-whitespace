# Highlight Whitespace

![demo](./demo.gif)

Go to the [Current Colorscheme](#current-colorscheme) section
to see what each color stands for.  
(Unfortunately placing it here breaks syntax
highlighting for all multi-line code blocks below it)

<!-- It breaks syntax highlighting of the code blocks below it for some reason
$${\color{PaleVioletRed}red}\text{ color
─ trailing whitespace in python (other than md)}$$

$${\color{RosyBrown}brown}\text{ ─ in markdown}$$

---

$${\color{#CDBE70}yellow}\text{ color
─ redundant (multiple) spaces in python}$$

$${\color{#87CEFF}blue}\text{ ─ in markdown}$$

---

$${\color{#FF7256}orange}\text{ color ─ a space before a comma in python}$$

$${\color{#7AC5CD}"green"}\text{ ─ in markdown}$$

---

$${\color{#8B668B}purple}\text{ color ─ tab indents instead of spaces}$$
--->

<!-- Also works for text coloring (but not center-aligned and also breaks highlighting)
${\color{PaleVioletRed}red}\text{ color ─ trailing whitespace in python (other than md)}$  
${\color{RosyBrown}brown}\text{ ─ in markdown}$

${\color{#CDBE70}yellow}\text{ color ─ redundant (multiple) spaces in python}$  
${\color{#87CEFF}blue}\text{ ─ in markdown}$

${\color{#FF7256}orange}\text{ color ─ a space before a comma in python}$  
${\color{#7AC5CD}"green"}\text{ ─ in markdown}$

${\color{#8B668B}purple}\text{ color ─ tab indents instead of spaces}$
--->


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

With [**vim-plug**](https://github.com/junegunn/vim-plug)

```vim
Plug 'lukoshkin/highlight-whitespace', { 'branch': 'vimscript' }
```

One can adapt the installation code for other plugin managers!


## Customization

Two ways to configure depending on the selected branch
<!-- Omitting a punctuation at the end emphasizes the direction of meaning -->

<details open>
<summary><Big><b>master (Lua)</b></Big></summary>
For the Lua implementation, the functionality is much wider.<br>One can
specify a color for each pattern and per filetype. It can be a regular color
name or hex code.

<ul>
<li><details open>
<summary>lazy.nvim</summary>

```lua
{
  "lukoshkin/highlight-whitespace",
  opts = {
    tws = "\\s\\+$",
    clear_on_winleave = false,
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
</details></li>
<li><details>
<summary>packer.nvim</summary>

```lua
use {
  'lukoshkin/highlight-whitespace',
  config = function ()
    require'highlight-whitespace'.setup {
      tws = '\\s\\+$',
      clear_on_winleave = false,
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
</details></li>
</ul>

`tws` - main pattern for trailing whitespace  
`clear_on_winleave` - clear highlighting when switching to another window
</details>

<details>
<summary><Big><b>vimscript</b></Big></summary>
Note you must specify both <code>ctermbg</code> and <code>guibg</code> values,
even if you don't care about one of them. <br> Specifying other than
<code>bg</code> keys has no effect.

```vim
let g:tws_pattern = '\s\+$'
let g:tws_color_md = { 'ctermbg': 138, 'guibg': 'RosyBrown' }
let g:tws_color_any = { 'ctermbg': 211, 'guibg': 'PaleVioletRed' }
```
</details>



## Future Development

* :heavy_check_mark: ~~It is possible to highlight tabs by specifying `patterns
  = { '\\s\\+$', '\\t\\+' }`. <br> In future patches, the customization will
  also allow setting a color for each pattern, e.g., in the palette table:~~

   ```lua
   palette = { python = {['\\s\\+$'] = 'PaleVioletRed', ['\\t\\+'] = 'plum4'} }
   ```

* I have a function for trimming trailing whitespace in my "vimrc"
  configuration. Adding a similar one for trimming any unwanted whitespace
  (including tabs and etc.) to the plugin is under the question.

* The approach with `matchadd` + `matchdelete` + `nvim_set_hl` might be not the
  most optimal. One of the other options to test will be looping over each line
  of a document looking for a pattern (lua's `string.find` or vim's
  `matchstrpos`) and then dynamically adding highlighting with
  `nvim_buf_add_highlight`.


## Story

***Why to create another HWS plugin?***  
(I refer to my plugin as `HighlightWS`, and similar others ─ as HWS.)
 <!-- 'and' is used ↑ here as 'while' -->

1. `HighlightWS` leverages `matchadd` instead of `match`.
1. Trailing whitespace in markdown files is highlighted with a different color.
1. Written in Lua. Vimscript version is also available.
1. I was configuring my vimrc, I didn't know about existing plugins.
1. It is highly customizable!

Let's talk about each point separately.

1. `match` function provides for creating just three matches (i.e., using
   `match`, `2match`, `3match`). Better not to occupy them, if one can achieve
   the same goals with `matchadd`.

1. Trailing whitespace in markdown files is not a bad thing and sometimes is
   even a necessity. Thus, more mild colors than red should be used.

1. Though the topic of Lua in Neovim is trending and may seem overhyped in some
   aspects, the fact that it is a Lua plugin is convenient for those who are
   not familiar with VimL and definitely handy for Lua programmers. Note there
   is also a Vimscript version on a separate branch for plugin managers that do
   not treat Lua code (it is a bit outdated, though).

1. Don't do that. I was not going to create a new plugin, though I ended up
   writing it. Googling _trailing whitespace vim_ terminated on [the first link
   ](https://vim.fandom.com/wiki/Remove_unwanted_spaces). By the way, the
   mentioned there tips are just 'tips', as written.

1. Actually, it is much wider than just highlighting whitespace. You can come
   up with your own pattern and color specifically for each filetype.


## Current Colorscheme
This section refers to the GIF at the README beginning

---

$${\color{PaleVioletRed}red}\text{ color
─ trailing whitespace in Python (other than md)}$$

$${\color{#3B3B3B}dark\ gray}\text{
─ leading and trailing whitespace in comment sections}$$

$${\color{RosyBrown}brown}\text{ ─ in markdown}$$

---

$${\color{#CDBE70}yellow}\text{ color
─ redundant (multiple) spaces in Python}$$

$${\color{#87CEFF}blue}\text{ ─ in markdown}$$

---

$${\color{#FF7256}orange}\text{ color ─ a space before a comma in Python}$$

$${\color{#7AC5CD}"green"}\text{ ─ in markdown}$$

---

$${\color{#8B668B}purple}\text{ color ─ tab indents instead of spaces}$$
