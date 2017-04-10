/* eslint-disable no-console, no-multi-spaces, spaced-comment */

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

    // Insert `baseProto` between the first object and the ultimate base (Object.prototype or null).
    if (!proto[__BASE_PROTO__]) {
        Object.setPrototypeOf(
            getFirstPrototype(proto),
            baseProto
        );
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

        // TODO: Check to ensure super is a function?
        if (isFunction(fn) && !fn[__SUPER__]) {
            fn[__SUPER__] = proto[key];
        }
    }
};

// Walk the prototype chain to get the first prototype in 'userland' (the 'base proto' in the chain above).
const getFirstPrototype = proto => {
    if (isFirstPrototype(proto)) {
        return proto;
    }

    return getFirstPrototype(Object.getPrototypeOf(proto));
};

const isFirstPrototype = proto =>
    Object.getPrototypeOf(proto) === (Object.prototype || null);

const isFunction = fn =>
    Object.prototype.toString.call(fn) === '[object Function]';

module.exports = {
    __INIT__,
    create
};

