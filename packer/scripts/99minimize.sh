set -ux

rm -r /root/.cache
apk del build_deps

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
sync
sync

exit 0
