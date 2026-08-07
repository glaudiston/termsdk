#!/usr/bin/env bash
# ANSI escape codes to control the terminal behavior

TERM_CSI_PREFIX="\e[" # Control Sequence Indroducer
TERM_PRIVATE="?" # private because it was vendor specific, but it is widely adopted.
TERM_PARAM_ON=h
TERM_PARAM_OFF=l

# Clear
TERM_PARAM_TO_BOTTOM=0
TERM_PARAM_TO_TOP=1
TERM_PARAM_ALL=2
TERM_CMD_CLEAR=J
TERM_ERASE_LINE=K
TERM_CLEAR=${TERM_CSI_PREFIX}${TERM_PARAM_ALL}${TERM_CMD_CLEAR}

# Display control
TERM_ALT_BUFFER="1049";
TERM_ALT_BUFFER_ON=$(printf "${TERM_CSI_PREFIX}${TERM_PRIVATE}${TERM_ALT_BUFFER}${TERM_PARAM_ON}");
TERM_ALT_BUFFER_OFF=$(printf "${TERM_CSI_PREFIX}${TERM_PRIVATE}${TERM_ALT_BUFFER}${TERM_PARAM_OFF}");

# Line Wrapping control
TERM_PARAM_LINE_WRAP="7"
TERM_LINE_WRAP_ON="${TERM_CSI_PREFIX}${TERM_PRIVATE}${TERM_PARAM_LINE_WRAP}${TERM_PARAM_ON}"
TERM_LINE_WRAP_OFF="${TERM_CSI_PREFIX}${TERM_PRIVATE}${TERM_PARAM_LINE_WRAP}${TERM_PARAM_OFF}"

# Cursor Movements/Position
TERM_CURSOR="25"
TERM_CURSOR_ON=$(printf "${TERM_CSI_PREFIX}${TERM_PRIVATE}${TERM_CURSOR}${TERM_PARAM_ON}")
TERM_CURSOR_OFF=$(printf "${TERM_CSI_PREFIX}${TERM_PRIVATE}${TERM_CURSOR}${TERM_PARAM_OFF}")
TERM_CURSOR_REQUEST_POSITION="${TERM_CSI_PREFIX}6n"
term_cursor_pos(){
	local old_stty=$(stty -g)
	stty -echo -icanon
	printf "${TERM_CURSOR_REQUEST_POSITION}"
	read -r resp
	stty "$old_stty"
	local clean_pos="${resp#*[}"
	clean_pos="${clean_pos%R*}"
	echo $clean_pos
}

TERM_MOVE_UP=A
TERM_MOVE_DOWN=B
TERM_MOVE_RIGHT=C
TERM_MOVE_LEFT=D
TERM_MOVE_FORWARD=f
TERM_MOVE_BACKWARDS=r
TERM_CURSOR_POSITION=H
TERM_CURSOR_SAVE="${TERM_CSI_PREFIX}s"
TERM_CURSOR_RESTOR="${TERM_CSI_PREFIX}u"
TERM_MOVE_HOME="${TERM_CSI_PREFIX}${TERM_CURSOR_POSITION}"
term_move(){
(
	flock -x 200 # mutex_lock
	local direction=$1;
	local steps=${2:-1}
	case ${direction,,} in
		up)
			printf "${TERM_CSI_PREFIX}${steps}${TERM_MOVE_UP}"
			;;
		down)
			printf "${TERM_CSI_PREFIX}${steps}${TERM_MOVE_DOWN}"
			;;
		left)
			printf "${TERM_CSI_PREFIX}${steps}${TERM_MOVE_LEFT}"
			;;
		right)
			printf "${TERM_CSI_PREFIX}${steps}${TERM_MOVE_RIGHT}"
			;;
		*)
			local row=$1
			local col=$2
			echo -ne "${TERM_CSI_PREFIX}${col};${row}${TERM_CURSOR_POSITION}"
			;;
	esac
	flock -u 200 # mutex_unlock
) 200>/dev/shm/term_$PPID.lock
}

# Scrolling and framing
TERM_SCROLL_UP=S
TERM_SCROLL_DOWN=P
term_set_scroll(){
	local margin_top=$1
	local margin_bottom=$2
	printf "${TERM_CSI_PREFIX}${margin_top};${margin_bottom}r"
}
term_reset_scroll(){
	printf "${TERM_CSI_PREFIX}r"
}

# Colors & Styling: SGR - Select Graphic Rendition
TERM_GRAPHIC=m
TERM_PARAM_SGR_RESET=0 # NC no color
TERM_PARAM_STYLE_BOLD=1
TERM_PARAM_STYLE_DIM=2
TERM_PARAM_STYLE_ITALIC=3
TERM_PARAM_STYLE_UNDERLINE=4
TERM_PARAM_STYLE_BLINK=5
TERM_PARAM_STYLE_INVERT=7
TERM_PARAM_STYLE_STRIKETHROUGH=9
#**Example: Bold, Italic, Underlined Red text**
#"\e[1;3;4;31m This is fancy text \e[0m"
TERM_COLOR_RESET="${TERM_CSI_PREFIX}${TERM_PARAM_SGR_RESET}${TERM_GRAPHIC}"
TERM_STYLE_BOLD="${TERM_CSI_PREFIX}${TERM_PARAM_STYLE_BOLD}${TERM_GRAPHIC}"
TERM_STYLE_DIM="${TERM_CSI_PREFIX}${TERM_PARAM_STYLE_DIM}${TERM_GRAPHIC}"
TERM_STYLE_ITALIC="${TERM_CSI_PREFIX}${TERM_PARAM_STYLE_ITALIC}${TERM_GRAPHIC}"
TERM_STYLE_UNDERLINE="${TERM_CSI_PREFIX}${TERM_PARAM_STYLE_UNDERLINE}${TERM_GRAPHIC}"
TERM_STYLE_BLINK="${TERM_CSI_PREFIX}${TERM_PARAM_STYLE_BLINK}${TERM_GRAPHIC}"
TERM_STYLE_INVERT="${TERM_CSI_PREFIX}${TERM_PARAM_STYLE_INVERT}${TERM_GRAPHIC}"
TERM_PARAM_COLOR_FOREGROUND_STANDARD=30
TERM_PARAM_COLOR_BACKGROUND_STANDARD=40
TERM_PARAM_COLOR_FOREGROUND_BRIGHT=90
TERM_PARAM_COLOR_BACKGROUND_BRIGHT=100
TERM_PARAM_COLOR_BLACK=0
TERM_PARAM_COLOR_RED=1
TERM_PARAM_COLOR_GREEN=2
TERM_PARAM_COLOR_YELLOW=3
TERM_PARAM_COLOR_BLUE=4
TERM_PARAM_COLOR_MAGENTA=5
TERM_PARAM_COLOR_CYAN=6
TERM_PARAM_COLOR_WHITE=7
declare -A TERM_COLORS=(
	[black]="0"
	[red]="1"
	[green]="2"
	[yellow]="3"
	[blue]="4"
	[magenta]="5"
	[cyan]="6"
	[white]="7"
	[8bit]="8"
	[rgb]="8"
)
term_color(){
	local color=${1,,}
	color=${color:=white}
	color_value=${TERM_COLORS[${color}]}
	local target=${2:-}
	target=${target:=foreground}
	local target_value=0
	[ "${target,,}" == background ] && target_value=10
	local extended_mode=$(( 38 + target_value ))
	if [ $color == 8bit ]; then
		local mode_8bit=5;
		local index=$3
		printf "${TERM_CSI_PREFIX}${extended_mode};${mode_8bit};${index}${TERM_GRAPHIC}"
		return
	fi;
	if [ $color == rgb ]; then
		local mode_24bit=2;
		local r=${3:-}
		local g=${4:-}
		local b=${5:-}
		printf "${TERM_CSI_PREFIX}${extended_mode};${mode_24bit};${r:=0};${g:=0};${b:=0}${TERM_GRAPHIC}"
		return
	fi
	# basic 16 colors (4-bits)
	local power=${3:-}
	power=${power:=standard}
	local power_value=30
	[ "${power,,}" == bright ] && power_value=90
	local color_value=$(( color_value + power_value + target_value ))
	printf "${TERM_CSI_PREFIX}${color_value}${TERM_GRAPHIC}"
}
TERM_COLOR_BLACK="$(term_color black)"
TERM_COLOR_RED="$(term_color red)"
TERM_COLOR_GREEN="$(term_color green)"
TERM_COLOR_YELLOW="$(term_color yellow)"
TERM_COLOR_BLUE="$(term_color blue)"
TERM_COLOR_MAGENTA="$(term_color magenta)"
TERM_COLOR_CYAN="$(term_color cyan)"
TERM_COLOR_WHITE="$(term_color white)"
TERM_PARAM_COLOR_8BIT=38
term_color_print_8bit_pallete(){
	for i in {0..255}; do
		printf "\e[38;5;${i}m%3d " $i
		if (( ($i + 1) % 16 == 0 )); then printf "\n"; fi
	done
	printf "\e[0m\n"
}

# OSC Operating System Commands
term_title(){
	printf "${TERM_CSI_PREFIX}0;$@\a"
}

