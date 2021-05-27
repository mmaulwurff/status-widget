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

class sw_HealthTracker : sw_Tracker
{

  override
  void initialize()
  {
    mIsEnabled = sw_Cvar.from("sw_enable_health");
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    if (!mIsEnabled.getBool()) return NULL;

    int oldValue = savedStatus.at("health").toInt();
    int newValue = players[consolePlayer].health;

    if (oldValue == newValue) return NULL;

    let result = sw_Messages.create();
    result.push("Health", oldValue, newValue);

    savedStatus.insert("health", string.format("%d", newValue));

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private sw_Cvar mIsEnabled;

} // class sw_HealthTracker
