const BASE_PROTO = Symbol.for('BASE_PROTO');
const FUNC_NAME = Symbol.for('FUNC_NAME');
const INIT = Symbol.for('INIT');
const NEXT = Symbol.for('NEXT');

const baseProto = {
    [BASE_PROTO]: true,
    super: function () {
        const caller = this.super.caller;
        caller[NEXT][caller[FUNC_NAME]].call(this);
    }
};

const create = (...args) => {
    const [proto, ...rest] = args;
    const p = Object.create(proto);

    for (let i = 0, len = rest.length; i < len; i++) {
        Object.assign(p, rest[i]);
    }

    return p;
};

const delegate = (...args) => {
    let [proto, ...rest] = args;

    if (!proto[BASE_PROTO]) {
        Object.setPrototypeOf(
            getRootPrototype(proto),
            baseProto
        );
    } else {
        // TODO: Check this!
        proto = Object.create(proto);
    }

    for (let i = 0, len = rest.length; i < len; i++) {
        enableChaining(rest[i], proto);
        Object.assign(proto, rest[i]);
    }


    if (proto[INIT]) {
        proto[INIT].apply(proto, rest);
    }

    return proto;
};

const enableChaining = (previous, next) => {
    const keys = Object.getOwnPropertySymbols(previous).concat(Object.keys(previous));

    for (let key of keys) {
        const fn = previous[key];

        if (isFunction(fn)) {
            fn[FUNC_NAME] = key;
            fn[NEXT] = next;
        }
    }
};

const getRootPrototype = previous => {
    if (isRootPrototype(previous)) {
        return previous;
    }

    let next = Object.getPrototypeOf(previous);
    enableChaining(previous, next);

    return getRootPrototype(next);
};

const isFunction = fn =>
    Object.prototype.toString.call(fn) === '[object Function]';

const isRootPrototype = proto =>
    Object.getPrototypeOf(proto) === (Object.prototype || null);

const p = create({
    foo() {
        console.log('base foo');
    },
}, {
    getUid: () => Math.random(),
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
    foo() {
        console.log('delegates to base foo');
        this.super();
    },
    bar() {
        console.log('delegates to base bar');
        this.super();
    }
});

const j = delegate(k, {
    [INIT]() {
        console.log('init!');
        this.getUid();
    },
    yobe: false
});

k.bar();
k.foo();
j.foo();
console.log(k.hasOwnProperty('yobe') === true);
console.log(j.hasOwnProperty('yobe') === true);

