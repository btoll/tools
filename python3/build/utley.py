import css_compress
import getopt
import js_compress
import json
import sys
import textwrap

def usage():
    str = '''
        USAGE:

        # Build all targets (assumes an utley.json build file).
        python3 utley.py

        # Specify a different build file.
        python3 utley.py --config=foo.json

        # Build only the CSS.
        python3 utley.py --css

        # Build only the JavaScript.
        python3 utley.py --js

        --config, -c  The location of the build file. Defaults to 'utley.json'.
        --css         Build the CSS only.
        --js          Build the JavaScript only.
    '''
    print(textwrap.dedent(str))

def main(argv):
    buildCss = False
    buildJs = False
    configFile = 'utley.json'
    css = []
    js = []

    # If there are no given arguments, assume an utley.json file and both build targets.
    if len(argv) == 0:
        css, js = getJson()
    else:
        try:
            opts, args = getopt.getopt(argv, 'hc:', ['help', 'config=', 'css', 'js'])
        except getopt.GetoptError:
            print('Error: Unrecognized flag.')
            usage()
            sys.exit(2)

        for opt, arg in opts:
            if opt in ('-h', '--help'):
                usage()
                sys.exit(0)
            elif opt in ('-c', '--config'):
                configFile = arg
            elif opt == '--css':
                buildCss = True
            elif opt == '--js':
                buildJs = True

        css, js = getJson(configFile, buildCss, buildJs)

    build(js, css)

def build(js=[], css=[]):
    for c in css:
        src = c.get('src')
        output = c.get('output')
        dest = c.get('dest', '.')
        version = c.get('version', '')
        dependencies = c.get('dependencies', [])
        exclude = c.get('exclude', [])

        css_compress.compress(src, output, dest, version, dependencies, exclude)

    for c in js:
        src = c.get('src')
        output = c.get('output')
        dest = c.get('dest', '.')
        version = c.get('version', '')
        dependencies = c.get('dependencies', [])
        exclude = c.get('exclude', [])

        js_compress.compress(src, output, dest, version, dependencies, exclude)

def getJson(resource='utley.json', css=True, js=True):
    try:
        # TODO: Is there a better way to get the values from the Json?
        with open(resource, mode='r', encoding='utf-8') as f:
            jsonData = json.loads(f.read())

        if css and js:
            return (jsonData.get('css'), jsonData.get('js'))
        elif css and not js:
            return (jsonData.get('css'), [])
        elif not css and js:
            return ([], jsonData.get('js'))

    # Exceptions could be bad Json or file not found.
    except (ValueError, FileNotFoundError) as e:
        print(e)
        sys.exit(1)

if __name__ == '__main__':
#    if len(sys.argv) == 1:
#        usage()
#        sys.exit(2)

    main(sys.argv[1:])

