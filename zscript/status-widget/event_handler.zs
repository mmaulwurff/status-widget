/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2021
 *
 * This file is part of Status-Widget.
 *
 * Status-Widget is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Status-Widget is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Status-Widget.  If not, see <https://www.gnu.org/licenses/>.
 */

class sw_EventHandler : EventHandler
{

  override
  void worldTick()
  {
    if (players[consolePlayer].mo == NULL) return;

    if (level.time == 1) initialize();
    else if (level.time > 1) updateQueue();
  }

  override
  void renderOverlay(RenderEvent event)
  {
    if (!mIsInitialized || players[consolePlayer].mo == NULL) return;

    uint queueSize = mQueue.size();
    if (queueSize == 0) return;

    Array<string> lines;
    double scale = mOptions.getScale();
    int longestRemainingLife = 0;

    int maxLife = 35 * mOptions.getLifetime();

    for (uint i = 0; i < queueSize; ++i)
    {
      let item = mQueue[i];

      int change = item.newValue - item.oldValue;
      string maybePlus = change > 0 ? "\cd+" : "\cg";
      lines.push(string.format("\cj%s %s%d\cj → \c-%d", item.name, maybePlus, change, item.newValue));

      longestRemainingLife = max(longestRemainingLife, maxLife - (level.time - mQueue[i].startTime));
    }

    int textWidth = 0;
    for (uint i = 0; i < queueSize; ++i)
    {
      textWidth = max(textWidth, NewSmallFont.stringWidth(lines[i]));
    }
    textWidth = int((textWidth + 1) * scale);

    int lineHeight = int(NewSmallFont.getHeight() * scale);
    int textHeight = lineHeight * queueSize;

    int screenWidth = Screen.getWidth();
    int screenHeight = Screen.getHeight();
    int alignment = mOptions.getAlignment();
    int baseX = makeBaseX(int(mOptions.getX() * screenWidth), textWidth, alignment);
    baseX = clamp(baseX, 0, screenWidth - textWidth - BORDER * 2);
    double y = min(mOptions.getY() * screenHeight, screenHeight - textHeight);

    int fadeTime = maxLife / 3;
    double dimAlpha = longestRemainingLife > fadeTime ? 1.0 : double(longestRemainingLife) / fadeTime;
    Screen.Dim( mOptions.getBackgroundColor()
              , 0.5 * dimAlpha * mOptions.getOpacity()
              , baseX
              , int(y)
              , textWidth + BORDER * 2
              , textHeight
              );

    for (uint i = 0; i < queueSize; ++i)
    {
      int remainingLife = maxLife - (level.time - mQueue[i].startTime);
      double alpha = remainingLife > fadeTime ? 1.0 : double(remainingLife) / fadeTime;
      int textX = makeTextX(baseX, lines[i], textWidth, alignment, scale);
      int max = mQueue[i].maxValue;
      int fontColor = (max > 0 && mQueue[i].newValue >= max) ? Font.CR_Cyan : Font.CR_White;
      Screen.drawText( NewSmallFont
                     , fontColor
                     , textX
                     , y
                     , lines[i]
                     , DTA_ScaleX , scale
                     , DTA_ScaleY , scale
                     , DTA_Alpha  , alpha * mOptions.getOpacity()
                     );
      y += lineHeight;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private ui
  int makeTextX(int x, string text, int maxTextWidth, int alignment, double scale)
  {
    switch (alignment)
    {
    case 0: return BORDER + x;
    case 1: return BORDER + x + (maxTextWidth - int(NewSmallFont.stringWidth(text) * scale)) / 2;
    case 2: return BORDER + x + (maxTextWidth - int(NewSmallFont.stringWidth(text) * scale));
    }

    return BORDER + x;
  }

  private ui
  int makeBaseX(int x, int textWidth, int alignment)
  {
    switch (alignment)
    {
    case 0: return x;
    case 1: return x - textWidth / 2;
    case 2: return x - textWidth;
    }

    return x;
  }

  private
  void initialize()
  {
    uint classesNumber = AllClasses.size();
    for (uint i = 0; i < classesNumber; ++i)
    {
      class aClass = AllClasses[i];
      if (aClass is "sw_Tracker" && aClass != "sw_Tracker")
      {
        let tracker = sw_Tracker(new(aClass));
        tracker.initialize();
        mTrackers.push(tracker);
      }
    }

    mState = Dictionary.create();
    mOptions = sw_Options.from();

    // Initialize storage. Non-elegant way.
    updateQueue();
    mQueue.clear();

    mIsInitialized = true;
  }

  private
  void updateQueue()
  {
    uint trackersNumber = mTrackers.size();
    for (uint t = 0; t < trackersNumber; ++t)
    {
      let tracker = mTrackers[t];
      sw_Messages status = tracker.getStatus(mState);

      if (status != NULL) mQueue.append(status.messages);
    }

    compressQueue();
    limitQueue();
  }

  private
  void compressQueue()
  {
    uint queueSize = mQueue.size();
    if (queueSize == 0) return;

    Array<sw_Message> newQueue;

    let firstItem = mQueue[0];
    int firstLifetime = level.time - firstItem.startTime;
    int maxLife = 35 * mOptions.getLifetime();
    if (firstLifetime < maxLife) newQueue.push(firstItem);

    for (uint i = 1; i < queueSize; ++i)
    {
      let item = mQueue[i];
      int lifetime = level.time - item.startTime;
      if (lifetime >= maxLife) continue;

      uint newQueueSize = newQueue.size();
      bool isMerged = false;
      for (uint j = 0; j < newQueueSize; ++j)
      {
        let previousItem = newQueue[j];
        int previousChange = previousItem.newValue - previousItem.oldValue;
        int change = item.newValue - item.oldValue;
        bool sameSign = (previousChange > 0 && change > 0) || (previousChange <= 0 && change <= 0);
        if (previousItem.name == item.name && sameSign)
        {
          previousItem.startTime = item.startTime;
          previousItem.newValue  = item.newValue;
          previousItem.maxValue  = item.maxValue;
          isMerged = true;
        }
      }

      if (!isMerged) newQueue.push(item);
    }

    mQueue.move(newQueue);
  }

  private
  void limitQueue()
  {
    uint limit = mOptions.getLimit();
    uint queueSize = mQueue.size();
    if (queueSize <= limit) return;

    Array<sw_Message> newQueue;

    for (uint i = queueSize - limit; i < queueSize; ++i)
    {
      newQueue.push(mQueue[i]);
    }

    mQueue.move(newQueue);
  }

  const BORDER = 3;

  private bool mIsInitialized;

  private Array<sw_Tracker> mTrackers;
  private Dictionary mState;
  private Array<sw_Message> mQueue;
  private sw_Options mOptions;

} // class sw_EventHandler
