# Highlight Whitespace

![demo](./demo.gif)

<span style="color:PaleVioletRed"> red </span> color
─ trailing whitespace in python (other than md)  
<span style="color:RosyBrown"> brown </span> ─ in markdown

<span style="color:#CDBE70"> yellow </span> color
─ redundant (multiple) spaces in python  
<span style="color:SkyBlue"> blue </span> ─ in markdown

<span style="color:coral"> orange </span> color
─ a space before a comma in python  
<span style="color:CadetBlue"> "green" </span> ─ in markdown

<span style="color:#8B668B"> purple </span> color
─ tab indents instead of spaces


## Installation

With [**Packer**](https://github.com/wbthomason/packer.nvim)

```lua
use 'lukoshkin/highlight-whitespace'
```

With [**vim-plug**](https://github.com/junegunn/vim-plug)

```vim
Plug 'lukoshkin/highlight-whitespace', { 'branch': 'vimscript' }
```

One can adapt the installation code for other plugin managers!


## Customization

Two ways to configure depending on the selected branch
<!-- Omitting a punctuation at the end emphasizes the direction of meaning -->

<details>
<summary><Big><b>vimscript</b></Big></summary>
Note you must specify both `ctermbg` and `guibg` values, even if you don't
care about one of them. <br> Specifying other than `bg` keys has no effect.

```vim
let g:tws_pattern = '\s\+$'
let g:tws_color_md = { 'ctermbg': 138, 'guibg': 'RosyBrown' }
let g:tws_color_any = { 'ctermbg': 211, 'guibg': 'PaleVioletRed' }
```
</details>

<details open>
<summary><Big><b>master (Lua)</b></Big></summary>
For the Lua implementation, the functionality is much wider. <br> One can
specify a color for each pattern and per filetype.

```lua
  use {
    'lukoshkin/highlight-whitespace',
    config = function ()
      require'highlight-whitespace'.setup {
        tws = '\\s\\+$',
        clear_on_winleave = false,
        user_palette = {
          markdown = {
            tws = 'RosyBrown',
            ['\\(\\S\\)\\@<=\\s\\(\\.\\|,\\)\\@='] = 'CadetBlue3',
            ['\\(\\S\\)\\@<= \\{2,\\}\\(\\S\\)\\@='] = 'SkyBlue1',
            ['\\t\\+'] = 'plum4',
          },
          other = {
            tws = 'PaleVioletRed',
            ['\\(\\S\\)\\@<=\\s\\(,\\)\\@='] = 'coral1',
            ['\\(\\S\\)\\@<= \\{2,\\}\\(\\S\\)\\@='] = 'LightGoldenrod3',
            ['\\t\\+'] = 'plum4',
          }
        }
      }
    end
  }
```

`tws` - main pattern for trailing whitespace  
`clear_on_winleave` - clear highlighting when switching to another window

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
