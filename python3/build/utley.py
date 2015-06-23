import css_compress
import getopt
import js_compress
import json
import sys
import textwrap

def usage():
    str = '''
        USAGE:

        python3 utley.py --config foo.json

        --config, -config, -c  The location of the build file.
    '''
    print(textwrap.dedent(str))

def getJson(resource='build.json'):
    try:
        # TODO: Is there a better way to get the values from the Json?
        with open(resource, mode='r', encoding='utf-8') as f:
            jsonData = json.loads(f.read())

        return (jsonData.get('css'), jsonData.get('js'))

    # Exceptions could be bad Json or file not found.
    except (ValueError, FileNotFoundError) as e:
        print(e)
        sys.exit(1)

def main(argv):
    css = []
    js = []

    # If there are no given arguments, assume a build.json file.
    if len(argv) == 0:
        css, js = getJson()

    try:
        opts, args = getopt.getopt(argv, 'h:c:', ['help', 'config'])
    except getopt.GetoptError:
        print('Error: Unrecognized flag.')
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            usage()
            sys.exit(0)
        elif opt in ('-c', '-config', '--config'):
            css, js = getJson(arg)

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

if __name__ == '__main__':
#    if len(sys.argv) == 1:
#        usage()
#        sys.exit(2)

    main(sys.argv[1:])

