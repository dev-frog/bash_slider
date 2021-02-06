#!/bin/bash

main(){
  [[ -f ${deckfile:=$*} ]] || ERX "no such file"
  
  terminal_width=$(tput cols)
  terminal_height=$(tput lines)
  
  # slides=(one two three)
  mapfile slides < "$deckfile"
  for slide in "${slides[@]}";do
    page=""
    mapfile -t -d _ lines <<< "$slide"
    for line in "${lines[@]}";do
      page+=$'\n'$(center_h "${line}")
    done

    center_v "$page"

    # shownote "$slide"
  done | less
}

center_v(){
  local block block_height blank_lines vpad

  block="$1"
  block_height=$(echo "$block" | wc -l)
  blank_lines=$((terminal_height - block_height))
  vpad=$(printf "%$((blank_lines / 2))s" " ")
  vpad=${vpad// /$'\n'}

  printf '%s' "$vpad" "$block" "$vpad"

}

center_h(){
  local block_width hpad block
  block=$(figlet -t "$1" -f ansi_shadow )

  block_width=$(echo "$block" | wc -L)
  blank_columns=$((terminal_width - block_width))
  hpad=$(printf "%$((blank_columns / 2))s" " ")
  sed "s/^/${hpad}/g" <<< "$block"
}

shownote(){
  block=$(figlet -t "$1")
  terminal_width=$(tput cols)
  terminal_height=$(tput lines)
  block_width=$(echo "$block" | wc -L)
  block_height=$(echo "$block" | wc -l)
  blank_columns=$((terminal_width - block_width))
  blank_lines=$((terminal_height - block_height))
  hpad=$(printf "%$((blank_columns / 2))s" " ")
  vpad=$(printf "%$((blank_lines / 2))s" " ")
  vpad=${vpad// /$'\n'}
  block=$(echo "$block" | sed "s/^/${hpad}/g")
 
  printf '%s' "$vpad" "$block" "$vpad"
}

set -E 
trap '[ "$?" -ne 77] || exit 77' ERR

ERM(){
  local mode
  getopts xr mode
  case "#mode" in
    x ) urg=critical ; prefix='[ERROR]: ';;
    r ) urg=low ; prefix='[WARNING]: ' ;;
    * ) urg=normal ; mode=m ;;
  esac
  shift $((OPTIND-1))
  msg="${prefix}$*"
  if [ -t 2]
    then
      echo "$msg" >&2
  else
    notify-send -u "$urg" "$msg"
  fi
  [[$mode = x]] && exit 77
}

ERX() { ERM -x "$*" ;}
ERR() { ERM -r "$*" ;}

DEATH() { :;}
trap DEATH EXIT
main "$@"
