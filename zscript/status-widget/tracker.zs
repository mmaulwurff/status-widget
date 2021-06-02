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

/**
 * Derive your class from sw_Tracker to make new Trackers.
 */
class sw_Tracker abstract
{

  /**
   * Sets up the tracker. This function is called only once per Tracker, before
   * getStatus is called, typically at the level start.
   */
  abstract play
  void initialize();

  /**
   * This function is used to check current status and create messages if
   * needed.
   *
   * @param savedStatus contains last reported status: counts of things player
   * had before this moment. Trackers read and write to `savedStatus`.
   */
  abstract
  sw_Messages getStatus(Dictionary savedStatus);

} // class sw_Tracker

class sw_Messages
{

  /**
   * Create sw_Messages with this function.
   */
  static
  sw_Messages create()
  {
    return new("sw_Messages");
  }

  /**
   * Put new messages into sw_Messages with this function.
   *
   * @param name message name, visible in UI. Messages with the same name will
   * be merged together.
   * @param oldValue old value, used to calculate difference which is visible in UI.
   * @param newValue new value, visible in UI, used to calculate difference.
   * @param maxValue max value, optional. If new value is equal or greater than max,
   * it's color is changed.
   */
  void push(string name, int oldValue, int newValue, int maxValue = -1)
  {
    let message = new("sw_Message");
    message.name      = name;
    message.oldValue  = oldValue;
    message.newValue  = newValue;
    message.maxValue  = maxValue;
    message.startTime = level.time;

    messages.push(message);
  }

  Array<sw_Message> messages;

} // class sw_Messages

class sw_Message
{

  string name;
  int oldValue;
  int newValue;
  int maxValue;
  int startTime;

} // class sw_Message
