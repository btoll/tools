asbits:
        gcc -g -o asbits asbits.c

clean:
        rm asbits

# https://www.gnu.org/software/make/manual/html_node/DESTDIR.html
install:
        mkdir -p $(DESTDIR)/usr/bin
        install -m 0755 asbits $(DESTDIR)/usr/bin/asbits

