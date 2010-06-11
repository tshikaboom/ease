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
 * A simple implementation of a widget using {@link SourceList}.
 *
 * SourceView consists of a {@link SourceList} and a Gtk.Bin packed into a
 * Gtk.HBox.
 */
public class Ease.SourceView : Gtk.HBox
{
	/**
	 * The content view.
	 */
	private Gtk.Alignment bin;
	
	/**
	 * The {@link SourceList} for this SourceView.
	 */
	private SourceList list;
	
	/**
	 * Creates an empty SourceView. Add groups with add_group().
	 */
	public SourceView()
	{
		// create widgets
		bin = new Gtk.Alignment(0, 0, 1, 1);
		list = new SourceList(bin);
		
		// set properties
		homogeneous = false;
		
		// assemble
		pack_start(list, false, false, 0);
		pack_start(new Gtk.VSeparator(), false, false, 0);
		pack_start(bin, true, true, 0);
	}
	
	/**
	 * Adds a {@link SourceGroup} to this SourceView's {@link SourceList}.
	 *
	 * @param group The group to add.
	 */
	public void add_group(SourceGroup group)
	{
		list.add_group(group);
	}
}

