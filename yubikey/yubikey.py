def yubikey():
    yubikey = input("Touch YubiKey: ")

    print("YubiKey encoded string", yubikey)
    print("YubiKey ID", yubikey[:12])
    print("YubiKey OTP", yubikey[12:])


if __name__ == "__main__":
    yubikey()
