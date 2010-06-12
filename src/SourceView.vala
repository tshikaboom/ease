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
 * A simple implementation of a widget using {@link Source.List}.
 *
 * Source.View consists of a {@link Source.List}, a separator, and a Gtk.Bin
 * packed into a Gtk.HBox.
 */
public class Source.View : Gtk.HBox
{
	/**
	 * The content view.
	 */
	private Gtk.Alignment bin;
	
	/**
	 * The {@link Source.List} for this Source.View.
	 */
	private Source.List list;
	
	/**
	 * Creates an empty Source.View. Add groups with add_group().
	 */
	public View()
	{
		// create widgets
		bin = new Gtk.Alignment(0, 0, 1, 1);
		list = new Source.List(bin);
		
		// set properties
		homogeneous = false;
		
		// assemble
		pack_start(list, false, false, 0);
		pack_start(new Gtk.VSeparator(), false, false, 0);
		pack_start(bin, true, true, 0);
	}
	
	/**
	 * Adds a {@link Source.Group} to this Source.View's {@link Source.List}.
	 *
	 * @param group The group to add.
	 */
	public void add_group(Source.Group group)
	{
		list.add_group(group);
	}
}

