#!/bin/bash
if [ $0 -eq "nobom" ]; then
    path=$1
    find $path -type f -name "*" -print | xargs -i sed -i '1 s/^\xef\xbb\xbf//' {} 
else
    path=$1
    find $path -type f -name "*" -print | xargs -i sed -i '1 s/^/\xef\xbb\xbf&/' {}
fi
echo "Convert finish"