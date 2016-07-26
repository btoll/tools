// Simple message encoder using XOR.
//
//
// 'hello world'
// .split('')
// .map(s => s.charCodeAt() ^ symmetricKey)
// .map(s => String.fromCharCode(s ^ symmetricKey))
// .join('');

'use strict';
let secret;

module.exports = {
    decode: (msg, symmetricKey) =>
        (
          secret = new Buffer(msg, 'base64').toString('utf8'),

          secret.split(' ')
              .map(c => String.fromCharCode(c ^ symmetricKey))
              .join('')
        ),

    encode: (msg, symmetricKey) =>
        (
            secret = msg.split('')
                .map(c => c.charCodeAt() ^ symmetricKey)
                .join(' '),

            new Buffer(secret, 'utf8').toString('base64')
        )
};

