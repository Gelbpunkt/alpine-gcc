# Maintainer: Natanael Copa <ncopa@alpinelinux.org>
pkgname=gcc
pkgver=11.0.1
[ "$BOOTSTRAP" = "nolibc" ] && pkgname="gcc-pass2"
[ "$CBUILD" != "$CHOST" ] && _cross="-$CARCH" || _cross=""
[ "$CHOST" != "$CTARGET" ] && _target="-$CTARGET_ARCH" || _target=""

pkgname="$pkgname$_target"
pkgrel=8
pkgdesc="The GNU Compiler Collection"
url="https://gcc.gnu.org"
arch="all"
license="GPL-2.0-or-later LGPL-2.1-or-later"
_gccrel=$pkgver-r$pkgrel
depends="binutils$_target isl"
makedepends_build="gcc$_cross g++$_cross paxmark bison flex texinfo gawk zip gmp-dev mpfr-dev mpc1-dev zlib-dev"
makedepends_host="linux-headers gmp-dev mpfr-dev mpc1-dev isl-dev zlib-dev !gettext-dev"
subpackages=" "
[ "$CHOST" = "$CTARGET" ] && subpackages="gcc-doc$_target"
replaces="libstdc++ binutils"

: "${LANG_CXX:=true}"
: "${LANG_D:=true}"
: "${LANG_OBJC:=true}"
: "${LANG_GO:=true}"
: "${LANG_FORTRAN:=true}"
: "${LANG_ADA:=false}"

_libgomp=true
_libgcc=true
_libatomic=true
_libitm=true

if [ "$CHOST" != "$CTARGET" ]; then
	if [ "$BOOTSTRAP" = nolibc ]; then
		LANG_CXX=false
		LANG_ADA=false
		_libgcc=false
		_builddir="$srcdir/build-cross-pass2"
	else
		_builddir="$srcdir/build-cross-final"
	fi
	LANG_OBJC=false
	LANG_GO=false
	LANG_FORTRAN=false
	LANG_D=false
	_libgomp=false
	_libatomic=false
	_libitm=false

	# reset target flags (should be set in crosscreate abuild)
	# fixup flags. seems gcc treats CPPFLAGS as global without
	# _FOR_xxx variants. wrap it in CFLAGS and CXXFLAGS.
	export CFLAGS="$CPPFLAGS $CFLAGS"
	export CXXFLAGS="$CPPFLAGS $CXXFLAGS"
	unset CPPFLAGS
	export CFLAGS_FOR_TARGET=" "
	export CXXFLAGS_FOR_TARGET=" "
	export LDFLAGS_FOR_TARGET=" "

	STRIP_FOR_TARGET="$CTARGET-strip"
elif [ "$CBUILD" != "$CHOST" ]; then
	# fixup flags. seems gcc treats CPPFLAGS as global without
	# _FOR_xxx variants. wrap it in CFLAGS and CXXFLAGS.
	export CFLAGS="$CPPFLAGS $CFLAGS"
	export CXXFLAGS="$CPPFLAGS $CXXFLAGS"
	unset CPPFLAGS

	# reset flags and cc for build
	export CC_FOR_BUILD="gcc"
	export CXX_FOR_BUILD="g++"
	export CFLAGS_FOR_BUILD=" "
	export CXXFLAGS_FOR_BUILD=" "
	export LDFLAGS_FOR_BUILD=" "
	export CFLAGS_FOR_TARGET=" "
	export CXXFLAGS_FOR_TARGET=" "
	export LDFLAGS_FOR_TARGET=" "

	# Languages that do not need bootstrapping
	LANG_OBJC=false
	LANG_GO=false
	LANG_FORTRAN=false
	LANG_D=false

	STRIP_FOR_TARGET=${CROSS_COMPILE}strip
	_builddir="$srcdir/build-cross-native"
else
	STRIP_FOR_TARGET=${CROSS_COMPILE}strip
	_builddir="$srcdir/build"
fi

# GDC hasn't been ported to PowerPC
# See libphobos/configure.tgt in GCC sources for supported targets
[ "$CARCH" = ppc64le ] && LANG_D=false

# Go needs {set,make,swap}context, unimplemented in musl
[ "$CTARGET_LIBC" = musl ] && LANG_GO=false

# libitm has TEXTRELs in ARM build, so disable for now
case "$CTARGET_ARCH" in
arm*)		_libitm=false ;;
mips*)		_libitm=false ;;
esac

# Fortran uses libquadmath if toolchain has __float128
# currently on x86, x86_64 and ia64
_libquadmath=$LANG_FORTRAN
case "$CTARGET_ARCH" in
x86 | x86_64)	_libquadmath=$LANG_FORTRAN ;;
*)		_libquadmath=false ;;
esac

# libatomic is a dependency for openvswitch
$_libatomic && subpackages="$subpackages libatomic::$CTARGET_ARCH"
$_libgcc && subpackages="$subpackages libgcc::$CTARGET_ARCH"
$_libquadmath && subpackages="$subpackages libquadmath::$CTARGET_ARCH"
if $_libgomp; then
	depends="$depends libgomp=$_gccrel"
	subpackages="$subpackages libgomp::$CTARGET_ARCH"
fi

_languages=c
if $LANG_CXX; then
	subpackages="$subpackages libstdc++:libcxx:$CTARGET_ARCH g++$_target:gpp"
	_languages="$_languages,c++"
fi
if $LANG_D; then
	subpackages="$subpackages libgphobos::$CTARGET_ARCH gcc-gdc$_target:gdc"
	_languages="$_languages,d"
	makedepends_build="$makedepends_build libucontext-dev"
fi
if $LANG_OBJC; then
	subpackages="$subpackages libobjc::$CTARGET_ARCH gcc-objc$_target:objc"
	_languages="$_languages,objc"
fi
if $LANG_GO; then
	subpackages="$subpackages libgo::$CTARGET_ARCH gcc-go$_target:go"
	_languages="$_languages,go"
fi
if $LANG_FORTRAN; then
	subpackages="$subpackages libgfortran::$CTARGET_ARCH gfortran$_target:gfortran"
	_languages="$_languages,fortran"
fi
if $LANG_ADA; then
	subpackages="$subpackages libgnat::$CTARGET_ARCH gcc-gnat$_target:gnat"
	_languages="$_languages,ada"
	[ "$CBUILD" = "$CTARGET" ] && makedepends_build="$makedepends_build gcc-gnat-bootstrap"
	[ "$CBUILD" != "$CTARGET" ] && makedepends_build="$makedepends_build gcc-gnat gcc-gnat$_cross"
fi
makedepends="$makedepends_build $makedepends_host"

source="gcc-11.0.1.tar.xz
	0001-posix_memalign.patch
	0002-gcc-poison-system-directories.patch
	0003-Turn-on-Wl-z-relro-z-now-by-default.patch
	0004-Turn-on-D_FORTIFY_SOURCE-2-by-default-for-C-C-ObjC-O.patch
	0005-On-linux-targets-pass-as-needed-by-default-to-the-li.patch
	0006-Enable-Wformat-and-Wformat-security-by-default.patch
	0007-Enable-Wtrampolines-by-default.patch
	0008-Disable-ssp-on-nostdlib-nodefaultlibs-and-ffreestand.patch
	0009-Ensure-that-msgfmt-doesn-t-encounter-problems-during.patch
	0010-Don-t-declare-asprintf-if-defined-as-a-macro.patch
	0011-libiberty-copy-PIC-objects-during-build-process.patch
	0012-libitm-disable-FORTIFY.patch
	0013-libgcc_s.patch
	0014-nopie.patch
	0015-libffi-use-__linux__-instead-of-__gnu_linux__-for-mu.patch
	0016-dlang-update-zlib-binding.patch
	0017-dlang-fix-fcntl-on-mips-add-libucontext-dep.patch
	0018-ada-fix-shared-linking.patch
	0019-build-fix-CXXFLAGS_FOR_BUILD-passing.patch
	0020-libstdc-futex-add-time64-compatibility.patch
	0021-add-fortify-headers-paths.patch
	0022-Alpine-musl-package-provides-libssp_nonshared.a.-We-.patch
	0023-DP-Use-push-state-pop-state-for-gold-as-well-when-li.patch
	0024-Pure-64-bit-MIPS.patch
	0025-use-pure-64-bit-configuration-where-appropriate.patch
	0026-always-build-libgcc_eh.a.patch
	0027-ada-libgnarl-compatibility-for-musl.patch
	0028-ada-musl-support-fixes.patch
	"

#	gcc-4.8-build-args.patch

# we build out-of-tree
_gccdir="$srcdir"/gcc-${_pkgbase:-$pkgver}
_gcclibdir="/usr/lib/gcc/$CTARGET/$pkgver"
_gcclibexec="/usr/libexec/gcc/$CTARGET/$pkgver"

prepare() {
	cd "$_gccdir"

	_err=
	for i in $source; do
		case "$i" in
		*.patch)
			msg "Applying $i"
			patch -p1 -i "$srcdir"/$i || _err="$_err $i"
			;;
		esac
	done

	if [ -n "$_err" ]; then
		error "The following patches failed:"
		for i in $_err; do
			echo "  $i"
		done
		return 1
	fi

	echo ${pkgver} > gcc/BASE-VER
}

build() {
	local _arch_configure=
	local _libc_configure=
	local _cross_configure=
	local _bootstrap_configure=
	local _symvers=

	cd "$_gccdir"

	case "$CTARGET" in
	aarch64-*-*-*)		_arch_configure="--with-arch=armv8-a --with-abi=lp64";;
	armv5-*-*-*eabi)	_arch_configure="--with-arch=armv5te --with-tune=arm926ej-s --with-float=soft --with-abi=aapcs-linux";;
	armv6-*-*-*eabihf)	_arch_configure="--with-arch=armv6zk --with-tune=arm1176jzf-s --with-fpu=vfp --with-float=hard --with-abi=aapcs-linux";;
	armv7-*-*-*eabihf)	_arch_configure="--with-arch=armv7-a --with-tune=generic-armv7-a --with-fpu=vfpv3-d16 --with-float=hard --with-abi=aapcs-linux --with-mode=thumb";;
	mips-*-*-*)		_arch_configure="--with-arch=mips32 --with-mips-plt --with-float=soft --with-abi=32";;
	mips64-*-*-*)		_arch_configure="--with-arch=mips3 --with-tune=mips64 --with-mips-plt --with-float=soft --with-abi=64";;
	mips64el-*-*-*)		_arch_configure="--with-arch=mips3 --with-tune=mips64 --with-mips-plt --with-float=soft --with-abi=64";;
	mipsel-*-*-*)		_arch_configure="--with-arch=mips32 --with-mips-plt --with-float=soft --with-abi=32";;
	powerpc-*-*-*)		_arch_configure="--enable-secureplt --enable-decimal-float=no";;
	powerpc64*-*-*-*)	_arch_configure="--with-abi=elfv2 --enable-secureplt --enable-decimal-float=no --enable-targets=powerpcle-linux";;
	i486-*-*-*)		_arch_configure="--with-arch=i486 --with-tune=generic --enable-cld";;
	i586-*-*-*)		_arch_configure="--with-arch=i586 --with-tune=generic --enable-cld";;
	s390x-*-*-*)		_arch_configure="--with-arch=z196 --with-tune=zEC12 --with-zarch --with-long-double-128 --enable-decimal-float";;
	esac

	case "$CTARGET_ARCH" in
	mips*)	_hash_style_configure="--with-linker-hash-style=sysv" ;;
	*)	_hash_style_configure="--with-linker-hash-style=gnu" ;;
	esac

	case "$CTARGET_LIBC" in
	musl)
		# musl does not support mudflap, or libsanitizer
		# libmpx uses secure_getenv and struct _libc_fpstate not present in musl
		# alpine musl provides libssp_nonshared.a, so we don't need libssp either
		_libc_configure="--disable-libssp --disable-libmpx --disable-libmudflap --disable-libsanitizer"
		_symvers="--disable-symvers"
		export libat_cv_have_ifunc=no
		;;
	esac

	[ "$CBUILD" != "$CHOST"   ] && _cross_configure="--disable-bootstrap"
	[ "$CHOST"  != "$CTARGET" ] && _cross_configure="--disable-bootstrap --with-sysroot=$CBUILDROOT"

	case "$BOOTSTRAP" in
	nolibc)	_bootstrap_configure="--with-newlib --disable-shared --enable-threads=no" ;;
	*)	_bootstrap_configure="--enable-shared --enable-threads --enable-tls" ;;
	esac

	$_libgomp	|| _bootstrap_configure="$_bootstrap_configure --disable-libgomp"
	$_libatomic	|| _bootstrap_configure="$_bootstrap_configure --disable-libatomic"
	$_libitm	|| _bootstrap_configure="$_bootstrap_configure --disable-libitm"
	$_libquadmath	|| _arch_configure="$_arch_configure --disable-libquadmath"

	msg "Building the following:"
	echo ""
	echo "  CBUILD=$CBUILD"
	echo "  CHOST=$CHOST"
	echo "  CTARGET=$CTARGET"
	echo "  CTARGET_ARCH=$CTARGET_ARCH"
	echo "  CTARGET_LIBC=$CTARGET_LIBC"
	echo "  languages=$_languages"
	echo "  arch_configure=$_arch_configure"
	echo "  libc_configure=$_libc_configure"
	echo "  cross_configure=$_cross_configure"
	echo "  bootstrap_configure=$_bootstrap_configure"
	echo "	hash_style_configure=$_hash_style_configure"
	echo ""

	export CFLAGS="$CFLAGS -O2"

	mkdir -p "$_builddir"
	cd "$_builddir"
	"$_gccdir"/configure --prefix=/usr \
		--mandir=/usr/share/man \
		--infodir=/usr/share/info \
		--build=${CBUILD} \
		--host=${CHOST} \
		--target=${CTARGET} \
		--with-pkgversion="Alpine $pkgver" \
		--enable-checking=release \
		--disable-fixed-point \
		--disable-libstdcxx-pch \
		--disable-multilib \
		--disable-nls \
		--disable-werror \
		$_symvers \
		--enable-__cxa_atexit \
		--enable-default-pie \
		--enable-default-ssp \
		--enable-cloog-backend \
		--enable-languages=$_languages \
		$_arch_configure \
		$_libc_configure \
		$_cross_configure \
		$_bootstrap_configure \
		--with-system-zlib \
		$_hash_style_configure
	make -j $(nproc)
}

package() {
	cd "$_builddir"
	make -j $(nproc) DESTDIR="$pkgdir" install

	ln -s gcc "$pkgdir"/usr/bin/cc

	# we dont support gcj -static
	# and saving 35MB is not bad.
	find "$pkgdir" \( -name libgtkpeer.a \
		-o -name libgjsmalsa.a \
		-o -name libgij.a \) \
		-delete

	# strip debug info from some static libs
	find "$pkgdir" \( -name libgfortran.a -o -name libobjc.a -o -name libgomp.a \
		-o -name libgphobos.a -o -name libgdruntime.a \
		-o -name libmudflap.a -o -name libmudflapth.a \
		-o -name libgcc.a -o -name libgcov.a -o -name libquadmath.a \
		-o -name libitm.a -o -name libgo.a -o -name libcaf\*.a \
		-o -name libatomic.a -o -name libasan.a -o -name libtsan.a \) \
		-a -type f \
		-exec ${STRIP_FOR_TARGET} -g {} +

	if $_libgomp; then
		mv "$pkgdir"/usr/lib/libgomp.spec "$pkgdir"/$_gcclibdir
	fi
	if $_libitm; then
		mv "$pkgdir"/usr/lib/libitm.spec "$pkgdir"/$_gcclibdir
	fi

	# remove ffi
	rm -f "$pkgdir"/usr/lib/libffi* "$pkgdir"/usr/share/man/man3/ffi*
	find "$pkgdir" -name 'ffi*.h' -delete

	local gdblib=${_target:+$CTARGET/}lib
	if [ -d "$pkgdir"/usr/$gdblib/ ]; then
		for i in $(find "$pkgdir"/usr/$gdblib/ -type f -maxdepth 1 -name "*-gdb.py"); do
			mkdir -p "$pkgdir"/usr/share/gdb/python/auto-load/usr/$gdblib
			mv "$i" "$pkgdir"/usr/share/gdb/python/auto-load/usr/$gdblib/
		done
	fi

	paxmark -pmrs "$pkgdir"/$_gcclibexec/cc1

	# move ada runtime libs
	if $LANG_ADA; then
		for i in $(find "$pkgdir"/$_gcclibdir/adalib/ -type f -maxdepth 1 -name "libgna*.so"); do
			mv "$i" "$pkgdir"/usr/lib/
			ln -s ../../../../${i##*/} $i
		done
	fi

	if [ "$CHOST" != "$CTARGET" ]; then
		# cross-gcc: remove any files that would conflict with the
		# native gcc package
		rm -rf "$pkgdir"/usr/bin/cc "$pkgdir"/usr/include "${pkgdir:?}"/usr/share
		# libcc1 does not depend on target, don't ship it
		rm -rf "$pkgdir"/usr/lib/libcc1.so*

		# fixup gcc library symlinks to be linker scripts so
		# linker finds the libs from relocated sysroot
		for so in "$pkgdir"/usr/"$CTARGET"/lib/*.so; do
			if [ -h "$so" ]; then
				local _real=$(basename "$(readlink "$so")")
				rm -f "$so"
				echo "GROUP ($_real)" > "$so"
			fi
		done
	else
		# add c89/c99 wrapper scripts
		cat >"$pkgdir"/usr/bin/c89 <<'EOF'
#!/bin/sh
_flavor="-std=c89"
for opt; do
	case "$opt" in
	-ansi|-std=c89|-std=iso9899:1990) _flavor="";;
	-std=*) echo "$(basename $0) called with non ANSI/ISO C option $opt" >&2
		exit 1;;
	esac
done
exec gcc $_flavor ${1+"$@"}
EOF
		cat >"$pkgdir"/usr/bin/c99 <<'EOF'
#!/bin/sh
_flavor="-std=c99"
for opt; do
	case "$opt" in
	-std=c99|-std=iso9899:1999) _flavor="";;
	-std=*) echo "$(basename $0) called with non ISO C99 option $opt" >&2
		exit 1;;
	esac
done
exec gcc $_flavor ${1+"$@"}
EOF
		chmod 755 "$pkgdir"/usr/bin/c?9

		# install lto plugin so regular binutils may use it
		mkdir -p "$pkgdir"/usr/lib/bfd-plugins
		ln -s /$_gcclibexec/liblto_plugin.so "$pkgdir/usr/lib/bfd-plugins/"
	fi
}

libatomic() {
	pkgdesc="GCC Atomic library"
	depends=
	replaces="gcc"

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/${_target:+$CTARGET/}lib/libatomic.so.* "$subpkgdir"/usr/lib/
}

libcxx() {
	pkgdesc="GNU C++ standard runtime library"
	depends=

	if [ "$CHOST" = "$CTARGET" ]; then
		# verify that we are using clock_gettime rather than doing direct syscalls
		# so we dont break 32 bit arches due to time64.
		nm -D "$pkgdir"/usr/lib/libstdc++.so.* | grep clock_gettime
	fi

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/${_target:+$CTARGET/}lib/libstdc++.so.* "$subpkgdir"/usr/lib/
}

gpp() {
	pkgdesc="GNU C++ standard library and compiler"
	depends="libstdc++=$_gccrel gcc=$_gccrel libc-dev"
	mkdir -p "$subpkgdir/$_gcclibexec" \
		"$subpkgdir"/usr/bin \
		"$subpkgdir"/usr/${_target:+$CTARGET/}include \
		"$subpkgdir"/usr/${_target:+$CTARGET/}lib \

	mv "$pkgdir/$_gcclibexec/cc1plus" "$subpkgdir/$_gcclibexec/"
	paxmark -pmrs "$subpkgdir/$_gcclibexec/cc1plus"

	mv "$pkgdir"/usr/${_target:+$CTARGET/}lib/*++* "$subpkgdir"/usr/${_target:+$CTARGET/}lib/
	mv "$pkgdir"/usr/${_target:+$CTARGET/}include/c++ "$subpkgdir"/usr/${_target:+$CTARGET/}include/
	mv "$pkgdir"/usr/bin/*++ "$subpkgdir"/usr/bin/
}

libobjc() {
	pkgdesc="GNU Objective-C runtime"
	replaces="objc"
	depends=
	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/${_target:+$CTARGET/}lib/libobjc.so.* "$subpkgdir"/usr/lib/
}

objc() {
	pkgdesc="GNU Objective-C"
	replaces="gcc"
	depends="libc-dev gcc=$_gccrel libobjc=$_gccrel"

	mkdir -p "$subpkgdir/$_gcclibexec" \
		"$subpkgdir"/$_gcclibdir/include \
		"$subpkgdir"/usr/lib
	mv "$pkgdir/$_gcclibexec/cc1obj" "$subpkgdir/$_gcclibexec/"
	mv "$pkgdir"/$_gcclibdir/include/objc "$subpkgdir"/$_gcclibdir/include/
	mv "$pkgdir"/usr/lib/libobjc.so "$pkgdir"/usr/lib/libobjc.a \
		"$subpkgdir"/usr/lib/
}

libgcc() {
	pkgdesc="GNU C compiler runtime libraries"
	depends=

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/${_target:+$CTARGET/}lib/libgcc_s.so.* "$subpkgdir"/usr/lib/
}

libgomp() {
	pkgdesc="GCC shared-memory parallel programming API library"
	depends=
	replaces="gcc"

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/${_target:+$CTARGET/}lib/libgomp.so.* "$subpkgdir"/usr/lib/
}

libgphobos() {
	pkgdesc="D programming language standard library for GCC"
	depends=

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/lib/libgdruntime.so.* "$subpkgdir"/usr/lib/
	mv "$pkgdir"/usr/lib/libgphobos.so.*  "$subpkgdir"/usr/lib/
}

gdc() {
	pkgdesc="GCC-based D language compiler"
	depends="gcc=$_gccrel libgphobos=$_gccrel musl-dev"
	depends="$depends libucontext-dev"

	mkdir -p "$subpkgdir/$_gcclibexec" \
		"$subpkgdir"/$_gcclibdir/include/d/ \
		"$subpkgdir"/usr/lib \
		"$subpkgdir"/usr/bin
	# Copy: The installed '.d' files, the static lib, the binary itself
	# The shared libs are part of 'libgphobos' so one can run program
	# without installing the compiler
	mv "$pkgdir/$_gcclibexec/d21" "$subpkgdir/$_gcclibexec/"
	mv "$pkgdir"/$_gcclibdir/include/d/* "$subpkgdir"/$_gcclibdir/include/d/
	mv "$pkgdir"/usr/lib/libgdruntime.a "$subpkgdir"/usr/lib/
	mv "$pkgdir"/usr/lib/libgphobos.a "$subpkgdir"/usr/lib/
	mv "$pkgdir"/usr/lib/libgphobos.spec "$subpkgdir"/usr/lib/
	mv "$pkgdir"/usr/bin/$CTARGET-gdc "$subpkgdir"/usr/bin/
	mv "$pkgdir"/usr/bin/gdc "$subpkgdir"/usr/bin/
}


libgo() {
	pkgdesc="Go runtime library for GCC"
	depends=

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/lib/libgo.so.* "$subpkgdir"/usr/lib/
}

go() {
	pkgdesc="Go support for GCC"
	depends="gcc=$_gccrel libgo=$_gccrel"

	mkdir -p "$subpkgdir"/$_gcclibexec \
		"$subpkgdir"/usr/lib \
		"$subpkgdir"/usr/bin
	mv "$pkgdir"/usr/lib/go "$subpkgdir"/usr/lib/
	mv "$pkgdir"/usr/bin/*gccgo "$subpkgdir"/usr/bin/
	mv "$pkgdir"/$_gcclibexec/go1 "$subpkgdir"/$_gcclibexec/
	mv "$pkgdir"/usr/lib/libgo.a \
		"$pkgdir"/usr/lib/libgo.so \
		"$pkgdir"/usr/lib/libgobegin.a \
		"$subpkgdir"/usr/lib/
}

libgfortran() {
	pkgdesc="Fortran runtime library for GCC"
	depends=

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/lib/libgfortran.so.* "$subpkgdir"/usr/lib/
}

libquadmath() {
	replaces="gcc"
	pkgdesc="128-bit math library for GCC"
	depends=

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/lib/libquadmath.so.* "$subpkgdir"/usr/lib/
}

gfortran() {
	pkgdesc="GNU Fortran Compiler"
	depends="gcc=$_gccrel libgfortran=$_gccrel"
	$_libquadmath && depends="$depends libquadmath=$_gccrel"
	replaces="gcc"

	mkdir -p "$subpkgdir"/$_gcclibexec \
		"$subpkgdir"/$_gcclibdir \
		"$subpkgdir"/usr/lib \
		"$subpkgdir"/usr/bin
	mv "$pkgdir"/usr/bin/*gfortran "$subpkgdir"/usr/bin/
	mv "$pkgdir"/usr/lib/libgfortran.a \
		"$pkgdir"/usr/lib/libgfortran.so \
		"$subpkgdir"/usr/lib/
	if $_libquadmath; then
		mv "$pkgdir"/usr/lib/libquadmath.a \
			"$pkgdir"/usr/lib/libquadmath.so \
			"$subpkgdir"/usr/lib/
	fi
	mv "$pkgdir"/$_gcclibdir/finclude "$subpkgdir"/$_gcclibdir/
	mv "$pkgdir"/$_gcclibexec/f951 "$subpkgdir"/$_gcclibexec
	mv "$pkgdir"/usr/lib/libgfortran.spec "$subpkgdir"/$_gcclibdir
}

libgnat() {
	pkgdesc="GNU Ada runtime shared libraries"
	depends=

	mkdir -p "$subpkgdir"/usr/lib
	mv "$pkgdir"/usr/lib/libgna*.so "$subpkgdir"/usr/lib/
}

gnat() {
	pkgdesc="Ada support for GCC"
	depends="gcc=$_gccrel"
	provides="$pkgname-gnat-bootstrap"
	[ "$CHOST" = "$CTARGET" ] && depends="$depends libgnat=$_gccrel"

	mkdir -p "$subpkgdir"/$_gcclibexec \
		"$subpkgdir"/$_gcclibdir \
		"$subpkgdir"/usr/bin
	mv "$pkgdir"/$_gcclibexec/*gnat* "$subpkgdir"/$_gcclibexec/
	mv "$pkgdir"/$_gcclibdir/*ada* "$subpkgdir"/$_gcclibdir/
	mv "$pkgdir"/usr/bin/*gnat* "$subpkgdir"/usr/bin/
}

sha512sums="2cf2db92cf9198511a1057951232800fe043c18806f9cc7e3571a3759cfa27260d0b3676a84400393018feacae4cb504966aafbeac723a17b5ed14e1a90b628b  gcc-11.0.1.tar.xz
ee2d344e912ebaddf71d53ff674ca7ea7837ee65f982a8f088339fd05261e441aace6087f7f936d32b502bff7e375094f48cb90562ab7734c57e1750d3fe2029  0001-posix_memalign.patch
deaf3ba25614df18b2b9b04244bcc9278c16d98f6fdeac17f7e2c0567be7c2836ab6d21fc9d8f779c672022d25fc278327d6d0d637bc200fadbb8d913ef95581  0002-gcc-poison-system-directories.patch
eb80ea94e008e33b97c8c0d47e74d639897a13357abbd130e9bff4ae30349b8f788acbaf4caa61f23022a86841c431b8bb639c536aab548dc735470a7c7ccfcf  0003-Turn-on-Wl-z-relro-z-now-by-default.patch
6cbc39dd24f7b4316b6e69940bf7c9f3ae889e8156f9c7dd72c8335e55a2a44d6fade37954296451b588bf8fc065514d4916ad527042b8f9a86d6e0d706e3c9c  0004-Turn-on-D_FORTIFY_SOURCE-2-by-default-for-C-C-ObjC-O.patch
e8c75aef864e5852fc78bfd7949232fc58b40a743d7c04a122ee6e021ee99f72edcff6efbf74e0eedc9405faf81d01208867b0571c4dc8cb44b9a03d1d25fbde  0005-On-linux-targets-pass-as-needed-by-default-to-the-li.patch
d5b3d40e1c4828d16684137487f64bf0b4b892fabc403f975f37d481a22647f923a3524a12714898937abdfbf875411e50b522134535f8d1852f103310aef5a3  0006-Enable-Wformat-and-Wformat-security-by-default.patch
e568a17fb3348964c0d21e7d67ffeae4f2f0dfd3f2986aaf9cec86c685c13f0c830dfc019b6bd7fe58b8635e5b8fca7ad992a92210f2be285b8cac6467c33a78  0007-Enable-Wtrampolines-by-default.patch
bf6a514b11d8ea6b496cff51954f13da33d80d31a6c434f60ff37648c16f862a9944c8e1f5280b994c15226915837b0fb83eda0673eafa0bc276ee5ad9fec813  0008-Disable-ssp-on-nostdlib-nodefaultlibs-and-ffreestand.patch
820be83d93ff5b8d8fc69cdeccec0c6ac2544ee6cce43ae35e6829222791733a1c0b2232fb5a7ad93ab9e6cd677f077d01a4f9dec7aa9c38b013f74aa6c74fc3  0009-Ensure-that-msgfmt-doesn-t-encounter-problems-during.patch
5be4c0ad27e3b86c06dcaefe34ee1271cb53ded3de9802bc1a8571497240ca870e22534f77adb52dc4556eb4861b94a6c9a39cf6a2e84ef62ee88a04a4a01868  0010-Don-t-declare-asprintf-if-defined-as-a-macro.patch
5024309e549b7e4a94f2af8bd727144bd27cf8b7cdcbb537a30f3dac28543697c214438da7af491e43cb90daac46344b7b0466729d5c4209ca8a3a0d5a7d027c  0011-libiberty-copy-PIC-objects-during-build-process.patch
c0ebc205f6598edbe6d68b8a287c36ef80826b864e5b92b37f64e7a21ab7048cae67dd5650cd3d1399beb890753ad96e898a94c52d13b3ca7b266a15fed043ca  0012-libitm-disable-FORTIFY.patch
4a4fae02231f49142ab90d4f3dcd093c13032781ff1659f6aca62da13f8c676e2ec9dcdd2e7959ec62835e13c515be9bd7a2e35d3c06768d44d9e1185cb40dac  0013-libgcc_s.patch
9c513a30146364ecd899ca26a27019ea1ba353e8e409e0becb50d2a051022b701586b9276a4f118dbdd131c4882a04cad4188219bb10aa36d7b0bbe2eb2ceb03  0014-nopie.patch
aec141251c3abae35b4dc3ecd3778e332fa5596282fea1fd08c8d5350d8a8740568910236ce8d38c5662232fa5412313cb0a1c7a46c79a5b5e2c643871bf643b  0015-libffi-use-__linux__-instead-of-__gnu_linux__-for-mu.patch
d3fc4ea6918b4c4ce57eb45437f88ec3982bd5c8e17d282003e195dc705e0c84996ec140151b2b2371917595d2d62f30a2cb4676150c1bc8b8fd3b8fb85ecbe9  0016-dlang-update-zlib-binding.patch
4ebf845f41c7a8ba5bfa624c8e1527eb0f15a48d6a8bd151435037bd4b9d71f955ac9b60ab453c0315d592e92f194be92b9c3fca40ed533d64c0a1995c3ad4be  0017-dlang-fix-fcntl-on-mips-add-libucontext-dep.patch
2ca085382a03d269a2f48ec49601328cec7c53eb69856ee55aea11610293c206e8881043030d2295f49a08a5897c9eb9a6126a5ae65edbd967e17e34dadfb2d8  0018-ada-fix-shared-linking.patch
307a1ac2a6cea20c900b7bef2d5d7ad98c2b8cc45bdb2a6adbf151f3228d5de2670c75ddf48e4d3c9ceb7ed42852e24be534773551bc050ad10005faaee2600c  0019-build-fix-CXXFLAGS_FOR_BUILD-passing.patch
d01d0031d97fa42363bd3fb0c0dda9b26e7f06660294f0ceec55624f6564f2ce372b9a255683c67d79dfa18fb8551416c04766debc2e1b9c587ef381eef64f0b  0020-libstdc-futex-add-time64-compatibility.patch
e9eb5ff439cff4a22abaa7b9e27a176b51e1e1f4361fd829bd26e4b5ffc0e4583b1d6728b1510991b069b42f0aae8a2e698f85edecb1d792e4c7e10079507de8  0021-add-fortify-headers-paths.patch
beb7aa26a3731855be2521495186af52d4764973f2bc1ad44554332e867fe52fa37bcb5747395e44ae0011413e702054a60a754ad81dd88bbf97e3c7c718f356  0022-Alpine-musl-package-provides-libssp_nonshared.a.-We-.patch
ac3288b7840e5cf2500608773f40e604798b30fcb885c9fec7ba0bcc4bcfd374211faa26e82fcf4669bf624d5ccb0bdc747897759be77af3621b8b3bb08bff85  0023-DP-Use-push-state-pop-state-for-gold-as-well-when-li.patch
7e953227e0d3f1105a754f3fdefbaaca0b106d337c5bcc9b6394712d7f47173f96906517030b508d5a57611cc637848f2e59aec92313b39f1e2221bd98729826  0024-Pure-64-bit-MIPS.patch
12eaad6a8781e76f38bc4ba5c8cd09cfe0a0b95c0cde83fe58dc10bdec542fe43389f2c84bd313629c45af8ed3ffd46cc4478f5a4152ea1eb8d4b8276ede499c  0025-use-pure-64-bit-configuration-where-appropriate.patch
73a649ac371f4a5da68c5f0b88010080efd7deaee29765ef7a299fd1654b5ccdbfee88c59e5d37ae55e37cf6fa218d989e411c04b17e0fd94268ed65d7dcd4bf  0026-always-build-libgcc_eh.a.patch
7b0394b9bec41582471aea8a4dba5ce7dac70243d5fd9f5309d6b178d471bf7f0ae1c89e6d3a2ebf8b4fec46035f7bd5241932c00749e50704c2278ffddb07cc  0027-ada-libgnarl-compatibility-for-musl.patch
8207323c530929517c799b24b1a7ba39c07bbb0e6770f878f1d66088ae16667e7706c9402ac04fe5eb6447a6ad12b548cc7e7612c5b217cd24e7d00094d2a28f  0028-ada-musl-support-fixes.patch"
