#!/bin/zsh

if [[ -z $2 ]]; then
  lines=3 
else
  lines=$2
fi



total_lines=$(wc -l $1)

if [[ $total_lines == $((2 * lines)) ]]; then
  cat "$1"
else
  echo "Warning"
  head -n $lines "$1"
  echo "..."
  tail -n $lines "$1"
fi

