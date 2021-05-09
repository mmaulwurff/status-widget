/* Copyright Alexander Kromm (mmaulwurff@gmail.com) 2021
 *
 * This file is part of Status Widget.
 *
 * Status Widget is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) any
 * later version.
 *
 * Status Widget is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * Status Widget.  If not, see <https://www.gnu.org/licenses/>.
 */

/**
 * This class provides access to a user or server Cvar.
 *
 * Accessing Cvars through this class is faster because calling Cvar.GetCvar()
 * is costly. This class caches the result of Cvar.GetCvar() and handles
 * loading a savegame.
 */
class sw_Cvar
{

// public: /////////////////////////////////////////////////////////////////////////////////////////

  static
  sw_Cvar from(string name)
  {
    let result = new("sw_Cvar");

    result.mName = name;
    result.load();

    return result;
  }

  string getString() { if (!mCvar) load(); return mCvar.getString(); }
  bool   getBool()   { if (!mCvar) load(); return mCvar.getInt();    }
  int    getInt()    { if (!mCvar) load(); return mCvar.getInt();    }
  double getDouble() { if (!mCvar) load(); return mCvar.getFloat();  }

// private: ////////////////////////////////////////////////////////////////////////////////////////

  private
  void load()
  {
    mCvar = Cvar.getCvar(mName, players[consolePlayer]);

    if (mCvar == NULL)
    {
      Console.printf("cvar %s not found", mName);
    }
  }

  private string         mName;
  private transient Cvar mCvar;

} // class sw_Cvar
