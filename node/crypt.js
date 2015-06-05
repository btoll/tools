var gpg = require('gpg'),

    argv = require('yargs')
        .usage('Usage: $0 --encrypt file.txt -output file.txt.asc [ -d -r -s -h ]')

        .alias('e', 'encrypt')
        .nargs('e', 1)
        .describe('e', 'The file to encrypt')

        .alias('d', 'decrypt')
        .nargs('d', 1)
        .describe('d', 'The file to decrypt')

        .alias('o', 'output')
        .nargs('o', 1)
        .describe('o', 'The name of the new file')

        .alias('r', 'recipients')
        .nargs('r', [])
        .describe('r', 'A comma-separated string of recipients')

        .alias('s', 'sign')
        .nargs('s', 1)
        .describe('s', 'The user ID used to sign the encrypted file')

        .alias('h', 'help')
        .help('h')

        .demand(['e','o'])

        .example('$0 -e private.txt -o ~/secret.asc', 'Encrypt the file "private.txt" and store it in "secret.asc"')
        .example('$0 -d ~/private.txt -o /usr/local/www/public.html', 'Decrypt the file located at "~/private.txt" and store it in "/usr/local/www/public.html"')

        .epilog('Copyright 2015')
        .argv,

    gpghome = process.env.CRYPT_GNUPGHOME || '/Users/btoll/.gnupg',
    gpgbinary = process.env.CRYPT_GPGBINARY || 'gpg';

if (!argv.r) {
    argv.r = 'benjamy2@yahoo.com';
}

gpg.encryptToFile({
    source: argv.e,
    dest: argv.o,
    recipients: argv.r
}, function (err, data){
    console.log(err);
});

