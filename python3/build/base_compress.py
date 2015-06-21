import os
import re

def make_abspath(root, ls):
    return [os.path.join(root, f) for f in ls]

def split_and_strip(ls):
    # Split string by comma and strip leading and trailing whitepace from each list element.
    return [f.strip() for f in ls.split(',')]

def walk(root, exclude=[]):
    # Any element in the exclude list is assumed to have an absolute path to the source directory.
    matches = []

    for dirpath, dirnames, filenames in os.walk(root):
        # First add all filenames to the list.
        #
        # Note we compare the joined dirpath/f against the elements in the exclude list. They will both
        # reference the same source location.
        matches += [os.path.join(dirpath, f) for f in filenames if re.search('.css$', f) and os.path.join(dirpath, f) not in exclude]

        # Then remove any dirnames in our exclude list so any filenames contained
        # within them are not included.
        #
        # Note here we have to compare the function arg `root` against the exclude list.
        [dirnames.remove(d) for d in dirnames if os.path.join(root, d) in exclude]

    return matches


