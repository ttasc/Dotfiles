source <(fzf --zsh) || { \
    source /usr/share/fzf/key-bindings.zsh && \
    source /usr/share/fzf/completion.zsh \
}

[ -x "$(command -v bat)" ] && previewtool="bat -n --color=always --line-range :500" || previewtool="less"
FZF_STYLE="
    --height 60%
    --highlight-line
    --info=inline-right
    --layout=reverse
    --border=none
    --ansi

    --color=bg+:#2d3f76
    --color=bg:#1e2030
    --color=border:#589ed7
    --color=fg:#c8d3f5
    --color=gutter:#1e2030
    --color=header:#ff966c
    --color=hl+:#65bcff
    --color=hl:#65bcff
    --color=info:#545c7e
    --color=marker:#ff007c
    --color=pointer:#ff007c
    --color=prompt:#65bcff
    --color=query:#c8d3f5:regular
    --color=scrollbar:#589ed7
    --color=separator:#ff966c
    --color=spinner:#ff007c
"
FZF_PREVIEW="
    --preview '$previewtool {}'
    --preview-window='hidden:wrap'
    --bind='ctrl-p:toggle-preview'
"
export FZF_DEFAULT_OPTS="
    $FZF_STYLE
    $FZF_PREVIEW
"
