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

public static class Ease.Serializer
{
	private static Gee.TreeMap<GLib.Type, CollectionBox> collections;
	
	private const string TYPE_KEY = "__EASE_SERIALIZER_OBJECT_TYPE_NAME__";
	
	public static Json.Object write(GLib.Object object)
	{
		// create the json object
		var json = new Json.Object();
		
		// store the object's type in the reserved key
		json.set_string_member(TYPE_KEY, object.get_type().name());
		
		// check for any excluded properties
		string[] exclude = {};
		if (object is Serializable)
		{
			exclude = (object as Serializable).serialize_exclude();
		}
		
		// iterate and serialize properties
		foreach (var pspec in object.get_class().list_properties())
		{
			// don't serialize excluded types
			if (pspec.name in exclude) continue;
			
			// if the object implements Serializable, allow custom behavior
			if (object is Serializable)
			{
				if ((object as Serializable).serialize_custom_run(pspec.name,
				                                                  json))
					continue;
			}
			
			// get the object/not object as a value
			GLib.Value val = GLib.Value(pspec.value_type);
			object.get_property(pspec.name, ref val);
			
			// if the object is a registered collection, turn it into an array
			if (collections != null)
			{
				var type = pspec.value_type;
				bool iterated = false;
				do
				{
					CollectionIterator? iterator = null;
					if ((iterator = find_iterator(type)) != null)
					{
						var array = new Json.Array();
						iterator((GLib.Object)val, array);
						json.set_array_member(pspec.name, array);
						iterated = true;
						break;
					}
				} while (0 != (type = type.parent()));
				
				if (iterated) continue;
			}
			
			// serialize GObjects
			if (Value.type_transformable(pspec.value_type, typeof(Object)))
			{
				json.set_object_member(pspec.name, write((Object)val));
			}
			
			// serialize basic types
			if (pspec.value_type == typeof(string))
			{
				json.set_string_member(pspec.name, (string)val); continue;
			}
			
			if (pspec.value_type == typeof(bool))
			{
				json.set_boolean_member(pspec.name, (bool)val); continue;
			}
			
			if (pspec.value_type == typeof(char))
			{
				json.set_int_member(pspec.name, (char)val); continue;
			}
			
			if (pspec.value_type == typeof(uchar))
			{
				json.set_int_member(pspec.name, (uchar)val); continue;
			}
			
			if (pspec.value_type == typeof(int))
			{
				json.set_int_member(pspec.name, (int)val); continue;
			}
			
			if (pspec.value_type == typeof(uint))
			{
				json.set_int_member(pspec.name, (uint)val); continue;
			}
			
			if (pspec.value_type == typeof(long))
			{
				json.set_int_member(pspec.name, (long)val); continue;
			}
			
			if (pspec.value_type == typeof(ulong))
			{
				json.set_int_member(pspec.name, (ulong)val); continue;
			}
			
			if (pspec.value_type == typeof(size_t))
			{
				json.set_int_member(pspec.name, (size_t)val); continue;
			}
			
			if (pspec.value_type == typeof(ssize_t))
			{
				json.set_int_member(pspec.name, (ssize_t)val); continue;
			}
			
			if (pspec.value_type == typeof(int8))
			{
				json.set_int_member(pspec.name, (int8)val); continue;
			}
			
			if (pspec.value_type == typeof(uint8))
			{
				json.set_int_member(pspec.name, (uint8)val); continue;
			}
			
			/*if (pspec.value_type == typeof(int16))
			{
				json.set_int_member(pspec.name, (int16)val); continue;
			}
			
			if (pspec.value_type == typeof(uint16))
			{
				json.set_int_member(pspec.name, (uint16)val); continue;
			}*/
			
			if (pspec.value_type == typeof(int32))
			{
				json.set_int_member(pspec.name, (int32)val); continue;
			}
			
			if (pspec.value_type == typeof(uint32))
			{
				json.set_int_member(pspec.name, (uint32)val); continue;
			}
			
			if (pspec.value_type == typeof(int64))
			{
				json.set_int_member(pspec.name, (int64)val); continue;
			}
			
			if (pspec.value_type == typeof(float))
			{
				json.set_double_member(pspec.name, (float)val); continue;
			}
			
			if (pspec.value_type == typeof(double))
			{
				json.set_double_member(pspec.name, (double)val); continue;
			}
			
			if (pspec.value_type.is_enum())
			{
				json.set_int_member(pspec.name, (int)val); continue;
			}
			
			// uint64 won't fit in an int64, so make it a string to preserve
			// the content (instead of just casting back and forth)
			if (pspec.value_type == typeof(uint64))
			{
				json.set_string_member(pspec.name, "%lld".printf((uint64)val));
				continue;
			}
		}
		
		return json;
	}
	
	public static GLib.Object read(Json.Object json)
	{
		// create the object with the type that TYPE_KEY specifies
		var type = GLib.Type.from_name(json.get_string_member(TYPE_KEY));
		var object = GLib.Object.newv(type, {});
		
		// deserialize all properties
		json.foreach_member((jobj, property, node) => {
			if (property == TYPE_KEY) return;
		
			// if the object implements Serializable, allow custom behavior
			if (object is Serializable)
			{
				if ((object as Serializable).deserialize_custom_run(property,
				                                                    jobj))
					return;
			}
			
			// get a paramspec for the property to deserialize into
			var klass = object.get_class();
			debug("asdf %p", klass);
			var pspec = klass.find_property(property);
			
			if (pspec == null) debug("Well, fuck.");
			
			// create a GValue to serialize into
			GLib.Value val = GLib.Value(pspec.value_type);
			
			// deserialize GObjects
			if (Value.type_transformable(pspec.value_type, typeof(Object)))
			{
				val = read(json.get_object_member(pspec.name));
			}
			
			// serialize basic types
			else if (pspec.value_type == typeof(string))
			{
				val = json.get_string_member(property);
			}
			
			else if (pspec.value_type == typeof(bool))
			{
				val = json.get_boolean_member(property);
			}
			
			else if (pspec.value_type == typeof(char))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(uchar))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(int))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(uint))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(long))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(ulong))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(size_t))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(ssize_t))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(int8))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(uint8))
			{
				val = json.get_int_member(property);
			}
			
			/*else if (pspec.value_type == typeof(int16))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(uint16))
			{
				val = json.get_int_member(property);
			}*/
			
			else if (pspec.value_type == typeof(int32))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(uint32))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(int64))
			{
				val = json.get_int_member(property);
			}
			
			else if (pspec.value_type == typeof(float))
			{
				val = json.get_double_member(property);
			}
			
			else if (pspec.value_type == typeof(double))
			{
				val = json.get_double_member(property);
			}
			
			else if (pspec.value_type.is_enum())
			{
				val = json.get_int_member(property);
			}
			
			object.set_property(property, val);
		});
		
		return object;
	}
	
	/**
	 * Registers an iteration function for a collection type.
	 *
	 * When attempting to find a collection iterator, the serializer will search
	 * the main class first, then its parent class, etc. Interfaces implemented
	 * by each level will be searched first.
	 *
	 * @param type The type.
	 * @param callback The function to iterate over the type.
	 */
	public static void register(GLib.Type type,
	                            CollectionIterator iterator,
	                            CollectionBuilder builder)
	{
		if (collections == null)
		{
			collections = new Gee.TreeMap<GLib.Type, CollectionBox>();
		}
		
		collections.set(type, new CollectionBox(iterator, builder));
	}
	
	/**
	 * Registers the builtin iterations functions.
	 */
	public static void register_builtins()
	{
		// GList
		register(typeof(GLib.List), (object, array) => {
			foreach (var item in (GLib.List<GLib.Object>)object)
			{
				array.add_object_element(write(item));
			}
		}, (object, array) => {
			unowned GLib.List<Object> list = (GLib.List<Object>)object;
			array.foreach_element((a, index, node) => {
				list.append(read(node.get_object()));
			});
		});
		
		// Gee.List
		register(typeof(Gee.List), (object, array) => {
			foreach (var item in object as Gee.List<GLib.Object>)
			{
				array.add_object_element(write(item));
			}
		}, (object, array) => {
			var list = object as Gee.List<GLib.Object>;
			array.foreach_element((a, index, node) => {
				list.insert(list.size, read(node.get_object()));
			});
		});
	}
	
	private static CollectionIterator find_iterator(Type type)
	{
		if (collections.has_key(type))
		{
			// vala bug
			var box = collections.get(type);
			return box.iterator;
		}
		
		foreach (var t in type.interfaces())
		{
			if (collections.has_key(t))
			{
				// vala bug again
				var box = collections.get(t);
				return box.iterator;
			}
		}
	
		return null;
	}
	
	/**
	 * Allows collections of arbitrary types to be serialized.
	 *
	 * @param object The collection object to be serialized into a JSON array.
	 * @param array The JSON array to add elements to.
	 */
	public delegate void CollectionIterator(GLib.Object object,
	                                        Json.Array array);
	
	/**
	 * Allows collections of arbitrary types to be deserialized.
	 *
	 * @param object The collection object to be deserialized into.
	 * @param array The JSON array to deserialize.
	 */
	public delegate void CollectionBuilder(GLib.Object object,
	                                       Json.Array array);
	
	/**
	 * Delegates cannot be used as generic type arguments in Vala, so we have to
	 * box them.
	 */
	private class CollectionBox
	{
		public CollectionIterator iterator;
		public CollectionBuilder builder;
		
		public CollectionBox(CollectionIterator iter, CollectionBuilder builder)
		{
			this.iterator = iter;
			this.builder = builder;
		}
	}
}

