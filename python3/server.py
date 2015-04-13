import subprocess

def put(resource, hostname, username, port, dest_remote):
    print('Pushing to server...')

    #p = subprocess.Popen(['scp', '-P', port, dest_dir + '/' + resource, username + '@' + hostname + ':' + dest_remote])
    p = subprocess.Popen(['scp', '-P', port, resource, username + '@' + hostname + ':' + dest_remote])
    sts = os.waitpid(p.pid, 0)

    print('Resource ' + resource + ' pushed to ' + dest_remote + ' on host ' + hostname + '.')

