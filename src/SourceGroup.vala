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
 * A group in a {@link Source.List}.
 *
 * Source.Group can contain any amount of {@link Source.Item}s. Above these items,
 * a header is shown in order to categorize a {@link Source.List}.
 */
public class Source.Group : Gtk.Alignment
{
	/**
	 * The group header, displayed on top of the {@link Source.Item}s.
	 */
	private Gtk.Label header;
	
	/**
	 * The Gtk.VBox containing all {@link Source.Item}s.
	 */
	private Gtk.VBox items_box;
	
	/**
	 * The Gtk.VBox containing the header and items_box.
	 */
	private Gtk.VBox all_box;
	
	/**
	 * Format string for the group header.
	 */
	private const string HEADER_FORMAT = "<b>%s</b>";
	
	/**
	 * Padding between each {@link Source.Item}.
	 */
	private const int ITEM_PADDING = 2;
	
	/**
	 * Padding to the left of all items.
	 */
	private const int ITEMS_PADDING_LEFT = 5;
	
	/**
	 * Padding to the right of all items.
	 */
	private const int ITEMS_PADDING_RIGHT = 5;
	
	/**
	 * Padding above the set of items.
	 */
	private const int ITEMS_PADDING_TOP = 5;
	
	/**
	 * Padding below the set of all items.
	 */
	private const int ITEMS_PADDING_BOTTOM = 10;
	
	/**
	 * Emitted when a child {@link Source.Item} of this group is clicked.
	 *
	 * @param sender The {@link Source.Item} that was clicked.
	 */
	public signal void clicked(Item sender);
	
	/**
	 * Create a new, empty, Source.Group.
	 *
	 * @param title The header of the Source.Group.
	 */
	public Group(string title)
	{
		// create subwidgets
		all_box = new Gtk.VBox(false, 0);
		items_box = new Gtk.VBox(true, ITEM_PADDING);
		var items_align = new Gtk.Alignment(0, 0, 1, 0);
		items_align.set_padding(ITEMS_PADDING_TOP,
		                        ITEMS_PADDING_BOTTOM,
		                        ITEMS_PADDING_LEFT,
		                        ITEMS_PADDING_RIGHT);
		header = new Gtk.Label(HEADER_FORMAT.printf(title));
		header.use_markup = true;
		var header_align = new Gtk.Alignment(0, 0, 0, 0);
		
		set(0, 0, 1, 0);
		
		// assemble contents
		items_align.add(items_box);
		header_align.add(header);
		all_box.pack_start(header_align, false, false, 0);
		all_box.pack_start(items_align, false, false, 0);
		add(all_box);
	}
	
	/**
	 * Adds a {@link Source.Item} to the end of this group.
	 *
	 * @param item The {@link Source.Item} to add.
	 */
	public void add_item(Item item)
	{
		items_box.pack_start(item, false, false, 0);
		
		item.clicked.connect((sender) => clicked(sender));
	}
}

