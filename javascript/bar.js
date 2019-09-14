let n = 987654321;

let isNegative = n < 0;
n = Math.abs(n);

let d = 10 ** (Math.log10(n) >> 0);

const a = [];

do {
    a.push(n % 10);
    n = n / 10 >> 0;
} while (n >= 1);

console.log(a.join('') * 1);

//console.log(
//    isNegative ?
//        -reversed :
//        reversed
//);

