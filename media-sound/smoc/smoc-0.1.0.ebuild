# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DOTNET_PKG_COMPAT="10.0"
NUGETS="
acornima@1.2.0
colorhelper@1.8.1
jetbrains.annotations@2025.2.2
jint@4.5.0
microsoft.bcl.asyncinterfaces@10.0.2
microsoft.build.tasks.git@8.0.0
microsoft.codeanalysis.analyzers@3.11.0
microsoft.codeanalysis.common@4.11.0
microsoft.codeanalysis.csharp@4.11.0
microsoft.extensions.configuration.abstractions@10.0.1
microsoft.extensions.configuration.binder@10.0.1
microsoft.extensions.configuration@10.0.1
microsoft.extensions.dependencyinjection.abstractions@10.0.2
microsoft.extensions.dependencyinjection.abstractions@9.0.0
microsoft.extensions.dependencyinjection@10.0.1
microsoft.extensions.logging.abstractions@10.0.2
microsoft.extensions.logging.abstractions@9.0.0
microsoft.extensions.logging.configuration@10.0.1
microsoft.extensions.logging.console@10.0.1
microsoft.extensions.logging@10.0.1
microsoft.extensions.options.configurationextensions@10.0.1
microsoft.extensions.options@10.0.1
microsoft.extensions.primitives@10.0.1
microsoft.net.illink.tasks@10.0.1
microsoft.netcore.platforms@1.1.0
microsoft.sourcelink.common@8.0.0
microsoft.sourcelink.github@8.0.0
netstandard.library@2.0.3
newtonsoft.json@13.0.4
serilog.extensions.logging.file@3.0.0
serilog.extensions.logging@3.1.0
serilog.formatting.compact@1.1.0
serilog.sinks.async@1.5.0
serilog.sinks.file@3.2.0
serilog.sinks.rollingfile@3.3.0
serilog@2.10.0
sixlabors.imagesharp@3.1.12
soundflow.codecs.ffmpeg@1.4.0
soundflow@1.4.0
system.buffers@4.5.1
system.collections.immutable@8.0.0
system.commandline@2.0.1
system.io.abstractions@22.0.16
system.memory@4.5.5
system.numerics.vectors@4.5.0
system.reflection.metadata@8.0.0
system.runtime.compilerservices.unsafe@6.0.0
system.text.encoding.codepages@7.0.0
system.threading.tasks.extensions@4.5.4
testableio.system.io.abstractions.wrappers@22.0.16
testableio.system.io.abstractions@22.0.16
testably.abstractions.filesystem.interface@9.0.0
wcwidth@4.0.0
youtubemusicapi@3.0.4
youtubesessiongenerator@1.0.3
"

inherit dotnet-pkg

DESCRIPTION="Streaming Music on Console (SMoC): A terminal-based music player (TUI) for streaming services."
HOMEPAGE="https://github.com/mrazza/smoc"
SRC_URI="https://razza.dev/${PN}/${PN}-${PV}.tar.gz"
SRC_URI+=" ${NUGET_URIS} "

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"

DOTNET_PKG_PROJECTS=(smoc/smoc.csproj)

DEPEND=""
RDEPEND="${DEPEND}"
BDEPEND=""

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
		sed -i '/<packageSources>/,/<\/packageSources>/ { /<packageSources>/b; /<\/packageSources>/b; d }' "${config}" || die
		
		# Explicitly disable the mapping feature in the config itself
		# We add this to the <config> section if it exists, or create it.
		sed -i '/<\/configuration>/i <config><add key="signatureValidationMode" value="accept" /><add key="noPackageSourceMapping" value="true" /></config>' "${config}" || die
	done < <(find . -iname "nuget.config" -print0)

	# 3. Fix Directory.Packages.props
	# Ensure CPM is ENABLED (so versions are found) but clear out any mappings there too
	if [[ -f Directory.Packages.props ]]; then
		einfo "Sanitizing Directory.Packages.props"
		sed -i '/<packageSourceMapping>/,/<\/packageSourceMapping>/d' Directory.Packages.props || die
	fi
}

