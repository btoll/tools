import getpass
import os
import socket
import subprocess

def put(resource, hostname, username, port, destination):
    print('Pushing to server...')

    p = subprocess.Popen(['scp', '-P', port, resource, username + '@' + hostname + ':' + destination])
    sts = os.waitpid(p.pid, 0)

    print('Resource ' + resource + ' pushed to ' + destination + ' on host ' + hostname + '.')

# Prepare to push to server. Returns True if local, in which case print a nice message.
def prepare(resource, username=getpass.getuser(), port=22, destination='~'):
    isLocal = True
    hostname = socket.gethostname()

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

        resp = input('Remote filepath [' + destination + ']: ')
        if resp != '':
            destination = resp

        put(resource, hostname, username, port, destination)
        isLocal = False

    return isLocal

