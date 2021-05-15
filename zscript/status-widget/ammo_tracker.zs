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
    let result = sw_Messages.create();

    uint ammosNumber = mAmmos.size();
    for (uint i = 0; i < ammosNumber; ++i)
    {
      string ammo = mAmmos[i];
      int oldValue = savedStatus.at(ammo).toInt();
      int newValue = players[consolePlayer].mo.countInv(ammo);

      if (oldValue == newValue) continue;

      class<Actor> ammoClass = ammo;
      result.push(getDefaultByType(ammoClass).getTag(), oldValue, newValue);

      savedStatus.insert(ammo, string.format("%d", newValue));
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
