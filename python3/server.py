import subprocess

def push_to_server(archive, hostname, username, port, dest_remote):
    print('Pushing to server...')

    #p = subprocess.Popen(['scp', '-P', port, dest_dir + '/' + archive, username + '@' + hostname + ':' + dest_remote])
    p = subprocess.Popen(['scp', '-P', port, archive, username + '@' + hostname + ':' + dest_remote])
    sts = os.waitpid(p.pid, 0)

    print('Archive ' + archive + ' pushed to ' + dest_remote + ' on host ' + hostname + '.')

