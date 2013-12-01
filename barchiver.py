import sys
from time import localtime
from os import getcwd, makedirs, waitpid, path, remove
from shutil import make_archive, move, ignore_patterns
from getopt import getopt, GetoptError
from subprocess import Popen
from getpass import getuser

def usage(level):
    if level == 0:
        print('Usage: python3 tar_jslite.py [-h | --help [[-n | --name] [-s | --src] [-d | --dest]]]\nTry `python3 barchiver.py --help` for more information.')

    elif level == 1:
        print('''Usage:

  Optional flags:
  -h, --help    Help.
  -n, --name    An optional archive name. The default is YYYYMMDDHHMMSS.
  -s, --src     The location of the assets to archive. Defaults to cwd.
  -d, --dest    The location of where the assets should be archived. Defaults to cwd.''')

def main(argv):
    try:   
        opts, args = getopt(argv, 'hn:s:d:', ['help', 'name=', 'src=', 'dest='])
    except GetoptError:
        usage(0)
        sys.exit(2)

    # Define some variables.
    dest_dir = '.'
    src_dir = '.'
    today = localtime()
    tmp_name = str(today.tm_year) + str(today.tm_mon) + str(today.tm_mday) + str(today.tm_hour) + str(today.tm_min) + str(today.tm_sec)
    port = '22'
    dest_remote = '~'
    hostname = 'benjamintoll.com'
    username = getuser()

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage(1)
            sys.exit(0)
        elif opt in ('-n', '--name'):
            tmp_name = arg
        elif opt in ('-s', '--src'):
            src_dir = arg
        elif opt in ('-d', '--dest'):
            dest_dir = arg

    resp = input('''Choose an archive format:
0 = tar.gz
1 = tar.bz2
2 = tar
3 = zip
? [0]: ''')
    if resp in ['1', '2', '3']:
        if resp == '1':
            format = 'bztar'
            tarball = tmp_name + '.tar.bz2'

        if resp == '2':
            format = 'tar'
            tarball = tmp_name + '.tar'

        if resp == '3':
            format = 'zip'
            tarball = tmp_name + '.zip'
    else:
        format = 'gztar'
        tarball = tmp_name + '.tar.gz'

    try:
        # Create the destination directory if it doesn't exist.
        if not path.exists(dest_dir):
            makedirs(dest_dir)

        try:
            archive = make_archive(tmp_name, format, dest_dir, src_dir)
        except FileNotFoundError as e:
            print(e)
            if (path.isfile(tarball)):
                remove(tarball)
                print('Cleaning up...')

            sys.exit(1)

        # Don't move the archive if the destination directory is the cwd.
        if dest_dir != '.' and dest_dir != getcwd():
            try:
                move(archive, dest_dir)
            except OSError as e:
                print(e)
                sys.exit(1)

        print('\nCreated new archive ' + tarball + ' in ' + path.abspath(dest_dir) + '.')

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
            print('Archive ' + tarball + ' pushed to ' + dest_remote + ' on remote server.')

        print('Done!')

    except KeyboardInterrupt:
        # Control-C sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')

        # If aborted at input() then tmp_name would have already been removed so first check for its existence.
        if (path.isfile(tarball)):
            remove(tarball)
            print('Cleaning up...')

        sys.exit(1)

if __name__ == '__main__':
    #if len(sys.argv) == 1:
        #usage(0)
        #sys.exit(2)

    main(sys.argv[1:])
