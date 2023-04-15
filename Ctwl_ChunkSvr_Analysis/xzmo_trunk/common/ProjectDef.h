#pragma once

#define     GAME_CLIENT         _T("xzmo")
#define     GAME_APPNAME        _T("3D版四川麻将")
#define     GAME_ID             283
#define     PORT_OF_GAMESVR     26283 //需要修改
#define     PORT_OF_GAMEMPSVR   (PORT_OF_GAMESVR + 20000)
#define     PORT_OF_CHUNKSVR    60465
#define     PORT_OF_ASSITSVR    (PORT_OF_CHUNKSVR + 1)
#define     PORT_OF_ASSITMPSVR  (PORT_OF_CHUNKSVR + 2)
#define     PORT_OF_CHUNKLOG    (PORT_OF_CHUNKSVR + 3)

#if GAME_ID == 0
    #error GAME_ID need to modify
#endif
#if PORT_OF_CHUNKSVR == 60000
    #error PORT_OF_CHUNKSVR need to modify
#endif
