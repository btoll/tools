// Simple message encoder using XOR.
//
//
// 'hello world'
// .split('')
// .map(s => s.charCodeAt() ^ symmetricKey)
// .map(s => String.fromCharCode(s ^ symmetricKey))
// .join('');

const sneak = {
  decrypt: (msg, symmetricKey) =>
      msg.split(' ')
          .map(c => String.fromCharCode(c ^ symmetricKey))
          .join(''),

  encrypt: (msg, symmetricKey) =>
      msg.split('')
          .map(c => c.charCodeAt() ^ symmetricKey)
          .join(' ')
};

const e = sneak.encrypt('the ides of march', 52354523);
process.stdout.write(`${e}\n\n`);

const d = sneak.decrypt(e, 52354523);
process.stdout.write(`${d}\n`);

