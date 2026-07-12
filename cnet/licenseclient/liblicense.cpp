// No-op license-client stub.
// Replaces the original license client so the game server and daemons can
// build and run without an external license service. All license checks are
// disabled (always return true).

#include <pthread.h>
#include "liblicense.h"

using namespace GNET;

// Global symbols required by liblicense.h
int MyGlobalVarStealth = 0;
void MyFunctionStealthCodeArea(void) {}

// SUCCESS macro value
int NnwP4BtXFg4CG179eUlroFIlI8RoCQn = 0;

// LIC macro value (not used by the no-op macros but defined to keep the symbol)
void* IGVlWBieGwYRrv8V7wmDYaZDgMOcSzn = NULL;

pthread_mutex_t LicenseInterfaces::license_mutex = PTHREAD_MUTEX_INITIALIZER;

bool LicenseInterfaces::Init(const char* m_ip, unsigned short m_port,
                             const char* m_login, const char* m_pass,
                             const char* service, int& result)
{
    SUCCESS = 0;
    result = 0;
    return true;
}

bool LicenseInterfaces::Complete()
{
    return true;
}

__int128 LicenseInterfaces::Value(__int128 v)
{
    switch (v)
    {
        case VAL_MAX_ONLINE        : return CXX_MAX_ONLINE;
        case VAL_INIT_SERVICE      : return CXX_INIT_SERVICE;
        case VAL_INVALID_LICENSE   : return CXX_INVALID_LICENSE;
        case VAL_GET_CONF_FILE     : return CXX_GET_CONF_FILE;
        case VAL_XOR_SIZE_MALLOC   : return CXX_XOR_SIZE_MALLOC;
        case VAL_DELETE_FREE       : return CXX_DELETE_FREE;
        case VAL_LUA_INIT          : return CXX_LUA_INIT;
        case VAL_FREE_OCTETS       : return CXX_FREE_OCTETS;
        case VAL_SLEEP_PROCESS     : return CXX_SLEEP_PROCESS;
        case VAL_GET_ROLE_LIST     : return CXX_GET_ROLE_LIST;
        case VAL_OOG_LIMITS        : return CXX_OOG_LIMITS;
        case VAL_MAX_CONNECT       : return CXX_MAX_CONNECT;
        case VAL_MAX_GAMEDATASEND  : return CXX_MAX_GAMEDATASEND;
        case VAL_MAX_KEEP_ALIVE    : return CXX_MAX_KEEP_ALIVE;
        case VAL_LOAD_INVENTORY    : return CXX_LOAD_INVENTORY;
        case VAL_LOAD_ROLE         : return CXX_LOAD_ROLE;
        case VAL_SAVE_INVENTORY    : return CXX_SAVE_INVENTORY;
        case VAL_SAVE_ROLE         : return CXX_SAVE_ROLE;
        case VAL_LOAD_FACTION      : return CXX_LOAD_FACTION;
        case VAL_LOAD_DOMAIN       : return CXX_LOAD_DOMAIN;
        case VAL_LOAD_DOMAIN2      : return CXX_LOAD_DOMAIN2;
        case VAL_GSHOP_ADD_GOLD    : return CXX_GSHOP_ADD_GOLD;
        case VAL_MAX_ROLE_MEMBER   : return CXX_MAX_ROLE_MEMBER;
        case VAL_GET_FACTION       : return CXX_GET_FACTION;
        case VAL_INIT_MYSQL        : return CXX_INIT_MYSQL;
        case VAL_LOAD_STATE        : return CXX_LOAD_STATE;
        case VAL_LOAD_ELEMENTS_DATA: return CXX_LOAD_ELEMENTS_DATA;
        case VAL_LOAD_TASK_DATA    : return CXX_LOAD_TASK_DATA;
        case VAL_LOAD_GSHOP_DATA   : return CXX_LOAD_GSHOP_DATA;
        case VAL_GET_ROLE          : return CXX_GET_ROLE;
        case VAL_PUT_ROLE          : return CXX_PUT_ROLE;
        case VAL_MUTEX_SPINLOK     : return CXX_MUTEX_SPINLOK;
        default: return 0;
    }
}

__int128 LicenseInterfaces::Check(__int128 v)
{
    v ^= SUCCESS;

    switch (v)
    {
        case HHH_MAX_ONLINE        : return (SUCCESS ^ XOR_MAX_ONLINE)        * (LicenseInterfaces::Value(VAL_MAX_ONLINE)        ^ SUCCESS);
        case HHH_INIT_SERVICE      : return (SUCCESS ^ XOR_INIT_SERVICE)      * (LicenseInterfaces::Value(VAL_INIT_SERVICE)      ^ SUCCESS);
        case HHH_INVALID_LICENSE   : return (SUCCESS ^ XOR_INVALID_LICENSE)   * (LicenseInterfaces::Value(VAL_INVALID_LICENSE)   ^ SUCCESS);
        case HHH_GET_CONF_FILE     : return (SUCCESS ^ XOR_GET_CONF_FILE)     * (LicenseInterfaces::Value(VAL_GET_CONF_FILE)     ^ SUCCESS);
        case HHH_XOR_SIZE_MALLOC   : return (SUCCESS ^ XOR_XOR_SIZE_MALLOC)   * (LicenseInterfaces::Value(VAL_XOR_SIZE_MALLOC)   ^ SUCCESS);
        case HHH_DELETE_FREE       : return (SUCCESS ^ XOR_DELETE_FREE)       * (LicenseInterfaces::Value(VAL_DELETE_FREE)       ^ SUCCESS);
        case HHH_LUA_INIT          : return (SUCCESS ^ XOR_LUA_INIT)          * (LicenseInterfaces::Value(VAL_LUA_INIT)          ^ SUCCESS);
        case HHH_FREE_OCTETS       : return (SUCCESS ^ XOR_FREE_OCTETS)       * (LicenseInterfaces::Value(VAL_FREE_OCTETS)       ^ SUCCESS);
        case HHH_SLEEP_PROCESS     : return (SUCCESS ^ XOR_SLEEP_PROCESS)     * (LicenseInterfaces::Value(VAL_SLEEP_PROCESS)     ^ SUCCESS);
        case HHH_GET_ROLE_LIST     : return (SUCCESS ^ XOR_GET_ROLE_LIST)     * (LicenseInterfaces::Value(VAL_GET_ROLE_LIST)     ^ SUCCESS);
        case HHH_OOG_LIMITS        : return (SUCCESS ^ XOR_OOG_LIMITS)        * (LicenseInterfaces::Value(VAL_OOG_LIMITS)        ^ SUCCESS);
        case HHH_MAX_CONNECT       : return (SUCCESS ^ XOR_MAX_CONNECT)       * (LicenseInterfaces::Value(VAL_MAX_CONNECT)       ^ SUCCESS);
        case HHH_MAX_GAMEDATASEND  : return (SUCCESS ^ XOR_MAX_GAMEDATASEND)  * (LicenseInterfaces::Value(VAL_MAX_GAMEDATASEND)  ^ SUCCESS);
        case HHH_MAX_KEEP_ALIVE    : return (SUCCESS ^ XOR_MAX_KEEP_ALIVE)    * (LicenseInterfaces::Value(VAL_MAX_KEEP_ALIVE)    ^ SUCCESS);
        case HHH_LOAD_INVENTORY    : return (SUCCESS ^ XOR_LOAD_INVENTORY)    * (LicenseInterfaces::Value(VAL_LOAD_INVENTORY)    ^ SUCCESS);
        case HHH_LOAD_ROLE         : return (SUCCESS ^ XOR_LOAD_ROLE)         * (LicenseInterfaces::Value(VAL_LOAD_ROLE)         ^ SUCCESS);
        case HHH_SAVE_INVENTORY    : return (SUCCESS ^ XOR_SAVE_INVENTORY)    * (LicenseInterfaces::Value(VAL_SAVE_INVENTORY)    ^ SUCCESS);
        case HHH_SAVE_ROLE         : return (SUCCESS ^ XOR_SAVE_ROLE)         * (LicenseInterfaces::Value(VAL_SAVE_ROLE)         ^ SUCCESS);
        case HHH_LOAD_FACTION      : return (SUCCESS ^ XOR_LOAD_FACTION)      * (LicenseInterfaces::Value(VAL_LOAD_FACTION)      ^ SUCCESS);
        case HHH_LOAD_DOMAIN       : return (SUCCESS ^ XOR_LOAD_DOMAIN)       * (LicenseInterfaces::Value(VAL_LOAD_DOMAIN)       ^ SUCCESS);
        case HHH_LOAD_DOMAIN2      : return (SUCCESS ^ XOR_LOAD_DOMAIN2)      * (LicenseInterfaces::Value(VAL_LOAD_DOMAIN2)      ^ SUCCESS);
        case HHH_GSHOP_ADD_GOLD    : return (SUCCESS ^ XOR_GSHOP_ADD_GOLD)    * (LicenseInterfaces::Value(VAL_GSHOP_ADD_GOLD)    ^ SUCCESS);
        case HHH_MAX_ROLE_MEMBER   : return (SUCCESS ^ XOR_MAX_ROLE_MEMBER)   * (LicenseInterfaces::Value(VAL_MAX_ROLE_MEMBER)   ^ SUCCESS);
        case HHH_GET_FACTION       : return (SUCCESS ^ XOR_GET_FACTION)       * (LicenseInterfaces::Value(VAL_GET_FACTION)       ^ SUCCESS);
        case HHH_INIT_MYSQL        : return (SUCCESS ^ XOR_INIT_MYSQL)        * (LicenseInterfaces::Value(VAL_INIT_MYSQL)        ^ SUCCESS);
        case HHH_LOAD_STATE        : return (SUCCESS ^ XOR_LOAD_STATE)        * (LicenseInterfaces::Value(VAL_LOAD_STATE)        ^ SUCCESS);
        case HHH_LOAD_ELEMENTS_DATA: return (SUCCESS ^ XOR_LOAD_ELEMENTS_DATA)* (LicenseInterfaces::Value(VAL_LOAD_ELEMENTS_DATA)^ SUCCESS);
        case HHH_LOAD_TASK_DATA    : return (SUCCESS ^ XOR_LOAD_TASK_DATA)    * (LicenseInterfaces::Value(VAL_LOAD_TASK_DATA)    ^ SUCCESS);
        case HHH_LOAD_GSHOP_DATA   : return (SUCCESS ^ XOR_LOAD_GSHOP_DATA)   * (LicenseInterfaces::Value(VAL_LOAD_GSHOP_DATA)   ^ SUCCESS);
        case HHH_GET_ROLE          : return (SUCCESS ^ XOR_GET_ROLE)          * (LicenseInterfaces::Value(VAL_GET_ROLE)          ^ SUCCESS);
        case HHH_PUT_ROLE          : return (SUCCESS ^ XOR_PUT_ROLE)          * (LicenseInterfaces::Value(VAL_PUT_ROLE)          ^ SUCCESS);
        case HHH_MUTEX_SPINLOK     : return (SUCCESS ^ XOR_MUTEX_SPINLOK)     * (LicenseInterfaces::Value(VAL_MUTEX_SPINLOK)     ^ SUCCESS);
        default: return 0;
    }
}
