#!/bin/sh

#
# Shell Bundle installer package for the SCX project
#

PATH=/usr/bin:/usr/sbin:/bin:/sbin
umask 022

# Can't use something like 'readlink -e $0' because that doesn't work everywhere
# And HP doesn't define $PWD in a sudo environment, so we define our own
case $0 in
    /*|~*)
        SCRIPT_INDIRECT="`dirname $0`"
        ;;
    *)
        PWD="`pwd`"
        SCRIPT_INDIRECT="`dirname $PWD/$0`"
        ;;
esac

SCRIPT_DIR="`(cd \"$SCRIPT_INDIRECT\"; pwd -P)`"
SCRIPT="$SCRIPT_DIR/`basename $0`"
EXTRACT_DIR="`pwd -P`/scxbundle.$$"

# These symbols will get replaced during the bundle creation process.
#
# The OM_PKG symbol should contain something like:
#       scx-1.5.1-115.rhel.6.x64 (script adds .rpm or .deb, as appropriate)
# Note that for non-Linux platforms, this symbol should contain full filename.
#

TAR_FILE=scx-1.9.1-0.aix.7.ppc.lpp.tar
OM_PKG=scx-1.9.1-0.aix.7.ppc.lpp
OMI_PKG=omi-1.9.1-0.aix.7.ppc.lpp

SCRIPT_LEN=486
SCRIPT_LEN_PLUS_ONE=487

usage()
{
    echo "usage: $1 [OPTIONS]"
    echo "Options:"
    echo "  --extract              Extract contents and exit."
    echo "  --force                Force upgrade (override version checks)."
    echo "  --install              Install the package from the system."
    echo "  --purge                Uninstall the package and remove all related data."
    echo "  --remove               Uninstall the package from the system."
    echo "  --restart-deps         Reconfigure and restart dependent service"
    echo "  --source-references    Show source code reference hashes."
    echo "  --upgrade              Upgrade the package in the system."
    echo "  --enable-opsmgr        Enable port 1270 for usage with opsmgr."
    echo "  --version              Version of this shell bundle."
    echo "  --debug                use shell debug mode."
    echo "  -? | --help            shows this usage text."
}

source_references()
{
    cat <<EOF
superproject: 4455c9e9c7a67fae614707d8705262cabd77d8fa
omi: f97b065612ae94a1c403b323bcaa46e4ca7399f3
omi-kits: d2b405279a5b75c572be59da64767bed2c01ea85
opsmgr: 7ca097c44bc668312278434d85276512581fc001
opsmgr-kits: ab32a43d24d902cb9da62c55fab148268723da10
pal: 0c26ce7cdd9352666ba658d25b9bf2a772b1455f
EOF
}

cleanup_and_exit()
{
    # $1: Exit status
    # $2: Non-blank (if we're not to delete bundles), otherwise empty

    if [ -z "$2" -a -d "$EXTRACT_DIR" ]; then
        cd $EXTRACT_DIR/..
        rm -rf $EXTRACT_DIR
    fi

    if [ -n "$1" ]; then
        exit $1
    else
        exit 0
    fi
}

check_version_installable() {
    # POSIX Semantic Version <= Test
    # Exit code 0 is true (i.e. installable).
    # Exit code non-zero means existing version is >= version to install.
    #
    # Parameter:
    #   Installed: "x.y.z.b" (like "4.2.2.135"), for major.minor.patch.build versions
    #   Available: "x.y.z.b" (like "4.2.2.135"), for major.minor.patch.build versions

    if [ $# -ne 2 ]; then
        echo "INTERNAL ERROR: Incorrect number of parameters passed to check_version_installable" >&2
        cleanup_and_exit 1
    fi

    # Current version installed
    local INS_MAJOR=`echo $1 | cut -d. -f1`
    local INS_MINOR=`echo $1 | cut -d. -f2`
    local INS_PATCH=`echo $1 | cut -d. -f3`
    local INS_BUILD=`echo $1 | cut -d. -f4`

    # Available version number
    local AVA_MAJOR=`echo $2 | cut -d. -f1`
    local AVA_MINOR=`echo $2 | cut -d. -f2`
    local AVA_PATCH=`echo $2 | cut -d. -f3`
    local AVA_BUILD=`echo $2 | cut -d. -f4`

    # Check bounds on MAJOR
    if [ $INS_MAJOR -lt $AVA_MAJOR ]; then
        return 0
    elif [ $INS_MAJOR -gt $AVA_MAJOR ]; then
        return 1
    fi

    # MAJOR matched, so check bounds on MINOR
    if [ $INS_MINOR -lt $AVA_MINOR ]; then
        return 0
    elif [ $INS_MINOR -gt $AVA_MINOR ]; then
        return 1
    fi

    # MINOR matched, so check bounds on PATCH
    if [ $INS_PATCH -lt $AVA_PATCH ]; then
        return 0
    elif [ $INS_PATCH -gt $AVA_PATCH ]; then
        return 1
    fi

    # PATCH matched, so check bounds on BUILD
    if [ $INS_BUILD -lt $AVA_BUILD ]; then
        return 0
    elif [ $INS_BUILD -gt $AVA_BUILD ]; then
        return 1
    fi

    # Version available is idential to installed version, so don't install
    return 1
}

getVersionNumber()
{
    # Parse a version number from a string.
    #
    # Parameter 1: string to parse version number string from
    #     (should contain something like mumble-4.2.2.135.universal.x86.tar)
    # Parameter 2: prefix to remove ("mumble-" in above example)

    if [ $# -ne 2 ]; then
        echo "INTERNAL ERROR: Incorrect number of parameters passed to getVersionNumber" >&2
        cleanup_and_exit 1
    fi

    echo $1 | sed -e "s/$2//" -e 's/\.aix\..*$//' -e 's/-/./'
}

verifyNoInstallationOption()
{
    if [ -n "${installMode}" ]; then
        echo "$0: Conflicting qualifiers, exiting" >&2
        cleanup_and_exit 1
    fi

    return;
}

# $1 - The name of the package to check as to whether it's installed
check_if_pkg_is_installed() {
    lslpp -L $1.rte 2> /dev/null 1> /dev/null
    return $?
}

# $1 - The filename of the package to be installed
# $2 - The package name of the package to be installed
pkg_add() {
    pkg_filename=$1
    pkg_name=$2

    echo "----- Installing package: $pkg_name ($pkg_filename) -----"
    /usr/sbin/installp -a -X -d $pkg_filename ${pkg_name}.rte
}

# $1 - The package name of the package to be uninstalled
# $2 - Optional parameter. Only used when forcibly removing omi on SunOS
pkg_rm() {
    echo "----- Removing package: $1 -----"
    /usr/sbin/installp -u $1.rte # 1> /dev/null 2> /dev/null
}


# $1 - The filename of the package to be installed
# $2 - The package name of the package to be installed
# $3 - Okay to upgrade the package? (Optional)
pkg_upd() {
    pkg_filename=$1
    pkg_name=$2
    pkg_allowed=$3

    echo "----- Updating package: $pkg_name ($pkg_filename) -----"

    if [ -z "${forceFlag}" -a -n "$pkg_allowed" ]; then
        if [ $pkg_allowed -ne 0 ]; then
            echo "Skipping package since existing version >= version available"
            return 0
        fi
    fi

    [ -n "${forceFlag}" -o "${pkg_name}" = "omi" ] && FORCE="-F" || FORCE=""
    /usr/sbin/installp -a -X $FORCE -d ${pkg_filename} $pkg_name.rte
}

getInstalledVersion()
{
    # Parameter: Package to check if installed
    # Returns: Printable string (version installed or "None")
    if check_if_pkg_is_installed $1; then
        local version="`lslpp -L $1.rte | awk 'NR==3 { print $2 }'`"
        getVersionNumber $version ${1}-
    else
        echo "None"
    fi
}

shouldInstall_omi()
{
    local versionInstalled=`getInstalledVersion omi`
    [ "$versionInstalled" = "None" ] && return 0
    local versionAvailable=`getVersionNumber $OMI_PKG omi-`

    check_version_installable $versionInstalled $versionAvailable
}

shouldInstall_scx()
{
    local versionInstalled=`getInstalledVersion scx`
    [ "$versionInstalled" = "None" ] && return 0
    local versionAvailable=`getVersionNumber $OM_PKG scx-`

    check_version_installable $versionInstalled $versionAvailable
}

#
# Main script follows
#

set +e

while [ $# -ne 0 ]
do
    case "$1" in
        --extract-script)
            # hidden option, not part of usage
            # echo "  --extract-script FILE  extract the script to FILE."
            head -${SCRIPT_LEN} "${SCRIPT}" > "$2"
            local shouldexit=true
            shift 2
            ;;

        --extract-binary)
            # hidden option, not part of usage
            # echo "  --extract-binary FILE  extract the binary to FILE."
            tail -n +${SCRIPT_LEN_PLUS_ONE} "${SCRIPT}" > "$2"
            local shouldexit=true
            shift 2
            ;;

        --extract)
            verifyNoInstallationOption
            installMode=E
            shift 1
            ;;

        --force)
            forceFlag=true
            shift 1
            ;;

        --install)
            verifyNoInstallationOption
            installMode=I
            shift 1
            ;;

        --purge)
            verifyNoInstallationOption
            installMode=P
            shouldexit=true
            shift 1
            ;;

        --remove)
            verifyNoInstallationOption
            installMode=R
            shouldexit=true
            shift 1
            ;;

        --restart-deps)
            restartDependencies=--restart-deps
            shift 1
            ;;

        --source-references)
            source_references
            cleanup_and_exit 0
            ;;

        --upgrade)
            verifyNoInstallationOption
            installMode=U
            shift 1
            ;;

        --enable-opsmgr)
            if [ ! -f /etc/scxagent-enable-port ]; then
                touch /etc/scxagent-enable-port
            fi
            shift 1
            ;;

        --version)
            echo "Version: `getVersionNumber $OM_PKG scx-`"
            exit 0
            ;;

        --debug)
            echo "Starting shell debug mode." >&2
            echo "" >&2
            echo "SCRIPT_INDIRECT: $SCRIPT_INDIRECT" >&2
            echo "SCRIPT_DIR:      $SCRIPT_DIR" >&2
            echo "EXTRACT DIR:     $EXTRACT_DIR" >&2
            echo "SCRIPT:          $SCRIPT" >&2
            echo >&2
            set -x
            shift 1
            ;;

        -? | --help)
            usage `basename $0` >&2
            cleanup_and_exit 0
            ;;

        *)
            usage `basename $0` >&2
            cleanup_and_exit 1
            ;;
    esac
done

if [ -z "${installMode}" ]; then
    echo "$0: No options specified, specify --help for help" >&2
    cleanup_and_exit 3
fi

#
# Note: From this point, we're in a temporary directory. This aids in cleanup
# from bundled packages in our package (we just remove the diretory when done).
#

mkdir -p $EXTRACT_DIR
cd $EXTRACT_DIR

# Do we need to remove the package?
if [ "$installMode" = "R" -o "$installMode" = "P" ]
then
    if [ -f /opt/microsoft/scx/bin/uninstall ]; then
        /opt/microsoft/scx/bin/uninstall $installMode
    else

        # Now just simply pkg_rm scx (and omi if it has no dependencies)
        pkg_rm scx
        pkg_rm omi
    fi

    if [ "$installMode" = "P" ]
    then
        echo "Purging all files in cross-platform agent ..."
        rm -rf /etc/opt/microsoft/scx /opt/microsoft/scx /var/opt/microsoft/scx
        rmdir /etc/opt/microsoft /opt/microsoft /var/opt/microsoft 1>/dev/null 2>/dev/null

        # If OMI is not installed, purge its directories as well.
        check_if_pkg_is_installed omi
        if [ $? -ne 0 ]; then
            rm -rf /etc/opt/omi /opt/omi /var/opt/omi
        fi
    fi
fi

if [ -n "${shouldexit}" ]
then
    # when extracting script/tarball don't also install
    cleanup_and_exit 0
fi

#
# Do stuff before extracting the binary here, for example test [ `id -u` -eq 0 ],
# validate space, platform, uninstall a previous version, backup config data, etc...
#

#
# Extract the binary here.
#

echo "Extracting..."

tail -n +${SCRIPT_LEN_PLUS_ONE} "${SCRIPT}" | gunzip -c | tar xf -
STATUS=$?
if [ ${STATUS} -ne 0 ]
then
    echo "Failed: could not extract the install bundle."
    cleanup_and_exit ${STATUS}
fi

#
# Do stuff after extracting the binary here, such as actually installing the package.
#

EXIT_STATUS=0
SCX_EXIT_STATUS=0
OMI_EXIT_STATUS=0

case "$installMode" in
    E)
        # Files are extracted, so just exit
        cleanup_and_exit 0 "SAVE"
        ;;

    I)
        echo "Installing cross-platform agent ..."

        check_if_pkg_is_installed omi
        if [ $? -eq 0 ]; then
            shouldInstall_omi
            pkg_upd $OMI_PKG omi $?
            OMI_EXIT_STATUS=$?
        else
            pkg_add $OMI_PKG omi
            OMI_EXIT_STATUS=$?
        fi

        pkg_add $OM_PKG scx
        SCX_EXIT_STATUS=$?

        ;;

    U)
        echo "Updating cross-platform agent ..."
        check_if_pkg_is_installed omi
        if [ $? -eq 0 ]; then
            shouldInstall_omi
            pkg_upd $OMI_PKG omi $?
            OMI_EXIT_STATUS=$?
        else
            # If omi is not installed and scx is installed the installed agent is 2012, in that case stoppping the service before updating
            check_if_pkg_is_installed scx
            if [ $? -eq 0 ]; then
                /opt/microsoft/scx/bin/tools/scxadmin -stop
            fi
            pkg_add $OMI_PKG omi
            OMI_EXIT_STATUS=$?
        fi

        shouldInstall_scx
        pkg_upd $OM_PKG scx $?
        SCX_EXIT_STATUS=$?

        ;;

    *)
        echo "$0: Invalid setting of variable \$installMode, exiting" >&2
        cleanup_and_exit 2
esac

# Remove temporary files (now part of cleanup_and_exit) and exit

if [ "$SCX_EXIT_STATUS" -ne 0 -o "$OMI_EXIT_STATUS" -ne 0 ]; then
    cleanup_and_exit 1
else
    cleanup_and_exit 0
fi

