#!/bin/bash
#
# Build script for Perfect World 1.7.6 Server
# Works with any $HOME / any user — no hardcoded /root/ paths.
#

set -e

# Resolve the project root (directory where this script lives)
PROJROOT="$(cd "$(dirname "$0")" && pwd)"

GS=cgame
NET=cnet
SKILL=cskill
SHARE="$PROJROOT/share"

echo ""
echo "=========================== setup $NET ==========================="
echo ""
cd "$PROJROOT/$NET"
rm -f common io mk storage rpc lua rpcgen
ln -sf "$SHARE/common/" .
ln -sf "$SHARE/io/" .
ln -sf "$SHARE/mk/" .
ln -sf "$SHARE/storage/" .
ln -sf "$SHARE/rpc/" .
ln -sf "$SHARE/lua/" .
ln -sf "$SHARE/rpcgen" .
cd "$PROJROOT"
echo ""
echo "=========================== setup iolib ==========================="
echo ""
mkdir -p iolib/inc
cd iolib/inc
rm -f *.h *.hxx
ln -sf "../../$NET/gamed/auctionsyslib.h"
ln -sf "../../$NET/gamed/sysauctionlib.h"
ln -sf "../../$NET/gdbclient/db_if.h"
ln -sf "../../$NET/gamed/factionlib.h"
ln -sf "../../$NET/common/glog.h"
ln -sf "../../$NET/gamed/gsp_if.h"
ln -sf "../../$NET/gamed/mailsyslib.h"
ln -sf "../../$NET/gamed/privilege.hxx"
ln -sf "../../$NET/gamed/sellpointlib.h"
ln -sf "../../$NET/gamed/stocklib.h"
ln -sf "../../$NET/gamed/webtradesyslib.h"
ln -sf "../../$NET/gamed/kingelectionsyslib.h"
ln -sf "../../$NET/gamed/pshopsyslib.h"
ln -sf "../../$NET/gdbclient/db_os.h"
ln -sf "$SHARE/io/luabase.h"

cd "$PROJROOT/iolib"
rm -f lib*.a
ln -sf "../$NET/io/libgsio.a"
ln -sf "../$NET/gdbclient/libdbCli.a"
ln -sf "../$SKILL/skill/libskill.a"
ln -sf "../$NET/gamed/libgsPro2.a"
ln -sf "../$NET/logclient/liblogCli.a"
cd "$PROJROOT"
buildlicense()
{
	echo ""
	echo "========================== build LicenseCli.a ============================"
	echo ""
	cd "$PROJROOT/$NET/licenseclient"
	make clean
	make -j$(nproc) || { cd "$PROJROOT"; return 1; }
	cd "$PROJROOT"
}

buildlua()
{
	echo ""
	echo "========================== build liblua.a ============================"
	echo ""
	cd "$PROJROOT/share/lua/src"
	make clean
	make -j$(nproc) || { cd "$PROJROOT"; return 1; }
	cd "$PROJROOT"
}

buildrpcgen()
{
	echo ""
	echo "========================== $NET rpcgen ============================"
	echo ""
	cd "$PROJROOT/$NET"
	# Remove fully generated daemon directories so rpcgen recreates them with
	# current attributes (uniquenamed/gfaction/gauthd/logservice/gacd contain
	# custom source files and must not be removed)
	rm -rf glinkd gdeliveryd gamedbd
	# gdbclient is a tracked directory with custom db_if.cpp/db_if.h/db_os.h/Makefile;
	# its generated .hrp files become stale when rpcdata/attributes change.
	rm -f gdbclient/*.hrp
	./rpcgen rpcalls.xml || { cd "$PROJROOT"; return 1; }
	cd "$PROJROOT"
}

buildrpcdata()
{
	echo ""
	echo "========================== $NET CP rpcdata ============================"
	echo ""
}


installfunc()
{
	echo ""
	echo "======================= Installing daemons ========================="
	echo ""
	local failed=0
	mkdir -p /home/gamed /home/gfactiond /home/gauthd /home/uniquenamed \
		 /home/gamedbd /home/gdeliveryd /home/glinkd /home/gacd /home/logservice 2>/dev/null || true

	copy_bin() {
		local src="$1" dst="$2"
		if [ ! -f "$src" ]; then
			echo "ERROR: required binary not found: $src"
			failed=1
			return
		fi
		mkdir -p "$(dirname "$dst")" 2>/dev/null || true
		if [ -d "$(dirname "$dst")" ]; then
			cp "$src" "$dst" || failed=1
		else
			echo "WARNING: cannot create install dir for $dst; skipping $src"
		fi
	}

	copy_bin_optional() {
		local src="$1" dst="$2"
		if [ ! -f "$src" ]; then
			echo "WARNING: optional binary not found, skipping: $src"
			return
		fi
		mkdir -p "$(dirname "$dst")" 2>/dev/null || true
		if [ -d "$(dirname "$dst")" ]; then
			cp "$src" "$dst" || true
		else
			echo "WARNING: cannot create install dir for $dst; skipping $src"
		fi
	}

	copy_bin "$PROJROOT/$GS/gs/gs"                  /home/gamed/gs
	copy_bin "$PROJROOT/$GS/gs/libtask.so"          /home/gamed/libtask.so
	copy_bin_optional "$PROJROOT/$NET/gfaction/gfactiond"    /home/gfactiond/gfactiond
	copy_bin_optional "$PROJROOT/$NET/gauthd/gauthd"         /home/gauthd/gauthd
	copy_bin_optional "$PROJROOT/$NET/uniquenamed/uniquenamed" /home/uniquenamed/uniquenamed
	copy_bin_optional "$PROJROOT/$NET/gamedbd/gamedbd"       /home/gamedbd/gamedbd
	copy_bin_optional "$PROJROOT/$NET/gdeliveryd/gdeliveryd" /home/gdeliveryd/gdeliveryd
	# Install the glinkd license-bypass wrapper. If a real glinkd ELF binary is
	# already present, preserve it as glinkd.real and install the wrapper as glinkd.
	if [ -f "$SHARE/glinkd-wrapper/glinkd" ] && [ -f "$SHARE/glinkd-wrapper/glinkd_init_patch.so" ]; then
		if [ -d /home/glinkd ]; then
			if [ -f /home/glinkd/glinkd ]; then
				if head -c 4 /home/glinkd/glinkd | grep -q 'ELF'; then
					cp -n /home/glinkd/glinkd /home/glinkd/glinkd.real 2>/dev/null || true
					echo "WARNING: preserved real glinkd binary as /home/glinkd/glinkd.real"
				fi
			fi
			cp -f "$SHARE/glinkd-wrapper/glinkd" /home/glinkd/glinkd || true
			cp -f "$SHARE/glinkd-wrapper/glinkd_init_patch.so" /home/glinkd/glinkd_init_patch.so || true
			echo "installed /home/glinkd/glinkd (wrapper) and /home/glinkd/glinkd_init_patch.so"
		fi
	fi
	copy_bin_optional "$PROJROOT/$NET/gacd/gacd"             /home/gacd/gacd
	copy_bin_optional "$PROJROOT/$NET/logservice/logservice" /home/logservice/logservice
	echo ""
	if [ $failed -eq 0 ]; then
		if [ -d /home/gamed ]; then
			echo "============================== Success!! ==============================="
		else
			echo "============================== Build Success!! ==============================="
			echo "(Install to /home/* was skipped because those directories are not writable."
			echo " Run as root or run install.sh first if you want to install the binaries.)"
		fi
	else
		echo "================= ERROR: install failed (required binary missing) ==============="
	fi
	echo ""
	return $failed
}

buildgslib()
{
	local failed=0
	echo ""
	echo "======================== build libgsio.a =========================="
	echo ""
	cd "$PROJROOT/$NET/io"
	make clean
	make lib -j$(nproc) || failed=1
	cd "$PROJROOT"
	echo ""
	echo "======================= build liblogCli.a ========================="
	echo ""
	cd "$PROJROOT/$NET/logclient"
	make clean
	make -f Makefile.gs clean
	make -f Makefile.gs -j$(nproc) || failed=1
	cd "$PROJROOT"
	echo ""
	echo "======================== build libgsPro2.a ========================="
	echo ""
	cd "$PROJROOT/$NET/gamed"
	make clean
	make lib -j$(nproc) || failed=1
	cd "$PROJROOT"
	echo ""
	echo "======================== build libdbCli.a =========================="
	echo ""
	cd "$PROJROOT/$NET/gdbclient"
	make clean
	make lib -j$(nproc) || failed=1
	cd "$PROJROOT"
	echo ""
	echo "======================== build libcm.a ==========================="
	echo ""
	cd "$PROJROOT/$GS/libcm"
	make clean
	make -j$(nproc) || failed=1
	cd "$PROJROOT"
	echo ""
	echo "======================== build libTrace.a =========================="
	echo ""
	cd "$PROJROOT/$GS/collision"
	make clean
	make -j$(nproc) || failed=1
	cd "$PROJROOT"
	echo ""
	echo "======================== setup cgame symlinks =========================="
	echo ""
	if [ ! -f "$PROJROOT/share/lua/src/liblua.a" ]; then
		echo "ERROR: share/lua/src/liblua.a not found. Run buildlua first."
		exit 1
	fi
	ln -sf "$PROJROOT/share/lua/src/liblua.a" "$PROJROOT/$GS/liblua.a"
	if [ -d "$PROJROOT/$GS/libonline" ] && [ -f "$PROJROOT/$GS/libonline/Makefile" ]; then
		cd "$PROJROOT/$GS/libonline"
		make clean
		make -j$(nproc) || failed=1
		cd "$PROJROOT"
	elif [ ! -f "$PROJROOT/$GS/libonline.a" ]; then
		echo "WARNING: cgame/libonline source not found; creating empty placeholder cgame/libonline.a"
		ar crs "$PROJROOT/$GS/libonline.a"
	fi
	echo ""
	echo "============================ make libgs ============================"
	echo ""
	cd "$PROJROOT/$GS/libgs"
	make clean
	make || failed=1
	cd "$PROJROOT"
	return $failed
}

buildskill()
{
	echo ""
	echo "======================== build libskill.a / libskill.so ========================="
	echo ""
	cd "$PROJROOT/$SKILL/skill"
	make clean
	make -j$(nproc) || { cd "$PROJROOT"; return 1; }
	cd "$PROJROOT"
}

buildtask()
{
	echo ""
	echo "======================= build libtask.o ========================="
	echo ""
	cd "$PROJROOT/$GS/gs/task"
	make clean
	make lib -j$(nproc) || { cd "$PROJROOT"; return 1; }
	cd "$PROJROOT"
}

builddeliver()
{
	cd "$PROJROOT/$NET"
	local failed=0

	echo ""
	echo "========================== build gauthd =============================="
	echo ""
	cd gauthd
	make clean
	make -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build logservice =============================="
	echo ""
	cd logservice
	make clean
	make -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build gacd =============================="
	echo ""
	cd gacd
	make clean
	make -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build glinkd wrapper =============================="
	echo ""
	cd "$SHARE/glinkd-wrapper"
	make clean
	make -j$(nproc) || failed=1
	cd "$PROJROOT/$NET"

	echo ""
	echo "========================== build gdeliveryd =============================="
	echo ""
	cd gdeliveryd
	make clean
	make -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build gamedbd =============================="
	echo ""
	cd gamedbd
	make clean
	make -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build uniquenamed =============================="
	echo ""
	cd uniquenamed
	make clean
	make -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build libgsio =============================="
	echo ""
	cd "$PROJROOT/$NET/io"
	make lib -j$(nproc) || failed=1
	cd ..

	echo ""
	echo "========================== build gfaction =============================="
	echo ""
	cd gfaction
	make clean
	if [ -d "operations" ]; then cp operations/*.h . 2>/dev/null; cp operations/*.hxx . 2>/dev/null; cp operations/*.cxx . 2>/dev/null; cp operations/*.inl . 2>/dev/null; fi
	make -j$(nproc) || failed=1
	cd ..
	
	cd "$PROJROOT"
	return $failed
}

builddeliveryd()
{
	cd "$PROJROOT/$NET"
	echo ""
	echo "========================== build gdeliveryd =============================="
	echo ""
	cd gdeliveryd
	make clean
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build gamedbd =============================="
	echo ""
	cd gamedbd
	make clean
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build uniquenamed =============================="
	echo ""
	cd uniquenamed
	make clean
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build libgsio =============================="
	echo ""
	cd "$PROJROOT/$NET/io"
	make lib -j$(nproc)
	cd ..

	echo ""
	echo "========================== build gfaction =============================="
	echo ""
	cd gfaction
	make clean
	if [ -d "operations" ]; then cp operations/*.h . 2>/dev/null; cp operations/*.hxx . 2>/dev/null; cp operations/*.cxx . 2>/dev/null; cp operations/*.inl . 2>/dev/null; fi
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build gacd =============================="
	echo ""
	cd gacd
	make clean
	make -j$(nproc)
	cd ..

	cd "$PROJROOT"
}


buildgs()
{
	echo ""
	echo "========================== build gs =============================="
	echo ""
	cd "$PROJROOT/$GS/gs"
	make clean
	make -j$(nproc) || { cd "$PROJROOT"; return 1; }
	cd "$PROJROOT"
}

rebuilddeliver()
{
	buildrpcgen || return 1
	builddeliver || return 1
}

rebuilddeliver2()
{
	builddeliver || return 1
}

rebuildgs()
{
	buildlua || return 1
	buildlicense || return 1
	buildskill || return 1
	buildgslib || return 1
	buildgs || return 1
}

rebuildall()
{
	echo ""
	echo "========================== build game all =============================="
	echo ""

	buildlua || return 1
	buildlicense || return 1
	buildrpcgen || return 1
	buildrpcdata || return 1
	buildskill || return 1
	buildgslib || return 1
	buildgs || return 1
	echo ""
	echo "======================== build optional deliver daemons ========================="
	echo ""
	if builddeliver; then
		echo "Deliver daemons built successfully."
	else
		echo "WARNING: builddeliver failed (some daemons may not be available)."
	fi
	installfunc
}

install()
{
	echo ""
	echo "========================== Installing.... =============================="
	echo ""

	installfunc || return 1
}


if [ $# -gt 0 ]; then
	if [ "$1" = "deliver" ]; then
		rebuilddeliver
	elif [ "$1" = "gs" ]; then
		rebuildgs
	elif [ "$1" = "all" ]; then
		rebuildall
	elif [ "$1" = "install" ]; then
		install
	elif [ "$1" = "deliveryd" ]; then
		rebuilddeliver2
	fi
fi
