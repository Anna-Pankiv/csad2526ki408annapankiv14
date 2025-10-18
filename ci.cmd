@echo off
rem ci.cmd — identical to ci.bat for environments that prefer .cmd
rem Usage: ci.cmd [Configuration]
rem Example: ci.cmd Release
setlocal

rem Choose configuration (default: Release)
if "%~1"=="" (
  set "CONFIG=Release"
) else (
  set "CONFIG=%~1"
)

rem Create and enter build directory
if not exist "build" (
  mkdir "build"
)
pushd "build"

rem Configure the project
cmake .. || goto :error

rem Build the project (works for multi-config generators like Visual Studio)
cmake --build . --config "%CONFIG%" || goto :error

rem Run tests with CTest (pass configuration for multi-config generators)
ctest -C "%CONFIG%" --output-on-failure || goto :error

popd
echo.
echo All steps completed successfully.
endlocal
exit /b 0

:error
popd 2>nul
echo.
echo ERROR: A step failed.
endlocal
exit /b 1
