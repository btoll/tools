import css_compress
import getopt
import js_compress
import json
import sys
import textwrap

def usage():
    str = '''
        USAGE:

            CLI:
                python3 build.py --config foo.json

            As an imported module:
                css_compress.compress(src[, output='min.css', dest='.', 'version='', --dependencies='', --exclude=''])

        --config, -config, -c  The location of the build file.
    '''
    print(textwrap.dedent(str))

def main(argv):
    css = []
    js = []

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
            try:
                # TODO: Is there a better way to get the values from the Json?
                with open(arg, mode='r', encoding='utf-8') as f:
                    json_data = json.loads(f.read())

                css = json_data.get('css')
                js = json_data.get('js')
#                src = json_data.get('src')
#                output = json_data.get('output')
#                version = str(json_data.get('version'))
#                exclude = json_data.get('exclude')

            # Exceptions could be bad Json or file not found.
            except (ValueError, FileNotFoundError) as e:
                print(e)
                sys.exit(1)

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

if __name__ == '__main__':
    if len(sys.argv) == 1:
        usage()
        sys.exit(2)

    main(sys.argv[1:])

