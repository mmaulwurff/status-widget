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

class sw_PowerupTracker : sw_Tracker
{

  override
  void initialize()
  {
    mIsEnabled = sw_Cvar.from("sw_enable_powerups");
  }

  override
  sw_Messages getStatus(Dictionary savedStatus)
  {
    if (!mIsEnabled.getBool()) return NULL;

    sw_Messages result = NULL;

    PlayerPawn player = players[consolePlayer].mo;
    for (Inventory inv = player.Inv; inv; inv = inv.Inv)
    {
      if (!(inv is "Powerup")) continue;

      string className = inv.getClassName();

      int oldValue = savedStatus.at(className).toInt();
      let power    = Powerup(inv);
      int newValue = int(ceil((power.effectTics + 1) / 35.0)); // we are 1 tic late, compensate.

      if (oldValue == newValue) continue;

      // Skip powerups with growing effect tics like berserk.
      if (newValue > oldValue && newValue > Powerup(inv.default).effectTics) continue;

      string name = (inv.getTag(".") == ".") ? makePowerupName(className) : inv.getTag();
      if (result == NULL) result = sw_Messages.create();
      result.push(name, oldValue, newValue);
      savedStatus.insert(className, string.format("%d", newValue));
    }

    return result;
  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  string makePowerupName(string className)
  {
    if (className.left(5) == "Power") className.remove(0, 5);
    return beautify(className);
  }

  private static
  string beautify(string aString)
  {
    string result = separateCamelCase(aString);
    result.replace("_", " ");
    return result;
  }

  private static
  string separateCamelCase(string source)
  {
    string result  = "";

    int letter1 = source.byteAt(0);
    int letter2;

    int sourceLength = source.length();
    for (int i = 1; i < sourceLength; ++i)
    {
      letter2 = source.byteAt(i);
      bool mustAddSpace = (isLowercase(letter1) && isUppercase(letter2));
      result.appendFormat(mustAddSpace ? "%c " : "%c", letter1);
      letter1 = letter2;
    }
    result.appendFormat("%c", letter2);

    return result;
  }

  private static bool isLowercase(int code) { return (LowercaseA <= code && code <= LowercaseZ); }
  private static bool isUppercase(int code) { return (UppercaseA <= code && code <= UppercaseZ); }

  enum ASCII
  {
    UppercaseA = 65,
    UppercaseZ = 90,
    LowercaseA = 97,
    LowercaseZ = 122,
  }

  private sw_Cvar mIsEnabled;

} // class sw_PowerupTracker
