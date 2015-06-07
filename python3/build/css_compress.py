import getopt
import getpass
import glob
import os
import re
import server
import subprocess
import sys
import textwrap
import time

def usage():
    str = '''
        USAGE:

            CLI:
                python3 css_compress.py -v 3.0.0 --src ../resources/css/ -o JSLITE_CSS_3.0.0.min.css

            As an imported module:
                css_compress.compress(version, src[, output='min.css', dest='.'])

        --version, -v   The version of the minified script, must be specified.
        --src, -s       The location of the CSS files, must be specified.
        --output, -o    The name of the new minimized file, defaults to 'min.css'.
        --dest, -d      The location where the minified file will be moved, defaults to cwd.
        --dependencies  A list of scripts, FIFO when compressed, default to an empty list.
    '''
    print(textwrap.dedent(str))

def main(argv):
    dest = '.'
    src = ''
    output = 'min.css'
    version = ''
    dependencies = []

    try:
        opts, args = getopt.getopt(argv, 'hv:s:o:d:', ['help', 'version=', 'src=', 'output=', 'dest=', 'dependencies='])
    except getopt.GetoptError:
        print('Error: Unrecognized flag.')
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(0)
        elif opt in ('-v', '--version'):
            version = arg
        elif opt in ('-s', '--src'):
            src = arg
        elif opt in ('-o', '--output'):
            output = arg
        elif opt in ('-d' '--dest'):
            dest = arg
        elif opt == '--dependencies':
            dependencies = arg

    compress(version, src, output, dest, dependencies)

def compress(version, src, output='min.css', dest='.', dependencies=[]):
    if not version:
        print('Error: You must provide a version.')
        sys.exit(2)

    if not src:
        print('Error: You must provide the location of the source files.')
        sys.exit(2)

    try:
        print('Creating minified script...\n')

        buff = []
        genny = (dependencies + [os.path.basename(filepath) for filepath in glob.glob(src + '*.css') if os.path.basename(filepath) not in dependencies])

        if (len(genny) - len(dependencies) <= 0):
            print('OPERATION ABORTED: No CSS files were found in the specified source directory. Check your path?')
            sys.exit(1)

        def replace_match(match_obj):
            if not match_obj.group(1) == '':
                return match_obj.group(1)
            else:
                return ''

        # Strip out any comments of the "/* ... */" type (non-greedy). The subexpression matches all chars AND whitespace.
        reStripComments = re.compile(r'/\*(?:.|\s)*?\*/')
        # Remove all whitespace before and after the following chars: { } : ; = , < >
        reRemoveWhitespace = re.compile(r'\s*({|}|:|;|=|,|<|>)\s*')
        # Lastly, replace all double spaces with a single space.
        reReplaceDoubleSpaces = re.compile(r'^\s+|\s+$')

        for script in genny:
            with open(src + script) as f:
                file_contents = f.read()

            file_contents = reStripComments.sub('', file_contents)
            file_contents = reRemoveWhitespace.sub(replace_match, file_contents)
            file_contents = reReplaceDoubleSpaces.sub('', file_contents)

            buff.append(file_contents)
            print('CSS file ' + script + ' minified.')

        # This will overwrite pre-existing.
        os.makedirs(dest, exist_ok=True)
        with open(dest + '/' + output, mode='w', encoding='utf-8') as fp:
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

