addr="user@ip"
app=""


tmux kill-session -t $app
tmux new -d -s $app
tmux rename-window -t $app 0


#{session}:{window}.{pane}

#init andorid x server (client)
tmux send-keys -t $app:0.0 'termux-x11 :0' ENTER


###slice
tmux split-window -h -t $app

#connect to client via ssh -Y (server)
tmux send-keys -t $app:0.1 "DISPLAY=:0 ssh -Y $addr" ENTER

#app launch commands

#if it is flatpak app
flatpak_id=''
tmux send-keys -t $app:0.1 "flatpak run --socket=x11 --share=network --device=dri $flatpak_id" ENTER


#make sure x window always max

tmux split-window -v -t $app:0.0
tmux send-keys -t $app:0.1 'export DISPLAY=:0' ENTER
tmux send-keys -t $app:0.1 "while true; do xdotool search $app | xargs -I {} xdotool windowsize {} 100% 100% && xdotool search $app | xargs -I {} xdotool windowmove {} 0 0; sleep 1; done 2>/dev/null" ENTER
