import getopt, getpass, json, os, re, shutil, server, socket, sys, time

# Define some variables.
archive = ''
dry_run = False
src_dir = '.'
root_dir = '.'
silent = False
pattern = '^.*$'
today = time.localtime()
dest_dir = tmp_name = str(today.tm_year) + str(today.tm_mon) + str(today.tm_mday) + str(today.tm_hour) + str(today.tm_min) + str(today.tm_sec)
port = '22'
dest_remote = '~'
hostname = socket.gethostname()
username = getpass.getuser()
format = 'gztar'
formats = {
    'gztar': '.tar.gz',
    'bztar': '.tar.bz2',
    'tar': '.tar',
    'zip': '.zip'
}

def usage(level):
#    if level == 0:
#        print('Usage: python3 tar_jslite.py [-h | --help [[-n | --name] [-s | --src] [-d | --dest] [-r | --root] [-c | --config] [--silent]]]\nTry `python3 barchiver.py --help` for more information.')
#
#    elif level == 1:
     if level == 1:
        print('''Usage:

Optional flags:
    -c, -config, --config      A config file that the script will read to get remote system information. Session will be non-interactive. Useful for automation.
    -d, -dest, --dest          The location of where the assets should be archived. Defaults to YYYYMMDDHHMMSS.
    -l, --dry-run              Do a dry run.
    -n, -name, --name          An optional archive name. The default is YYYYMMDDHHMMSS.
    -p, -pattern, --pattern
    -r, -root, --root          The directory that will be the root directory of the archive. For example, we typically chdir into root_dir before creating the archive. Defaults to '.'
    -s, -src, --src            The location of the assets to archive. Defaults to cwd.
    -h, -help, --help          Help.''')

def main(argv):
    global dry_run, format, hostname, pattern, port, username

    try:
        opts, args = getopt.getopt(argv, 'hln:p:s:d:r:c:', ['help', 'dry-run', 'silent', 'name=', 'pattern=', 'src=', 'dest=', 'root=', 'config='])
    except getopt.GetoptError:
        usage(0)
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '-help', '--help'):
            usage(1)
            sys.exit(0)
        elif opt in ('-l', '--dry-run'):
            dry_run = True
        elif opt in ('-n', '-name', '--name'):
            tmp_name = arg
        elif opt in ('-s', '-src', '--src'):
            src_dir = arg
        elif opt in ('-d', '-dest', '--dest'):
            dest_dir = arg
        elif opt in ('-p', '-pattern', '--pattern'):
            pattern = arg
        elif opt in ('-r', '-root', '--root'):
            root_dir = arg
        elif opt in ('-c', '-config', '--config'):
            try:
                # This can read 'username hostname port'.
                # username, hostname, port = open(arg, encoding='utf-8').readline().split()

                # TODO: Is there a better way to get the values from the Json?
                with open(arg, mode='r', encoding='utf-8') as f:
                    json_data = json.loads(f.read())

                username = json_data.get('username')
                hostname = json_data.get('hostname')
                port = str(json_data.get('port'))
                format = json_data.get('format')

                silent = True

            # Exceptions could be bad Json or file not found.
            except (ValueError, FileNotFoundError) as e:
                print(e)
                sys.exit(1)

    try:
        if not silent:
            resp = input('''Choose an archive format:
    0 = tar.bz2
    1 = tar.gz
    2 = zip
    3 = tar
    ? [0]: ''')
            if resp in ['1', '2', '3']:
                if resp == '1':
                    format = 'gztar'

                if resp == '2':
                    format = 'zip'

                if resp == '3':
                    format = 'tar'
            else:
                format = 'bztar'

            try:
                create_archive()
            except FileNotFoundError as e:
                print(e)

                if (os.path.isfile(archive)):
                    os.remove(archive)
                    print('Cleaning up...')

            if not dry_run:
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

                    server.put(archive, hostname, username, port, dest_remote)

        else:
            # Non-interactive session.
            create_archive()

            if not dry_run:
                server.put(archive, hostname, username, port, dest_remote)

        if not dry_run:
            print('Done!')

    except (KeyboardInterrupt, EOFError):
        # Control-C or Control-D sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')

        # If aborted at input() then tmp_name would have already been removed so first check for its existence.
        if (os.path.isfile(archive)):
            os.remove(archive)
            print('Cleaning up...')

        sys.exit(1)

def create_archive():
    global archive

    # Create the destination directory if it doesn't exist.
    if not dry_run:
        if not os.path.exists(dest_dir):
            os.makedirs(dest_dir)

        #[shutil.move(f, dest_dir) for f in next(os.walk(src_dir))[1] + next(os.walk(src_dir))[2] if re.match(pattern, f)]
        [shutil.move(f, dest_dir) for f in os.listdir(src_dir) if re.match(pattern, f)]
        shutil.make_archive(tmp_name, format, root_dir, src_dir)

        # This is the archive file name, i.e., "2015323153949.tar.bz2"
        archive = tmp_name + formats[format]

        print('Created new archive in ' + os.path.abspath(archive))

    else:
        files = [f for f in os.listdir(src_dir) if re.match(pattern, f)]
        print('The following files/directories will be archived:\n')
        print(files)

if __name__ == '__main__':
    #if len(sys.argv) == 1:
        #usage(0)
        #sys.exit(2)

    main(sys.argv[1:])

