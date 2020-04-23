# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools systemd eutils

DESCRIPTION="Distributed compiling of C(++) code across several machines; based on distcc"
HOMEPAGE="https://github.com/icecc/icecream"
SRC_URI="https://github.com/icecc/${PN}/archive/${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~arm ~hppa ~ppc ~sparc ~x86"
IUSE="zstd systemd man"

DEPEND="
	acct-user/icecream
	acct-group/icecream
	sys-libs/libcap-ng
	man? (  ~app-text/docbook-xml-dtd-4.2
		app-text/docbook-xsl-stylesheets
		>=dev-libs/libxslt-1.1.2 )
	zstd? ( app-arch/zstd )"

RDEPEND="
	${DEPEND}
	dev-util/shadowman
"

AT_NOELIBTOOOLIZE="yes"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--enable-shared --disable-static \
		--enable-clang-wrappers \
		--enable-clang-rewrite-includes \
		$(use_with man)
}

src_compile() {
	default
	if use man; then
        emake -C doc
    fi
}


src_install() {
	emake DESTDIR="${D}" install
	find "${D}" -name '*.la' -delete || die

	newconfd suse/sysconfig.icecream icecream

#	newinitd "${FILESDIR}"/icecream-r2 icecream

	insinto /etc/logrotate.d
	newins suse/logrotate icecream

	insinto /usr/share/shadowman/tools
	newins - icecc <<<'/usr/libexec/icecc/bin'

	if use systemd; then
		insinto /usr/libexec/icecc
		newins "${FILESDIR}"/start_iceccd start_iceccd
		newins "${FILESDIR}"/start_icecc-scheduler start_icecc-scheduler
		systemd_dounit "${FILESDIR}"/icecream.service
		systemd_dounit "${FILESDIR}"/icecream-scheduler.service
	fi
}

pkg_prerm() {
	if [[ -z ${REPLACED_BY_VERSION} && ${ROOT} == / ]]; then
		eselect compiler-shadow remove icecc
	fi
}

pkg_postinst() {
	cat >> /etc/conf.d/icecream <<-EOF
		ICECREAM_USER="icecream"
	EOF
	if [[ ${ROOT} == / ]]; then
		eselect compiler-shadow update icecc
	fi
}
