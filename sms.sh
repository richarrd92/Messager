#!/bin/bash

# make necessary directory/files
_makeDirectory() {
    # make .messages directory if doesnt exist
    if [ ! -d ".messages" ]; then
        mkdir .messages
    fi
}

# print help guide
_help() {
    echo
    echo "-------------- GUIDE --------------" 
    echo
    echo "Option: "
    echo "1) ./sms.sh help"
    echo "2) ./sms.sh send \"senderNumber\" \"recieverNumber\" \"message\"" 
    echo "3) ./sms.sh remove \"number\""
    echo "4) ./sms.sh search \"recieverNumber\" [--message] [--number]"
    echo

    echo "Note:  Searches _fromNumber by default"
    echo "       Add [--message] to search by message"
    echo

    echo "-----------------------------------" 
    echo
}

# send messages
_sendMessage() {
    # arguments 
    senderNumber=$1
    recieverNumber=$2
    message=$3

    # removes (-) from number
    # makes and appends info to number.txt files
    echo "o;*$message*;@${recieverNumber//-/}" >> ".messages/${senderNumber//-/}.txt"
    echo "i;*$message*;@${senderNumber//-/}" >> ".messages/${recieverNumber//-/}.txt"

    # confirmation output
    echo "Message sent from $senderNumber to $recieverNumber"
}

# remove messages
_removeMessage() {

    # number to be deleted
    number=$1

    # Validates Number entered
    fileName=".messages/${number//-/}.txt"
    if [ -f "$fileName" ]; then

        # Ask for confirmation
        echo -n "Would you like to delete all messages related to $number? (y/n): " 
        read userInput

            # aborts removal action 
            if [[ ! $userInput =~ ^[yY]$ ]]; then
                echo "REMOVE ACTION CANCELLED"
                return
            fi

        # removes file
        rm "$fileName"

    else 
        # wrong number 
        echo "NUMBER DOES NOT EXIST"
        return
    fi
    

    # opens messages directory
    cd .messages
    messageFiles=(*)

    # Loop through .messages directory
    for t in "${messageFiles[@]}"
    do 
        # check if file is not empty 
        if [ -s $t ] 
        then 
            # delete lines that contain the number
            sed -i "/${number//-/}/d" "$t"
        fi
    done

    echo "ALL MESSAGES HAVE BEEN DELETED"
}

# search messages
_searchMessage() {

    # number/word to be searched
    number=$1 
    searchMethod=$2

    # checks for message flag
    if [ "$searchMethod" == "--message" ]
    then

        # CASE 1: SEARCHES BY WORD
        wordFound=false # sets word found to false by default 

            # opens messages directory
            cd .messages
            messageFiles=(*)

            # Loop through .messages directory
            for t in "${messageFiles[@]}"
            do 
                while read line
                do
                    if [[ "$line" =~ $number ]]
                    then 
                        # word was found at least once
                        wordFound=true
                    fi
                done < $t
            done

            # Validates Number/word entered
            if [ $wordFound == true ] # match case found
            then 
                echo "The following results were found for $number:"
                echo
                printf "%-10s\t%-10s\t%s\n" "From" "To" "Message"
                echo "-------------------------------------------"

                # Loop through .messages directory
                for t in "${messageFiles[@]}"
                do 
                    while read line
                    do
                        if [[ "$line" =~ $number ]]
                        then 
                            # Input string
                            input="$line"

                            # Extract the first character using sed and store it in firstChar
                            firstChar=$(echo "$input" | sed -n 's/^\(.\).*/\1/p')

                            # Extract the message and recieverNumber using sed from lines 
                            message=$(echo "$input" | sed -n 's/.*;\*\(.*\)\*;@.*/\1/p')
                            recieverNumber=$(echo "$input" | sed -n 's/.*@//p')
                            senderNumber=$(echo "$t" | sed -n 's/^\([0-9]\+\)\.txt$/\1/p')
                            
                            # match 'o' for “from” phone number.
                            # case 2: destination# != sender# no duplicate messages
                            if [ "$firstChar" == "o" ] && [ ! $recieverNumber == $senderNumber ]
                            then
                                # print formatted output
                                printf "%-10s\t%-10s\t%-10s\n" "$senderNumber" "$recieverNumber" "$message"
                            fi
                        fi
                    done < $t
                done

            else
                # no match found
                echo "No results found for $number"
                return
            fi

    else
        # CASE 2: SEARCHES BY NUMBER

            # Validates Number entered
            fileName=".messages/${number//-/}.txt"
            if [ -f "$fileName" ]; then

                echo "The following results were found for $number:"
                echo
                printf "%-10s\t%-10s\t%s\n" "From" "To" "Message"
                echo "-------------------------------------------"

                # Matches messages that corresponds relate number
                cd .messages
                messageFiles=(*)

                # Loop through .messages directory
                for t in "${messageFiles[@]}"
                do 
                    # iterate through each number's txt files
                    while read line
                    do
                        
                        # Input string
                        input="$line"

                        # Extract the first character using sed and store it in firstChar
                        firstChar=$(echo "$input" | sed -n 's/^\(.\).*/\1/p')

                        # Extract the message and recieverNumber using sed from lines 
                        message=$(echo "$input" | sed -n 's/.*;\*\(.*\)\*;@.*/\1/p')
                        recieverNumber=$(echo "$input" | sed -n 's/.*@//p')

                        # match 'o' for “from” phone number.
                        # case 2: destination# != sender# no duplicate messages
                        if [ "$firstChar" == "o" ] && [ $recieverNumber -ne ${number//-/} ]
                        then
                            # print formatted output
                            printf "%-10s\t%-10s\t%-10s\n" "${number//-/}" "$recieverNumber" "$message"
                        fi

                    done < $t # t -> .txt files 
                done

            else 
                echo "No results found for $number"
                return
            fi
    fi
}

# Loads _help() by default
if [ $# -eq 0 ]; then
    _help
    exit 1
fi    


command=$1
shift

# Matches specific command
case $command in
# ./sms.sh help
    help) 
        _help ;;

# ./sms.sh send
    send)
        # validates arguments 
        if [ $# -ne 3 ]; then
            echo "INVALID INPUT. FOLLOW GUIDE"
            _help
            exit 1
        fi

        # makes .messages directory
        _makeDirectory
        _sendMessage "$@" ;;

# ./sms.sh remove
    remove)
        # validates arguments 
        if [ $# -ne 1 ]; then
            echo "INVALID INPUT. FOLLOW GUIDE"
            _help
            exit 1
        fi

        # makes .messages directory
        _makeDirectory
        _removeMessage "$1" ;;

# ./sms.sh search
    search)
        # validates arguments 
        if [ $# -lt 1 ]; then
            echo "INVALID INPUT. FOLLOW GUIDE"
            _help
            exit 1
        fi

        # makes .messages directory
        _makeDirectory
        _searchMessage "$@" ;;

# ./sms.sh (other entries)
    *)
        echo "INVALID INPUT. FOLLOW GUIDE"
        _help
        exit 1 ;;
        
esac
