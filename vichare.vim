set foldcolumn=0

call pathogen#infect()

let g:rustfmt_autosave = 1

autocmd VimEnter * nmap <C-N> :NERDTreeToggle<CR>

set history=50		" keep 50 lines of command line history
set nu          " show row number
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set nobackup
set autoindent		" always set autoindenting on
set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set showmatch
set expandtab
set tabstop=2
set shiftwidth=2

set incsearch

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    " Any search highlights the string matched by the search
    set hlsearch
endif

filetype plugin indent on

" link clipboard to unnamed
" set clipboard+=unnamed


if has('autocmd')
    " when event "set filetype" occurs (see :help filetype)
    " autocmd Filetype perl call PerlDetected()
    " autocmd Filetype java call JavaDetected()
    " autocmd Filetype tex call TeXDetected()
    " autocmd Filetype mp call MetaPostDetected()
    autocmd Filetype cpp call CppDetected()
    " autocmd Filetype c call CppDetected()
    " autocmd Filetype html call HtmlDetected()
    " autocmd Filetype htm call HtmlDetected()
endif


if has("all_builtin_terms")
        func CppDetected()
            "------ put the cursor between "" or () automatically ----
            " inoremap "" ""<C-C>i
            " inoremap () ()<C-C>i

            " ----- put ; at the end ----
            nmap ;; A;<ESC>

            "----------- Ctrl+J to input a empty block {} --------
            nmap <C-J> A {<CR>}<C-C>O;<ESC>
            imap <C-J> <C-C>A {<CR>}<C-C>O

            " ------ Compile and Run ---------
            "map <F9> :!make "%:p:r"<CR>
            map <F9> :!g++ -o "%:p:r" --std=c++11 "%:p"<CR>
            map <F10> :!"%:p:r"<CR>

            " ------ F11 for template --------
            nmap <F11> O#include <iostream><CR><CR>using namespace std;<CR><CR>int main() {<CR>return 0;<CR>}<C-C>
            nmap <F11> <C-C>O#include <iostream><CR><CR>using namespace std;<CR><CR>int main() {<CR>return 0;<CR>}<C-C>
        endfunc
endif
