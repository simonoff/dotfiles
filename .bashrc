########################################################################
# Evil bash settings file for Ciaran McCreesh <ciaranm at gentoo.org>
#
# Not many comments here, you'll have to guess how it works. Note that
# I use the same .bashrc on Linux, IRIX and Slowaris, so there's some
# strange uname stuff in there.
#
# Most recent update: Sat Aug 20 20:29:08 2011
#
# Get the latest version from:
#     http://dev.gentoo.org/~ciaranm/configs/bashrc
#
########################################################################

export UNAME_S=$(uname -s 2>&1 || echo "Linux" )
if [ "${TERM}" == "rxvt-unicode" ] ; then
	export TERMTYPE="256"
elif [ "${TERM}" != "dumb" ] ; then
	export TERMTYPE="16"
else
	export TERMTYPE=""
fi

select_by_term() {
	if [ "${TERMTYPE}" == "256" ] ; then
		echo -n "$1"
	elif [ "${TERMTYPE}" == "16" ] ; then
		echo -n "$2"
	else
		echo -n "$3"
	fi
}

if [ -n "${PATH/*$HOME\/bin:*}" ] ; then
	export PATH="$HOME/bin:$PATH"
fi

if [ -n "${PATH/*\/usr\/local\/bin:*}" ] ; then
	export PATH="/usr/local/bin:$PATH"
fi

if [ -f /usr/bin/less ] ; then
	export PAGER=less
	alias page=$PAGER
	export LESS="--ignore-case --long-prompt"
fi

alias ls="ls --color"
alias ll="ls --color -l -h"
alias la="ls -a --color"
alias pd="pushd"
alias pp="popd"

# More standard stuff
case $TERM in
	xterm*|rxvt*|Eterm|eterm)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@$HOSTNAME:${PWD/$HOME/~}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033_${USER}@$HOSTNAME:${PWD/$HOME/~}\033\\"'
		;;
esac

# Bash completion
[ -f /etc/profile.d/bash-completion ] && \
	source /etc/profile.d/bash-completion

# Set up host-specific things
hostcolour() {
	case ${1:-`hostname`} in
		gentoo) # teal
			echo $(select_by_term '\033[38;5;22m' '\033[0;36m' '' )
			;;
		devel) # magenta
			echo $(select_by_term '\033[38;5;54m' '\033[01;35m' '' )
			;;
		router) # green
			echo $(select_by_term '\033[38;5;20m' '\033[01;32m' '' )
			;;

		*) # orange
			echo $(select_by_term '\033[38;5;68m' '\033[01;31m' '' )
			;;
	esac
}

ps1_return_colour() {
	if [ "$1" == "0" ] ; then
		echo -e $(select_by_term '\033[0;0m\033[38;5;78m' '\033[0;37m' '' )
	else
		echo -e $(select_by_term '\033[0;0m\033[38;5;64m' '\033[01;31m' '' )
	fi
	return $1
}

PS1H="\[$(hostcolour)\]${HOSTNAME}"
PS1U=$(select_by_term '\[\033[38;5;78m\]\u' '\[\033[0;39m\]\u' '\u' )
PS1D=$(select_by_term '\[\033[38;5;38m\]\W' '\[\033[01;34m\]\W' '\W' )
PS1R=$(select_by_term "\\[\\033[00;39m\\]\$?" "\\[\\033[00;39m\\]\$?" "\$?" )
export PS1E=$(select_by_term '\[\033[00m\]' '\[\033[00m\]' '' )
export PS1="${PS1U}@${PS1H} ${PS1D} ${PS1R} ${PS1L}${PS1S}${PS1E}$ "
alias cvu="cvs update"
alias cvc="cvs commit"
alias svu="svn update"
alias svs="svn status"
alias svc="svn commit"
alias ssync="rsync --rsh=ssh"
alias ssyncr="rsync --rsh=ssh --recursive --verbose --progress"
alias grab="sudo chown ${USER} --recursive"
alias hmakej="hilite make -j"
alias clean="rm *~"

# toys
makepasswords() {
	# suggest a bunch of possible passwords. not suitable for really early perl
	# versions that don't do auto srand() things.
	perl <<EOPERL
		my @a = ("a".."z","A".."Z","0".."9",(split //, q{#@,.<>$%&()*^}));
		for (1..10) {
			print join "", map { \$a[rand @a] } (1..rand(3)+7);
			print qq{\n}
		}
EOPERL
}

# vim: set noet ts=4 tw=80 :
