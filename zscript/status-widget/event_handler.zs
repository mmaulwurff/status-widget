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
    }

    int textWidth = 0;
    for (uint i = 0; i < queueSize; ++i)
    {
      textWidth = max(textWidth, NewSmallFont.stringWidth(lines[i]));
    }
    textWidth = int((textWidth + 1) * scale);

    int lineHeight = int(NewSmallFont.getHeight() * scale);
    double y = 100;
    int border = 3;
    Screen.Dim("000000", 0.5, 0, int(y), textWidth + border * 2, lineHeight * queueSize);

    for (uint i = 0; i < queueSize; ++i)
    {
      Screen.drawText( NewSmallFont
                     , Font.CR_White
                     , border
                     , y
                     , lines[i]
                     , DTA_ScaleX, scale
                     , DTA_ScaleY, scale
                     );
      y += lineHeight;
    }
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

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

    // Initialize storage. Non-elegant way.
    updateQueue();
    mQueue.clear();

    mScale = sw_Cvar.from("sw_scale");
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
  }

  private
  void compressQueue()
  {
    uint queueSize = mQueue.size();
    if (queueSize == 0) return;

    Array<sw_Message> newQueue;

    let firstItem = mQueue[0];
    int firstLifetime = level.time - firstItem.startTime;
    if (firstLifetime < MAX_LIFE) newQueue.push(firstItem);

    for (uint i = 1; i < queueSize; ++i)
    {
      let item = mQueue[i];
      int lifetime = level.time - item.startTime;
      if (lifetime >= MAX_LIFE) continue;

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

  const MAX_LIFE = 35 * 3;

  private Array<sw_Tracker> mTrackers;
  private Dictionary mState;
  private Array<sw_Message> mQueue;

  private sw_Cvar mScale;

} // class sw_EventHandler
