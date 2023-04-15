@echo off 
setlocal enabledelayedexpansion

set workdir=%~dp0
set complier=%workdir%protoc.exe

if not exist %complier% (
	echo error: There is No %complier%
	exit
)

echo The Current Directory is: %workdir%

for /d %%i in (*) do (
  set foldername=%%i
  set protofiledir=%workdir%!foldername!
  echo enter !protofiledir! 
  rem "进入该目录,以免生成.cc/.cpp文件时包含头文件带相对路径前缀"
  cd !protofiledir!
  for %%f in (*.proto) do (
	set filename=%%f
	echo Find file: !filename!
	
	set outputdir=!protofiledir!
	echo The output directory is: !outputdir!

	rem ".h和.cpp文件的输出路径;pb文件的输出路径"
	set cppoutdir=!outputdir!
	if not exist !cppoutdir! (
		md !cppoutdir!
	)
	set luaoutdir=!outputdir!
	if not exist !luaoutdir! (
		md !luaoutdir!
	)
	
	rem "执行编译程序"
	set pbfilename=!filename:~0,-6!.pb
	echo The output *.pb file is: !luaoutdir!\!pbfilename!
	%complier%  !filename!  -o !luaoutdir!\!pbfilename! --cpp_out=!cppoutdir!
  )
  cd %workdir%
)
cd %~dp0
echo Finished
