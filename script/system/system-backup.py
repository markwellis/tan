from optparse import OptionParser
from os import system,makedirs,path,chdir,rmdir
from socket import gethostname
from datetime import date

hostname=gethostname()
backup_path="/mnt/stuff/backups/" + date.today().strftime("%Y.%m.%d")
fullpath=backup_path + "/" + hostname + ".tar.bz2"
backup_point="/mnt/backup"

if not path.exists(backup_path):
	makedirs(backup_path)
if not path.exists(backup_point):
	makedirs(backup_point)

mount_return=system("mount -o bind / " + backup_point)
chdir(backup_point)
tar_return=system("tar -cjpf " + fullpath + " ./ --exclude \"./mnt/*\" --exclude \"./tmp/*\" --exclude \"./usr/tmp/*\" --exclude \"./var/tmp/*\"  --exclude \"./var/cache/apt/archives/*\" ")

chdir(backup_path)
sha512sum_retun=system("sha512sum -b " + hostname + ".tar.bz2 > " + hostname + ".tar.bz2.sha512sum")

chdir("/")
mount_return=system("umount " + backup_point)

if mount_return==0:
	rmdir(backup_point)
else:
	print "umount failed, code: " + mount_return
