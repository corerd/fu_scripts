Running GIMP Python-Fu scripts
==============================
To run a Python-Fu script it not necessary to register it as a plugin.

Running it from command line avoids to pollute Gimp's menus and procedure name space.

Giving a Python script saved as `fu_script.py`, it should looks like:
```
# The following import is mandatory
from gimpfu import * 

#  Other import here
# ...


def run(fu_args):
    # Entry point called from command line together optional parameters
    # ...


if __name__ == "__main__":
        print "Running as __main__"
```

To call it from Windows Command shell:
```
gimp -idf --batch-interpreter python-fu-eval -b "import sys;sys.path=['.']+sys.path;import fu_script;fu_script.run('fu_arg1', ...)" -b "pdb.gimp_quit(1)"
```

Arguments description:
- `-idf`: work without user interface, and load neither data nor fonts
          (you may perhaps need to keep the fonts to load PDFs).
- `--batch-interpreter python-fu-eval`: whatever follows `-b` is Python, not script-fu.
- `-b "import sys;sys.path=['.']+sys.path;import batch;batch.run('./images')"`: the code that we ask Gimp to execute, namely:
    - `import sys;sys.path=['.']+sys.path;`: extend the import path to include the current directory
    - `import fu_script;`: import our Python-Fu module, which is now in a directory which is part of the path.
    - `fu_script.run('fu_arg1', ...)`: call the run() function of the fu_script module we imported,
                                       giving its optional parameters list
- `-b "pdb.gimp_quit(1)"`: another piece of python: exit when done.

Note the use of double and single quotes to pass all parameters to GIMP and then to Python:
- double quotes for GIMP
- single quotes for Python

In a Linux/OSX shell one would do the opposite.

In Windows PowerShell, escape double and single quotes using backtick character (`).

**Debugging tips**

To debug, matters are bit complicated in Windows because there is no always a stdout stream.

Things that can help:
- remove the `-i` parameter temporarily so that you get the UI and perhaps a chance to see messages.
- Add `--verbose` which makes Gimp start a secondary console window.
- There are other tricks to see messages listed [here](https://www.gimp-forum.net/Thread-Debugging-python-fu-scripts-in-Windows).
- You can also start Gimp normally and run your script from the Python-fu console (Filters>Python-fu>Console).
  You will have to extend the path and import the file "manually".


Automation Stuff
----------------
To run a GIMP Python-Fu script from command line are provided `fu_batch_task.ps1` and `fu_batch_task.bat`
Windows scripts together VsCode configuration files.


References
----------
[How to run python scripts using gimpfu from command line](https://stackoverflow.com/a/44435560)

[Beginner’s guide to python scripting in GIMP](https://medium.com/@chriziegler/introduction-to-python-scripting-in-gimp-141b860ad7e)
