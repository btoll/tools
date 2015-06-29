import os
import re
import sys

def filter_exclusions(root, exclude=[], suffix='js'):
    # Any element in the exclude list is assumed to have an absolute path to the source directory.
    matches = []

    # Normalize by making any path entry in the exclude list absolute.
    exclude = make_abspath(root, exclude)

    for dirpath, dirnames, filenames in os.walk(root):
        # First add all filenames to the list.
        #
        # Note we compare the joined dirpath/f against the elements in the exclude list. They will both
        # reference the same source location.
        matches += [os.path.join(dirpath, f) for f in filenames if re.search('.' + suffix + '$', f) and os.path.join(dirpath, f) not in exclude]

        # Then remove any dirnames in our exclude list so any filenames contained
        # within them are not included.
        #
        # Note here we have to compare the function arg `root` against the exclude list.
        [dirnames.remove(d) for d in dirnames if os.path.join(root, d) in exclude]

    return matches

def make_abspath(root, ls):
    return [os.path.join(root, f) for f in ls]

def make_list(ls):
    # Split string by comma and strip leading and trailing whitepace from each list element.
    return ls if type(ls) is list else [f.strip() for f in ls.split(',')]

def process_files(src, files):
    return [f for f in make_abspath(src, files) if os.path.isfile(f)]

def sift_list(root, suffix, exclude=[], dependencies=[]):
    # TODO: add more line comments!
    # Clone.
    original = dependencies[:]
    target = []

    # `root` should always be a list.
    for src in root:
        # Let's only operate on filenames with absolute paths.
        dependencies = process_files(src, original)
        matches = filter_exclusions(src, exclude, suffix)

        # Make sure our dependencies are at the front of the stack and not duped. The
        # new list will be the target list of files to be processed by the minifier.
        target += (dependencies + [f for f in matches if f not in dependencies])

        if (len(target) <= 0):
            print('OPERATION ABORTED: Either no ' + suffix.upper() + ' source files were found in the specified source directory or there were more exclusions than source files.')
            sys.exit(1)

    return target

