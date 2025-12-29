#！/bin/bash
set -e

echo $USER

cd /boot

echo "---initrd copy optimize begin---"
ls -l

ln -sf initrd.img-6.1.59-rt16 initrd.img
cp -p initrd.img-6.1.59-rt16 initrd.img-6.1.59-rt16.new
sync
ln -sf initrd.img-6.1.59-rt16.new initrd.img

ls -l

echo "---initrd copy optimize done---"

exit 0