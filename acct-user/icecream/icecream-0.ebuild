# Copyright 2020 YangJie yjsss75@gmail.com
# Distributed under the terms of the GNU General Public License v2
# from https://github.com/bombo82 


EAPI=7

inherit acct-user

DESCRIPTION="User for sys-devel-icecream"
ACCT_USER_ID=-1
ACCT_USER_HOME=/var/cache/icecream
ACCT_USER_GROUPS=( icecream )

acct-user_add_deps
