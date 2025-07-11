chcp 65001
for /f "tokens=1,2 delims==" %%a in (config.txt) do (set %%a=%%b)
%editor_path% "%cd%\map.w3x"