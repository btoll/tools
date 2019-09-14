let n = 9534236111;

let isNegative = n < 0;
n = Math.abs(n);

let d = 10 ** (Math.log10(n) >> 0);

const a = [];

do {
    console.log(n/d>>0);
    a.unshift(n/d>>0);
    n %= d;
    d /= 10;
} while (n > 0);

const reversed = a.join('') * 1;

console.log(
    isNegative ?
        -reversed :
        reversed
);

