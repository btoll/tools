import sys


def main():
    try:
        octet = sys.argv[1]

        if "." in octet:
            octet = octet.split(".")[0]

        bits = int(octet) >> 4

        if bits <= 7:
            print("Class A")
        elif bits >= 8 and bits <= 11:
            print("Class B")
        elif bits == 12 or bits == 13:
            print("Class C")
        elif bits == 14:
            print("Class D")
        elif bits == 15:
            print("Class E")
        else:
            print("Unknown Network Class")

    except IndexError:
        print("[ERROR] Missing argument")
    except ValueError:
        print("[ERROR] Argument must be of type `int`")


if __name__ == "__main__":
    main()

