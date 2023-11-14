"""Hello World in GIMP Python-Fu Demo

Import this Python module in the following command line:
gimp -idf --batch-interpreter python-fu-eval -b "import sys;sys.path=['.']+sys.path;import %fu_script%;%fu_script%.run(%optional_arguments%)" -b "pdb.gimp_quit(1)"

Arguments description:
    -idf : work without user interface, and load neither data nor fonts
           (you may perhaps need to keep the fonts to load pdfs)

    --batch-interpreter python-fu-eval : whatever follows -b is Python, not script-fu

    "import sys;sys.path=['.']+sys.path;import %fu_script%;%fu_script%.run(%optional_arguments%)" :
           the code that we ask Gimp to execute, namely:
                import sys;sys.path=['.']+sys.path;
                     # extend the import path to include the current directory
                import %fu_script%;
                     # import the file with our script, which is now in a directory
                     # which is part of the path.
                %fu_script%.run(<optional_arguments>)
                     # call the run() function of the %fu_script% module we imported,
                     # giving it any optional arguments

    -b "pdb.gimp_quit(1)": another piece of python: exit when done.

Note how the command line cleverly uses double and single quotes to pass all parameters
to Gimp and then to Python(*).
You can use forward slashes as file separators in Windows.

"""
import sys
from gimpfu import *


def run(people=None, andMore=None):
    """The run function of the Python module imported as GIMP argument
    with optional arguments list.
    """
    if people is None:
        people = 'GIMP'
    if andMore is not None:
        people = '{} and {}'.format(people, andMore)
    gimp.message('Python-Fu: Hello {}'.format(people))


if __name__ == "__main__":
    print("Running as __main__ with args: {}".format(sys.argv))
