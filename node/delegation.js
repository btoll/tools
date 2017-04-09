/* eslint-disable no-console, no-constant-condition, no-multi-spaces, spaced-comment */

// Other objects relative to { my object }
//
//
//       Object.prototype / null
//                 |
//                 |
//             base proto
//                 |
//                 |
//             prev proto
//                 |
//                 |
//            { my object }
//                 |
//                 |
//             next proto
//                 |
//                 |
//                \_/
//
//

const __BASE_PROTO__ = Symbol.for('__BASE_PROTO__');
const __INIT__       = Symbol.for('__INIT__');
const __SUPER__      = Symbol.for('__SUPER__');

//////////////////////////////////////////////////////////////
//  Helpers.
//////////////////////////////////////////////////////////////

// TODO: This should just do one thing!
// Walk the prototype chain.
const getRootPrototype = proto => {
    if (isRootPrototype(proto)) {
        return proto;
    }

    let prevProto = Object.getPrototypeOf(proto);
    enableSuper(proto, prevProto);

    return getRootPrototype(prevProto);
};

const increment = (() => {
    let i = 0;

    return function* () {
        while (true) {
            yield i++;
        }
    };
})();

const isFunction = fn =>
    Object.prototype.toString.call(fn) === '[object Function]';

const isRootPrototype = proto =>
    Object.getPrototypeOf(proto) === (Object.prototype || null);

//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////

const baseProto = {
    [__BASE_PROTO__]: true,
    super: function () {
        try {
            const caller = this.super.caller;
            caller[__SUPER__].apply(this, arguments);
        } catch (e) {
            throw new Error('[ERROR] No super. Sad!');
        }
    }
};

const create = (proto, /* optional */ fns) => {
    const p = Object.create(proto);

    // TODO: This SHOULD only walk the prototype chain, assigning super abilities, if not already done!
    if (!proto[__BASE_PROTO__]) {
        Object.setPrototypeOf(
            getRootPrototype(proto),
            baseProto
        );
    } else {
        // TODO: Check this!
        proto = Object.create(proto);
    }

    // Since delegate accepts an optional 2nd arg of objects to be mixed in, we have to assign super to them, as well.
    if (fns) {
        enableSuper(fns, proto);
        Object.assign(p, fns);
    }

    if (p[__INIT__]) {
        p[__INIT__].apply(p);
    }

    return p;
};

const enableSuper = (obj, proto) => {
    // Symbols like __INIT__ may want to call super, too.
    const keys = Object.getOwnPropertySymbols(obj).concat(Object.keys(obj));

    for (let key of keys) {
        const fn = obj[key];

        // Every function gets `super` ability.
        // TODO: Don't process the same function twice!
        // TODO: Check to ensure super is a function?
        if (isFunction(fn)) {
            fn[__SUPER__] = proto[key];
        }
    }
};

//////////////////////////////////////////////////////////////
//  Examples.
//////////////////////////////////////////////////////////////

const p = create({
    // Use Symbol expression as the key for `init` to ensure we don't overwrite any existing property.
    [__INIT__]() {
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

const k = create(p, {
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
    [__INIT__]() {
        console.log('init k!');
        console.log('hi molly');
        console.log(this.getUid());
        this.super();
    },
    yobe: false
});

const j = create(k, {
    [__INIT__]() {
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

