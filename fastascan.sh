#!/bin/zsh



# ______   ______     ______     ______   ______     ______     ______     ______     __   __    
#/\  ___\ /\  __ \   /\  ___\   /\__  _\ /\  __ \   /\  ___\   /\  ___\   /\  __ \   /\ "-.\ \   
#\ \  __\ \ \  __ \  \ \___  \  \/_/\ \/ \ \  __ \  \ \___  \  \ \ \____  \ \  __ \  \ \ \-.  \  
# \ \_\    \ \_\ \_\  \/\_____\    \ \_\  \ \_\ \_\  \/\_____\  \ \_____\  \ \_\ \_\  \ \_\\"\_\ 
#  \/_/     \/_/\/_/   \/_____/     \/_/   \/_/\/_/   \/_____/   \/_____/   \/_/\/_/   \/_/ \/_/ 
#                                                                                                


############################################
# This script takes two optional arguments:#
# fastascan -folder -number_of_lines       #
# default number_of_lines -> 0             #
# default folder -> current folder	   #
############################################

# This script reports the following information : 
# Number of .fa & .fasta files 
# How many unique fasta ID's they contain in total
 


if [[ -z $1 ]]; then
    fasta_files=$(find . -type f \( -name "*.fasta" -or -name "*.fa" \))

    if [[ -z $fasta_files ]]; then
        echo "There are not any FASTA files."
    else

	fasta_num=$(echo $fasta_files | wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find . -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | sort | uniq | wc -l |awk '{$1=$1};1')

        echo "\n* Number of FASTA files: $fasta_num\n"
        echo "* Number of unique headers: $uniq_headers\n"
    fi
else
    fasta_files=$(find "$1" -type f \( -name "*.fasta" -or -name "*.fa" \))

    if [[ -z $fasta_files ]]; then
        echo "There are not any FASTA files in $1."
    else
	fasta_num=$(echo $fasta_files| wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find $1 -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | sort | uniq | wc -l |awk '{$1=$1};1')
        echo "\n* Number of FASTA files in $1: $fasta_num\n"
        echo "* Number of unique headers: $uniq_headers\n"
    fi
fi


echo $fasta_files

for file in "$fasta_files"; do
    if [[ -h "$file" ]]; then
        echo "$file is a symbolic link."
    else
        echo "$file is NOT a symbolic link."
    fi
done
