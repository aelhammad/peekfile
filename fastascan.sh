#!/bin/zsh


start_time=$(date +%s)


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

#Just for aesthetics


echo '
________             _____
___  __/_____ _________  /______ ___________________ _______
__  /_ _  __ `/_  ___/  __/  __ `/_  ___/  ___/  __ `/_  __ \
_  __/ / /_/ /_(__  )/ /_ / /_/ /_(__  )/ /__ / /_/ /_  / / /
/_/    \__,_/ /____/ \__/ \__,_/ /____/ \___/ \__,_/ /_/ /_/
'


aes1=">-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------<"
aes2="~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*"
#Add color to our string
yellow='\033[1;33m'
reset='\033[0m'
echo -e "${yellow}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~FILE SUMMARY~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~${reset}"


#To output the results in a more tidy way we will use an intermediate file to append the data.

echo -e  "FILE PATH" '\t' "SYMLINK" '\t' "NUMBER OF SEQUENCES" '\t' "TOTAL SEQUENCE LENGTH" '\t' "FILE CONTENT" > fastascan_intermediate.txt



#We see if the first positional argument is empty or not.
if [[ -z $1 ]]; then
    #To avoid problem with symbolic links it is important to add the -type l option.	
    fasta_files=$(find . \( -type f -o -type l \) -name "*.fasta" -or -name "*.fa")
    
    if [[ -z $fasta_files ]]; then

	#This condition returns a message if there are not any fasta files
        echo "There are not any FASTA files."

    else
	#Here we get all the headers ignoring the origin files using awk to get only the identifieres (a.k.a the first word before a space) 
	#Note that awk '{$1=$1};1' is just used to remove spaces before the number obtained with wc -l, for formatting reasons.
	fasta_num=$(echo $fasta_files | wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find . -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | awk -F '>' '{print $2}'| sort | uniq | wc -l | awk '{$1=$1};1')

        echo "\n* NUMBER OF FASTA FILES: $fasta_num\n"
        echo "* NUMBER OF UNIQUE HEADERS: $uniq_headers\n"
    fi
else
	
    #If the user does not provide any directory we will search inside the current one.
    fasta_files=$(find $1 \( -type f -o -type l \) -name "*.fasta" -or -name "*.fa")

    if [[ -z $fasta_files ]]; then
        echo "There are not any FASTA files in $1."
    else
	fasta_num=$(echo $fasta_files| wc -l | awk '{$1=$1};1')
        uniq_headers=$(grep '>' $(find $1 -type f -name "*.fasta" -or -name "*.fa") | awk -F' ' '/>/{print $1}' | awk -F '>' '{print $2}'| sort | uniq | wc -l | awk '{$1=$1};1')
        echo "\n* NUMBER OF FASTA FILES IN $1: $fasta_num\n"
        echo "* NUMBER OF UNIQUE HEADERS: $uniq_headers\n"
    fi
fi




#Sees if fasta_files variable is not empty
	if [[ -n $fasta_files ]]; then
	



	#Testing if it is a symlink
    	echo $fasta_files | while read -r file; do
	
        if [[ -h $file ]]; then

    		symlink="Yes"
        else
            	symlink="No"
        fi
	
	#Here we count the number of sequences, and total sequence lenght. It's important to keep in mind not counting newline characters for the total sequence_lenght
	
	sequence_num=$(grep ">" $file | wc -l | awk '{$1=$1};1')
	total_seqlen=$(cat $file | sed -E '/^>/!s/[^A-Za-z]//g' | grep -v '>'| tr -d "\n" | wc -c | awk '{$1=$1};1' )
	
	#Here we use two string variables that are the file and the file without characters that are ATCGN, N sometimes appears in some nucleotide sequences as unknown nucleotdie. I tried to just get the first 10 lines of each file (head) for the sake of efficency, however the difference is not that big and comparing the whole file we will be sure 100% about the content. 
	#Here a regular experssion is used with egrep.
	
	file_tester=$(cat $file | sed -E '/^>/!s/[^A-Za-z]//g' | grep -v '>'| tr -d "\n")
	nucleotide_tester=$(echo $file_tester | egrep -i '^[ATCGNU]+$')
	
	if [[ -n $file_tester ]];then
		if [[ $file_tester == $nucleotide_tester ]];then 
			content="Nucleotide based"
		else 
			content="Aminoacid based"
		fi
	else 
		content="Empty"
	fi

	line_number=$(cat $file | wc -l)
	
	#Here we print the lines from each file depending on the N($2) value provided
	if [[ -n $2 && $2 -gt 0 ]]; then
		
		echo -e $aes2 '\n' $aes1 '\n' $file '\t' "Symlink:" $symlink '\t' "Sequence number:" $sequence_num '\t' "Total sequence length:" $total_seqlen '\t' "File content:" $content '\n' >> fastascan_intermediate.txt
		
		if [[ $line_number -le $((2 * $2)) ]]; then

        		cat $file >> fastascan_intermediate.txt
    		else
        		head -n $2 $file >> fastascan_intermediate.txt
        		echo "..." >> fastascan_intermediate.txt
        		tail -n $2 $file >> fastascan_intermediate.txt

    		fi
	else 
		echo -e $file '\t' $symlink '\t' $sequence_num '\t' $total_seqlen '\t' $content  >> fastascan_intermediate.txt

	fi
	

	done
	
	#This new command is only to print the output in a more legible way, it creates a table from the input data and sets '\t' as delimiter for this table.
	column -t -s $'\t' fastascan_intermediate.txt
	

	#Also we could cat the file directly to avoid using new commands:
	#cat fastascan_intermediate.txt

	#Remove the intermediate file.
	rm fastascan_intermediate.txt

fi 



