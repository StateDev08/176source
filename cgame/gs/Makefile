.DEFAULT_GOAL := all

BASEOBJ = property.o start.o object.o grid.o netmsg.o world.o usermsg.o player_dispatcher.o player.o npc.o gimp.o substance.o msgqueue.o actobject.o item.o matter.o filter.o filter_man.o attack.o item_list.o aggrolist.o actsession.o npcsession.o ainpc.o playercmd.o aipolicy.o playerctrl.o playertemplate.o npcgenerator.o terrain.o playerteam.o serviceprovider.o servicenpc.o guardnpc.o playertrade.o objmanager.o obj_interface.o potion_filter.o fly_filter.o skill_filter.o rune_filter.o playerinvade.o playertrashbox.o worldmanager.o  invincible_filter.o sitdown_filter.o pvplimit_filter.o playerstall.o travel_filter.o gm_player.o npc_filter.o patrol_agent.o cooldown.o breath_ctrl.o player_pvp.o effect_filter.o aei_filter.o userlogin.o petnpc.o dbgprt.o aitrigger.o serverstat.o aiman.o playerduel.o duel_filter.o playerbind.o mount_filter.o petdataman.o petman.o playerbattle.o siegenpc.o towerbuild_filter.o global_drop.o pet_filter.o playermall.o antiwallow.o playermisc.o invisible_filter.o public_quest.o multi_exp_ctrl.o shielduser_filter.o weddingmanager.o teamrelationjob.o wedding_filter.o playerfaction.o dpsrankmanager.o playerforce.o online_award.o online_award_filter.o threadusage.o pk_protected_filter.o nonpenalty_pvp_filter.o playercountrybattle.o gt_award_filter.o global_controller.o meridianmanager.o touchtrade.o titlemanager.o playertitle.o playerdailysign.o player_reincarnation.o uniquedataclient.o historymanager.o playergiftcard.o playerbattlebase.o playertrickbattle.o autoteamman.o staticmap.o playerfatering.o fateringmanager.o playerclock.o mapresman.o random_maze.o moving_action_env.o moving_action.o playersanctuarycheck.o playerinstancereenter.o playersolochallenge.o playermnfaction.o player_single_arena_imp.o luamanager.o player_lottery.o player_lua.o glyph_manager.o player_lib.o player_arena_of_aurora.o arenamanager.o player_money.o world_points_manager.o activity_event_manager.o celestial_memorial_manager.o repository_manager.o player_sequrity.o emulate_settings.o instance_settings.o codex_manager.o ranking_manager.o player_ranking.o player_newhistory.o questionmanager.o player_arena_team.o player_storage_back.o association_manager.o kid_manager.o player_kid.o player_kid_addons.o player_pvp_camp.o storage_gamed.o gmysql_manager.o

GSOBJ = global_userlogin.o global_message.o global_manager.o  global_world_stubs.o 
INOBJ = $(patsubst %.cpp,%.o,$(filter-out instance/instance_world_stubs.cpp,$(wildcard instance/*.cpp)))

include ../Rules.make

SUBDIR = io item template task  pathfinding  instance ai wallow mobile
LIC_DIR = $(PROJROOT)/cnet/licenseclient/vm
IOOBJ = $(patsubst %.cpp,%.o,$(wildcard io/*.cpp)) $(BASEPATH)/io/pollio.o
ITEMOBJ = $(patsubst %.cpp,%.o,$(filter-out item/player.cpp item/actobject.cpp item/item_addon_armor.cpp item/item_addon_weapon.cpp item/item_addon_decoration.cpp item/item_addon_new_armor.cpp,$(wildcard item/*.cpp)))
WALLOWOBJ = $(patsubst %.cpp,%.o,$(filter-out wallow/player.cpp,$(wildcard wallow/*.cpp)))
TEMPLATEOBJ = $(patsubst %.cpp,%.o,$(filter-out template/arenaofaurora_ctrl.cpp template/npcgenerator.cpp template/itemdataman.cpp,$(wildcard template/*.cpp)))
TASKOBJ = task/taskman.o
PFOBJ = $(patsubst %.cpp,%.o,$(wildcard pathfinding/*.cpp))
AIOBJ = $(patsubst %.cpp,%.o,$(wildcard ai/*.cpp))
TASKOBJ2 = task/TaskProcess.o task/TaskTempl.o task/TaskTemplMan.o task/TaskServer.o task/TaskLoader.o
MOBILEOBJ = $(patsubst %.cpp,%.o,$(wildcard mobile/*.cpp))
SUBOBJ= $(IOOBJ) $(ITEMOBJ) $(TEMPLATEOBJ) $(TASKOBJ) $(PFOBJ) $(AIOBJ) $(WALLOWOBJ) $(MOBILEOBJ)

LICENSE_OBJ = $(LIC_DIR)/LicenseCli.a
all: 	gs

gs:	$(BASEOBJ) $(GSOBJ) $(INOBJ) $(SUBOBJ) libtask.so
	$(LD) -fPIC -Wl,-rpath,'$$ORIGIN' $(BASEOBJ) $(INOBJ) $(GSOBJ) $(SUBOBJ) $(CMLIB) $(LICENSE_OBJ) libtask.so $(ALLLIB) -o gs

	@echo "Build complete: gs"
	@echo "Run 'make install' to copy binaries to /home/gamed/"

	
solib: libtask.so

libtask.so: $(TASKOBJ2)
	$(CPP) -shared -fPIC -o libtask.so $(TASKOBJ2)
%.o: %.c
	$(CC) -c $(INC) $< -o $@

%.o: %.cc
	$(CPP) -c $(INC) $< -o $@

%.o: %.cxx
	$(CPP) -c $(INC) $< -o $@ 

%.o: %.cpp
	$(CPP) -c $(INC) $< -o $@

FORCE:

clean: 	FORCE
	rm -f *.o *.a libtask.so gs
	rm -f $(SUBDIR:%=%/*.o)
	rm -f $(BASEPATH)/io/pollio.o

CPP += -fPIC
