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
 * An implementation of {@link Source.BaseView} with a Gtk.HPaned
 *
 * Source.View consists of a {@link Source.List}, a separator, and a Gtk.Bin
 * packed into a Gtk.HBox.
 */
public class Source.PaneView : BaseView
{	
	/**
	 * Creates an empty Source.View. Add groups with add_group().
	 *
	 * @param with_separator If true, a Gtk.Separator is included to the right
	 * of the drag handle.
	 */
	public PaneView(bool with_separator)
	{
		// create base widgets
		base();
		
		// create pane widgets and build the view
		var hpane = new Gtk.HPaned();
		hpane.pack1(list, false, false);
		
		// if a separator is requested, build an hbox with it and the bin
		if (with_separator)
		{
			var hbox = new Gtk.HBox(false, 0);
			hbox.pack_start(new Gtk.VSeparator(), false, false, 0);
			hbox.pack_start(bin, true, true, 0);
			hpane.pack2(hbox, true, false);
		}
		
		// otherwise, just pack the bin in
		else
		{
			hpane.pack2(bin, true, false);
		}
		
		// add the hpaned to the view
		add(hpane);
	}
}

