# vim-textobj-vimscript

Custom text objects for Vimscript blocks, providing convenient ways to select and manipulate control structures and functions in your Vim configuration files.

## Description

This plugin provides text objects for Vimscript blocks, split into two categories:

- **Control structures** (`c` text object): `if`, `for`, `while`, `try`, and `augroup` blocks
- **Functions** (`f` text object): `function` definitions

With these text objects, you can easily select, delete, copy, or change entire blocks of Vimscript code with simple key combinations.

## Requirements

This plugin depends on [vim-textobj-user](https://github.com/kana/vim-textobj-user) by kana.

You must install `vim-textobj-user` first for this plugin to work.

## Installation

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'kana/vim-textobj-user'
Plug 'sophiehicks1/vim-textobj-vimscript'
```

### Using [Vundle](https://github.com/VundleVim/Vundle.vim)

```vim
Plugin 'kana/vim-textobj-user'
Plugin 'sophiehicks1/vim-textobj-vimscript'
```

### Using [Pathogen](https://github.com/tpope/vim-pathogen)

```bash
cd ~/.vim/bundle
git clone https://github.com/kana/vim-textobj-user
git clone https://github.com/sophiehicks1/vim-textobj-vimscript
```

### Using Vim 8 native package manager

```bash
mkdir -p ~/.vim/pack/plugins/start
cd ~/.vim/pack/plugins/start
git clone https://github.com/kana/vim-textobj-user
git clone https://github.com/sophiehicks1/vim-textobj-vimscript
```

## Usage

This plugin provides four main text objects that work in Vim files (filetype=vim):

### Control Structure Text Objects

- `ac` - **a**round **c**ontrol structure block (includes start/end lines)
- `ic` - **i**nner **c**ontrol structure block (excludes start/end lines)

### Function Text Objects

- `af` - **a**round **f**unction block (includes function/endfunction lines)
- `if` - **i**nner **f**unction block (excludes function/endfunction lines)

### Supported Blocks

#### Control Structures (`ac`/`ic`)

1. **if blocks**
   ```vim
   if condition
       " code
   elseif other_condition
       " more code
   else
       " default code
   endif
   ```

2. **for loops**
   ```vim
   for item in list
       " code
   endfor
   ```

3. **while loops**
   ```vim
   while condition
       " code
   endwhile
   ```

4. **try-catch blocks**
   ```vim
   try
       " code
   catch /pattern/
       " error handling
   finally
       " cleanup
   endtry
   ```

5. **augroup blocks**
   ```vim
   augroup MyGroup
       autocmd!
       autocmd FileType vim command
   augroup END
   ```

#### Functions (`af`/`if`)

```vim
function! MyFunction() abort
    " function body
endfunction
```

## Examples

### Basic Operations

When your cursor is inside any Vimscript block:

- `vac` - Visually select around control structure (including start/end)
- `vic` - Visually select inner control structure (excluding start/end)
- `vaf` - Visually select around function (including function/endfunction)
- `vif` - Visually select inner function (excluding function/endfunction)

### Common Use Cases

```vim
" Delete an entire if block (including if/endif)
dac

" Delete just the contents of a function (keep function/endfunction)
dif

" Change the entire try-catch block
cac

" Yank a function definition with its signature
yaf

" Indent an entire for loop
>ac

" Comment out a function's body
vicgc  " (with vim-commentary plugin)
```

### Around vs Inner Selection

Given this code:
```vim
function! Example()
    let x = 1
    echo x
endfunction
```

- `vaf` selects all 4 lines (including `function!` and `endfunction`)
- `vif` selects only lines 2-3 (the function body)

Given this code:
```vim
if condition
    do_something()
else
    do_other()
endif
```

- `vac` selects all 5 lines (including `if` and `endif`)
- `vic` selects only lines 2-4 (the body, excluding `if` and `endif`)

## Features

- **Linewise selection**: All text objects operate on complete lines
- **Nested block support**: Correctly handles nested control structures
- **Comment/string aware**: Skips matches inside comments and strings (requires `:syntax on`)
- **Handles optional colons**: Works with both `if` and `:if` style commands

## Configuration

This plugin works out of the box with no configuration needed. The text objects are automatically available in any Vim file.

The plugin only loads once and sets up the text objects using the `vim-textobj-user` framework.

## Troubleshooting

### Text objects not working

1. Make sure `vim-textobj-user` is installed
2. Ensure you're editing a Vim file (`:set filetype?` should show `vim`)
3. Check that the plugin loaded (`:echo exists('g:loaded_textobj_vimscript_blocks')` should return `1`)

### Comment/string detection not working

Enable syntax highlighting with `:syntax on` in your vimrc. Without syntax highlighting, the plugin falls back to simple line-based comment detection.

## License

This plugin is released into the public domain. Feel free to use, modify, and distribute it as you see fit.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests on GitHub.

When contributing, please:
- Follow the existing code style
- Test your changes with various Vimscript blocks
- Update documentation if adding new features

## Related Plugins

- [vim-textobj-user](https://github.com/kana/vim-textobj-user) - Framework for custom text objects (required)
- [vim-textobj-entire](https://github.com/kana/vim-textobj-entire) - Text objects for entire buffer
- [vim-textobj-indent](https://github.com/kana/vim-textobj-indent) - Text objects for indented blocks
- [vim-textobj-function](https://github.com/kana/vim-textobj-function) - Text objects for functions in various languages

## Credits

Created using the [vim-textobj-user](https://github.com/kana/vim-textobj-user) framework by kana.
