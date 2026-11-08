
# ---- Surcouche CIH (ajoutée à la fin du profiledef.sh de releng par build.sh) ----
iso_name="cih-archlinux"
iso_label="CIH_ARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="CIH <https://github.com/cih-hoche/infra>"
iso_application="CIH Arch Linux installer"
file_permissions+=(
  ["/usr/local/bin/cih-install"]="0:0:755"
  ["/root/cih"]="0:0:700"
)
