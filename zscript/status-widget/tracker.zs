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

class sw_Message
{

  string name;
  int oldValue;
  int newValue;
  int startTime;

} // class sw_Message

class sw_Messages
{

  static
  sw_Messages create()
  {
    return new("sw_Messages");
  }

  void push(string name, int oldValue, int newValue)
  {
    let message = new("sw_Message");
    message.name      = name;
    message.oldValue  = oldValue;
    message.newValue  = newValue;
    message.startTime = level.time;

    messages.push(message);
  }

  Array<sw_Message> messages;

} // class sw_Messages

class sw_Tracker abstract
{

  abstract play
  void initialize();

  abstract
  sw_Messages getStatus(Dictionary savedStatus);

} // class sw_Tracker
