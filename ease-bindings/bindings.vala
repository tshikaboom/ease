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
 * Provides functions for simply synchonizing GObject properties of different
 * instances.
 */
namespace Binding
{
	private Gee.LinkedList<Binding> bindings()
	{
		if (bindings_lazy != null) return bindings_lazy;
		return bindings_lazy = new Gee.LinkedList<Binding>();
	}
	private Gee.LinkedList<Binding> bindings_lazy;
	
	/**
	 * Binds two properties of two GObjects together. When one is changed,
	 * the other will be updated to match its value. If the values differ
	 * initially, the first object's property value will be used. The properties
	 * must be of the same type.
	 *
	 * Binding a property of an object does not increase its reference count.
	 * If an object's reference count drops to zero and it is finalized, all
	 * bindings that it currently has will be dropped.
	 *
	 * @param object1 The first object.
	 * @param property1 The first object's property.
	 * @param object2 The second object.
	 * @param property2 The second object's property.
	 */
	public void connect(GLib.Object object1, string property1,
	                    GLib.Object object2, string property2)
	{
		// keep track of the binding
		bindings().add(new Binding(object1, property1, object2, property2));
	}
	
	public void transformed(GLib.Object object1, string property1,
	                        TransformFunction transform_function1,
	                        GLib.Object object2, string property2,
	                        TransformFunction transform_function2)
	{
		bindings().add(new Binding.transformed(object1, property1,
		                                       transform_function1,
		                                       object2, property2,
		                                       transform_function2));
	}
	
	/**
	 * Drops a binding. Order does not need to match the order in which
	 * 
	 * @param object1 The first object.
	 * @param property1 The first object's property.
	 * @param object2 The second object.
	 * @param property2 The second object's property.
	 */
	public void drop(GLib.Object object1, string property1,
	                 GLib.Object object2, string property2)
	{
		drop_if((obj1, prop1, obj2, prop2) => {
			return ((obj1 == object1 && prop1 == property1 &&
			         obj2 == object2 && prop2 == property2) ||
			        (obj2 == object1 && prop2 == property1 &&
			         obj1 == object2 && prop1 == property2));
		});
	}
	
	/**
	 * Drops all bindings that the given object is involved in.
	 *
	 * @param object The object to drop all bindings for.
	 */
	public void drop_object(GLib.Object object)
	{
		drop_if((obj1, prop1, obj2, prop2) => {
			return (obj1 == object || obj2 == object);
		});
	}
	
	/**
	 * Drops all bindings for a specific property of an object.
	 *
	 * @param object The object to drop bindings from.
	 * @param property The property to unbind.
	 */
	public void drop_property(GLib.Object object, string property)
	{
		drop_if((obj1, prop1, obj2, prop2) => {
			return ((obj1 == object && prop1 == property) ||
			        (obj2 == object && prop2 == property));
		});
	}
	
	/**
	 * Allows conditional dropping of bindings via a {@link DropFunction}.
	 *
	 * @param function A {@link DropFunction}.
	 */
	public void drop_if(DropFunction function)
	{
		if (bindings().size < 1) return;
		
		// iterate over each binding
		var itr = bindings().iterator();
		for (itr.first();; itr.next())
		{
			var binding = itr.get() as Binding;
			
			// remove the binding if desired
			if (function(binding.obj1, binding.prop1,
			             binding.obj2, binding.prop2))
			{
				itr.remove();
				
				// check if there now are any bindings referring to the objects
				bool has1 = false, has2 = false;
				foreach (var b in bindings())
				{
					if (b.obj1 == binding.obj1 || b.obj2 == binding.obj1)
					{
						has1 = true;
					}
					if (b.obj1 == binding.obj2 || b.obj2 == binding.obj2)
					{
						has2 = true;
					}
				}
				
				// if not, disconnect their signal handlers
				if (!has1)
				{
					binding.obj1.notify[binding.prop1].disconnect(on_notify);
				}
				if (!has2)
				{
					binding.obj2.notify[binding.prop2].disconnect(on_notify);
				}
			}
			if (!itr.has_next()) break;
		}
	}
	
	private void on_notify(GLib.Object object, GLib.ParamSpec pspec)
	{
		foreach (var binding in bindings())
		{
			if (binding.silence) continue;
			if ((object == binding.obj1 && pspec.name == binding.prop1) ||
			    (object == binding.obj2 && pspec.name == binding.prop2))
			{
				binding.apply(object);
			}
		}
	}
	
	private void connect_signals(GLib.Object obj1, string prop1,
	                             GLib.Object obj2, string prop2)
	{
		bool has1 = false, has2 = false;
		
		foreach (var binding in bindings())
		{
			if ((binding.obj1 == obj1 && binding.prop1 == prop1) ||
			    (binding.obj2 == obj1 && binding.prop2 == prop1))
			{
				has1 = true;
			}
			if ((binding.obj1 == obj2 && binding.prop1 == prop2) ||
			    (binding.obj2 == obj2 && binding.prop2 == prop2))
			{
				has2 = true;
			}
		}
		
		if (!has1) obj1.notify[prop1].connect(on_notify);
		if (!has2) obj2.notify[prop2].connect(on_notify);
	}
	
	/**
	 * A delegate for conditional dropping of bindings. The delegate will be
	 * called for each binding currently in existence. Returning "true" will
	 * cause the binding to be dropped.
	 */
	public delegate bool DropFunction(GLib.Object object1, string property1,
	                                  GLib.Object object2, string property2);
	
	/**
	 * Transforms one type into another.
	 */
	public delegate GLib.Value TransformFunction(GLib.Value value_in);
	
	private class Binding : GLib.Object
	{
		public weak GLib.Object obj1;
		public weak GLib.Object obj2;
		public string prop1;
		public string prop2;
		public bool silence = false;
		private TransformFunction func1;
		private TransformFunction func2;
		
		public Binding(GLib.Object o1, string p1, GLib.Object o2, string p2)
		{
			// set members
			obj1 = o1;
			obj2 = o2;
			prop1 = p1;
			prop2 = p2;
			
			// perform initial synchronization
			apply(o1);
			
			// connect signal handlers
			connect_signals(o1, p1, o2, p2);
			
			// when an object is finalized, destroy all bindings for it
			o1.weak_ref(drop_object);
			o2.weak_ref(drop_object);
		}
		
		public Binding.transformed(GLib.Object o1, string p1,
		                           TransformFunction f1,
		                           GLib.Object o2, string p2,
		                           TransformFunction f2)
		{
			func1 = f1;
			func2 = f2;
			this(o1, p1, o2, p2);
		}
		
		public void apply(GLib.Object from)
		{
			// don't apply a silenced binding
			if (silence) return;
			
			// don't loop on this binding
			silence = true;
			
			GLib.Object to;
			string from_prop, to_prop;
			TransformFunction func = null;
				
			if (from == obj1)
			{
				from_prop = prop1;
				to_prop = prop2;
				to = obj2;
				func = func1;
			}
			else if (from == obj2)
			{
				from_prop = prop2;
				to_prop = prop1;
				to = obj1;
				func = func2;
			}
			else return; // this binding doesn't have that object
		
			// get the value from the sender
			var type = from.get_class().find_property(from_prop).value_type;
			var storage = GLib.Value(type);
			from.get_property(from_prop, ref storage);
		
			// set the value on the bound object
			to.set_property(to_prop, func == null ? storage : func(storage));
			
			// start acting on this binding again
			silence = false;
		}
	}
}

