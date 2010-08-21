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

namespace Bindings
{
	private Gee.LinkedList<Binding> bindings()
	{
		if (bindings_lazy != null) return bindings_lazy;
		return bindings_lazy = new Gee.LinkedList<Binding>();
	}
	private Gee.LinkedList<Binding> bindings_lazy;
	
	public void connect(GLib.Object object1, string property1,
	                    GLib.Object object2, string property2)
	{
		// connect signal handlers
		connect_signals(object1, property1, object2, property2);
		
		// keep track of the binding
		bindings().add(new Binding(object1, property1, object2, property2));
		
		// when an object is finalized, destroy all bindings for it
		object1.weak_ref(on_finalize);
		object2.weak_ref(on_finalize);
	}
	
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
	
	public void drop_object(GLib.Object object)
	{
		drop_if((obj1, prop1, obj2, prop2) => {
			return (obj1 == object || obj2 == object);
		});
	}
	
	public void drop_property(GLib.Object object, string property)
	{
		drop_if((obj1, prop1, obj2, prop2) => {
			return ((obj1 == object && prop1 == property) ||
			        (obj2 == object && prop2 == property));
		});
	}
	
	public void drop_if(DropFunction function)
	{
		if (bindings().size < 1) return;
		
		var itr = bindings().iterator();
		for (itr.first();; itr.next())
		{
			var binding = itr.get() as Binding;
			weak GLib.Object object1 = binding.obj1, object2 = binding.obj2;
			weak string prop1 = binding.prop1, prop2 = binding.prop2;
			if (function(binding.obj1, binding.prop1,
			             binding.obj2, binding.prop2))
			{
				itr.remove();
				bool has1 = false, has2 = false;
				foreach (var b in bindings())
				{
					if (b.obj1 == object1 || b.obj2 == object1)
					{
						has1 = true;
					}
					if (b.obj1 == object2 || b.obj2 == object2)
					{
						has2 = true;
					}
				}
				
				if (!has1) object1.notify[prop1].disconnect(on_notify);
				if (!has2) object2.notify[prop2].disconnect(on_notify);
			}
			if (!itr.has_next()) break;
		}
	}
	
	private void on_notify(GLib.Object object, GLib.ParamSpec pspec)
	{
		debug("asdf");
		foreach (var binding in bindings())
		{
			if (binding.silence) continue;
			if (object == binding.obj1 && pspec.name == binding.prop1)
			{
				// don't loop on this binding
				binding.silence = true;
				
				// perform the set
				set(object, pspec.name, binding.obj2, binding.prop2);
				
				// start acting on this binding again
				binding.silence = false;
			}
			else if (object == binding.obj2 && pspec.name == binding.prop2)
			{
				// don't loop on this binding
				binding.silence = true;
				
				// perform the set
				set(object, pspec.name, binding.obj1, binding.prop1);
				
				// start acting on this binding again
				binding.silence = false;
			}
		}
	}
	
	private void set(GLib.Object from, string from_prop,
	                 GLib.Object to, string to_prop)
	{
		// get the value from the sender
		var type = from.get_class().find_property(from_prop).value_type;
		var storage = GLib.Value(type);
		from.get_property(from_prop, ref storage);
		
		// set the value on the bound object
		to.set_property(to_prop, storage);
	}
	
	private void on_finalize(GLib.Object object)
	{
		if (bindings().size < 1) return;
		
		var itr = bindings().iterator();
		for (itr.first();; itr.next())
		{
			var binding = itr.get() as Binding;
			if (binding.obj1 == object || binding.obj2 == object)
			{
				itr.remove();
			}
			if (!itr.has_next()) break;
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
	
	public delegate bool DropFunction(GLib.Object object1, string property1,
	                                  GLib.Object object2, string property2);
	
	private class Binding : GLib.Object
	{
		public weak GLib.Object obj1;
		public weak GLib.Object obj2;
		public string prop1;
		public string prop2;
		public bool silence = false;
		
		public Binding(GLib.Object o1, string p1, GLib.Object o2, string p2)
		{
			obj1 = o1;
			obj2 = o2;
			prop1 = p1;
			prop2 = p2;
		}
	}
}

