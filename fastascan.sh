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
# default folder -> current directory	   #
############################################

#Please provide an existing directory in the first argument.
#Please provide a positive integer for the second argument. 

# This script reports the following information : 
# Number of .fa & .fasta files 
# How many unique fasta ID's they contain in total
# It also provides a header with useful information & prints file content depending on the number of lines provided.



#We see if the first positional argument is empty or not.

if [[ -z $1 ]]; then
    fasta_files=$(find . -type f -name "*.fasta" -or -name "*.fa")

    if [[ -z $fasta_files ]]; then

	#This condition returns a message if there are not any fasta files
        echo "There are not any FASTA files."

    else
	#Here we get all the headers ignoring the origin files using awk to get only the identifieres (a.k.a the first word before a space) 
	#Note that awk '{$1=$1};1' is just used to remove spaces before the number obtained with wc -l, for formatting reasons.
	fasta_num=$(echo $fasta_files | wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find . -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | awk -F '>' '{print $2}'| sort | uniq | wc -l | awk '{$1=$1};1')

        echo "\n* Number of FASTA files: $fasta_num\n"
        echo "* Number of unique headers: $uniq_headers\n"
    fi
else
	
    #If the user does not provide any directory we will search inside the current one.
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


#Sees if fasta_files variable is not empty
if [[ -n $fasta_files ]]; then
	
	#Testing if it is a symlink
    	echo "$fasta_files" | while read -r file; do
        if [[ -h "$file" ]]; then
    	symlink="Yes"
        else
            symlink="No"
        fi
	
	#Here we count the number of sequence, and total sequence lenght. It's important to keep in mind not counting newline characters for the total sequence_lenght
	sequence_num=$(grep ">" $file | wc -l | awk '{$1=$1};1')
	total_seqlen=$(cat $file | sed -E '/^>/!s/[^A-Za-z]//g' | grep -v '>'| tr -d "\n" | wc -c | awk '{$1=$1};1' )
	
	#Here we use two string variables that are the file and the file without characters that are ATCGN, N sometimes appears in some nucleotide sequences as unknown nucleotdie. We just get the first 10 lines of each file (head) for the sake of efficency, to avoid the script being too slow when comparing huge fasta files.
	file_tester=$(cat $file | head | sed -E '/^>/!s/[^A-Za-z]//g' | grep -v '>'| tr -d "\n")
	nucleotide_tester=$(echo $file_tester | egrep -i '^[ATCGN]+$')
	
	if [[ $file_tester == $nucleotide_tester ]];then 
		content="Nucleotide based"
	else 
		content="Aminoacid based"
	fi

	#Just for aesthetics
	aes1=">-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<"
	echo $aes1
	echo $file "-> Is a symlink:" $symlink " | Number of sequences:" $sequence_num "| total sequence length: " $total_seqlen "| file content is" $content 
    	echo $aes1
	aes2="+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	line_number=$(cat $file | wc -l)
	

	#Here we print the lines from each file depending on the N($2) value provided
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
