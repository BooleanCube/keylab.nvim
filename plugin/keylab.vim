fun! KeylabReload()
    lua package.loaded["keylab"] = nil
    lua package.loaded["keylab.utils"] = nil
endfun

com! KeylabReload call KeylabReload()

" add setup configuration here through lua
