/* eslint-disable no-console, no-constant-condition */

const d = require('./delegation');

const incr = (() => {
    let i = 0;

    return ({
        [Symbol.iterator]: () => ({
            next: () => ({
                done: false,
                value: i++
            })
        })
    });
})();

const increment = function* () {
    while (true) {
        yield* incr;
    }
};

const p = d.create({
    // Use Symbol expression as the key for `init` to ensure we don't overwrite any existing property.
    [d.__INIT__]() {
        console.log('init p!');
        console.log('hi pepper');
        console.log(this.getUid());
    },
    foo() {
        console.log('base foo');
    }
}, {
    getUid: (() => {
        // Start the generator.
        const i = increment();
        return () => i.next().value;
    })(),
    foo() {
        console.log('middle foo');
        this.super();
    },
    bar() {
        this.yobe = true;
        console.log('base bar');
    }
});

const k = d.create(p, {
    foo(msg) {
        if (msg) {
            console.log(msg);
        }

        console.log('delegates to base foo');
        this.super();
    },
    bar() {
        console.log('delegates to base bar');
        this.super();
    },
    [d.__INIT__]() {
        console.log('init k!');
        console.log('hi molly');
        console.log(this.getUid());
        this.super();
    },
    yobe: false
});

const j = d.create(k, {
    [d.__INIT__]() {
        console.log('init!');
        console.log('hi all doggies');
        console.log(this.getUid());
        this.super();
    },
    yobe: false,
    foo() {
        console.log('i am foo!!');
        this.super('i come from an object upstream from the callee!');
    }
});

k.bar();
k.foo();
j.foo();
console.log(k.hasOwnProperty('yobe') === true);
console.log(j.hasOwnProperty('yobe') === true);

