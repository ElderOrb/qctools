/*  Copyright (c) BAVC. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license that can
 *  be found in the License.html file in the root of the source tree.
 */

//---------------------------------------------------------------------------
#ifndef AudioStats_H
#define AudioStats_H

#include "Core/Core.h"
#include "Core/CommonStats.h"

#include <string>
#include <vector>
#include <stdint.h>
using namespace std;

struct AVFrame;
struct AVStream;

class AudioStats : public CommonStats
{
public:
    // Constructor / Destructor
    AudioStats(size_t FrameCount=0, double Duration=0, AVStream* stream = NULL);
    ~AudioStats();

    // External data
    void                        StatsFromExternalData(const char* Data, size_t Size);
    void                        StatsFromFrame(struct AVFrame* Frame, int Width, int Height);
    void                        TimeStampFromFrame(struct AVFrame* Frame, size_t FramePos);
    string                      StatsToXML(const activefilters& filters);
};

#endif // Stats_H
