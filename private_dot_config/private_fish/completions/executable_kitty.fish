if functions -q _ksi_completions
    complete -f -c kitty -a "(_ksi_completions)"
else
    complete -f -c kitty -a "(commandline -cop | kitty +complete fish)"
end

complete -c animdl -a "download grab schedule search stream update" -f
complete -c animdl -l help -x -d "displays all commands"
