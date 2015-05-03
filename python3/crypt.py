import getopt
import getpass
import gnupg
import json
import server
import socket
import sys
import textwrap

def usage():
    str = '''\
        Usage:
        Optional flags:
            -c, -config, --config           A config file that the script will read to get remote system information. Session will be non-interactive.
                                            Useful for automation.
            -d, -decrypt, --decrypt         Signals the specified operation should be decryption rather than the default encryption.
            -f, -file, --file               The file on which to operate.
            -r, -recipients, --recipients   A comma-separated string of recipients.
            -s, -sign, --sign               The user ID with which to sign the encrypted file.
            -h, -help, --help               Help.
    '''

    print(textwrap.dedent(str))

def main(argv):
    json = False
    decrypt = False
    filename = ''
    recipients = None
    sign = None

    try:
        opts, args = getopt.getopt(argv, 'hdc:f:r:s:', ['help', 'decrypt', 'config=', 'file=', 'recipients=', 'sign='])
    except getopt.GetoptError:
        print('Error: Unrecognized function argument.')
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '-help', '--help'):
            usage()
            sys.exit(0)
        elif opt in ('-d', '-decrypt', '--decrypt'):
            decrypt = True
        elif opt in ('-f', '-file', '--file'):
            filename = arg
        elif opt in ('-r', '-recipients', '--recipients'):
            recipients = arg
        elif opt in ('-s', '-sign', '--sign'):
            sign = arg
        elif opt in ('-c', '-config', '--config'):
            json = arg

    if (filename):
        if not decrypt:
            encrypt_file(filename, recipients=recipients, sign=sign, json=json)
        else:
            decrypt_file(filename)
    else:
        print('Error: You must specify a file.')
        sys.exit(1)

def encrypt_file(filename, **kwargs):
    recipients = kwargs.get('recipients')
    if not recipients:
        recipients = 'benjam72@yahoo.com'

    sign = kwargs.get('sign')
    if not sign:
        sign = 'benjam72@yahoo.com'

    json = kwargs.get('json')

    gpg = _setup()
    stream = _stream(filename)

    passphrase = _get_passphrase()
    encrypted = gpg.encrypt_file(stream, [recipients], sign=sign, passphrase=passphrase, output=filename + '.asc')

    if encrypted.ok:
        destination = '~'
        hostname = socket.gethostname()
        port = '80'
        username = getpass.getuser()

        print('File encryption successful.')

        if json:
            try:
                # This can read 'username hostname port'.
                # username, hostname, port = open(arg, encoding='utf-8').readline().split()

                # TODO: Is there a better way to get the values from the Json?
                with open(json, mode='r', encoding='utf-8') as f:
                    json_data = json.loads(f.read())

                username = json_data.get('username')
                hostname = json_data.get('hostname')
                port = str(json_data.get('port'))

            # Exceptions could be bad Json or file not found.
            except (ValueError, FileNotFoundError) as e:
                print(e)
                sys.exit(1)

            server.put(archive, hostname, username, port, destination)
        else:
            resp = input('Push to remote server? [y|N]: ')

            if resp in ['Y', 'y']:
                port = 80

                resp = input('Username [' + username + ']: ')
                if resp != '':
                    username = resp

                resp = input('Port [' + port + ']: ')
                if resp != '':
                    port = resp

                resp = input('Hostname [' + hostname + ']: ')
                if resp != '':
                    hostname = resp

                resp = input('Remote filepath [' + destination + ']: ')
                if resp != '':
                    destination = resp

                server.put(archive, hostname, username, port, destination)

        sys.exit(0)
    else:
        print('Error: ' + encrypted.stderr)
        sys.exit(1)

def decrypt_file(filename):
    gpg = _setup()
    stream = _stream(filename)

    passphrase = _get_passphrase()
    decrypted = gpg.decrypt_file(stream, passphrase=passphrase)

    if decrypted.ok:
        print('File decryption successful.')
        sys.exit(0)
    else:
        print('Error: ' + decrypted.stderr)
        sys.exit(1)

def _get_passphrase():
    try:
        return getpass.getpass('Please enter your passphrase: ')

    except KeyboardInterrupt:
        # Control-C sent a SIGINT to the process, handle it.
        print('\nProcess aborted!')
        sys.exit(1)

def _setup():
    return gnupg.GPG(gnupghome='/Users/btoll/.gnupg', gpgbinary='gpg')

def _stream(filename):
    return open(filename, 'rb');

if __name__ == '__main__':
    if (len(sys.argv) > 1):
        main(sys.argv[1:])
    else:
        usage()
        sys.exit(0)

