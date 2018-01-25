# Variables and Paths {{{1
# ZSH {{{2
export ZSH_CUSTOM=${HOME}/.config/zsh/custom
export ZPLUG_HOME=${HOME}/.zplug

# Python {{{2
[[ ":$PATH:" != *":$HOME/Applications/miniconda/bin:"* ]] && export PATH=$HOME/Applications/miniconda/bin:$PATH

# Local bin {{{2
[[ ":$PATH:" != *":$HOME/.local/bin:"* ]] && export PATH=$HOME/.local/bin:$PATH

# Plugins {{{1
# Setup zplug {{{2
if [[ ! -d ${ZPLUG_HOME} ]]; then
  git clone https://github.com/gustybear/zplug ${ZPLUG_HOME}
  source ${ZPLUG_HOME}/init.zsh && zplug update --self
fi
source ${ZPLUG_HOME}/init.zsh

# Global {{{2
# zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh"
zplug "plugins/ssh-agent", from:oh-my-zsh
zplug "zsh-users/zsh-syntax-highlighting", defer:1

zplug "junegunn/fzf", dir:"${HOME}/.fzf", hook-build:"./install --all"
zplug "junegunn/8b572b8d4b5eddd8b85e5f4d40f17236", from:gist
zplug "todotxt/todo.txt-cli", hook-build:"make; make install prefix=${HOME}/.local"
zplug "andreafabrizi/Dropbox-Uploader", as:command, use:"dropbox_uploader.sh"
# OSX {{{2
if [[ $OSTYPE == *darwin* ]]; then
  zplug "plugins/osx", from:oh-my-zsh
  zplug "gohugoio/hugo", from:gh-r, as:command, use:"*macOS*64bit*"
fi
# LINUX {{{2
if [[ $OSTYPE == *linux* ]]; then
  zplug "plugins/ubuntu", from:oh-my-zsh
  zplug "gohugoio/hugo", from:gh-r, as:command, use:"*Linux*64bit*gz"
fi

# Initialize zplug {{{2
if ! zplug check --verbose; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  else
    echo
  fi
fi

zplug load

# Configuratoions {{{1
# Prompt
PS1=' → '
# SSH-AGENT {{{2
zstyle :omz:plugins:ssh-agent agent-forwarding on

# FZF configurations {{{2
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Use ~~ as the trigger sequence instead of the default **
# export FZF_COMPLETION_TRIGGER='~~'

# Use fd (https://github.com/sharkdp/fd) instead of the default find
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# Options to fzf command
# export FZF_COMPLETION_OPTS=''

# Completion
# command for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --follow --exclude ".git" . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d --hidden --follow --exclude ".git" . "$1"
}

# CTRL-T: paste the selected files and directories onto the command line
# Preview the content of the file under the cursor using highlight
# Automatically selects the item if there's only one
# Automatically exits when the list is empty
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview '(highlight -O ansi -l {} 2> /dev/null || cat {} || tree -C {}) 2> /dev/null | head -200' --select-1 --exit-0"

# CTRL-R: paste the selected command from history onto the command line
# Full command on preview window
# Sorting and exact matching by defaults
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview' --sort --exact"

# ALT-C: cd into the selected directory
# Uses tree command to show the entries of the directory
# Automatically selects the item if there's only one
# Automatically exits when the list is empty
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200' --select-1 --exit-0"

# CTRL-X CTRL-R: directly executing the command
fzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle     -N     fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

# FZF Git key functions
[ -f ${ZPLUG_REPOS}/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236/functions.sh ] && source ${ZPLUG_REPOS}/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236/functions.sh
[ -f ${ZPLUG_REPOS}/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236/key-binding.zsh ] && source ${ZPLUG_REPOS}/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236/key-binding.zsh

# If within tmux open FZF in seperate window
if [[ -n "$TMUX" ]]; then
  export FZF_TMUX=1
  # Overwrite fzf-down in tmux
  fzf-down() {
  fzf-tmux --height 50% "$@" --border
  }
fi

# Project configurations {{{2
if [[ ! -d ${ZSH_CUSTOM} ]]; then
  mkdir -p ${ZSH_CUSTOM}
else
  find -L ${ZSH_CUSTOM} -type l -exec rm {} \;
fi

for config_file ($ZSH_CUSTOM/*.zsh(N)); do
  source $config_file
done
unset config_file

# Iterm2 (osx) configurations {{{2
if [[ $OSTYPE == *darwin* ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" \
    && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Aliases {{{1
# Global {{{2
# VIM
export EDITOR=vim
VIM=$(command -v vim)
alias v=$VIM

# TODO.TXT
TODO=$(command -v todo.sh)
alias tls="$TODO ls"
alias ta="$TODO a"
alias trm="$TODO rm"
alias tdo="$TODO do"
alias tpri="$TODO pri"

# OSX {{{2
if [[ $OSTYPE == *darwin* ]]; then
  # Desktop Programs
  alias brews='brew list -1'
  alias bubo='brew update && brew outdated'
  alias bubc='brew upgrade && brew cleanup'
  alias bubu='bubo && bubc'
  alias bco=_brew_clean_orphans
  alias photoshop="open -a '/Applications/Adobe Photoshop CC 2018/Adobe Photoshop CC 2018.app'"
  alias acrobat="open -a '/Applications/Adobe Acrobat DC/Adobe Acrobat.app'"
  alias preview="open -a '$PREVIEW'"
  alias xcode="open -a '/Applications/Xcode.app'"
  alias safari="open -a safari"
  alias firefox="open -a firefox"
  alias f='open -a Finder '
  alias fh='open -a Finder .'

  # Clean Trash
  alias dlclean="rmtrash ${HOME}/Downloads/*"
  alias declean="rmtrash ${HOME}/Desktop/*"
  alias trclean='rm -rf ~/.Trash/*'

  # Reset dock
  alias dokreset='defaults delete com.apple.dock; killall Dock'

  # Reset lanuchpad
  alias lapreset='defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock'

  # Get rid of those pesky .DS_Store files recursively
  alias dsclean='find . -type f -name .DS_Store -delete'

  # Track who is listening to your iTunes music
  alias whotunes='lsof -r 2 -n -P -F n -c iTunes -a -i TCP@`hostname`:3689'

  # Flush your dns cache
  alias flush='dscacheutil -flushcache'

  # From http://apple.stackexchange.com/questions/110343/copy-last-command-in-terminal
  alias copyLastCmd='fc -ln -1 | awk '\''{$1=$1}1'\'' ORS='\'''\'' | pbcopy'

  # Use Finder's Quick Look on a file (^C or space to close)
  alias ql='qlmanage -p 2>/dev/null'

  # Mute/Unmute the system volume. Plays nice with all other volume settings.
  alias mute="osascript -e 'set volume output muted true'"
  alias unmute="osascript -e 'set volume output muted false'"
fi

# Linux {{{2
if [[ $OSTYPE == *linux* ]]; then
  alias cpth=_cp_to_host
fi

# Short Cut Functions {{{1
# To debug, run the function with "DEBUG=true function" {{{1
# Navigate git {{{2
# cd to the root directory of the repo {{{3
function grcd
{
  if [ "$DEBUG" = "true" ]; then
    set -x
  fi

  if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
    cd `git rev-parse --show-toplevel`
  else
    echo 'Not in a git repository.'
  fi

  if [ "$DEBUG" = "true" ]; then
    set +x
  fi
}

# Run the makefile at the root of the git repo {{{3
function grmk
{
  if [ "$DEBUG" = "true" ]; then
    set -x
  fi

  if [ -d .git ] || git rev-parse --git-dir > /dev/null 2>&1; then
    make -C `git rev-parse --show-toplevel`
  else
    echo 'Not in a git repository.'
  fi

  if [ "$DEBUG" = "true" ]; then
    set +x
  fi
}

# Project management {{{2
# Variables {{{3
SEARCH_DIR=(${HOME} ${HOME}/Documents) #/Volumes/Elements/Documents
RESEARCH_DIR=($(find ${SEARCH_DIR} -maxdepth 1 -mindepth 1 -type d -name "research" 2>/dev/null))
TEACHING_DIR=($(find ${SEARCH_DIR} -maxdepth 1 -mindepth 1 -type d -name "teaching" 2>/dev/null))
STUDENTS_DIR=($(find ${SEARCH_DIR} -maxdepth 1 -mindepth 1 -type d -name "students" 2>/dev/null))

PROJECT_DIRS=($(find ${RESEARCH_DIR} ${STUDENTS_DIR} -maxdepth 1 -mindepth 1 -type d 2>/dev/null))
COURSE_DIRS=($(find ${TEACHING_DIR} -maxdepth 1 -mindepth 1 -type d 2>/dev/null))
TEMPLATE_DIR=($(find ${SEARCH_DIR} -maxdepth 1 -mindepth 1 -type d -name "_templates" 2>/dev/null))
WEBSITES_DIR=($(find ${SEARCH_DIR} -maxdepth 1 -mindepth 1 -type d -name "__websites" 2>/dev/null))
DOTFILES_DIR=($(find ${SEARCH_DIR} -maxdepth 1 -mindepth 1 -type d -name ".dotfiles" 2>/dev/null))

# Initialize project {{{3
function prit() {
  local answer project_type
  local project_name person_name
  local course_number course_semester course_year
  local dir_name
  local proj_path

  echo -n "Is this a (r)esearch/(a)ward/(t)alk/(c)ourse/(s)tudent/(p)ersonal? "
  old_stty_cfg=$(stty -g)
  stty raw -echo ; answer=$(head -c 1) ; stty $old_stty_cfg

  if echo "$answer" | grep -iq "^r" ;then
    project_type="project"
  elif echo "$answer" | grep -iq "^a" ;then
    project_type="award"
  elif echo "$answer" | grep -iq "^t" ;then
    project_type="talk"
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
    proj_path=$HOME/Documents/teaching/"$dir_name"
    git_branch="course"
  elif [[ "$project_type" == "personal" ]]; then
    proj_path=$HOME/Documents/personal/"$dir_name"
    git_branch="project"
  elif [[ "$project_type" == "student" ]]; then
    proj_path=$HOME/Documents/students/"$dir_name"
    git_branch="project"
  elif [[ ("$project_type" == "project") || ("$project_type" == "award") || ("$project_type" == "talk") ]]; then
    proj_path=$HOME/Documents/research/"$dir_name"
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

# Check project status {{{3
function prst() {
  for dir in ${PROJECT_DIRS} ${COURSE_DIRS} ${TEMPLATE_DIR} ${WEBSITES_DIR} ${DOTFILES_DIR};
  do
    (if [ -d "${dir}/.git" ]; then \
      echo "Entering ${dir}."; \
      echo "Checking status... "; \
      cd ${dir} &&  git status -sb; \
      echo; \
    fi);
  done
}

# Pull update from remote {{{3
function prpl() {
  for dir in ${PROJECT_DIRS} ${COURSE_DIRS} ${TEMPLATE_DIR} ${WEBSITES_DIR} ${DOTFILES_DIR};
  do
    (if [ -d "${dir}/.git" ]; then \
      echo "Entering ${dir}."; \
      echo "Updating... "; \
      cd ${dir} &&  git pull; \
      echo; \
     fi);
  done
}

# Commit local changes and push to remote {{{3
function prup() {
  for dir in ${PROJECT_DIRS} ${COURSE_DIRS} ${TEMPLATE_DIR} ${WEBSITES_DIR} ${DOTFILES_DIR};
  do
    (if [ -d "${dir}/.git" ]; then \
      echo "Entering ${dir}."; \
      cd ${dir}; \
      if ! git diff-index --quiet $(git write-tree) -- || [ -n "$(git status --porcelain)" ]; then \
        echo "Committing ... "; \
        git add -A; \
        LANG=C git -c color.status=false status \
         | sed -n -e '1,/Changes to be committed:/ d' \
           -e '1,1 d' \
           -e '/^Untracked files:/,$ d' \
           -e 's/^\s*//' \
           -e '/./p' \
           > ${dir}/.git/msg.txt; \
        git commit -F ${dir}/.git/msg.txt ; \
        rm -rf ${dir}/.git/msg.txt; \
        git push -v; \
      fi; \
    fi);
  done
}

# Website management {{{2
# Update website {{{3
function wbup() {
  if [ -z "${WEBSITES_DIR}" ]; then
    for dir in ${PROJECT_DIRS} ${COURSE_DIRS};
    do
      (echo "Entering ${dir}."; make -C ${dir} publish_s3)
    done
  else
    for dir in ${WEBSITES_DIR};
    do
      (echo "Entering ${dir}."; make -C ${dir} publish);
    done
  fi
}

# Zotero pdf search {{{2
function fzf-zotero() {
    local DIR open
    declare -A already
    DIR="${HOME}/.cache/pdftotext"
    mkdir -p "${DIR}"
    if [ "$(uname)" = "Darwin" ]; then
        open=open
    else
        open="gio open"
    fi

    {
    ag -g ".pdf$"; # fast, without pdftotext
    ag -g ".pdf$" \
    | while read -r FILE; do
        local EXPIRY HASH CACHE
        HASH=$(md5sum "$FILE" | cut -c 1-32)
        # Remove duplicates (file that has same hash as already seen file)
        [ ${already[$HASH]+abc} ] && continue # see https://stackoverflow.com/a/13221491
        already[$HASH]=$HASH
        EXPIRY=$(( 86400 + $RANDOM * 20 )) # 1 day (86400 seconds) plus some random
        CMD="pdftotext -f 1 -l 1 '$FILE' - 2>/dev/null | tr \"\n\" \"_\" "
        CACHE="$DIR/$HASH"
        test -f "${CACHE}" && [ $(expr $(date +%s) - $(date -r "$CACHE" +%s)) -le $EXPIRY ] || eval "$CMD" > "${CACHE}"
        echo -e "$FILE\t$(cat ${CACHE})"
    done
    } | fzf -e  -d '\t' \
        --preview-window up:75% \
        --preview '
                v=$(echo {q} | tr " " "|");
                echo {1} | grep -E "^|$v" -i --color=always;
                pdftotext -f 1 -l 1 {1} - | grep -E "^|$v" -i --color=always' \
        | awk 'BEGIN {FS="\t"; OFS="\t"}; {print "\""$1"\""}' \
        | xargs $open > /dev/null 2> /dev/null
}

# Tmux {{{2
# Use FZF to switch Tmux sessions{{{3
# bind-key s run "tmux new-window 'bash -ci _fzf_tmux_switch_sessions'"
function fzf-tmux-ssession() {
  local -r fmt='#{session_id}:|#S|(#{session_attached} attached)'
  { tmux display-message -p -F "$fmt" && tmux list-sessions -F "$fmt"; } \
    | awk '!seen[$1]++' \
    | column -t -s'|' \
    | fzf -q '$' --reverse --prompt 'switch session: ' -1 \
    | cut -d':' -f1 \
    | xargs tmux switch-client -t
}

# Use FZF to switch Tmux panes{{{3
# bind-key s run "tmux new-window 'bash -ci _fzf_tmux_switch_panes'"
function fzf-tmux-spanes() {
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
