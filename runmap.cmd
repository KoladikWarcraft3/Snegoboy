chcp 65001
for /f "tokens=1,2 delims==" %%a in (config.txt) do (set %%a=%%b)
.\WarcraftIII-pack\lua53.exe pack.lua
%warcraft_path% -loadfile "%cd%\map.w3x" -launch -nowfpause
