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
  void playerEntered(PlayerEvent event)
  {
    if (event.playerNumber != consolePlayer) return;

    initialize();
  }

  override
  void worldTick()
  {
    if (players[consolePlayer].mo == NULL) return;

    updateQueue();
  }

  override
  void renderOverlay(RenderEvent event)
  {
    if (players[consolePlayer].mo == NULL) return;

    uint queueSize = mQueue.size();
    if (queueSize == 0) return;

    Array<string> lines;
    double scale = mScale.getDouble();
    int longestRemainingLife = 0;

    int maxLife = 35 * mLifetime.getInt();

    for (uint i = 0; i < queueSize; ++i)
    {
      let item = mQueue[i];

      if (item.oldValue >= 0)
      {
        int change = item.newValue - item.oldValue;
        string maybePlus = change > 0 ? "\cd+" : "\cg";
        lines.push(string.format("%s %s%d\c- → %d", item.name, maybePlus, change, item.newValue));
      }
      else
      {
        lines.push(string.format("%s \cd+%d", item.name, item.newValue));
      }

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
    int alignment = mAlignment.getInt();
    int baseX = makeBaseX(int(mX.getDouble() * screenWidth), textWidth, alignment);
    baseX = clamp(baseX, 0, screenWidth - textWidth - BORDER * 2);
    double y = min(mY.getDouble() * screenHeight, screenHeight - textHeight);

    int fadeTime = maxLife / 3;
    double dimAlpha = longestRemainingLife > fadeTime ? 1.0 : double(longestRemainingLife) / fadeTime;
    Screen.Dim( mBackgroundColor.getString()
              , 0.5 * dimAlpha
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
      Screen.drawText( NewSmallFont
                     , Font.CR_White
                     , textX
                     , y
                     , lines[i]
                     , DTA_ScaleX , scale
                     , DTA_ScaleY , scale
                     , DTA_Alpha  , alpha
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

    mScale = sw_Cvar.from("sw_scale");
    mX     = sw_Cvar.from("sw_x");
    mY     = sw_Cvar.from("sw_y");

    mBackgroundColor = sw_Cvar.from("sw_background_color");

    mLimit     = sw_Cvar.from("sw_limit");
    mAlignment = sw_Cvar.from("sw_alignment");
    mLifetime  = sw_Cvar.from("sw_lifetime");

    // Initialize storage. Non-elegant way.
    updateQueue();
    mQueue.clear();
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
    int maxLife = 35 * mLifetime.getInt();
    if (firstLifetime < maxLife) newQueue.push(firstItem);

    for (uint i = 1; i < queueSize; ++i)
    {
      let item = mQueue[i];
      int lifetime = level.time - item.startTime;
      if (lifetime >= maxLife) continue;

      let previousItem = mQueue[i - 1];

      int previousChange = previousItem.newValue - previousItem.oldValue;
      int change = item.newValue - item.oldValue;
      bool sameSign = (previousChange > 0 && change > 0) || (previousChange <= 0 && change <= 0);
      if (previousItem.name == item.name && sameSign)
      {
        previousItem.startTime = item.startTime;
        previousItem.newValue = (previousItem.oldValue >= 0)
          ? item.newValue
          : previousItem.newValue + item.newValue
          ;
      }
      else
      {
        newQueue.push(item);
      }
    }

    mQueue.move(newQueue);
  }

  private
  void limitQueue()
  {
    uint limit = mLimit.getInt();
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

  private Array<sw_Tracker> mTrackers;
  private Dictionary mState;
  private Array<sw_Message> mQueue;

  private sw_Cvar mScale;
  private sw_Cvar mX;
  private sw_Cvar mY;
  private sw_Cvar mBackgroundColor;
  private sw_Cvar mLimit;
  private sw_Cvar mAlignment;
  private sw_Cvar mLifetime;

} // class sw_EventHandler
