/*  Ease, a GTK presentation application
    Copyright (C) 2010 Nate Stedman

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

namespace Ease
{
	public class ElementMap
	{
		private Gee.Map<string, ElementMapValue> map;

		public ElementMap()
		{
			map = new Gee.HashMap<string, ElementMapValue>();
		}

		public void set_int(string key, int val)
		{
			if (map.has_key(key))
			{
				map.get(key).int_val = val;
			}
			else
			{
				var value = new ElementMapValue();
				value.int_val = val;
				map.set(key, value);
			}
		}

		public void set_str(string key, string val)
		{
			if (map.has_key(key))
			{
				map.get(key).str_val = val;
			}
			else
			{
				var value = new ElementMapValue();
				value.str_val = val;
				map.set(key, value);
			}
		}
		
		public int get_int(string key)
		{
			return map.get(key).int_val;
		}

		public string get_str(string key)
		{
			return map.get(key).str_val;
		}
	}
}
