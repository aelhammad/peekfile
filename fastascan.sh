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
    fasta_files=$(find . -type f -name "*.fasta" -or -name "*.fa")

    if [[ -z $fasta_files ]]; then
        echo "There are not any FASTA files."
    else

	fasta_num=$(echo $fasta_files | wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find . -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | awk -F '>' '{print $2}'| sort | uniq | wc -l | awk '{$1=$1};1')

        echo "\n* Number of FASTA files: $fasta_num\n"
        echo "* Number of unique headers: $uniq_headers\n"
    fi
else
    fasta_files=$(find "$1" -type f -name "*.fasta" -or -name "*.fa")

    if [[ -z $fasta_files ]]; then
        echo "There are not any FASTA files in $1."
    else
	fasta_num=$(echo $fasta_files| wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find $1 -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | awk -F '>' '{print $2}'| sort | uniq | wc -l | awk '{$1=$1};1')
        echo "\n* Number of FASTA files in $1: $fasta_num\n"
        echo "* Number of unique headers: $uniq_headers\n"
    fi
fi

if [[ -n $fasta_files ]]; then

    	echo "$fasta_files" | while read -r file; do
        if [[ -h "$file" ]]; then
            symlink= "Yes"
        else
            symlink="No"
        fi
	
	sequence_num=$(grep ">" $file | wc -l | awk '{$1=$1};1')
	total_seqlen=$(cat $file | sed -E '/^>/!s/[^A-Za-z]//g' | grep -v '>'| tr -d "\n" | wc -c | awk '{$1=$1};1' )
	
	
	file_tester=$(cat $file | head | sed -E '/^>/!s/[^A-Za-z]//g' | grep -v '>'| tr -d "\n")
	nucleotide_tester=$(echo $file_tester | egrep -i '^[ATCGN]+$')
	
	if [[ $file_tester == $nucleotide_tester ]];then 
		content="Nucleotide based"
	else 
		content="Aminoacid based"
	fi

	aes1=">-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<"
	echo $aes1
	echo $file "-> Is a symlink:" $symlink " | Number of sequences:" $sequence_num "| total sequence length: " $total_seqlen "| file content is" $content 
    	echo $aes1
	aes2="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	line_number=$(cat $file | wc -l)
	
	if [[ -n $2 && $2 -gt 0 ]]; then
		echo $aes2	
    		if [[ $line_number -le $((2 * $2)) ]]; then
        		cat $file
    		else
        		head -n $2 $file
        		echo "..."
        		tail -n $2 $file
    		fi
		echo $aes2
	fi
	

	done
fi
