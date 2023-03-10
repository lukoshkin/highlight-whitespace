# Trailing Whitespace

![demo](./demo.gif)

**Why to create another TWS plugin?**  
(I refer to my plugin as `TrailingWS`, and similar others ─ as TWS.)
 <!-- 'and' is used ↑ here as 'while' -->

1. `TrailingWS` leverages `matchadd` instead of `match`.
1. Trailing whitespace in markdown files is highlighted with a different color.
1. Written in Lua. Vimscript version is also present.
1. I was configuring my vimrc, I didn't know about existing plugins.

Let's talk about each point separately.

1. `match` function provides for creating just three matches (i.e., using
   `match`, `2match`, `3match`). Better not to occupy them, if one can achieve
   the same goals with `matchadd`.

1. Trailing whitespace in markdown files is not a bad thing and sometimes is a
   necessity. Thus, more mild colors than red should be used.

1. Though the topic of Lua in Neovim is trending and may seem overhyped in some
   aspects, the fact that it is a Lua plugin is convenient for those who are
   not familiar with VimL and definitely handy for Lua programmers. Note there
   is also a Vimscript version on a separate branch for plugin managers that do
   not treat Lua code.

1. Don't do that. I was not going to create a new plugin, though I ended up
   writing it. Googling _trailing whitespace vim_ terminated on [the first link
   ](https://vim.fandom.com/wiki/Remove_unwanted_spaces). By the way, the
   mentioned there tips are just 'tips', as written.


## Installation

With [**Packer**](https://github.com/wbthomason/packer.nvim)

```lua
use 'lukoshkin/trailing-whitespace'
```

With [**vim-plug**](https://github.com/junegunn/vim-plug)

```vim
Plug 'lukoshkin/trailing-whitespace', { 'branch': 'vimscript' }
```

One can adapt it for other plugin managers!


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
For the Lua implementation, the functionality is a bit wider. <br> One can
specify a trailing whitespace color per filetype.

```lua
use {
   'lukoshkin/trailing-whitespace',
   config = function ()
      require'trailing-whitespace'.setup {
         patterns = { '\\s\\+$' },
         palette = { markdown = 'RosyBrown' },
         default_color = 'PaleVioletRed',
      }
   end
}
```

The first pattern in the `patterns` table is not highlighted in the insert
mode. Therefore, it makes sense to specify as the first element a pattern
corresponding to **trailing** whitespace.
</details>


## Future Development

* It is possible to highlight tabs by specifying `patterns = { '\\s\\+$',
  '\\t\\+' }`. <br> In future patches, the customization will also allow
  setting a color for each pattern, e.g., in the palette table:

   ```lua
   palette = { python = {['\\s\\+$'] = 'PaleVioletRed', ['\\t\\+'] = 'plum4'} }
   ```

* I have a function for trimming trailing whitespace in my vimrc configuration.
  Adding a similar one for trimming any unwanted whitespace (including tabs and
  etc.) to `TrailingWS` is under the question.
