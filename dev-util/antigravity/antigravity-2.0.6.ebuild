# Copyright 2024-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

BUILD_ID="5413878570549248"

DESCRIPTION="Official desktop application for the Google Antigravity platform"
HOMEPAGE="https://antigravity.google"
SRC_URI="
	amd64? ( https://storage.googleapis.com/antigravity-public/antigravity-hub/${PV}-${BUILD_ID}/linux-x64/Antigravity.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://storage.googleapis.com/antigravity-public/antigravity-hub/${PV}-${BUILD_ID}/linux-arm/Antigravity.tar.gz -> ${P}-arm64.tar.gz )
"

S="${WORKDIR}/Antigravity-x64"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~arm64"
IUSE=""

RESTRICT="mirror bindist strip test"

RDEPEND="
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	app-accessibility/at-spi2-core
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/freetype
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libX11
	x11-libs/libxcb
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libxkbcommon
	x11-libs/libXrandr
	x11-libs/libXrender
	x11-libs/pango
"
DEPEND="${RDEPEND}"


src_install() {
	local destdir="/opt/${PN}"

	insinto "${destdir}"
	doins -r .

	# Restore executable bits and SUID where electron expects them.
	fperms 0755 "${destdir}"/antigravity
	fperms 0755 "${destdir}"/chrome_crashpad_handler
	fperms 4755 "${destdir}"/chrome-sandbox
	fperms 0755 "${destdir}"/resources/bin/language_server
	fperms 0755 "${destdir}"/resources/bin/webm_encoder

	dosym -r "${destdir}/antigravity" /usr/bin/antigravity

	# domenu "${FILESDIR}/${PN}.desktop"

	# Extract icon.png straight from app.asar so we always ship the current
	# upstream icon instead of a stale copy from ${FILESDIR}. The asar header
	# is a Chromium Pickle: bytes 12-15 hold the JSON length, bytes 16+ hold
	# the JSON manifest, file payloads start after the JSON (4-byte aligned).
	python3 - "${S}/resources/app.asar" "${T}/icon.png" <<-'EOF' || die "icon extraction failed"
		import json, struct, sys
		asar_path, out_path = sys.argv[1], sys.argv[2]
		with open(asar_path, "rb") as f:
      f.seek(12)
      json_size = struct.unpack("<I", f.read(4))[0]
      header = json.loads(f.read(json_size))
      payload_base = 16 + (json_size + 3 & ~3)
      entry = header["files"]["icon.png"]
      f.seek(payload_base + int(entry["offset"]))
      data = f.read(entry["size"])
		with open(out_path, "wb") as out:
      out.write(data)
	EOF

	# Render the icon at every standard hicolor size. A single 512x512 entry
	# is enough for GTK lookups, but Plasma's KIconLoader will fall back to a
	# shorter icon name (stripping trailing '-segment's) when it cannot find
	# an exact-size match - so 'google-antigravity' degrades to 'google',
	# which other icon themes (e.g. Kora) happen to ship as a Google logo.
	# Installing every standard size prevents that fallback.
	local size
	for size in 16 22 24 32 48 64 128 256 512; do
		magick "${T}/icon.png" -resize "${size}x${size}" \
			"${T}/icon-${size}.png" || die "resize to ${size} failed"
		newicon -s "${size}" "${T}/icon-${size}.png" "${PN}.png"
	done
}

pkg_postinst() {
	xdg_desktop_database_update
	xdg_icon_cache_update

	elog "Antigravity has been installed to /opt/${PN}."
	elog "Launch it from your application menu or by running: antigravity"
	elog ""
	elog "The bundled auto-updater is non-functional under this packaging;"
	elog "bump the ebuild to install new upstream releases."
}

pkg_postrm() {
	xdg_desktop_database_update
	xdg_icon_cache_update
}

