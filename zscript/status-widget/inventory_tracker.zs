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

class sw_InventoryTracker : sw_Tracker
{

  override
  void initialize() {}

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    let result = new("sw_Messages");

    let player = players[consolePlayer].mo;
    for (Inventory inv = player.firstInv(); inv != NULL; inv = inv.nextInv())
    {
      string className = inv.getClassName();
      int oldValue = savedStatus.at(className).toInt();
      int newValue = inv.amount;

      if (oldValue == newValue) continue;

      let message = new("sw_Message");
      message.name      = inv.getTag();
      message.oldValue  = oldValue;
      message.newValue  = newValue;
      message.startTime = level.time;

      savedStatus.insert(className, string.format("%d", newValue));
      result.messages.push(message);
    }

    return result;
  }

} // class sw_InventoryTracker
