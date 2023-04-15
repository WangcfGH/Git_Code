#include "stdafx.h"


CReplayModel::CReplayModel()
{
}


CReplayModel::~CReplayModel()
{
}

int CReplayModel::GetReplayInitalDataSize(int nTotalChairs)
{
    return (CHAIR_CARDS * sizeof(int) * nTotalChairs);
}

