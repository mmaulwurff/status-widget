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

class sw_OxygenTracker : sw_Tracker
{

  override
  void initialize()
  {
    mIsEnabled = sw_Cvar.from("sw_enable_oxygen");
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    if (!mIsEnabled.getBool()) return NULL;

    PlayerInfo player = players[consolePlayer];
    int oldValue  = savedStatus.at(KEY).toInt();
    int airSupply = (player.air_finished - Level.maptime) / 35;

    if (oldValue == airSupply) return NULL;

    let result = sw_Messages.create();
    result.push(StringTable.localize("$SW_OXYGEN"), oldValue, airSupply);
    savedStatus.insert(KEY, string.format("%d", airSupply));
    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  const KEY = "sw_oxygen";

  private sw_Cvar mIsEnabled;

} // class sw_OxygenTracker
