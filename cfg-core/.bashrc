# .bashrc for OS X and Ubuntu
# ====================================================================
# - https://github.com/gustybear/dotfiles
# - zheng.iao@icloud.com

# System default
# --------------------------------------------------------------------

[ -f /etc/profile ] && [ "$PLATFORM" != 'Darwin' ] || PATH="" && source /etc/profile
[ -f /etc/bashrc ] && . /etc/bashrc
export PATH_EXPANDED=""
export PLATFORM=$(uname -s)

# Get the BASE dir
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
BASE="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Options
# --------------------------------------------------------------------

### Change directory without cd (only available in bash 4)
shopt -s autocd

### Autocorrect directory name when cd
shopt -s cdspell

### Append to the history file
shopt -s histappend

### Check the window size after each command ($LINES, $COLUMNS)
shopt -s checkwinsize

### Better-looking less for binary files
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

### Bash completion
### OS X
if [ "$PLATFORM" = 'Darwin' ]; then
  [ -f $(brew --prefix)/etc/bash_completion ] && . $(brew --prefix)/etc/bash_completion
fi

### Linux
if [ "$PLATFORM" = 'Linux' ]; then
  [ -f /etc/bash_completion ] && . /etc/bash_completion
fi

### Disable CTRL-S and CTRL-Q
[[ $- =~ i ]] && stty -ixoff -ixon

# If there are multiple matches for completion, Tab should cycle through them

bind 'TAB':menu-complete

# Display a list of the matching files

bind "set show-all-if-ambiguous on"

# Perform partial completion on the first Tab press,
# only start cycling full results on the second Tab press

bind "set menu-complete-display-prefix on"


# Environment variables
# --------------------------------------------------------------------

### man bash
export HISTCONTROL=ignoreboth:erasedups
export HISTSIZE=
export HISTFILESIZE=
export HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S:   "
export MAILDIR=$HOME/.mail
[ -z "$TMPDIR" ] && TMPDIR=/tmp

export EDITOR=vim
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

### OS X PATH
if [ "$PLATFORM" = 'Darwin' ]; then
  export COPYFILE_DISABLE=true
  export LOCALBIN=${HOME}/.local/bin
  export GOPATH=${HOME}/.local/share/go
  export GOROOT=$(brew --prefix)/opt/go
  export PYTHONROOT=$(brew --prefix)/opt/python
  export DROPBOX_DIR=${HOME}/Cloud/Dropbox
  mkdir -p $GOPATH
  if [ -z "$PATH_EXPANDED" ]; then
    export PATH=$LOCALBIN:$PYTHONROOT/libexec/bin:$GOPATH/bin:$GOROOT/libexec/bin:$PATH
  fi
fi

### Linux PATH
if [ "$PLATFORM" = 'Linux' ]; then
  export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:.:/usr/local/lib
  export LOCALBIN=${HOME}/.local/bin
  export GOPATH=${HOME}/.local/share/go
  export GOROOT=/usr/local/go
  export DROPBOX_DIR=${HOME}/Dropbox
  mkdir -p $GOPATH
  if [ -z "$PATH_EXPANDED" ]; then
    export PATH=$LOCALBIN:$GOPATH/bin:$GOROOT/bin:$PATH
  fi
fi
export PATH_EXPANDED=1

### Prompt
__git_ps1() { :;}
if [ -e ~/.git-prompt.sh ]; then
  source ~/.git-prompt.sh
fi
PS1='\[\e[34m\]\u\[\e[1;32m\]@\[\e[0;33m\]\h\[\e[35m\]:\[\e[m\]\W\[\e[1;30m\]$(__git_ps1)\[\e[1;31m\]> \[\e[0m\]'

### FZF
csi() {
  echo -en "\x1b[$*"
}

fzf-down() {
  fzf --height 50% "$@" --border
}

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND='fd --type f --type d --hidden --follow --exclude .git'
[ -n "$NVIM_LISTEN_ADDRESS" ] && export FZF_DEFAULT_OPTS='--no-height'

if [ -x ~/.vim/plugged/fzf.vim/bin/preview.rb ]; then
  export FZF_CTRL_T_OPTS="--preview '~/.vim/plugged/fzf.vim/bin/preview.rb {} | head -200'"
fi

export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort' --header 'Press CTRL-Y to copy command into clipboard' --border"

command -v blsd > /dev/null && export FZF_ALT_C_COMMAND='blsd $dir'
command -v tree > /dev/null && export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Key Bindings
# --------------------------------------------------------------------
# Bind CTRL-X-CTRL-T to tmuxwords.sh
[ -n "$TMUX_PANE" ] && bind '"\C-x\C-t": "$(fzf_tmux_words)\e\C-e\er"'

# Aliases
# --------------------------------------------------------------------

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias cd.='cd ..'
alias cd..='cd ..'
alias l='ls -alF'
alias ll='ls -l'
alias vi='vim'
alias vi2='vi -O2 '
alias hc="history -c"
alias which='type -p'
alias k5='kill -9 %%'
alias gs='git status'
alias gv='vim +GV +"autocmd BufWipeout <buffer> qall"'
alias gl='git log --graph --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"'

[ "$PLATFORM" = 'Darwin' ] && alias tac='tail -r'

### Tmux
alias tmux="tmux -2"
alias tmuxls="ls $TMPDIR/tmux*/"

### Colored ls
if [ -x /usr/bin/dircolors ]; then
  eval "`dircolors -b`"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
elif [ "$PLATFORM" = Darwin ]; then
  alias ls='ls -G'
fi

alias bert='bundle exec rake test'
alias ber='bundle exec rake'
alias be='bundle exec'


# Helper functions
# --------------------------------------------------------------------
### Control
miniprompt() {
  unset PROMPT_COMMAND
  PS1="\[\e[38;5;168m\]> \[\e[0m\]"
}

tail-until() {
  pattern=$1
  shift
  grep -m 1 "$pattern" <(exec tail -F "$@"); kill $!
}

repeat() {
  local _
  for _ in $(seq $1); do
    eval "$2"
  done
}

ftheme() {
  [ -d ~/Projects/github/iTerm2-Color-Schemes/ ] || return
  local base
  base=~/Projects/github/iTerm2-Color-Schemes
  $base/tools/preview.rb "$(
    ls {$base/schemes,~/.vim/plugged/seoul256.vim/iterm2}/*.itermcolors | fzf)"
}

### Navigation
..cd() {
  cd ..
  cd "$@"
}

_parent_dirs() {
  COMPREPLY=( $(cd ..; find . -mindepth 1 -maxdepth 1 -type d -print | cut -c3- | grep "^${COMP_WORDS[COMP_CWORD]}") )
}

complete -F _parent_dirs -o default -o bashdefault ..cd

### File
ext() {
  ext-all --exclude .git --exclude target --exclude "*.log"
}

ext-all() {
  local name=$(basename $(pwd))
  cd ..
  tar -cvzf "$name.tgz" $* --exclude "$name.tgz" "$name"
  cd -
  mv ../"$name".tgz .
}

if [ "$PLATFORM" = 'Darwin' ]; then
  o() {
    open --reveal "${1:-.}"
  }
fi

### Search
csbuild() {
  [ $# -eq 0 ] && return

  cmd="find `pwd`"
  for ext in $@; do
    cmd=" $cmd -name '*.$ext' -o"
  done
  echo ${cmd: 0: ${#cmd} - 3}
  eval "${cmd: 0: ${#cmd} - 3}" > cscope.files &&
  cscope -b -q && rm cscope.files
}

# ftags - search ctags
ftags() {
  local line
  [ -e tags ] &&
  line=$(
    awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
    cut -c1-$COLUMNS | fzf --nth=2 --tiebreak=begin
  ) && $EDITOR $(cut -f3 <<< "$line") -c "set nocst" \
                                      -c "silent tag $(cut -f2 <<< "$line")"
}

### Edit
viw() {
  vim "$(which "$1")"
}

temp() {
  vim +"set buftype=nofile bufhidden=wipe nobuflisted noswapfile tw=${1:-0}"
}

# v - open files in ~/.viminfo
v() {
  local files
  files=$(grep '^>' ~/.viminfo | cut -c3- |
          while read line; do
            [ -f "${line/\~/$HOME}" ] && echo "$line"
          done | fzf -d -m -q "$*" -1) && vim ${files//\~/$HOME}
}

# https://github.com/wellle/tmux-complete.vim
fzf_tmux_words() {
[ -n "$TMUX_PANE" ] || return
  tmuxwords.rb --all --scroll 500 --min 5 | fzf-down --multi | paste -sd" " -
}


# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
  local file
  file=$(fzf-tmux --query="$1" --select-1 --exit-0)
  [ -n "$file" ] && ${EDITOR:-vim} "$file"
}

# Modified version where you can press
#   - CTRL-O to open with `open` command,
#   - CTRL-E or Enter key to open with the $EDITOR
fo() {
  local out file key
  IFS=$'\n' read -d '' -r -a out < <(fzf-tmux --query="$1" --exit-0 --expect=ctrl-o,ctrl-e)
  key=${out[0]}
  file=${out[1]}
  if [ -n "$file" ]; then
    if [ "$key" = ctrl-o ]; then
      open "$file"
    else
      ${EDITOR:-vim} "$file"
    fi
  fi
}

### Tmux
tt() {
  if [ $# -lt 1 ]; then
    echo 'usage: tt <commands...>'
    return 1
  fi

  local head="$1"
  local tail='echo -n Press enter to finish.; read'

  while [ $# -gt 1 ]; do
    shift
    tmux split-window "$SHELL -ci \"$1; $tail\""
    tmux select-layout tiled > /dev/null
  done

  tmux set-window-option synchronize-panes on > /dev/null
  $SHELL -ci "$head; $tail"
}

tx() {
  tmux splitw "$*; echo -n Press enter to finish.; read"
  tmux select-layout tiled
  tmux last-pane
}

tping() {
  for p in $(tmux list-windows -F "#{pane_id}"); do
    tmux send-keys -t $p Enter
  done
}

tpingping() {
  [ $# -ne 1 ] && return
  while true; do
    echo -n '.'
    tmux send-keys -t $1 ' '
    sleep 10
  done
}

# Switch tmux-sessions
fs() {
  local session
  session=$(tmux list-sessions -F "#{session_name}" | \
    fzf --height 40% --reverse --query="$1" --select-1 --exit-0) &&
  tmux switch-client -t "$session"
}

# ftpane - switch pane (@george-b)
ftpane() {
  [ -n "$TMUX_PANE" ] || return
  local panes current_window current_pane target target_window target_pane
  panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
  current_pane=$(tmux display-message -p '#I:#P')
  current_window=$(tmux display-message -p '#I')

  target=$(echo "$panes" | grep -v "$current_pane" | fzf +m --reverse) || return

  target_window=$(echo $target | awk 'BEGIN{FS=":|-"} {print$1}')
  target_pane=$(echo $target | awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1)

  if [[ $current_window -eq $target_window ]]; then
    tmux select-pane -t ${target_window}.${target_pane}
  else
    tmux select-pane -t ${target_window}.${target_pane} &&
    tmux select-window -t $target_window
  fi
}

### Git
gitzip() {
  git archive -o $(basename $PWD).zip HEAD
}

gittgz() {
  git archive -o $(basename $PWD).tgz HEAD
}

gitdiffb() {
  if [ $# -ne 2 ]; then
    echo two branch names required
    return
  fi
  git log --graph \
  --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' \
  --abbrev-commit --date=relative $1..$2
}

acdul() {
  acdcli ul -x 8 -r 4 -o "$@"
}

acddu() {
  acdcli ls -lbr "$1" | awk '{sum += $3} END { print sum / 1024 / 1024 / 1024 " GB" }'
}

make-patch() {
  local name="$(git log --oneline HEAD^.. | awk '{print $2}')"
  git format-patch HEAD^.. --stdout > "$name.patch"
}

pbc() {
  perl -pe 'chomp if eof' | pbcopy
}

cheap-bin() {
  local PID=$(jps -lv |
      fzf --height 30% --reverse --inline-info \
          --preview 'echo {}' --preview-window bottom:wrap | awk '{print $1}')
  [ -n "$PID" ] && jmap -dump:format=b,file=cheap.bin $PID
}

if [ "$PLATFORM" = 'Darwin' ]; then
  resizes() {
    mkdir -p out &&
    for jpg in *.JPG; do
      echo $jpg
      [ -e out/$jpg ] || sips -Z 2048 --setProperty formatOptions 80 $jpg --out out/$jpg
    done
  }

  j() { export JAVA_HOME=$(/usr/libexec/java_home -v1.$1); }

  # https://gist.github.com/Andrewpk/7558715
  alias startvpn="sudo launchctl load -w /Library/LaunchDaemons/net.juniper.AccessService.plist; open -a '/Applications/Junos Pulse.app/Contents/Plugins/JamUI/PulseTray.app/Contents/MacOS/PulseTray'"
  alias quitvpn="osascript -e 'tell application \"PulseTray.app\" to quit';sudo launchctl unload -w /Library/LaunchDaemons/net.juniper.AccessService.plist"
fi

jfr() {
  if [ $# -ne 1 ]; then
    echo 'usage: jfr DURATION'
    return 1
  fi
  local pid path
  pid=$(jcmd | grep -v jcmd | fzf --height 30% --reverse | cut -d' ' -f1)
  path="/tmp/jfr-$(date +'%Y%m%d-%H%M%S').jfr"
  date
  jcmd "$pid" JFR.start duration="${1:-60}s" filename="$path" || return
  while jcmd "$pid" JFR.check | grep running > /dev/null; do
    echo -n .
    sleep 1
  done
  echo
  open "$path"
}

jfr-remote() (
  set -x -o pipefail
  if [ $# -ne 3 ]; then
    echo 'usage: jfr-remote HOST SUDOUSER DURATION'
    return 1
  fi
  local pid path dur
  pid=$(ssh -t "$1" "sudo -i sudo -u $2 jcmd" 2> /dev/null | grep -v jcmd |
        fzf --height 30% --reverse | cut -d' ' -f1) || return 1
  path="/tmp/jfr-$(date +'%Y%m%d-%H%M%S').jfr"
  dur="${3:-60}s"
  date
  ssh -t "$1" "sudo -i sudo -u $2 jcmd $pid JFR.start duration=$dur filename=$path || return"
  sleep $dur
  sleep 3
  ssh -t "$1" "sudo -i sudo -u $2 chmod o+r $path"
  scp "$1:$path" /tmp && open "$path"
)

# Figlet font selector => copy to clipboard
fgl() (
  [ $# -eq 0 ] && return
  cd /usr/local/Cellar/figlet/*/share/figlet/fonts
  local font=$(ls *.flf | sort | fzf --no-multi --reverse --preview "figlet -f {} $@") &&
  figlet -f "$font" "$@" | pbcopy
)

# fco - checkout git branch/tag
fco() {
  local tags branches target
  tags=$(git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
  branches=$(
    git branch --all | grep -v HEAD             |
    sed "s/.* //"    | sed "s#remotes/[^/]*/##" |
    sort -u          | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
  target=$(
    (echo "$tags"; echo "$branches") | sed '/^$/d' |
    fzf-down --no-hscroll --reverse --ansi +m -d "\t" -n 2 -q "$*") || return
  git checkout $(echo "$target" | awk '{print $2}')
}


# Z integration
source "$HOME/.local/bin/z.sh"
unalias z 2> /dev/null
z() {
  [ $# -gt 0 ] && _z "$*" && return
  cd "$(_z -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "${*##-* }" | sed 's/^[0-9,.]* *//')"
}

# c - browse chrome history
c() {
  local cols sep
  export cols=$(( COLUMNS / 3 ))
  export sep='{::}'

  cp -f ~/Library/Application\ Support/Google/Chrome/Default/History /tmp/h
  sqlite3 -separator $sep /tmp/h \
    "select title, url from urls order by last_visit_time desc" |
  ruby -ne '
    cols = ENV["cols"].to_i
    title, url = $_.split(ENV["sep"])
    len = 0
    puts "\x1b[36m" + title.each_char.take_while { |e|
      if len < cols
        len += e =~ /\p{Han}|\p{Katakana}|\p{Hiragana}|\p{Hangul}/ ? 2 : 1
      end
    }.join + " " * (2 + cols - len) + "\x1b[m" + url' |
  fzf --ansi --multi --no-hscroll --tiebreak=index |
  sed 's#.*\(https*://\)#\1#' | xargs open
}

# so - my stackoverflow favorites
so() {
  $BASE/../bin/stackoverflow-favorites |
    fzf --ansi --reverse --with-nth ..-2 --tac --tiebreak index |
    awk '{print $NF}' | while read -r line; do
      open "$line"
    done
}

# GIT heart FZF
# -------------

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1}) | head -500' |
  cut -c4- | sed 's/.* -> //'
}

gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1) | head -200' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {} | head -200'
}

gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always | head -200' |
  grep -o "[a-f0-9]\{7,\}"
}

gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1} | head -200' |
  cut -d$'\t' -f1
}

if [[ $- =~ i ]]; then
  bind '"\er": redraw-current-line'
  bind '"\C-g\C-f": "$(gf)\e\C-e\er"'
  bind '"\C-g\C-b": "$(gb)\e\C-e\er"'
  bind '"\C-g\C-t": "$(gt)\e\C-e\er"'
  bind '"\C-g\C-h": "$(gh)\e\C-e\er"'
  bind '"\C-g\C-r": "$(gr)\e\C-e\er"'
fi

# Creating or append git ignore by query gitignore.io
git-add-ignore() {
  result=$(curl "https://www.gitignore.io/api/$1" 2>/dev/null)

  if [[ $result =~ ERROR ]]; then
    echo "Query '$1' has no match. See a list of possible queries with 'gi list'"
  elif [[ $1 == list ]]; then
    echo "Possible search keywords: "
    echo "$result"
  else
    echo "Iterms to add:"
    echo "$result"
    if [[ -f .gitignore ]]; then
      result=`echo "$result" | \
              grep -v -e "# Created by https://www.gitignore.io" \
                      -e "# End of https://www.gitignore.io" `
      echo ".gitignore already exists, appending"
      echo "$result" >> .gitignore
    else
      echo "$result" > .gitignore
    fi
  fi
}

# Project Repository Management
#-------------------------------------------------------------------------------
# Given a path to a folder containing some git repos, compute the
# names of the folders which actually do contain git repos.
repo-find() {
  local dirname_cmd
  if [ "$PLATFORM" == "Darwin" ]; then  # macOS
    dirname_cmd="gdirname"
  elif [ "$PLATFORM" == "Linux" ]; then  # Linux
    dirname_cmd="dirname"
  fi
	# https://stackoverflow.com/questions/23356779/how-can-i-store-find-command-result-as-arrays-in-bash
	git_directories=()
	while IFS=  read -r -d $'\0'; do
		git_directories+=("$REPLY")
	done < <(find $1 -maxdepth 2 -type 'd' -name ".git" -print0 2>/dev/null)

	for i in ${git_directories[*]}; do
		if [[ ! -z $i ]]; then
    		$dirname_cmd -z $i | xargs -0 -L1
    fi
  done
}

# List all the git repos in the path.
repo-ls() {
    local path=$1
    local repo
    for repo in $(repo-find $path) ; do
        echo ${repo} ":" $(git -C ${repo} symbolic-ref HEAD | sed -e "s/^refs\/heads\///")
    done
}

# Make a automatic commit if within a git repo.
# The commitment message can be from the stdin or generated from git status.
repo-commit() {
  local commit_message
  is_in_git_repo || return
  if ! git diff-index --quiet $(git write-tree) -- || [ -n "$(git status --porcelain)" ]; then
    echo "Attempt automatic commit ... ";
    git add -A;
    git status -sb;
    echo -n "Input the commit message: ";
    read commit_message;
    if [[ ! -n "$commit_message" ]]; then
      commit_message=$(LANG=C git -c color.status=false status -s);
    fi;
    echo "Commit message: "; echo "$commit_message"; echo;
    echo "$commit_message" | git commit -F -;
  fi
  git push -v
}

# Create a prject folder based on the input information
prj-init() {
  local answer project_type
  local project_name person_name
  local course_number course_semester course_year
  local dir_name
  local proj_path

  echo -n "Is this a (r)esearch/(a)ward/(t)alk/s(e)rvice/(c)ourse/(s)tudent/(p)ersonal? "
  old_stty_cfg=$(stty -g)
  stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

  if echo "$answer" | grep -iq "^r" ;then
    project_type="project"
  elif echo "$answer" | grep -iq "^a" ;then
    project_type="award"
  elif echo "$answer" | grep -iq "^t" ;then
    project_type="talk"
  elif echo "$answer" | grep -iq "^e" ;then
    project_type="service"
  elif echo "$answer" | grep -iq "^c" ;then
    project_type="course"
  elif echo "$answer" | grep -iq "^s" ;then
    project_type="student"
  elif echo "$answer" | grep -iq "^p" ;then
    project_type="personal"
  else
    echo "invalid semester"
    exit 1
  fi

  if echo "$answer" | grep -Eiq "^s|^p" ;then
    echo -n "\nType in the name of the person(s): "
    read person_name
    person_name="${person_name// /_}"

    echo -n "Type in the name of the project: "
    read project_name
    project_name="${project_name// /_}"

  elif echo "$answer" | grep -Eiq "^c" ;then
    echo -n "\nType in the course number: "
    read course_name
    course_name="${course_name// /_}"

    echo -n "Type in the year: "
    read course_year
    course_year="${course_year// /_}"

    echo -n "Is this a (s)pring/s(u)mmer/(f)all course? "
    old_stty_cfg=$(stty -g)
    stty raw -echo ; semester=$(head -c 1) ; stty $old_stty_cfg

    if echo "$semester" | grep -iq "^s" ;then
      course_semester="spring"
    elif echo "$semester" | grep -iq "^u" ;then
      course_semester="summer"
    elif echo "$semester" | grep -iq "^f" ;then
      course_semester="fall"
    else
      echo "invalid semester"
      exit 1
    fi
  elif echo "$answer" | grep -Eiq "^r|^a|^t" ;then
    echo -n "\nType in the name of the project: "
    read project_name
    project_name="${project_name// /_}"
  fi

  if [[ -n "$course_name" ]]; then
    dir_name="$project_type"_"$course_name"_"$course_year"_"$course_semester"
  elif [[ -n "$person_name" ]]; then
    dir_name="$project_type"_`date +%Y_%m_%d`_"$person_name"_"$project_name"
  else
    dir_name="$project_type"_`date +%Y_%m_%d`_"$project_name"
  fi
  dir_name="${dir_name%_}"

  if [[ "$project_type" == "course" ]]; then
    proj_path=$HOME/Projects/teaching/"$dir_name"
    git_branch="course"
  elif [[ "$project_type" == "personal" ]]; then
    proj_path=$HOME/Projects/personal/"$dir_name"
    git_branch="project"
  elif [[ "$project_type" == "student" ]]; then
    proj_path=$HOME/Projects/students/"$dir_name"
    git_branch="project"
  elif [[ "$project_type" == "services" ]]; then
    proj_path=$HOME/Projects/services/"$dir_name"
    git_branch="project"
  elif [[ ("$project_type" == "project") || ("$project_type" == "award") || ("$project_type" == "talk") ]]; then
    proj_path=$HOME/Projects/research/"$dir_name"
    git_branch="project"
  fi

  if [[ "$project_type" == "personal" ]]; then
    mkdir -p "$proj_path"
  else
    git_repo="https://github.com/gustybear/templates.git"
    git clone --depth=1 -b "$git_branch" "$git_repo" "$proj_path"
    make --directory="$proj_path" init
  fi
}

# Check project status in a batch
prj-status() {
  local current_dir=${PWD}
  local repos=$(repo-find "${HOME}/Projects/* ${HOME}/.dotfiles")
  for dir in ${repos};
  do
      echo "Checking status of ${dir}...";
      cd ${dir} && git status -sb;
  done
  cd ${current_dir}
}

# Pull projects from remote
prj-pull() {
  local current_dir=${PWD}
  local repos=$(repo-find "${HOME}/Projects/* ${HOME}/.dotfiles")
  for dir in ${repos};
  do
      echo "Pulling updates of ${dir} from remote...";
      cd ${dir} && git pull;
  done
  cd ${current_dir}
}

# Update projects to remote
prj-update() {
  local current_dir=${PWD}
  local repos=$(repo-find "${HOME}/Projects/* ${HOME}/.dotfiles")
  for dir in ${repos};
  do
      echo "Updating ${dir} to remote...";
      cd ${dir} && repo-commit;
  done
  cd ${current_dir}
}

# Change to project directory using fzf
prj-fzf() {
  local dir
  dir=$(repo-find "${HOME}/Projects/* ${HOME}/.dotfiles" |
  fzf-tmux --preview-window up:75% \
    --preview 'cd {}; echo "git summary";
              LANG=C git -c color.status=false status -sb; 
              echo;
              tree -C {} | head -200' \
    --select-1) &&
  cd ${dir}
}

# Todo.sh task search
todo-fzf() {
  local todo_cmd
  if [ "$PLATFORM" == "Darwin" ]; then  # macOS
    todo_cmd="todo.sh"
  elif [ "$PLATFORM" == "Linux" ]; then  # Linux
    todo_cmd="todo-txt"
  fi
  local task
  task=$($todo_cmd ls | awk '$1~/^[0-9]+$/' |
        fzf-tmux --ansi --select-1 --exit-0 \
            --bind "ctrl-m:execute-silent(sed 's#.*: \(message://[^ ]\{0,\}%3e\).*#\1#' <<< {} | xargs open -a Mail)+abort" \
            --bind "ctrl-x:execute-silent(sed 's#^\([0-9]\{1,\}\) .*#\1#' <<< {} |xargs $todo_cmd -f del)+abort")
  echo $task
}

# Update website {{{3
site-update() {
  local current_dir=${PWD}
  local web="${HOME}/Projects/__websites"
  local repos=$(repo-find "${HOME}/Projects/*")
  if [ -z  ${web} ]; then
    echo "No website folder"
    for dir in ${repos};
    do
      (echo "Updating materials..."; make -C ${dir} publish_s3)
    done
  else
    echo "Updating website...";
    make -C ${web} publish;
  fi
  cd ${current_dir}
}


[ -f ~/.fzf.bash ] && source ~/.fzf.bash

LOCAL=$BASE/../cfg-local/bashrc-local
[ -f "$LOCAL" ] && source "$LOCAL"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" 
