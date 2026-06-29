# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT="10.0"
NUGETS="
	acornima@1.6.2
	colorhelper@1.8.1
	jetbrains.annotations@2026.2.0
	jint@4.9.3
	markdig@1.3.2
	microsoft.bcl.asyncinterfaces@10.0.8
	microsoft.extensions.configuration.abstractions@10.0.9
	microsoft.extensions.configuration.binder@10.0.9
	microsoft.extensions.configuration.fileextensions@10.0.7
	microsoft.extensions.configuration.json@10.0.7
	microsoft.extensions.configuration@10.0.9
	microsoft.extensions.dependencyinjection.abstractions@10.0.9
	microsoft.extensions.dependencyinjection@10.0.9
	microsoft.extensions.fileproviders.abstractions@10.0.7
	microsoft.extensions.fileproviders.physical@10.0.7
	microsoft.extensions.filesystemglobbing@10.0.7
	microsoft.extensions.logging.abstractions@10.0.9
	microsoft.extensions.logging.configuration@10.0.9
	microsoft.extensions.logging.console@10.0.9
	microsoft.extensions.logging@10.0.9
	microsoft.extensions.options.configurationextensions@10.0.9
	microsoft.extensions.options@10.0.9
	microsoft.extensions.primitives@10.0.9
	newtonsoft.json@13.0.4
	onigwrap@1.0.11
	serilog.extensions.logging.file@3.0.0
	serilog.extensions.logging@3.1.0
	serilog.formatting.compact@1.1.0
	serilog.sinks.async@1.5.0
	serilog.sinks.file@3.2.0
	serilog.sinks.rollingfile@3.3.0
	serilog@2.10.0
	sixlabors.imagesharp@4.0.0
	soundflow.codecs.ffmpeg@1.4.0
	soundflow@1.4.1
	system.commandline@2.0.9
	system.io.abstractions@22.1.1
	system.io.hashing@8.0.0
	terminal.gui@2.4.16
	testableio.system.io.abstractions.wrappers@22.1.1
	testableio.system.io.abstractions@22.1.1
	testably.abstractions.filesystem.interface@10.1.0
	textmatesharp.grammars@2.0.4
	textmatesharp@2.0.4
	wcwidth@4.0.1
	youtubemusicapi@3.0.9
	youtubesessiongenerator@1.0.3
"

inherit dotnet-pkg

DESCRIPTION="Console music player (TUI) for streaming services"
HOMEPAGE="https://github.com/mrazza/smoc"
SRC_URI="https://github.com/mrazza/${PN}/archive/refs/tags/v${PV/_/-}.tar.gz -> ${P}.tar.gz"
SRC_URI+=" ${NUGET_URIS} "
S="${WORKDIR}/${PN}-${PV/_/-}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DOTNET_PKG_PROJECTS=(smoc/smoc.csproj)

RDEPEND="${DEPEND}"

src_prepare() {
	default

	# 1. Kill the 'dotnet nuget push' command in any project file
	# This prevents the build from trying to copy files to a non-existent homedir
	find . -name "*.csproj" -exec sed -i '/dotnet nuget push/d' {} + || die

	# 2. Find every nuget.config and neuter the mapping/sources
	local config
	while IFS= read -r -d '' config; do
		einfo "Neutralizing PackageSourceMapping in ${config}"

		# Remove the entire <packageSourceMapping> section
		sed -i '/<packageSourceMapping>/,/<\/packageSourceMapping>/d' "${config}" || die

		# Remove any <clear /> or <add /> tags inside <packageSources>
		# so it doesn't try to go to nuget.org
		sed -i '/<packageSources>/,/<\/packageSources>/ { /<packageSources>/b; /<\/packageSources>/b; d }' \
			"${config}" || die

		# Explicitly disable the mapping feature in the config itself
		# We add this to the <config> section if it exists, or create it.
		local cfg='<config>'
		cfg+='<add key="signatureValidationMode" value="accept" />'
		cfg+='<add key="noPackageSourceMapping" value="true" />'
		cfg+='</config>'
		sed -i "/<\/configuration>/i ${cfg}" "${config}" || die
	done < <(find . -iname "nuget.config" -print0)

	# 3. Fix Directory.Packages.props
	# Ensure CPM is ENABLED (so versions are found) but clear out any mappings there too
	if [[ -f Directory.Packages.props ]]; then
		einfo "Sanitizing Directory.Packages.props"
		sed -i '/<packageSourceMapping>/,/<\/packageSourceMapping>/d' Directory.Packages.props || die
	fi
}
