# This is an example PKGBUILD file. Use this as a start to creating your own,
# and remove these comments. For more information, see 'man PKGBUILD'.
# NOTE: Please fill out the license field for your package! If it is unknown,
# then please put 'unknown'.

# Maintainer: Seth Hinz <sethhinz@me.com>
pkgname=inject
pkgver=0.1
pkgrel=1
pkgdesc="A command-line utility that allows piped input to be substituted into a command."
arch=('x86_64')
url="https://github.com/shinzlet/inject"
license=('MIT')
provides=()
conflicts=()
source=("https://github.com/shinzlet/inject/")

package() {
	cd "$pkgname-$pkgver"
	make DESTDIR="$pkgdir/" install
}
