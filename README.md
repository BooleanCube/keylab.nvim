<p align="center">
  <a href="https://github.com/BooleanCube/keylab.nvim" />
    <img alt="keylab" src="https://github.com/BooleanCube/keylab.nvim/blob/main/images/logo.png?raw=true" height="260" />
  </a>
  <p align="center">Practice coding on neovim to boost your productivity</p>
  <p align="center">
    <a href="LICENSE.md"><img alt="Software License" src="https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square"></a>
    <a href="https://github.com/BooleanCube/keylab.nvim/actions"><img alt="Actions" src="https://img.shields.io/github/actions/workflow/status/BooleanCube/keylab.nvim/main.yml?style=flat-square&branch=master"></a>
    <a href="doc/keylab.txt"><img alt="Doc" src="https://img.shields.io/badge/doc-%3Ah%20keylab.txt-brightgreen.svg?style=flat-square"></a>
    <a href="https://github.com/BooleanCube/keylab.nvim/issues"><img alt="Issues" src="https://img.shields.io/github/issues/BooleanCube/keylab.nvim?style=flat-square"></a>
    <a href="https://github.com/BooleanCube/keylab.nvim"><img alt="size" src="https://img.shields.io/github/repo-size/BooleanCube/keylab.nvim.svg?style=flat-square"></a>
  </p>
  </a>
</p>

----
<br>

> CPM means characters per minute (similar measurement to words per minute). I used CPM instead of WPM to produce more accurate results since the concept of "words" in programming languages isn't clear.

<br>

![image](https://github.com/BooleanCube/keylab.nvim/blob/f794722563d454a756147aaad94a9034dfd42272/doc/usage.gif)

<br>

<p>
keylab.nvim aims to aid new neovim users to boost their productivity by practicing their keybinding configurations multiple times. When used enough times, improvements in typing ability are noticeable.
</p>
<p>
keylab.nvim also serves as a plugin to measure the user's coding speed. Similar to <code>https://www.speedtyper.dev/ (by codicocodes)</code>, except this has custom scripts and your personal vim configuration as possible options. Measure your true coding speed on neovim and aim for even higher results. All languages supported by your neovim configuration, are also supported.
</p>

## Features
- Customizable configuration and setup
- Simple mechanics and free controls (easy-to-use)
- Multilingual support
- Clean documentation
- Efficient & optimized plugin

## Tips
<p>
To use keylab effectively, I would suggest 3-5 practice sessions everyday before you get into work. Try to beat your past session in every session you play and keep your average CPM high. In less than a week's time, you will realise how much you have improved over a short time period.
</p>
<p>
My biggest improvements were: being able to locate and press weird keys (like ">(#{") without having to look at the keyboard. I also saw a decent increase in accuracy which means I don't mess up on weird keys that often anymore.
</p>

## Setup
### Prerequisites
<p>
  <b>Make sure to check you have <code>nvim >= 0.9</code> (with <code>nvim -v</code>) for full lua support.</b><br>
</p>
<p>
  <b>Keylab also requires <a href="https://github.com/nvim-lua/plenary.nvim">plenary.nvim</a> dependencies to store performance data and development testing (in case you want to contribute).</b><br>
  If you are using <a href="https://github.com/nvim-telescope/telescope.nvim">telescope.nvim</a>, you have probably already installed plenary dependencies before which means you won't have to install it again.
</p>

### Installation
<p>
  Use your plugin manager of choice to install keylab after checking the prerequisites:
</p>
<p>
  
  <details>
    <summary>Packer</summary>
  
1. Paste the following template in your `vimrc` file:
   ```lua
   return require('packer').startup(function(use)
       use { 'BooleanCube/keylab.nvim', requires = 'nvim-lua/plenary.nvim' }
    
       -- without plenary.nvim
       use 'BooleanCube/keylab.nvim'
   end)
   ```
2. Run `:PackerInstall` in neovim to install the plugin.
  </details>
  
  
  <details>
    <summary>Vim-Plug</summary>
  
1. Paste the following template in your `vimrc` file:
   ```vim
   call plug#begin()
       Plug 'BooleanCube/keylab.nvim'
    
       " ignore if you don't need plenary.nvim
       Plug 'nvim-lua/plenary.nvim'
   call plug#end()
   ```
2. Run `:PlugInstall` in neovim to install the plugin
  </details>
  
  
  <details>
    <summary>Vundle</summary>

1. Paste the following template into your `vimrc` file:
   ```vim
   call vundle#begin()
       Plugin 'BooleanCube/keylab.vim'
    
       " ignore if you don't need plenary.nvim
       Plugin 'nvim-lua/plenary.nvim'
   call vundle#end()
   ```
2. Run `:PluginInstall` in neovim to install the plugin
  </details>
  
</p>

### Plugin Configuration
- Plugin configuration with Lua:
  ```lua
  local keylab = require("keylab")
  keylab.setup({
      LINES = 15, -- 10 by default
      force_accuracy = false, -- true by default
      correct_fg = "#FFFFFF", -- #B8BB26 by default
      wrong_bg = "#000000" -- #FB4934 by default
  })
  ```

- Plugin configuration with Vimscript:
  ```vim
  " idk vimscript lmfao
  lua << EOF
      local keylab = require("keylab")
      keylab.setup({
          LINES = 10,
          force_accuracy = true,
          correct_fg = "#B8BB26",
          wrong_bg = "#FB4934"
      })
  EOF
  ```
  
### Keybinding
- Keybinding the start function in Lua:
  ```lua
  vim.keymap.set('n', '<leader>kl', require('keylab').start, { desc = "Start a keylab session" })
  ```

- Keybinding the start function in Vimscript:
  ```vim
  nnoremap <silent> <leader>kl :KeylabStart<cr>
  ```


### TODO
- [ ] Fix custom highlighting options
- [ ] add more configuration options ()

----

> "The only way to learn a new programming language is by writing programs in it."<br>- Dennis Ritchie

*Created by BooleanCube ;]*
