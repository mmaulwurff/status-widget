/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2020-2021
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

class sw_Message
{

  string name;
  int oldValue;
  int newValue;
  int startTime;

} // class sw_Message

class sw_Messages
{

  Array<sw_Message> messages;

} // class sw_Messages

class sw_Tracker abstract
{

  abstract play
  void initialize();

  abstract
  sw_Messages getStatus(Dictionary savedStatus);

} // class sw_Tracker

class sw_HealthTracker : sw_Tracker
{

  override
  void initialize() {}

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    int oldValue = savedStatus.at("health").toInt();
    int newValue = players[consolePlayer].health;

    if (oldValue == newValue) return NULL;

    let result  = new("sw_Messages");
    let message = new("sw_Message");

    message.name      = "Health";
    message.oldValue  = oldValue;
    message.newValue  = newValue;
    message.startTime = level.time;

    savedStatus.insert("health", string.format("%d", newValue));
    result.messages.push(message);

    return result;
  }

} // class sw_Tracker

class sw_AmmoTracker : sw_Tracker
{

  override
  void initialize()
  {
    uint classesNumber = AllActorClasses.size();
    for (uint i = 0; i < classesNumber; ++i)
    {
      class<Ammo> aClass = (class<Ammo>)(AllActorClasses[i]);
      if (aClass && getDefaultByType(aClass).getParentAmmo() == aClass)
      {
        mAmmos.push(aClass.getClassName());
      }
    }
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    let result = new("sw_Messages");

    uint ammosNumber = mAmmos.size();
    for (uint i = 0; i < ammosNumber; ++i)
    {
      string ammo = mAmmos[i];
      int oldValue = savedStatus.at(ammo).toInt();
      int newValue = players[consolePlayer].mo.countInv(ammo);

      if (oldValue == newValue) continue;

      let message = new("sw_Message");

      class<Actor> ammoClass = ammo;
      message.name      = getDefaultByType(ammoClass).getTag();
      message.oldValue  = oldValue;
      message.newValue  = newValue;
      message.startTime = level.time;

      savedStatus.insert(ammo, string.format("%d", newValue));
      result.messages.push(message);
    }

    if (result.messages.size() >= 18)
    {
      result.messages.clear();

      let message = new("sw_Message");

      message.name      = "Ammo Package";
      message.oldValue  = -1;
      message.newValue  = 1;
      message.startTime = level.time;

      result.messages.push(message);
    }

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  Array<string> mAmmos;

} // class sw_AmmoTracker

class sw_EventHandler : EventHandler
{

  override
  void playerEntered(PlayerEvent event)
  {
    if (event.playerNumber != consolePlayer) return;

    mTrackers.push(new("sw_HealthTracker"));
    mTrackers.push(new("sw_AmmoTracker"));

    uint trackersNumber = mTrackers.size();
    for (uint i = 0; i < trackersNumber; ++i)
    {
      mTrackers[i].initialize();
    }

    mState = Dictionary.create();

    // Initialize storage. Non-elegant way.
    updateQueue();
    mQueue.clear();
  }

  override
  void worldTick()
  {
    updateQueue();
  }

  override
  void renderOverlay(RenderEvent event)
  {
    uint queueSize = mQueue.size();
    if (queueSize == 0) return;

    Array<string> lines;
    double scale = 2.0;

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
    Screen.Dim("000000", 0.5, 0, y, textWidth + border * 2, lineHeight * queueSize);

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

} // class sw_EventHandler
