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
 * Abstract base for a simple implementation of a widget using
 * {@link Source.List}.
 *
 * Source.BaseView creates a {@link Source.List} and a Gtk.Bin. These can be
 * placed into container widgets by subclasses.
 */
public abstract class Source.BaseView : Gtk.Alignment
{
	/**
	 * The content view.
	 */
	protected Gtk.Alignment bin;
	
	/**
	 * The {@link Source.List} for this Source.BaseView.
	 */
	protected Source.List list;
	
	/**
	 * The width request of this Source.BaseView's {@link Source.List}.
	 */
	public int list_width_request
	{
		get { return list.width_request; }
		set { list.width_request = value; }
	}
	
	/**
	 * Creates the list and bin widgets. Should be called by subclass
	 * constructors.
	 */
	public BaseView()
	{
		// create widgets
		bin = new Gtk.Alignment(0, 0, 1, 1);
		list = new Source.List(bin);
		
		// set properties
		set(0, 0, 1, 1);
	}
	
	/**
	 * Adds a {@link Source.Group} to this Source.BaseView's
	 * {@link Source.List}.
	 *
	 * @param group The group to add.
	 */
	public void add_group(Source.Group group)
	{
		list.add_group(group);
	}
}

