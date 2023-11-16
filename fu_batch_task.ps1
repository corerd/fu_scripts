# Call GIMP to run a Python-Fu script from command line
# See: https://stackoverflow.com/a/44435560
#
# Syntax: fu_batch_task.ps1 python-fu-module-name [fu_arg_1 [fu_arg_2 [... fu_arg_N]]]
#
# python-fu-module-name is the script file name without the .py extension.
# fu_args are the optional parameters for the Python-Fu module.
# Parameter list entries don't include quotes and are separated by spaces, NOT commas.

# Get GIMP istallation path.
# See: Finding the full path to an executable on Windows (more than a "which" equivalent)
#      https://stackoverflow.com/q/73596124
# The GIMP application is searched in Windows Start of the current user so it is uniquely identified.
# Searching in its installation folder 'C:\Program Files\GIMP*' returns many executables
# from which it is difficult to choose the right one automatically.
#
# The following instruction returns GIMP Name and Application User Model ID (AUMID).
$GIMP_APP = Get-StartApps | Where-Object { $_.Name -like '*gimp*' }
if ([string]::IsNullOrEmpty($GIMP_APP)) {
    Write-Host "ERROR: GIMP is required but it is not installed"
    exit
}
# Assign the application full path
# assuming it is installed for all users under C:\Program Files\
$GIMP_PATH = "C:\Program Files" + ( [string]$GIMP_APP.AppId -replace "\{.*?\}", "" )
if (!(Test-Path $GIMP_PATH))
{
    Write-Host "GIMP path not found"
    exit
}

# Check calling argumests
if ($args.Count -eq 0) {
    Write-Host "ERROR: No arguments supplied."
    Write-Host "Syntax: fu_batch_task.ps1 python-fu-module-name [fu_arg_1 [fu_arg_2 [... fu_arg_N]]]"
    exit
}

# From the calling arguments, esctract the Python-Fu module name and its optional parameters
$fu_args = ""
$argc = 0
foreach ($arg in $args) {
    if ($argc -eq 0) {
        # Extract the Python-Fu module name from the first mandatory argument
        $fu_script = $arg
    } else {
        # The remaining optional aruguments are given to Python-Fu module
        # as comma separated single quoted parameters list,
        # escaping single quotes using backtick character (`).
        if ([string]::IsNullOrEmpty($fu_args)) {
            $fu_args = "`'$arg`'"
        } else {
            $fu_args += ", `'$arg`'"
        }
    }
    $argc += 1
}

# GIMP command line arguments
$gimp_args = ""

# Work without user interface, and load neither data nor fonts
# (you may perhaps need to keep the fonts to load pdfs)
$gimp_args += "-idf "

# Whatever follows -b is Python code
$gimp_args += "--batch-interpreter python-fu-eval "

# The Python-Fu module that we ask Gimp to execute.
# Note the use of double and single quotes to pass all parameters to GIMP and then to Python:
#   - double quotes for GIMP
#   - single quotes for Python
# In a Linux/OSX shell one would do the opposite.
# In PowerShell, escape double and single quotes using backtick character (`).
$gimp_args += "-b `"import sys;sys.path=[`'.`']+sys.path;import $fu_script;$fu_script.run($fu_args)`" "
# Namely:
#   - import sys;sys.path=[`'.`']+sys.path; : extend the import path to include the current directory
#   - import $fu_script; : import the given Python-Fu module, which is now in a directory which is part of the path
#   - $fu_script.run($fu_args) : call the run() function of the imported $fu_script giving its $fu_args

# Another piece of Python code to exit when done
$gimp_args += "-b `"pdb.gimp_quit(1)`" "

# Start GIMP
Write-Host "Call" $GIMP_APP.Name "to run Python-Fu module:"
Write-Host "$fu_script($fu_args)"
Start-Process -FilePath $GIMP_PATH -ArgumentList $gimp_args

# Debugging tips
# To debug, matters are bit complicated in Windows because there is no always a stdout stream.
# Things that can help:
#   - remove the -i parameter temporarily so that you get the UI and perhaps a chance to see messages.
#   - Add --verbose which makes Gimp start a secondary console window.
#   - There are other tricks to see messages listed here:
#     https://www.gimp-forum.net/Thread-Debugging-python-fu-scripts-in-Windows
#   - You can also start Gimp normally and run your script from the Python-fu console (Filters>Python-fu>Console).
#     You will have to extend the path and import the file "manually".
