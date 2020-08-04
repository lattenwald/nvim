" Custom surrounds
let b:surround_{char2nr('c')} = "```\r```"
let b:surround_{char2nr('C')} = "```\n\r```"

highlight mkdDone ctermbg=LightGreen guibg=LightGreen
match mkdDone /\<DONE\>/
