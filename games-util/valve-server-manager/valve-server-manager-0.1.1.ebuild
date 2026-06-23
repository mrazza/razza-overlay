# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

CRATES="
	adler2@2.0.1
	allocator-api2@0.2.21
	base64@0.22.1
	bitflags@2.13.0
	block2@0.6.2
	cassowary@0.3.0
	castaway@0.2.4
	cc@1.2.65
	cfg-if@1.0.4
	cfg_aliases@0.2.1
	compact_str@0.7.1
	crc32fast@1.5.0
	crossterm@0.27.0
	crossterm_winapi@0.9.1
	ctrlc@3.5.2
	directories@5.0.1
	dirs-sys@0.4.1
	dispatch2@0.3.1
	displaydoc@0.2.6
	either@1.16.0
	equivalent@1.0.2
	errno@0.3.14
	find-msvc-tools@0.1.9
	flate2@1.1.9
	foldhash@0.1.5
	form_urlencoded@1.2.2
	getrandom@0.2.17
	hashbrown@0.15.5
	hashbrown@0.17.1
	heck@0.5.0
	icu_collections@2.2.0
	icu_locale_core@2.2.0
	icu_normalizer@2.2.0
	icu_normalizer_data@2.2.0
	icu_properties@2.2.0
	icu_properties_data@2.2.0
	icu_provider@2.2.0
	idna@1.1.0
	idna_adapter@1.2.2
	indexmap@2.14.0
	is_elevated@0.1.2
	itertools@0.12.1
	itertools@0.13.0
	itoa@1.0.18
	libc@0.2.186
	libredox@0.1.17
	litemap@0.8.2
	lock_api@0.4.14
	log@0.4.33
	lru@0.12.5
	memchr@2.8.2
	miniz_oxide@0.8.9
	mio@0.8.11
	nix@0.31.3
	objc2-encode@4.1.0
	objc2@0.6.4
	once_cell@1.21.4
	option-ext@0.2.0
	parking_lot@0.12.5
	parking_lot_core@0.9.12
	paste@1.0.15
	percent-encoding@2.3.2
	potential_utf@0.1.5
	proc-macro2@1.0.106
	quote@1.0.46
	ratatui@0.26.3
	redox_syscall@0.5.18
	redox_users@0.4.6
	ring@0.17.14
	rustls-pki-types@1.14.1
	rustls-webpki@0.103.13
	rustls@0.23.41
	rustversion@1.0.22
	ryu@1.0.23
	scopeguard@1.2.0
	serde@1.0.228
	serde_core@1.0.228
	serde_derive@1.0.228
	serde_json@1.0.150
	serde_spanned@0.6.9
	shlex@2.0.1
	signal-hook-mio@0.2.5
	signal-hook-registry@1.4.8
	signal-hook@0.3.18
	simd-adler32@0.3.9
	smallvec@1.15.2
	stability@0.2.1
	stable_deref_trait@1.2.1
	static_assertions@1.1.0
	strum@0.26.3
	strum_macros@0.26.4
	subtle@2.6.1
	syn@2.0.118
	synstructure@0.13.2
	thiserror-impl@1.0.69
	thiserror@1.0.69
	tinystr@0.8.3
	toml@0.8.23
	toml_datetime@0.6.11
	toml_edit@0.22.27
	toml_write@0.1.2
	unicode-ident@1.0.24
	unicode-segmentation@1.13.3
	unicode-truncate@1.1.0
	unicode-width@0.1.14
	untrusted@0.9.0
	ureq@2.12.1
	url@2.5.8
	utf8_iter@1.0.4
	wasi@0.11.1+wasi-snapshot-preview1
	webpki-roots@0.26.11
	webpki-roots@1.0.8
	winapi-i686-pc-windows-gnu@0.4.0
	winapi-x86_64-pc-windows-gnu@0.4.0
	winapi@0.3.9
	windows-link@0.2.1
	windows-sys@0.48.0
	windows-sys@0.52.0
	windows-sys@0.61.2
	windows-targets@0.48.5
	windows-targets@0.52.6
	windows_aarch64_gnullvm@0.48.5
	windows_aarch64_gnullvm@0.52.6
	windows_aarch64_msvc@0.48.5
	windows_aarch64_msvc@0.52.6
	windows_i686_gnu@0.48.5
	windows_i686_gnu@0.52.6
	windows_i686_gnullvm@0.52.6
	windows_i686_msvc@0.48.5
	windows_i686_msvc@0.52.6
	windows_x86_64_gnu@0.48.5
	windows_x86_64_gnu@0.52.6
	windows_x86_64_gnullvm@0.48.5
	windows_x86_64_gnullvm@0.52.6
	windows_x86_64_msvc@0.48.5
	windows_x86_64_msvc@0.52.6
	winnow@0.7.15
	writeable@0.6.3
	yoke-derive@0.8.2
	yoke@0.8.3
	zerofrom-derive@0.1.7
	zerofrom@0.1.8
	zeroize@1.9.0
	zerotrie@0.2.4
	zerovec-derive@0.11.3
	zerovec@0.11.6
	zmij@1.0.21
"

inherit cargo

DESCRIPTION="Simple TUI in Rust to manage network access to Valve game servers"
HOMEPAGE="https://github.com/mrazza/valve-server-manager"
SRC_URI="
	https://github.com/mrazza/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz
	${CARGO_CRATE_URIS}
"

LICENSE="Apache-2.0"
# Dependent crate licenses
LICENSE+=" Apache-2.0-with-LLVM-exceptions BSD-2 BSD ISC MIT Unicode-3.0"
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="net-firewall/iptables"

QA_FLAGS_IGNORED="usr/bin/valve-server-manager"

pkg_postinst() {
	elog "valve-server-manager requires administrative privileges (root/sudo)"
	elog "to manage your system firewall rules (iptables)."
}
