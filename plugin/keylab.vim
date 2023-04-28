fun! KeylabReload()
    lua package.loaded["keylab"] = nil
    lua package.loaded["keylab.utils"] = nil
    lua package.loaded["keylab.perf"] = nil
endfun

fun! KeylabStart()
    lua require("keylab").start()
endfun

fun! KeylabClearPerf()
    call inputsave()
    let confirmation = input('Are you sure you want to lose all your performance data? [Y/n] ')
    if or(confirmation == "Y", confirmation == "y")
        lua require("keylab.perf").delete_db()
        echo "Successfully deleted database file!"
    elseif or(confirmation == "N", confirmation == "n")
        echo "Cancelled database deletion..."
        return
    else
        echo "Please confirm with Y (yes) or n (no)."
    endif
endfun

com! KeylabReload call KeylabReload()
com! KeylabStart call KeylabStart()
com! KeylabClearPerf call KeylabClearPerf()
