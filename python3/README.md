### barchiver Python script
Must have at least Python 3.2

- Supports archive formats gzip, bzip2, tar and zip.
- Supports pushing archive to a remote server.
- Supports pointing script at a config file for the remote server params.

Example usage:

    barchiver --name my_archive_20131225 --src . --dest /usr/local/www/dotfiles
    barchiver --name motley --config ~/.barchiver/benjamintoll.com

For example, the file ~/.barchiver/benjamintoll.com in the example above could look like this:

    {
        "hostname": "benjamintoll.com",
        "username": "benjamin",
        "port": 2009,
        "format": "bztar"
    }

Usage:

    Property | Description
    ------------ | ------------
    -n, --name | An optional archive name. The default is YYYYMMDDHHMMSS.
    -s, --src | The location of the assets to archive. Defaults to cwd.
    -d, --dest | The location of where the assets should be archived. Defaults to cwd.
    -r, --root | The directory that will be the root directory of the archive. For example, we typically chdir into root_dir before creating the archive. Defaults to cwd.
    -c, --config | A config file that the script will read to get remote system information. Session will be non-interactive. Useful for automation.
    -h, --help | Help.

