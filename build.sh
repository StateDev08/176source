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
echo ""
echo "====================== softlink libskill.so ======================="
echo ""
cd "$PROJROOT/$GS/gs"
rm -f libskill.so
ln -sf "../../$SKILL/libskill.so"
cd "$PROJROOT"

buildlicense()
{
	echo ""
	echo "========================== build LicenseCli.a ============================"
	echo ""
	cd "$PROJROOT/$NET/licenseclient"
	make clean
	make -j$(nproc)
	cd "$PROJROOT"
}

buildlua()
{
	echo ""
	echo "========================== build liblua.a ============================"
	echo ""
	cd "$PROJROOT/share/lua/src"
	make clean
	make -j$(nproc)
	cd "$PROJROOT"
}

buildrpcgen()
{
	echo ""
	echo "========================== $NET rpcgen ============================"
	echo ""
	cd "$PROJROOT/$NET"
	./rpcgen rpcalls.xml
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
	mkdir -p /home/gamed /home/gfactiond /home/gauthd /home/uniquenamed
	mkdir -p /home/gamedbd /home/gdeliveryd /home/glinkd /home/gacd /home/logservice

	cp "$PROJROOT/$GS/gs/gs"              /home/gamed/gs
	cp "$PROJROOT/$GS/gs/libtask.so"      /home/gamed/libtask.so
	cp "$PROJROOT/$SKILL/libskill.so"     /home/gamed/libskill.so
	cp "$PROJROOT/$NET/gfaction/gfactiond" /home/gfactiond/gfactiond
	cp "$PROJROOT/$NET/gauthd/gauthd"     /home/gauthd/gauthd
	cp "$PROJROOT/$NET/uniquenamed/uniquenamed" /home/uniquenamed/uniquenamed
	cp "$PROJROOT/$NET/gamedbd/gamedbd"   /home/gamedbd/gamedbd
	cp "$PROJROOT/$NET/gdeliveryd/gdeliveryd" /home/gdeliveryd/gdeliveryd
	cp "$PROJROOT/$NET/glinkd/glinkd"     /home/glinkd/glinkd
	cp "$PROJROOT/$NET/gacd/gacd"         /home/gacd/gacd
	cp "$PROJROOT/$NET/logservice/logservice" /home/logservice/logservice
	echo ""
	echo "============================== Success!! ==============================="
	echo ""
}

buildgslib()
{
	echo "======================= build liblogCli.a ========================="
	echo ""
	cd "$PROJROOT/$NET/logclient"
	make clean
	make -f Makefile.gs clean
	make -f Makefile.gs -j$(nproc)
	cd "$PROJROOT"
	echo ""
	echo "======================== build libgsPro2.a ========================="
	echo ""
	cd "$PROJROOT/$NET/gamed"
	make clean
	make lib -j$(nproc)
	cd "$PROJROOT"
	echo ""
	echo "======================== build libdbCli.a =========================="
	echo ""
	cd "$PROJROOT/$NET/gdbclient"
	make clean
	make lib -j$(nproc)
	cd "$PROJROOT"
	echo ""
	echo "============================ make libgs ============================"
	echo ""
	cd "$PROJROOT/$GS"
	cd libgs
	mkdir -p io gs db sk log
	make
	cd "$PROJROOT"
}

buildskill()
{
	echo ""
	echo "============================= ant gen =============================="
	echo ""
	cd "$PROJROOT/$SKILL/skill/gen"
	mkdir -p skills buffcondition
	ant
	echo ""
	echo "========================== gen skills =============================="
	echo ""
	chmod a+x gen
#	./gen
	echo ""
	echo "======================= build libskills.o ========================="
	echo ""
	make clean
	make -j$(nproc)
	cd "$PROJROOT"
}

buildgame()
{
	echo ""
	echo "======================= build cgame ========================="
	echo ""
	cd "$PROJROOT/$GS"
	make clean
	make -j$(nproc)
	cd "$PROJROOT"
}

buildtask()
{
	echo ""
	echo "======================= build libtask.o ========================="
	echo ""
	cd "$PROJROOT/$GS/gs/task"
	make clean
	make lib -j$(nproc)
	cd "$PROJROOT"
}

builddeliver()
{
	cd "$PROJROOT/$NET"

	echo ""
	echo "========================== build gauthd =============================="
	echo ""
	cd gauthd
	make clean
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build logservice =============================="
	echo ""
	cd logservice
	make clean
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build gacd =============================="
	echo ""
	cd gacd
	make clean
	make -j$(nproc)
	cd ..

	echo ""
	echo "========================== build glinkd =============================="
	echo ""
	cd glinkd
	make clean
	make -j$(nproc)
	cd ..

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
	if [ -d "operations" ]; then cp operations/*.h . 2>/dev/null; cp operations/*.hxx . 2>/dev/null; cp operations/*.cxx . 2>/dev/null; fi
	make -j$(nproc)
	cd ..
	
	cd "$PROJROOT"
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
	make -j$(nproc)
	cd "$PROJROOT"
}

rebuilddeliver()
{
	buildrpcgen
	builddeliver
}

rebuilddeliver2()
{
	builddeliver
}

rebuildgs()
{
	buildgslib
}

rebuildall()
{
	echo ""
	echo "========================== build game all =============================="
	echo ""

	buildlua
	buildlicense
	buildrpcgen
	buildrpcdata
	builddeliver
	buildgslib
	buildskill
	buildgame
	installfunc
}

install()
{
	echo ""
	echo "========================== Installing.... =============================="
	echo ""

	installfunc
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
