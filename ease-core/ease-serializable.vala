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

public interface Ease.Serializable
{
	public abstract string[] serialize_exclude();
	
	/**
	 * Simply combines two arrays, for use with serialize_exclude.
	 */
	public string[] serialize_combine(string[] one, string[] two)
	{
		string[] combined = new string[one.length + two.length];
		
		for (int i = 0; i < one.length; i++)
		{
			if (i < one.length) combined[i] = one[i];
			else combined[i] = two[i - one.length];
		}
		
		return combined;
	}
	
	/**
	 * Triggers the serialize_custom function properly for subclasses.
	 */
	internal bool serialize_custom_run(string property, Json.Object object)
	{
		return serialize_custom(property, object);
	}
	
	/**
	 * Allows custom serialization for specific properties that cannot be
	 * serialized in the typical way.
	 *
	 * If the property was serialized in a custom manner, the function should
	 * return true, otherwise false. By default, this function simply returns
	 * false.
	 *
	 * @param property The property to serialize.
	 * @param object The JSON object to modify.
	 */
	public virtual bool serialize_custom(string property, Json.Object object)
	{
		return false;
	}
	
	/**
	 * Triggers the serialize_custom function properly for subclasses.
	 */
	internal bool deserialize_custom_run(string property, Json.Object object)
	{
		return deserialize_custom(property, object);
	}
	
	/**
	 * Allows custom deserialization for specific properties that cannot be
	 * deserialized in the typical way.
	 *
	 * If the property was deserialized in a custom manner, the function should
	 * return true, otherwise false. By default, this function simply returns
	 * false.
	 *
	 * @param property The property to deserialize.
	 * @param object The JSON object to read from.
	 */
	public virtual bool deserialize_custom(string property, Json.Object object)
	{
		return false;
	}
}
