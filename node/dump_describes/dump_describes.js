'use strict';

let esprima = require('esprima'),
    fs = require('fs'),
    results = new Map();

function visit(object, fn, results) {
    results = fn.call(null, object, results);

    for (let n in object) {
        if (object.hasOwnProperty(n)) {
            let obj = object[n];

            if (typeof obj === 'object' && obj !== null) {
                visit(obj, fn, results);
            }
        }
    }

    return results;
}

function collect(node, results) {
    let type = node.type;

    if (type === 'ExpressionStatement') {
        let expression = node.expression;

        if (expression.type === 'CallExpression' && expression.callee.type === 'Identifier' && expression.callee.name === 'describe') {
            if (expression.arguments[0].type === 'Literal') {
                results.set(expression.arguments[0].value, new Map());
                results = visit(expression.arguments[1].body, collect, results.get(expression.arguments[0].value));
            } else {
                // TODO: It's a WrappingNode.
                // get results...
            }
        }
    }

    return results;
}

fs.readFile(process.argv[2], 'utf8', function (err, fileContents) {
    if (err) {
        throw err;
    }

    console.dir(visit(esprima.parse(fileContents), collect, results));
});

