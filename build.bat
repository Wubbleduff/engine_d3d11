
@echo off


REM Compiler versions
REM clang version 17.0.3
REM Microsoft (R) C/C++ Optimizing Compiler Version 19.41.34123 for x64


call build_clean


REM -------------------------------- Common --------------------------------

set NAME=engine_d3d11

set SRC=src

REM Avoid C runtime library
REM https://hero.handmade.network/forums/code-discussion/t/94-guide_-_how_to_avoid_c_c++_runtime_on_windows
set COMMON_COMPILE_FLAGS=/Od /c /W4 /WX /EHsc /std:c17 /GS- /Gs9999999

REM TODO: Remove the "common" include for each project
set INCLUDE_DIRS=/I"src" /I"src_external" /I"../common"


set DEBUG_COMPILE_FLAGS=/DDEBUG /Zi
set DEBUG_LINK_FLAGS=/NODEFAULTLIB /STACK:0x100000,0x100000 /SUBSYSTEM:WINDOWS /MACHINE:X64 /DEBUG:FULL
set LIBS=kernel32.lib user32.lib gdi32.lib d3d11.lib dxgi.lib dxguid.lib


REM -------------------------------- D3D11 Shaders --------------------------------
rmdir /s /Q src\platform_win32\shaders\generated
mkdir src\platform_win32\shaders\generated

fxc.exe /nologo /T vs_5_0 /E vs /O3 /WX /Zpc /Ges /Fh src\platform_win32\shaders\generated\d3d11_vshader_basic.h /Vn d3d11_vshader_basic /Qstrip_reflect /Qstrip_debug /Qstrip_priv src\platform_win32\shaders\basic.hlsl
if %errorlevel% neq 0 exit /b %errorlevel%
fxc.exe /nologo /T ps_5_0 /E ps /O3 /WX /Zpc /Ges /Fh src\platform_win32\shaders\generated\d3d11_pshader_basic.h /Vn d3d11_pshader_basic /Qstrip_reflect /Qstrip_debug /Qstrip_priv src\platform_win32\shaders\basic.hlsl
if %errorlevel% neq 0 exit /b %errorlevel%

fxc.exe /nologo /T vs_5_0 /E vs /O3 /WX /Zpc /Ges /Fh src\platform_win32\shaders\generated\d3d11_vshader_basic_color.h /Vn d3d11_vshader_basic_color /Qstrip_reflect /Qstrip_debug /Qstrip_priv src\platform_win32\shaders\basic_color.hlsl
if %errorlevel% neq 0 exit /b %errorlevel%
fxc.exe /nologo /T ps_5_0 /E ps /O3 /WX /Zpc /Ges /Fh src\platform_win32\shaders\generated\d3d11_pshader_basic_color.h /Vn d3d11_pshader_basic_color /Qstrip_reflect /Qstrip_debug /Qstrip_priv src\platform_win32\shaders\basic_color.hlsl
if %errorlevel% neq 0 exit /b %errorlevel%


REM -------------------------------- Clang --------------------------------

set CLANG_COMPILE_FLAGS=-march=skylake

set CLANG_INTERMEDIATE_DIR=.\clang_build_intermediate
set CLANG_DEPLOY_DEBUG_DIR=.\clang_deploy\debug

mkdir %CLANG_INTERMEDIATE_DIR%
mkdir %CLANG_DEPLOY_DEBUG_DIR%

clang-cl %COMMON_COMPILE_FLAGS% %CLANG_COMPILE_FLAGS% %DEBUG_COMPILE_FLAGS% %INCLUDE_DIRS% /Fo%CLANG_INTERMEDIATE_DIR%\platform_win32_unity_build.obj %SRC%\platform_win32\platform_win32_unity_build.c
if %errorlevel% neq 0 exit /b %errorlevel%

lld-link %DEBUG_LINK_FLAGS% %LIBS% %CLANG_INTERMEDIATE_DIR%\*.obj /OUT:"%CLANG_INTERMEDIATE_DIR%\%NAME%.exe"
if %errorlevel% neq 0 exit /b %errorlevel%

xcopy /Y %CLANG_INTERMEDIATE_DIR%\%NAME%.exe %CLANG_DEPLOY_DEBUG_DIR%
xcopy /Y %CLANG_INTERMEDIATE_DIR%\%NAME%.pdb %CLANG_DEPLOY_DEBUG_DIR%

echo.
echo %CLANG_DEPLOY_DEBUG_DIR%\%NAME%.exe
echo.


REM -------------------------------- MSVC ---------------------------------

set MSVC_INTERMEDIATE_DIR=.\msvc_build_intermediate
set MSVC_DEPLOY_DEBUG_DIR=.\msvc_deploy\debug

mkdir %MSVC_INTERMEDIATE_DIR%
mkdir %MSVC_DEPLOY_DEBUG_DIR%

cl %COMMON_COMPILE_FLAGS% %DEBUG_COMPILE_FLAGS% %INCLUDE_DIRS% /Fo%MSVC_INTERMEDIATE_DIR%\platform_win32_unity_build.obj %SRC%\platform_win32\platform_win32_unity_build.c
if %errorlevel% neq 0 exit /b %errorlevel%

link %DEBUG_LINK_FLAGS% %LIBS% %MSVC_INTERMEDIATE_DIR%\*.obj /OUT:"%MSVC_INTERMEDIATE_DIR%\%NAME%.exe"
if %errorlevel% neq 0 exit /b %errorlevel%

xcopy /Y %MSVC_INTERMEDIATE_DIR%\%NAME%.exe %MSVC_DEPLOY_DEBUG_DIR%
xcopy /Y %MSVC_INTERMEDIATE_DIR%\%NAME%.pdb %MSVC_DEPLOY_DEBUG_DIR%

echo.
echo %MSVC_DEPLOY_DEBUG_DIR%\%NAME%.exe
echo.
