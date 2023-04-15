#pragma once
class CReplayModel
{
public:
    CReplayModel();
    virtual ~CReplayModel();

    virtual int  GetReplayInitalDataSize(int nTotalChairs);

public:
    CReplayRecord m_ReplayRecord;
    int m_nReplayYQWScore[MAX_CHAIR_COUNT];
};

