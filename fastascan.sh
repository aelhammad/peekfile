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
 

if [[ -z $1 ]];then
	 
	fasta_num=$(find . -type f -name "*.fasta" -or -name "*.fa" | wc -l | awk '{$1=$1};1')
	echo "There are $fasta_num fasta files in $PWD"
	
else
	fasta_num=$(find $1 -type f -name "*.fasta" -or -name "*.fa" | wc -l | awk '{$1=$1};1')
        echo "There are $fasta_num fasta files in $1"
fi







