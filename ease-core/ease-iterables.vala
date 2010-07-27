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
 * A Gtk.TreeModel iterable through "foreach".
 *
 * The foreach loop returns a Gtk.TreeIter. The Gtk.TreePath provided by the 
 * built in TreeModel foreach function is not (immediately) available.
 */
public interface Ease.Iterable.TreeModel : Gtk.TreeModel
{
	public Iterator iterator()
	{
		return new Iterator(this);
	}

	public class Iterator
	{
		private Gtk.TreeIter itr;
		private TreeModel model;
		private bool more;
		
		public Iterator(TreeModel self)
		{
			more = self.get_iter_first(out itr);
			model = self;
		}
		
		public bool next()
		{
			return more;
		}
		
		public Gtk.TreeIter get()
		{
			var ret = itr;
			more = model.iter_next(ref itr);
			return ret;
		}
	}
}

/**
 * ListStore with the {@link Iterable.TreeModel} mixin.
 */
public class Ease.Iterable.ListStore : Gtk.ListStore, TreeModel
{
	/**
	 * Creates an iterable ListStore with the specified types.
	 */
	public ListStore(Type[] types)
	{
		set_column_types(types);
	}
	
	/**
	 * The number of items in this ListStore.
	 */
	public int size { get { return iter_n_children(null); } }
}
