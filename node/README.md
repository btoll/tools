# delegate

## Examples

```
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

const base = d.create({
    // Use Symbol expression as the key for `init` to ensure we don't overwrite any existing property.
    [d.__INIT__]() {
        console.log('init p!');
        console.log(this.getUid());
    },
    foo() {
        console.log('base foo');
    },
    getUid: (() => {
        // Start the generator.
        const i = increment();
        return () => i.next().value;
    })()
});

const j = d.create(base, {
    foo(msg) {
        if (msg) {
            console.log(msg);
        }

        console.log('calls to base foo');
        this.super();
    },
    bar() {
        console.log('calls to base bar');
        this.super();
    }
});

const k = d.create(j, {
    foo() {
        console.log('i am foo!!');
        this.super('i come from an object upstream from the callee!');
    }
});
```

## License

[GPLv3](COPYING)

## Author

Benjamin Toll

