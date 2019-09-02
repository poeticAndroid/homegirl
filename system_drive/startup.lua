fs.mount("shared", "http://homegirl.zone/")
sys.exec("/cmd/shell.lua", {}, "user:")
sys.exec("user:startup.lua", {}, "user:")
