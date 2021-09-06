export ZSH=$HOME/.oh-my-zsh
prod_zones="dca20 dca1 dca11 dca4 dca8 icn99 las99 phx2 phx3 phx4 phx5 phx99 ALL_ZONES"
alias bhd="bazel run //src/code.uber.internal/infra/bhd/cmd/cli --"

plugins=(git docker docker-compose zsh-z zsh-syntax-highlighting)
ZSH_THEME="crcandy"
#ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#9BC7FF"
source $ZSH/oh-my-zsh.sh
DISABLE_UPDATE_PROMPT=true

export EDITOR=nvim

alias hc="hostctl console -if"
alias nv="nvim -n" 
alias ad="arc diff HEAD^"
alias rel="source ~/.zshrc"
alias gs="git status ."
alias gprom="git pull --rebase origin main"
alias gcaa="git commit -a --amend"
alias gcam="git commit -am"
alias gca="git add .; git commit -m $1"
alias gcm="git commit -m"
alias gr="git rebase"
alias gre="git rebase --edit-todo"
alias grc="git rebase --continue"
alias grl="git reflog"
alias his="hostissue"
alias zl='lzc host list -z $1 "${@:2}"'
alias sshdev='ssh zachcheung.devpod-us-or'
alias infra='cd ~/go-code/src/code.uber.internal/infra/'
alias nf='nv $(fzf)'

alias tmc="nc -q 5000 localhost 2224"
alias fmc="nc localhost 2225"
vtmc(){
  cat ~/.vitemp | tmc
}
uuid(){

id=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
echo $id
echo $id | pbcopy
}

lhs(){
lzc host show --format='{{.Hostname}} {{.UUID}} {{.Group}} {{.ProviderType}} {{.ServerType}}
{{.Manufacturer}} {{.Layout}} {{.Type}} {{.Interfaces.Primary.IPv4}} {{.Interfaces.Primary.MAC}}
{{.Interfaces.BMC.IPv4}}' $@ | sed 's/ *$//g' | awk '{ gsub(" ", "\n", $0); print}'
}
unalias gdt
gdt(){
d=${1:-1}
git difftool HEAD~$d HEAD~$(($d-1))
}

gdo(){
d=${1:-1}
top=$(git rev-parse --show-toplevel)
files="$(git --no-pager diff HEAD~$d HEAD~$(($d-1)) --name-only | sed "s,^,$top/,")"

exist_files=""
echo $files | while read f; do
 if [[ -f "$f" || -d "$f" ]]; then
    exist_files="$exist_files $f"
  else
    echo "$f doesn't exist"
  fi
done

eval "nv $exist_files" 
}

gduo(){
  d=${1:-1}
  top=$(git rev-parse --show-toplevel)
  files="$(git --no-pager diff --diff-filter=U  --name-only | sed "s,^,$top/,")"
  
  exist_files=""
  echo $files | while read f; do
   if [[ -f "$f" || -d "$f" ]]; then
      exist_files="$exist_files $f"
    else
      echo "$f doesn't exist"
    fi
  done

  eval "nv $exist_files" 
}

gdou(){
  d=${1:-1}
  top=$(git rev-parse --show-toplevel)
  files="$(git --no-pager diff --name-only | sed "s,^,$top/,")"
  
  exist_files=""
  echo $files | while read f; do
   if [[ -f "$f" || -d "$f" ]]; then
      exist_files="$exist_files $f"
    else
      echo "$f doesn't exist"
    fi
  done

  eval "nv $exist_files" 
}

alias gl="git log --pretty=oneline --abbrev-commit"
sgp(){
~/go-code/bin/setup-gopath "//src/code.uber.internal/infra/$1/..."
}
vt(){
usso -utoken utoken -aud usecret -print 2>/dev/null | jq -j .shp_utoken | vault write -format=json -namespace=$1 auth/utoken/login jwt=- | jq -j '.auth.client_token' | pbcopy 
}
cleartemp(){
cd;
rm -rf temp;
mkdir temp;
cd temp;
}
export VAULT_ADDR="https://ess.uberinternal.com"

HIST_STAMPS="mm/dd/yyyy"

echo -e "`date +"%Y-%m-%d %H:%M:%S"` direnv hooking zsh" > /dev/null
eval "$(direnv hook zsh)" > /dev/null
bindkey -v

 # Remove mode switching delay.
KEYTIMEOUT=5

# Change cursor shape for different vi modes.
#function zle-keymap-select {
#  if [[ ${KEYMAP} == vicmd ]] ||
#     [[ $1 = 'block' ]]; then
#    echo -ne '\e[2 q'
#
#  elif [[ ${KEYMAP} == main ]] ||
#       [[ ${KEYMAP} == viins ]] ||
#       [[ ${KEYMAP} = '' ]] ||
#       [[ $1 = 'beam' ]]; then
#    echo -ne '\e[6 q'
#  fi
#}
#zle -N zle-keymap-select

# Use beam shape cursor on startup.
# echo -ne '\e[6 q'

# Use beam shape cursor for each new prompt.
_fix_cursor() {
   echo -ne '\e[6 q'
}

precmd_functions+=(_fix_cursor)

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey '^R' history-incremental-search-backward
export MONOREPO_GOPATH_MODE=1 # This is optional. Without it, GOPATH mode will be off by default
export GO111MODULE="off"
source $HOME/gopathmodeFunc.bash
export FZF_DEFAULT_COMMAND='rg --files --no-ignore-vcs --hidden'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/usr/local/bin/google-cloud-sdk/path.zsh.inc' ]; then . '/usr/local/bin/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/usr/local/bin/google-cloud-sdk/completion.zsh.inc' ]; then . '/usr/local/bin/google-cloud-sdk/completion.zsh.inc'; fi
HISTTIMEFORMAT="%d/%m/%y %T "
HISTTIMEFORMAT="%F %T "

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
