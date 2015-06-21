# TODO: support compressors other than YUI Compressor?

import base_compress
import getopt
import getpass
import os
import server
import subprocess
import sys
import textwrap

def usage():
    str = '''
        USAGE:

            CLI:
                python3 js_compress.py -s /usr/local/www/PeteJS/src/ -d /usr/local/www/owlsnestfarm/build/ -o pete.js --dependencies 'Pete.prototype.js, Pete.js, Pete.Element.js, Pete.Composite.js, Pete.Observer.js'

            As an imported module:
                js_compress.compress(src[, output='min.js', dest='.', version='3.0.0', dependencies='', exclude='', jar=None])

        --src, -s       The location of the JavaScript source files, must be specified.
        --output, -o    The name of the new minimized file, defaults to 'min.js'.
        --dest, -d      The location where the minified file will be moved, defaults to cwd.
        --version, -v   The version of the minified script.
        --dependencies  Any number of directories or filenames, separated by a comma, defaults to an empty list. FIFO.
                        The absolute path will be prepended to the element, depends on the src location.
        --exclude       Any number of directories or filenames, separated by a comma, that should be excluded in the build, defaults to an empty list.
                        The absolute path will be prepended to the element, depends on the src location.
        --jar, -j       The location of the jar file, defaults to the value of YUICOMPRESSOR environment variable.
    '''
    print(textwrap.dedent(str))

def main(argv):
    jar = None
    dest = '.'
    src = ''
    output = 'min.js'
    version = ''
    dependencies = []
    exclude = []

    try:
        opts, args = getopt.getopt(argv, 'hs:o:d:v:j:', ['help', 'src=', 'output=', 'dest=', 'version=', 'dependencies=', 'exclude=', 'jar='])
    except getopt.GetoptError:
        print('Error: Unrecognized flag.')
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(0)
        elif opt in ('-s', '--src'):
            src = arg
        elif opt in ('-o', '--output'):
            output = arg
        elif opt in ('-v', '--version'):
            version = arg
        elif opt in ('-d', '--dest'):
            dest = arg
        elif opt == '--dependencies':
            dependencies = arg if type(arg) is list else base.split_and_strip(arg)
        elif opt == '--exclude':
            exclude = arg if type(arg) is list else base.split_and_strip(arg)
        elif opt in ('-j', '--jar'):
            jar = arg

    compress(src, output, dest, version, dependencies, exclude, jar)

def compress(src, output='min.js', dest='.', version='', dependencies=[], exclude=[], jar=None):
    if not src:
        print('Error: You must provide the location of the source files.')
        sys.exit(2)

    if not jar:
        # Provide an alternate location to the jar to override the environment variable (if set).
        jar = os.getenv('YUICOMPRESSOR')
        if not jar:
            jar = input('Location of YUI Compressor jar (set a YUICOMPRESSOR environment variable to skip this step): ')
            if not jar:
                print('Error: You must provide the location of YUI Compressor jar.')
                sys.exit(2)

    try:
        print('Creating minified script...\n')

        buff = []
        exclude = base.make_abspath(src, exclude)
        matches = base.walk(src, exclude)

        ls = (dependencies + [f for f in matches if os.path.basename(f) not in dependencies])

        if (len(ls) - len(dependencies) - len(exclude) <= 0):
            print('OPERATION ABORTED: No JavaScript source files were found in the specified source directory. Check your path?')
            sys.exit(1)

        for script in ls:
            buff.append(subprocess.getoutput('java -jar ' + jar + ' ' + src + script))
            print('Script ' + script + ' minified.')

        # This will overwrite pre-existing.
        os.makedirs(dest, exist_ok=True)
        # Let's append in case a build prepending copyright information (or anything, really) before calling here.
        with open(dest + '/' + output, mode='a', encoding='utf-8') as fp:
            # Flush the buffer (only perform I/O once).
            fp.write(''.join(buff))

        if server.prepare(output):
            print('Created minified script ' + output + ' in ' + dest)

    except (KeyboardInterrupt, EOFError):
        # Control-C or Control-D sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) == 1:
        usage()
        sys.exit(2)

    main(sys.argv[1:])

