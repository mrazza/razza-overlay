# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PN="LeiterWatercolorStudio"
LEITER_COMMIT="092efb435d968169a340d343c91f26bcadb1154f"

DOTNET_PKG_COMPAT="10.0"
NUGETS="
	avalonia.angle.windows.natives@2.1.25547.20250602
	avalonia.buildservices@11.3.2
	avalonia.controls.colorpicker@11.3.23
	avalonia.desktop@11.3.23
	avalonia.diagnostics@11.3.23
	avalonia.fonts.inter@11.3.23
	avalonia.freedesktop@11.3.23
	avalonia.native@11.3.23
	avalonia.remote.protocol@11.3.23
	avalonia.skia@11.3.23
	avalonia.themes.fluent@11.3.23
	avalonia.themes.simple@11.3.23
	avalonia.win32@11.3.23
	avalonia.x11@11.3.23
	avalonia@11.3.23
	communitytoolkit.mvvm@8.4.2
	harfbuzzsharp.nativeassets.linux@8.3.1.1
	harfbuzzsharp.nativeassets.macos@8.3.1.1
	harfbuzzsharp.nativeassets.webassembly@8.3.1.1
	harfbuzzsharp.nativeassets.win32@8.3.1.1
	harfbuzzsharp@8.3.1.1
	microcom.runtime@0.11.0
	sixlabors.imagesharp@3.1.12
	skiasharp.nativeassets.linux@2.88.9
	skiasharp.nativeassets.macos@2.88.9
	skiasharp.nativeassets.webassembly@2.88.9
	skiasharp.nativeassets.win32@2.88.9
	skiasharp@2.88.9
	tmds.dbus.protocol@0.21.3
"

inherit desktop dotnet-pkg multiprocessing xdg

DESCRIPTION="Desktop watercolor studio for Leiter photo watercolorization"
HOMEPAGE="https://github.com/mrazza/LeiterWatercolorStudio"
SRC_URI="https://github.com/mrazza/${MY_PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz
	https://github.com/mrazza/Leiter/archive/${LEITER_COMMIT}.tar.gz -> Leiter-${LEITER_COMMIT}.tar.gz
	${NUGET_URIS}"
S="${WORKDIR}/${MY_PN}-${PV}"

LICENSE="Apache-2.0 LGPL-3+"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="test"

RDEPEND="
	media-libs/fontconfig
	media-libs/freetype
	media-libs/libglvnd
	x11-libs/libX11
	x11-libs/libXcursor
	x11-libs/libXext
	x11-libs/libXi
	x11-libs/libXrandr
	x11-libs/libXrender
"

DOTNET_PKG_PROJECTS=( "src/LeiterWatercolorStudio.App/LeiterWatercolorStudio.App.csproj" )

src_unpack() {
	dotnet-pkg_src_unpack

	rmdir "${S}/extern/Leiter" 2>/dev/null || rm -rf "${S}/extern/Leiter"
	mv "${WORKDIR}/Leiter-${LEITER_COMMIT}" "${S}/extern/Leiter" || die
}

src_prepare() {
	default

	# 1. Kill 'dotnet nuget push' in project files to prevent writes to home
	find . -name "*.csproj" -exec sed -i '/dotnet nuget push/d' {} + || die

	# 2. Neuter package source mappings and remote sources in nuget.config
	local config
	while IFS= read -r -d '' config; do
		einfo "Neutralizing PackageSourceMapping in ${config}"
		sed -i '/<packageSourceMapping>/,/<\/packageSourceMapping>/d' "${config}" || die
		sed -i '/<packageSources>/,/<\/packageSources>/ { /<packageSources>/b; /<\/packageSources>/b; d }' \
			"${config}" || die

		local cfg='<config>'
		cfg+='<add key="signatureValidationMode" value="accept" />'
		cfg+='<add key="noPackageSourceMapping" value="true" />'
		cfg+='</config>'
		sed -i "/<\/configuration>/i ${cfg}" "${config}" || die
	done < <(find . -iname "nuget.config" -print0)

	# 3. Sanitize Central Package Management (Directory.Packages.props)
	local props
	while IFS= read -r -d '' props; do
		einfo "Sanitizing PackageSourceMapping in ${props}"
		sed -i '/<packageSourceMapping>/,/<\/packageSourceMapping>/d' "${props}" || die
	done < <(find . -iname "Directory.Packages.props" -print0)
}

src_compile() {
	local -a publish_args=(
		--configuration "${DOTNET_PKG_CONFIGURATION}"
		--no-restore
		--no-self-contained
		--output "${DOTNET_PKG_OUTPUT}"
		--runtime "${DOTNET_PKG_RUNTIME}"
		--verbosity "${DOTNET_VERBOSITY}"
		-maxCpuCount:$(makeopts_jobs)
		-p:PublishReadyToRun=true
	)

	if ! use debug ; then
		publish_args+=(
			-p:StripSymbols=true
			-p:NativeDebugSymbols=false
		)
	fi

	edotnet publish "${DOTNET_PKG_PROJECTS[0]}" "${publish_args[@]}"
}

src_install() {
	dotnet-pkg-base_install

	dotnet-pkg-base_append-launchervar "DOTNET_TieredPGO=1"
	dotnet-pkg-base_append-launchervar "DOTNET_TC_QuickJitForLoops=1"
	dotnet-pkg-base_append-launchervar "DOTNET_ReadyToRun=1"

	dotnet-pkg-base_dolauncher "/usr/share/${P}/${MY_PN}" "${PN}"
	dosym -r "/usr/bin/${PN}" "/usr/bin/${MY_PN}"

	make_desktop_entry "${PN}" "Leiter Watercolor Studio" "" "Graphics;2DGraphics;RasterGraphics;"

	einstalldocs
}
