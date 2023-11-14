@echo off
rem Call GIMP to run a Python-Fu script
rem Suitable for VsCode Tasks
rem See: https://stackoverflow.com/a/44435560
rem
rem Syntax: fu_batch_task.bat python-fu-module-name [optional-python-arguments...]
rem
rem python-fu-module-name is the script file name without the .py extension

rem Enable delayed expansion of variables
setlocal enabledelayedexpansion

rem Check calling argumests
if "%*"=="" (
    echo No arguments supplied.
    echo Syntax: fu_batch_task.bat python-fu-module-name [optional-python-arguments...]
    exit
)

rem Assign GIMP executable
rem The following path must be updated with each new version
set gimp="C:\Program Files\GIMP 2\bin\gimp-2.10.exe"

rem Assign the Python-Fu script name from the first argument
set fu_script=%1

rem Assign the optional Python aruguments list (comma separated)
rem from the remaining batch arguments
set optional_python_args=
set argc=0
for %%a in (%*) do (
    if !argc! gtr 0 (
        if "!optional_python_args!" == "" (
            set optional_python_args=!optional_python_args!'%%a'
        ) else (
            set optional_python_args=!optional_python_args!, '%%a'
        )
    )
    set /a argc+=1
)

echo Calling: %fu_script%(%optional_python_args%)
%gimp% -idf --batch-interpreter python-fu-eval -b "import sys;sys.path=['.']+sys.path;import %fu_script%;%fu_script%.run(%optional_python_args%)" -b "pdb.gimp_quit(1)"

rem Arguments description:
rem     -idf : work without user interface, and load neither data nor fonts
rem            (you may perhaps need to keep the fonts to load pdfs)
rem
rem     --batch-interpreter python-fu-eval : whatever follows -b is Python, not script-fu
rem
rem    "import sys;sys.path=['.']+sys.path;import %fu_script%;%fu_script%.run(%optional_python_args%)" :
rem           the code that we ask Gimp to execute, namely:
rem                import sys;sys.path=['.']+sys.path;
rem                     # extend the import path to include the current directory
rem                import %fu_script%;
rem                     # import the file with our script, which is now in a directory
rem                     # which is part of the path.
rem                %fu_script%.run([optional_python_args])
rem                     # call the run() function of the %fu_script% module we imported,
rem                     # giving it any optional arguments
rem
rem     -b "pdb.gimp_quit(1)": another piece of python: exit when done.
rem
rem Note how the command line cleverly uses double and single quotes to pass all parameters
rem to Gimp and then to Python(*).
rem In a Linux/OSX shell one would do the opposite: single quotes for the shell, double quotes for Python.
rem You can use forward slashes as file separators in Windows.
rem
rem To debug, matters are bit complicated in Windows because there is no always a stdout stream.
rem Things that can help:
rem     - remove the -i parameter temporarily so that you get the UI and perhaps a chance to see messages.
rem     - Add --verbose which makes Gimp start a secondary console window.
rem You can also start Gimp normally and run your script from the Python-fu console (Filters>Python-fu>Console).
rem You will have to extend the path and import the file "manually".
rem 
rem There are other tricks to see messages listed here:
rem https://www.gimp-forum.net/Thread-Debugging-python-fu-scripts-in-Windows
