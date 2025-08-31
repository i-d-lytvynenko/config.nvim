" Vim syntax file
" Language:         Leightweight orgmode alternative
" Maintainer:       i-d-lytvynenko <lytvynenko.i.d@gmail.com>
" Latest Revision:  2024-05-26

if exists("b:current_syntax")
  finish
endif

let s:cpo_save = &cpo
set cpo&vim



syn match orgPage =^\_s*---.\{-}---=
hi def link orgPage Type

syn match orgHeadline =^\_s*\*\+\s.*=
highlight orgHeadline guifg=#c75ae8 gui=bold

syn match orgTack =^\v\_s*\zs(-|((\l|\d)+(\.(\l|\d)+)*[).]))\ze =
hi def link orgTack Type

syn match orgCheckbox =^\_s*\zs\[[X -]\]\ze =
hi def link orgCheckbox Type

syn match orgCheckboxSummary =^\_s*\zs\[\d*[/]\d*\]\ze =
syn match orgCheckboxSummary =\zs\[\d*[/]\d*\]\ze\s*$=
hi def link orgCheckboxSummary Type

syn match orgTime =\[\d\d[:]\d\d\]=
hi def link orgTime Number

syn match orgLink =\[\[\(.\{-}\)\]\]=
syn match orgLink =\v\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%([&:#*@~%_\-=?!+;/0-9a-z]+%(%([.;/?]|[.][.]+)[&:#*@~%_\-=?!+/0-9a-z]+|:\d+|,%(%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)@![0-9a-z]+))*|\([&:#*@~%_\-=?!+;/.0-9a-z]*\)|\[[&:#*@~%_\-=?!+;/.0-9a-z]*\]|\{%([&:#*@~%_\-=?!+;/.0-9a-z]*|\{[&:#*@~%_\-=?!+;/.0-9a-z]*\})\})+=
hi def link orgLink Constant

syn match orgLinkHeadline ={{\(.\{-}\)}}=
hi def link orgLinkHeadline Statement

syn region orgString start="^\_s*\zs{\ze$" end="^\_s*\zs}\ze$"
syn match orgString ={{\@!\(.\{-}\)}=
hi def link orgString String

syn match orgStrikeout =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\~.\(.\{-}\)\~\ze\([.,!?'":;}\])]\|\_s\|$\)=
hi def link orgStrikeout Comment

syn match orgBold =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\*.\(.\{-}\)\*\ze\([.,!?'":;}\])]\|\_s\|$\)=
highlight orgBold guifg=#f6f6f6 gui=bold

syn match orgUnderline =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs_\(.\{-}\)_\ze\([.,!?'":;}\])]\|\_s\|$\)=
highlight orgUnderline guisp=#f6f6f6 guifg=#f6f6f6 gui=underline

syn match orgItalic =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\/\(.\{-}\)\/\ze\([.,!?'":;}\])]\|\_s\|$\)=
highlight orgItalic guifg=#e2e2e2 gui=italic

syn match orgGreen =^\_s*\zs\: \(.*\)\ze$=
syn match orgGreen =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\:\(.\{-}\)\:\ze\([.,!?'":;}\])]\|\_s\|$\)=
highlight orgGreen guifg=#77ff9b gui=bold

syn match orgYellow =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\;\(.\{-}\)\;\ze\([.,!?'":;}\])]\|\_s\|$\)=
syn match orgYellow =^\_s*\zs\; \(.*\)\ze$=
hi def link orgYellow WarningMsg

syn match orgRed =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\!\(.\{-}\)\!\ze\([.,!?'":;}\])]\|\_s\|$\)=
syn match orgRed =^\_s*\zs\! \(.*\)\ze$=
hi def link orgRed ErrorMsg

syn match orgBlue =\(^\|\_s\|(\|\[\|{\|"\|'\)\zs\^\(.\{-}\)\^\ze\([.,!?'":;}\])]\|\_s\|$\)=
syn match orgBlue =^\_s*\zs\^ \(.*\)\ze$=
hi def link orgBlue MoreMsg


let b:current_syntax = "org"

let &cpo = s:cpo_save
unlet s:cpo_save
