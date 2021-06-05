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

class sw_KeyTracker : sw_Tracker
{

  override
  void initialize()
  {
    mIsEnabled = sw_Cvar.from("sw_enable_keys");
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    if (!mIsEnabled.getBool()) return NULL;

    sw_Messages result = NULL;

    for (Inventory inv = players[consolePlayer].mo.Inv; inv; inv = inv.Inv)
    {
      if (!(inv is "Key")) continue;

      string className = inv.getClassName();
      int oldValue = savedStatus.at(className).toInt();
      int newValue = inv.amount;

      if (oldValue == newValue) continue;

      if (result == NULL) result = sw_Messages.create();
      result.push(inv.getTag(), oldValue, newValue);
      savedStatus.insert(className, string.format("%d", newValue));
    }

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private sw_Cvar mIsEnabled;

} // class sw_WeaponTracker
