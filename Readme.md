Gcc Toolchains
========================================

Support platforms
----------------------------------------

a. arm_arm-eabi (for Linux kernel)
b. arm_arm-linux-gnueabi (for C applications with glibc)

Building arm-eabi-*
----------------------------------------

```
$ . build/envsetup.sh
$ lunch 1
$ make install -j8
```

Building arm-linux-gnueabi-*
----------------------------------------

### Building glibc

```
$ . build/envsetup.sh
$ lunch 2
$ make install-target-minimal-gcc -j[num]
$ make install-target-minimal-libgcc -j[num]
$ make install-target-glibc -j[num]
```

### Modify libc.so and libpthread.so

path: $(sysroot)/usr/lib/libc.so

```
/* GNU ld script
   Use the shared library, but some functions are only in
   the static library, so try that secondarily.  */
OUTPUT_FORMAT(elf32-littlearm)
GROUP ( /usr/lib/libc.so.6 /usr/lib/libc_nonshared.a  AS_NEEDED ( /usr/lib/ld-linux.so.3 ) )
```

path: $(sysroot)/usr/lib/libpthread.so

```
/* GNU ld script
   Use the shared library, but some functions are only in
   the static library, so try that secondarily.  */
OUTPUT_FORMAT(elf32-littlearm)
GROUP ( /usr/lib/libpthread.so.0 /usr/lib/libpthread_nonshared.a )
```

### Building toolchains

```
$ make install -j[num]
```

Dependencies:
----------------------------------------

```
$ sudo apt-get install makeinfo
$ sudo apt-get install texinfo
```

Packages Url:
----------------------------------------

* gcc:                 ftp://ftp.gnu.org/gnu/gcc/
* gdb:                 ftp://ftp.gnu.org/gnu/gdb/
* glibc:               ftp://ftp.gnu.org/gnu/glibc/
* glibc-linuxthreads:  ftp://ftp.gnu.org/gnu/glibc/
* kernel:              ftp://ftp.kernel.org/pub/linux/kernel/
* binutils:            ftp://ftp.gnu.org/gnu/binutils/
* gmp:                 ftp://ftp.gnu.org/gnu/gmp/
* mpc:                 http://www.multiprecision.org/mpc
* mpfr:                http://ftp.gnu.org/gnu/mpfr/
* isl:                 http://isl.gforge.inria.fr/
* cloog:               http://www.cloog.org/
* ppl:                 http://bugseng.com/products/ppl/download
* expat:               http://sourceforge.net/projects/expat/files/latest/download
* ccache:              https://ccache.samba.org/download.html
