set -ux

apk upgrade -U --no-cache --available

source /etc/os-release

cat << EOF > /etc/motd

$PRETTY_NAME ($VERSION_ID) Development Environment

Built for use with Docker

See the Alpine Wiki for how-to guides and
general information about administrating
Alpine systems and development.
See <http://wiki.alpinelinux.org>

EOF
