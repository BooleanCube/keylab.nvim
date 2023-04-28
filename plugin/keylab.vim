fun! KeylabReload()
    lua package.loaded["keylab"] = nil
    lua package.loaded["keylab.utils"] = nil
endfun

fun! KeylabStart()
    lua require("keylab").start()
endfun

com! KeylabReload call KeylabReload()
com! KeylabStart call KeylabStart()

