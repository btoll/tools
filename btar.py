import sys
from time import localtime
from os import listdir, waitpid, path
from shutil import copytree, rmtree, make_archive, ignore_patterns
from getopt import getopt, GetoptError
from subprocess import Popen
from getpass import getuser

def usage(level):
    if level == 0:
        print('''Usage: python3 tar_jslite.py [-h | --help [[-s | --src] [-d | --dest]]] [SOURCE | DESTINATION]
Try `python3 btar.py --help' for more information.''')

    elif level == 1:
        print('''Usage:
  -h, --help    Help.
  -s, --src     The location of the assets to archive.
  -d, --dest    The location of where the assets should be archived.''')

def main(argv):
    try:   
        opts, args = getopt(argv, 'hs:d:', ['help', 'src=', 'dest='])
    except GetoptError:
        usage(0)
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage(1)
            sys.exit(0)
        elif opt in ('-s', '--src'):
            src_dir = arg
        elif opt in ('-d', '--dest'):
            dest_dir = arg

    # Define some variables.
    today = localtime()
    tmp_name = str(today.tm_year) + str(today.tm_mon) + str(today.tm_mday)
    tmp_dir = tmp_name + '/'
    format = 'gztar'
    port = '22'
    dest_remote = '~'
    hostname = 'benjamintoll.com'
    username = getuser()

    resp = input('Archive format [' + format.upper() + ', bztar, tar, zip]: ')
    if resp != '':
        format = resp

    try:
        copytree(src_dir, tmp_dir, ignore=ignore_patterns('a*', '_*'))

        print('Creating new tarball...')
        tar = make_archive(tmp_name, format, dest_dir, src_dir)

        # Create the tarball variable.
        if format == 'gztar':
            tarball = tmp_name + '.tar.gz'
        elif format == 'bztar':
            tarball = tmp_name + '.tar.bz2'
        elif format == 'tar':
            tarball = tmp_name + '.tar'
        elif format == 'zip':
            tarball = tmp_name + '.zip'

        print('Created new tarball ' + tarball + ' in ' + dest_dir + '/')
        print('Cleaning up...')
        rmtree(tmp_dir)

        resp = input('Push to remote server? [y|N]: ')
        if resp in ['Y', 'y']:
            resp = input('Username [' + username + ']: ')
            if resp != '':
                username = resp

            resp = input('Port [' + port + ']: ')
            if resp != '':
                port = resp

            resp = input('Hostname [' + hostname + ']: ')
            if resp != '':
                hostname = resp

            resp = input('Remote filepath [' + dest_remote + ']: ')
            if resp != '':
                dest_remote = resp

            p = Popen(['scp', '-P', port, dest_dir + '/' + tarball, username + '@' + hostname + ':' + dest_remote])
            sts = waitpid(p.pid, 0)
            print('Tarball ' + tarball + ' pushed to ' + dest_remote + ' on remote server.')
        else:
            print('Tarball ' + tarball + ' created in ' + dest_dir + '/')

        print('Done!')

    except (KeyboardInterrupt):
        # Control-c sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')

        # If aborted at input() then tmp_dir would have already been removed so first check for its existence.
        if (path.isdir(tmp_dir)):
            print('Cleaning up...')
            rmtree(tmp_dir)
            print('Done!')
        sys.exit(1)

if __name__ == '__main__':
    if len(sys.argv) == 1:
        usage(0)
        sys.exit(2)

    main(sys.argv[1:])
