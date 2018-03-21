#!/usr/bin/env bash
# vars
colors="/usr/scripts/colors.sh"
refresh=".2"
padding="   "
height="30"
font="-*-cure-*"
ifont="-*-siji-*"
battery="BAT0"


# colors
source "$colors"


# functions
desktop() {
	current="$(xdotool "get_desktop")"
	
	case "$current" in
		"0")
			desktop="un"
			;;
		"1")
			desktop="deux"
			;;
		"2")
			desktop="trois"
			;;
		"3")
			desktop="quatre"
			;;
		"4")
			desktop="cinq"
			;;
		*)
			desktop="???"
			;;
	esac
	
	printf "$desktop"
}

mpd() {
	current="$(mpc "current")"
	
	printf "$current"
}

spotify() {
	current="$(sps "current")"
	pid="$(pidof "spotify")"
	
	if [ "$pid" ] ; then
		printf "$padding$current$padding"
	else
		:
	fi
}

window() {
	current="$(xdotool "getwindowfocus" "getwindowname")"
	
	if [ "$current" == "Openbox" ] ; then
		:
	else
		printf "$current"
	fi
}

weather() {
	cat "/tmp/weather"
}

battery() {
	id="BAT0"
	percent="$(cat "/sys/class/power_supply/"$id"/capacity")"
	power="$(cat "/sys/class/power_supply/"$id"/status")"
	
	echo "$percent%%"
}

clock() {
	clock="$(date "+%a %R")"
	printf "$clock"
}


# loops
dloop() {
	while :; do
		echo "%{l}\
		$a1$af2%{A3:sps 'play' &:}$padding$(desktop)$padding%{A}$txt$bg\
		$a3$(spotify)$bg\
		$a2$padding$(window)$padding$bg\
		%{r}\
		$a2%{A:notify-send 'updating the weather' && weather &:}$padding$(weather)$padding%{A}$bg\
		$a2%{A:calendar &:}$padding$(clock)$padding%{A}$bg"
		sleep "$refresh"
	done |\

	lemonbar \
		-f "$font" \
		-f "$ifont" \
		-g "x"$height"" \
	| bash
}

lloop() {
	while :; do
		echo "%{l}\
		$a1$af2%{A3:sps 'play' &:}$padding$(desktop)$padding%{A}$txt$bg\
		$a3$(spotify)$bg\
		$a2$padding$(window)$padding$bg\
		%{r}\
		$a2%{A:batstat &:}$padding $(battery)$padding%{A}$bg\
		$a2%{A:calendar &:}$padding $(clock)$padding%{A}$bg"
		sleep "$refresh"
	done |\

	lemonbar \
		-f "$font" \
		-f "$ifont" \
		-g "x"$height"" \
	| bash
}


# exec
if [ -f "/sys/class/power_supply/"$battery"/status" ] ; then
	lloop
else
	dloop
fi