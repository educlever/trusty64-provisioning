#!/bin/bash
locale-gen ${CONFIG_locale:-"en_US.UTF-8"}
update-locale LC_ALL=en_US.UTF-8

# pour supprimer toutes les locales sauf quelques unes :
# locale-gen --purge en_US.UTF-8 fr_FR.UTF-8   < gardera en_US.UTF-8 fr_FR.UTF-8 et éliminera les autres
