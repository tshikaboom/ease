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

/**
 * Contains data about an {@link Element}
 *
 * ElementMap contains a Gee.Map with string keys and
 * {@link ElementMapValue} values. Each {@link Element} has exactly one
 * ElementMap, which stores all data about its owner.
 *
 * The vast majority of XML conversion of {@link Element}s is done by
 * ElementMap.
 */
public class Ease.ElementMap : Object
{
	/**
	 * The internal data store for ElementMap.
	 */
	private Gee.Map<string, ElementMapValue> map;
	
	/**
	 * Creates an ElementMap.
	 * 
	 * The ElementMap class stores data about an {@link Element}, allowing
	 * for a single class to represent every type of {@link Element}, with
	 * less type checking.
	 *
	 * @param filename The path to the filename.
	 */
	public ElementMap()
	{
		map = new Gee.HashMap<string, ElementMapValue>();
	}
	
	/**
	 * Creates and returns a copy of this ElementMap.
	 */
	public ElementMap copy()
	{
		var ret = new ElementMap();
		
		foreach (var key in map.keys)
		{
			ret.set("%s".printf(key), "%s".printf(get(key)));
		}
		
		return ret;
	}
	
	/**
	 * Output this ElementData as JSON.
	 * 
	 * Returns a JSON object with the element's data.
	 */
	public Json.Node to_json()
	{
		var node = new Json.Node(Json.NodeType.OBJECT);
		var obj = new Json.Object();
		
		foreach (var key in map.keys)
		{
			obj.set_string_member(key, get(key));
		}
		
		node.set_object(obj);
		return node;
	}

	/**
	 * Set a value.
	 * 
	 * ElementMap uses a key/value system to make exporting XML and adding
	 * new types of Elements easy. 
	 *
	 * @param key The map key.
	 * @param val A string to be stored as the key's value.
	 */
	public new void set(string key, string val)
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

	/**
	 * Get a value, given a key.
	 *
	 * @param key The key to get a value for.
	 */
	public new string get(string key)
	{
		return map.get(key).str_val;
	}
	
	/**
	 * Prints each of the map's keys and values to stdout.
	 */
	public void print()
	{
		foreach (var key in map.keys)
		{
			stdout.printf("%s: %s\n", key, get(key));
		}
	}
}

