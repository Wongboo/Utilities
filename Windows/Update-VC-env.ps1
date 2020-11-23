cmd /c " @call `"C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat`" && SET" |
Where-Object {($_ -match '^([^=]+)=(.*)') -and ([System.Environment]::GetEnvironmentVariable($matches[1]) -ne $matches[2])}|
Out-File -FilePath C:\Users\90834\Documents\env.txt