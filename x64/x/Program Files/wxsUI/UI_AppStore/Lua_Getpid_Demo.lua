proc = winapi.spawn_process([[X:\Program Files\PENetwork\PENetwork.exe]])
a = proc:get_pid()
winapi.show_message("È¡µÃpid", a)