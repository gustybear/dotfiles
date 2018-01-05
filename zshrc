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

# Universal plugins {{{2
# zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh"
zplug "plugins/zsh_reload",   from:oh-my-zsh
zplug "plugins/cp",   from:oh-my-zsh
zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/vi-mode",   from:oh-my-zsh

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3

# OSX specific plugins {{{2
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/osx", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"
zplug "plugins/ssh-agent", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# LINUX specific plugins {{{2
zplug "plugins/ubuntu", from:oh-my-zsh, if:"[[ $OSTYPE == *linux* ]]"

# GIT repos managed by zplug {{{2
zplug "junegunn/fzf", dir:"${HOME}/.fzf", hook-build:"./install --all"
zplug "todotxt/todo.txt-cli", hook-build:"make; make install prefix=${HOME}/.local"
zplug "gustybear/Dropbox-Uploader", hook-build:"chmod +x ./dropbox_uploader.sh", as:command, use:"dropbox_uploader.sh"
if [[ $OSTYPE == *darwin* ]]; then
  zplug "gohugoio/hugo", from:gh-r, as:command, use:"*macOS*64bit*"
fi
if [[ $OSTYPE == *linux* ]]; then
  zplug "gohugoio/hugo", from:gh-r, as:command, use:"*Linux*64bit*gz"
fi

# Theme {{{2
zplug "denysdovhan/spaceship-zsh-theme", use:spaceship.zsh, from:github, as:theme

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

# Plugin Configuratoions {{{1
# HISTORY-SUBSTRING-SEARCH configurations {{{2
# bind UP and DOWN arrow keys
zmodload zsh/terminfo
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

# bind UP and DOWN arrow keys (compatibility fallback
# for Ubuntu 12.04, Fedora 21, and MacOSX 10.9 users)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# bind P and N for EMACS mode
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

# TODO.TXT configurations {{{2
TODO=$(command -v todo.sh)
alias tls="$TODO ls"
alias ta="$TODO a"
alias trm="$TODO rm"
alias tdo="$TODO do"
alias tpri="$TODO pri"

# FZF configurations {{{2
# ---------
if [[ ! "$PATH" == *${HOME}/.fzf/bin* ]]; then
  export PATH="$PATH:${HOME}/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "${HOME}/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "${HOME}/.fzf/shell/key-bindings.zsh"

# fh - repeat history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# CTRL-R script to insert the selected command from history into the command line/region
__fzf_history ()
{
  __ehc $(history | fzf --tac --tiebreak=index | perl -ne 'm/^\s*([0-9]+)/ and print "!$1"')
}

__ehc()
{
  if
    [[ -n $1 ]]
  then
    bind '"\er": redraw-current-line'
    bind '"\e^": magic-space'
    READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
    READLINE_POINT=$(( READLINE_POINT + ${#1} ))
  else
    bind '"\er":'
    bind '"\e^":'
  fi
}

# SSH-AGENT (osx) configurations {{{2
if [[ $OSTYPE == *darwin* ]]; then
  zstyle :omz:plugins:ssh-agent agent-forwarding on
  zstyle :omz:plugins:ssh-agent identities id_rsa amazon_aws_2017_03_31.pem
fi

# Theme configurations {{{2
SPACESHIP_PROMPT_ORDER=(
time     #
vi_mode  # these sections will be
user     # before prompt char
host     #
char
dir
git
node
ruby
xcode
swift
golang
docker
venv
pyenv
)

# USER
SPACESHIP_USER_PREFIX="" # remove `with` before username
SPACESHIP_USER_SUFFIX="" # remove space before host

# HOST
# Result will look like this:
#   username@:(hostname)
SPACESHIP_HOST_PREFIX="@:("
SPACESHIP_HOST_SUFFIX=") "

# DIR
SPACESHIP_DIR_PREFIX='' # disable directory prefix, cause it's not the first section
SPACESHIP_DIR_TRUNC='1' # show only last directory

# GIT
# Disable git symbol
SPACESHIP_GIT_SYMBOL="" # disable git prefix
SPACESHIP_GIT_BRANCH_PREFIX="" # disable branch prefix too
# Wrap git in `git:(...)`
SPACESHIP_GIT_PREFIX='git:('
SPACESHIP_GIT_SUFFIX=") "
SPACESHIP_GIT_BRANCH_SUFFIX="" # remove space after branch name
# Unwrap git status from `[...]`
SPACESHIP_GIT_STATUS_PREFIX=""
SPACESHIP_GIT_STATUS_SUFFIX=""

# NODE
SPACESHIP_NODE_PREFIX="node:("
SPACESHIP_NODE_SUFFIX=") "
SPACESHIP_NODE_SYMBOL=""

# RUBY
SPACESHIP_RUBY_PREFIX="ruby:("
SPACESHIP_RUBY_SUFFIX=") "
SPACESHIP_RUBY_SYMBOL=""

# XCODE
SPACESHIP_XCODE_PREFIX="xcode:("
SPACESHIP_XCODE_SUFFIX=") "
SPACESHIP_XCODE_SYMBOL=""

# SWIFT
SPACESHIP_SWIFT_PREFIX="swift:("
SPACESHIP_SWIFT_SUFFIX=") "
SPACESHIP_SWIFT_SYMBOL=""

# GOLANG
SPACESHIP_GOLANG_PREFIX="go:("
SPACESHIP_GOLANG_SUFFIX=") "
SPACESHIP_GOLANG_SYMBOL=""

# DOCKER
SPACESHIP_DOCKER_PREFIX="docker:("
SPACESHIP_DOCKER_SUFFIX=") "
SPACESHIP_DOCKER_SYMBOL=""

# VENV
SPACESHIP_VENV_PREFIX="venv:("
SPACESHIP_VENV_SUFFIX=") "

# PYENV
SPACESHIP_PYENV_PREFIX="python:("
SPACESHIP_PYENV_SUFFIX=") "
SPACESHIP_PYENV_SYMBOL=""

# Disable <<< normal mode indicator (from vi-mode in oh-my-zsh)
export RPS1="%{$reset_color%}"

# Additional Configurations {{{1
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

# Iterm shell integration (osx) {{{2
if [[ $OSTYPE == *darwin* ]]; then
  test -e "${HOME}/.iterm2_shell_integration.zsh" \
    && source "${HOME}/.iterm2_shell_integration.zsh"
fi

# Aliases {{{1
# Universal aliases {{{2
# VIM
export EDITOR=vim
VIM=$(command -v vim)
alias v=$VIM

# Pin to the tail of long commands for an audible alert after long processes
## curl http://downloads.com/hugefile.zip; lmk
alias lmk="say 'Process complete.'"

# OSX specific aliases {{{2
if [[ $OSTYPE == *darwin* ]]; then
  # Desktop Programs
  alias photoshop="open -a '/Applications/Adobe Photoshop CS3/Adobe Photoshop.app'"
  alias preview="open -a '$PREVIEW'"
  alias xcode="open -a '/Applications/XCode.app'"
  alias safari="open -a safari"
  alias firefox="open -a firefox"
  alias f='open -a Finder '
  alias fh='open -a Finder .'

  # Reset dock
  alias dock_reset='defaults delete com.apple.dock; killall Dock'

  # Reset lanuchpad
  alias launchpad_reset='defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock'

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

# Functions {{{1
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
function grmake
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
function proj_init
{
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
function proj_status
{
  if [ "$DEBUG" = "true" ]; then
    set -x
  fi

  for dir in ${PROJECT_DIRS} ${COURSE_DIRS} ${TEMPLATE_DIR} ${WEBSITES_DIR} ${DOTFILES_DIR};
  do
    (if [ -d "${dir}/.git" ]; then \
      echo "Entering ${dir}."; \
      echo "Checking status... "; \
      cd ${dir} &&  git status; \
      echo; \
    fi);
  done

  if [ "$DEBUG" = "true" ]; then
    set +x
  fi
}

# Pull update from remote {{{3
function proj_pull
{
  if [ "$DEBUG" = "true" ]; then
    set -x
  fi

  for dir in ${PROJECT_DIRS} ${COURSE_DIRS} ${TEMPLATE_DIR} ${WEBSITES_DIR} ${DOTFILES_DIR};
  do
    (if [ -d "${dir}/.git" ]; then \
      echo "Entering ${dir}."; \
      echo "Updating... "; \
      cd ${dir} &&  git pull; \
      echo; \
     fi);
  done

  if [ "$DEBUG" = "true" ]; then
    set +x
  fi
}

# Commit local changes and push to remote {{{3
function proj_update
{
  if [ "$DEBUG" = "true" ]; then
    set -x
  fi

  for dir in ${PROJECT_DIRS} ${COURSE_DIRS} ${TEMPLATE_DIR} ${WEBSITES_DIR} ${DOTFILES_DIR};
  do
    (if [ -d "${dir}/.git" ]; then \
      echo "Entering ${dir}."; \
      cd ${dir}; \
      if ! git diff-index --quiet HEAD --; then \
        echo "Committing ... "; \
        git add -A; \
        LANG=C git -c color.status=false status \
         | sed -n -e '1,/Changes to be committed:/ d' \
           -e '1,1 d' \
           -e '/^Untracked files:/,$ d' \
           -e 's/^\s*//' \
           -e '/./p' \
           > msg.txt; \
        git commit -F msg.txt ; \
        rm -rf msg.txt; \
        git push; \
      fi; \
    fi);
  done

  if [ "$DEBUG" = "true" ]; then
    set +x
  fi
}

# Website management {{{2
# Update website {{{3
function website_update
{
  if [ "$DEBUG" = "true" ]; then
    set -x
  fi

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

  if [ "$DEBUG" = "true" ]; then
    set +x
  fi
}

# Clean homebrew (mac) {{{2
if [[ $OSTYPE == *darwin* ]]; then
  declare -A visited_formulas

  function check_formulas
  {
    for formula in "$@"; do
      if [[ -z `brew uses --installed $formula` ]] && ! (( ${+visited_formulas[$formula]} )) && [[ $formula != "brew-cask" ]]; then
        read "input?$formula is not depended on by other formulas. Remove? [Y/n] "
        visited_formulas[$formula]=1
        if [[ "$input" == "Y" ]]; then
          brew remove $formula
          check_formulas `brew deps --1 --installed $formula`
        fi
      fi
    done
  }

  function brew_autoremove
  {
    echo "Searching for formulas not depended on by other formulas..."
    check_formulas `brew list`
  }
fi

# Copy from remote to local (linux) {{{2
if [[ $OSTYPE == *linux* ]]; then
  function cp_to_download
  {
    if [ "$DEBUG" = "true" ]; then
      scp -vP 2222 $1 yao@127.0.0.1:~/Downloads/
    else
      scp -P 2222 $1 yao@127.0.0.1:~/Downloads/
    fi

  }
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
