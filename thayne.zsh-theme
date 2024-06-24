# inspired by powerlevel10k and pure
setopt prompt_subst
autoload -Uz add-zsh-hook

# Background color
local bg=236
# separator
local sep="%244F╱ "
typeset -i __thayne_time=-1

.prompt_path() {
    # TODO: make this smarter
    echo '%3~'
}

.thayne_p_preexec() {
    print -f "\e]2;%s - %s\a" ${(D)PWD} $2
    __thayne_time=$SECONDS
}

.thayne_p_precmd() {
    local -i duration
    local human
    if (( __thayne_time >= 0 )); then
        (( duration = SECONDS - __thayne_time ))
        __thayne_time=-1
        if (( duration >= 1 )); then
            local hours=$(( duration / (3600 * 24)))
            local hours=$(( duration / 3600 % 24))
            local minutes=$(( duration / 60 % 60))
            local seconds=$(( duration % 60))
            (( days > 0 )) && human+="${days}d "
            (( hours > 0)) && human+="${hours}h "
            (( minutes > 0)) && human+="${minutes}m "
            (( seconds > 0 )) &&  human+="${seconds}s "
        fi
    fi
    typeset -g lastdur=$duration
    if [[ -n $human ]]; then
        typeset -g last_human=$human
        psvar[1]=$human
    else
        psvar[1]=""
    fi
    # just git the branch name, this is much faster than full git status
    # TODO: also determine if dirty
    # use `git diff-index --quiet --ignore-submodules HEAD`
    psvar[2]=$(git rev-parse --abbrev-ref HEAD 2>&-)
    # Update window title
    print -Pn "\e]2;%~\a"
}

add-zsh-hook precmd .thayne_p_precmd
add-zsh-hook preexec .thayne_p_preexec

# make it easier to use newlines
local nl=$'\n'
local statend=$' %${bg}F%k\n%${bg}K'

# jobs foreground = 37
PROMPT="%B%${bg}K%(0?..%196F✘ %?%(1V. ${sep}.${statend}))%(1V. %1v${statend}.)\
%66F %* ${sep}\
%31F \$(.prompt_path)\
%(2V. ${sep}%76F %2v.)\
%(1j. ${sep}%175F %j.)\
 %k%${bg}F
%F{green}%(!.#.)❯%b "

# TODO: implement transient prompt?
