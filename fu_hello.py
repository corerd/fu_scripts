"""Hello World in GIMP Python-Fu Demo

Run this script from command line as:
gimp -idf --batch-interpreter python-fu-eval -b "import sys;sys.path=['.']+sys.path;import fu_hello;fu_hello.run(['arg_1' ['arg_2']])" -b "pdb.gimp_quit(1)"
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
