python -m SimpleHTTPServer & 

childpid=$!
trap "kill -TERM ${childpid}" EXIT

ls . compiled/* src/* | entr -s '~/Downloads/Godot3.3.app/Contents/MacOS/Godot --export-debug "HTML5" --no-window out/ld48.html'
