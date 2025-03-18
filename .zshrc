alias gl='git log --graph --oneline --all -n 1000 --abbrev=4'

function tmx() {
  if [ -n "$1" ]
  then
    tmux attach -t "$1" || tmux new -s "$1"
  fi
}

function _tmx() {
  local list
  list=`tmux ls 2>&1 | sed -n 's/^\([^:]*\):.*$/\1/gp'`
  cur="${COMP_WORDS[COMP_CWORD]}"
  if [[ ${COMP_CWORD} -eq 1 ]] ; then
    COMPREPLY=( $(compgen -W "${list}" -- ${cur}) )
  fi
}
complete -F _tmx tmx

# On Linux
# function tmx() {
#   if [ -n "$1" ]
#   then
#     tmux attach -t "$1" || tmux new -s "$1"
#   fi
# }
# 
# function _tmx() {
#   local list
#   list=`tmux ls 2>&1 | sed -n 's/^\([^:]*\):.*$/\1/gp'`
#   cur="${COMP_WORDS[COMP_CWORD]}"
#   if [[ ${COMP_CWORD} -eq 1 ]] ; then
#     COMPREPLY=( $(compgen -W "${list}" -- ${cur}) )
#   fi
# }
# 
# autoload bashcompinit && bashcompinit
# complete -F _tmx tmx

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# Vi mode
bindkey -v
bindkey "^?" backward-delete-char

# On Mac
function alert () {
  _CODE=$?
  _SNAME=$(
    for s in $(tmux list-sessions -F '#{session_name}'); do
      tmux list-panes -F '#{pane_tty} #{session_name}:#I' -t "$s"
    done | grep "$(tty)" | awk '{print $2}')
  osascript -e "display notification \"$(echo ${history[$HISTCMD]} | tr '"\' "“⧹")\" with title \"${_SNAME}($((return $_CODE) && echo ✅ || echo ❌)$_CODE)\" sound name \"Glass\""
  # afplay /System/Library/Sounds/Glass.aiff
}

