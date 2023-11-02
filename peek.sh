#!/bin/zsh
#!/bin/zsh

# Check if the second argument (number of lines) is provided
if [[ -z $2 ]]; then
  lines=3  # Default to 3 lines if not provided
else
  lines=$2
fi

head -n $lines $1
echo "..."
tail -n $lines $1



