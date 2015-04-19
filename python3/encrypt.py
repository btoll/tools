import getopt, getpass, gnupg, json, server, sys

def usage():
        print('''Usage:

Optional flags:
    -c, -config, --config           A config file that the script will read to get remote system information. Session will be non-interactive.
                                    Useful for automation.
    -f, -file, --file               The file to encrypt.
    -n, -name, --name               An optional archive name. The default is YYYYMMDDHHMMSS.
    -r, -recipients, --recipients   A comma-separated string of recipients.
    -h, -help, --help               Help.''')

def main(argv):
    filename = '';

    try:
        opts, args = getopt.getopt(argv, 'hc:f:n:r:', ['help', 'config=', 'file=', 'name=', 'recipients='])
    except getopt.GetoptError:
        print('Something bad happened.')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '-help', '--help'):
            usage()
            sys.exit(0)
        elif opt in ('-f', '-file', '--file'):
            filename = arg
        elif opt in ('-n', '-name', '--name'):
            tmp_name = arg
        elif opt in ('-r', '-recipients', '--recipients'):
            recipients = arg
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

    if (filename):
        encrypt_file(filename, recipients)

def encrypt_file(filename, recipients='benjam72@yahoo.com', sign='benjam72@yahoo.com'):
    gpg = gnupg.GPG(gnupghome='/Users/btoll/.gnupg', gpgbinary='gpg')
    stream = open(filename, 'rb');

    try:
        passphrase = getpass.getpass('Please enter your passphrase: ')

    except KeyboardInterrupt:
        # Control-C sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')
        sys.exit(1)

    encrypted = gpg.encrypt_file(stream, [recipients], sign=sign, passphrase=passphrase, output=filename + '.asc')

    if encrypted.ok:
        print('File encryption successful.')
        sys.exit(0)
    else:
        print('There was a problem!: ' + encrypted.stderr)
        sys.exit(1)

def decrypt_file(filename):
    gpg = gnupg.GPG(gnupghome='/Users/btoll/.gnupg', gpgbinary='gpg')
    stream = open(filename, 'rb');

    try:
        passphrase = getpass.getpass('Please enter your passphrase: ')

    except KeyboardInterrupt:
        # Control-C sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')
        sys.exit(1)

    decrypted = gpg.decrypt_file(encrypted_string, passphrase=passphrase)

    if decrypted.ok:
        print('File encryption successful.')
        sys.exit(0)
    else:
        print('There was a problem!: ' + decrypted.stderr)
        sys.exit(1)

if __name__ == '__main__':
    if (len(sys.argv) > 1):
        main(sys.argv[1:])
    else:
        usage()
        sys.exit(0)

