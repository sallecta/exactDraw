#!/bin/bash

#git add *
#git add **/.gitignore
#git add .gitignore
git add -u 
git status
echo 'Check status:'
echo '- write commit message or just press Enter to upload;'
echo '- type Ctrl+C to cancel.'
read commmitMessage

if [ "$commmitMessage" = "" ]
then
    commmitMessage='...'
fi
echo commit message is \"$commmitMessage\"
git commit --message="$commmitMessage"
git push
