 local path = "X:\\ranking.txt"
   
    local file = io.open(path, "r")
     local text = file:read("*a")
        file:close()
      bz = text:match("http://h2.ioliu.cn/bing/[^\"]*1080[^\"]*jpg")
	
			  exec(
            "/hide",
            [[cmd /c echo ]] .. bz .. [[>X:\now.txt]]
        )
		  exec(
            "/wait",
            [[cmd /c aria2c --allow-overwrite=true ]] .. bz .. [[ -d "X:\\" -o wallpaper.jpg>%temp%\bz.log]]
        )
		
	
		    winapi.show_message("!!!", bz)
			Desktop:SetWallPaper("X:\\00.jpg")

		
