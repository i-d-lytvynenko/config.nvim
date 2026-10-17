" Better syntax highlighting
syn match aldaDyn1 "\v\(p{3,}\)"
syn match aldaDyn2 "\v\((pp|p|mp)\)"
syn match aldaDyn3 "\v\(mf\)"
syn match aldaDyn4 "\v\(f{1,2}\)"
syn match aldaDyn5 "\v\(f{3,}\)"
syn match aldaRest "\v<r(\d+\.*)?(\*\d+)?>"
syn match aldaShift "\v[<>]"
hi aldaDyn1 guifg=#4b5263 | hi aldaDyn2 guifg=#7f848e | hi aldaDyn3 guifg=#abb2bf
hi aldaDyn4 guifg=#e5c07b | hi aldaDyn5 guifg=#e06c75 gui=bold
hi link aldaRest NonText  | hi link aldaShift WarningMsg

" Plugin regex fix
syn clear aldaIdentifier aldaMarker aldaAtMarker
syn match aldaIdentifier "\v[a-zA-Z]{2,}[[:alnum:]_\-+'()]*"
syn match aldaMarker     "\v\%[a-zA-Z]{2,}[[:alnum:]_\-+'()]*"
syn match aldaAtMarker   "\v\@[a-zA-Z]{2,}[[:alnum:]_\-+'()]*"
