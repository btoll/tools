import getopt
import getpass
import os
import server
import shutil
import subprocess
import sys
import tarfile
import textwrap

def usage():
    str = '''
        USAGE:

            CLI:
                python3 tar.py --src ../src/ -v 3.0.0

            As an imported module:
                tar.tar(src[, dest='.', version])

        --src, -s      The location of the JavaScript source files, must be specified.
        --dest, -d     The location where the minified file will be moved, defaults to cwd.
        --version, -v  The version of the minified script.
    '''
    print(textwrap.dedent(str))

def main(argv):
    dest = '.'
    src = ''
    version = ''

    try:
        opts, args = getopt.getopt(argv, 'hs:d:v:', ['help', 'src=', 'dest=', 'version='])
    except getopt.GetoptError:
        print('Error: Unrecognized flag.')
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(0)
        elif opt == '--src':
            src = arg
        elif opt == '--dest':
            dest = arg
        elif opt in ('-v', '--version'):
            version = arg

    tar(src, dest, version)

def tar(src, dest='.', version):
    if not src:
        print('Error: You must provide the location of the source files.')
        sys.exit(2)

    # Define some constants.
    tarball = 'JSLITE_' + version + '.tgz'
    tmp_dir = 'jslite/'
    port = '22'
    dest_remote = '~'
    username = getpass.getuser()

    try:
        shutil.copytree(src, tmp, ignore=shutil.ignore_patterns('a*', '_*'))
        tar_object = tarfile.open(dest + '/' + tarball, 'w:gz')
        print('Creating new tarball...')

        for file in os.listdir(tmp_dir):
            tar_object.add(tmp_dir + file)

        tar_object.close()

        print('Created new tarball ' + tarball + ' in ' + dest + '/')
        print('Cleaning up...')
        shutil.rmtree(tmp_dir)

        if server.prepare(tarball):
            print('Created tarball ' + tarball + ' in ' + dest + '/')

    except (KeyboardInterrupt, EOFError):
        # Control-C or Control-D sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')

        # If aborted at input() then tmp_dir would have already been removed so first check for its existence.
        if (os.path.isdir(tmp_dir)):
            print('Cleaning up...')
            shutil.rmtree(tmp_dir)
            print('Done!')

        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) == 1:
        usage()
        sys.exit(2)

    main(sys.argv[1:])

