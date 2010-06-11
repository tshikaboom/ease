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
 * A widget for switching between multiple data sources.
 *
 * SourceList contains {@link SourceGroup}s, which in turn contain
 * {@link SourceItem}s. Each SourceItem is linked to a Gtk.Widget, which
 * is displayed in the SourceList's linked Gtk.Bin when clicked.
 *
 * For a simple SourceList next to bin implementation, use {@link SourceView}.
 */
public class Ease.SourceList : Gtk.Alignment
{
	/**
	 * The child of this widget, provides scrollbars if necessary.
	 */
	private Gtk.ScrolledWindow scroll;
	
	/**
	 * Gtk.VBox to contain this SourceList's {@link SourceGroup}s.
	 */
	private Gtk.VBox box;
	
	/**
	 * The bin used by this widget's {@link SourceItem}s to display their
	 * linked widgets.
	 */
	private Gtk.Bin bin;
	
	/**
	 * The currently selected {@link SourceItem}.
	 */
	private SourceItem selected;
	
	/**
	 * The Gtk.ShadowType of the scrolled window.
	 */
	private const Gtk.ShadowType SHADOW = Gtk.ShadowType.NONE;
	
	/**
	 * The behaviour of the horizontal scroll bar.
	 */
	private const Gtk.PolicyType H_POLICY = Gtk.PolicyType.NEVER;
	
	/**
	 * The behaviour of the vertical scroll bar.
	 */
	private const Gtk.PolicyType V_POLICY = Gtk.PolicyType.AUTOMATIC;
	
	/**
	 * Emitted when a {@link SourceItem} in this SourceList is clicked.
	 *
	 * @param sender The SourceItem that was clicked.
	 */
	public signal void clicked(SourceItem sender);

	/**
	 * Creates a SourceList and links it to a Gtk.Bin
	 *
	 * @param linked_bin The Gtk.Bin to link this SourceView with.
	 */
	public SourceList(Gtk.Bin linked_bin)
	{
		// create widgets
		scroll = new Gtk.ScrolledWindow(null, null);
		box = new Gtk.VBox(false, 0);
		
		// set properties
		bin = linked_bin;
		scroll.shadow_type = SHADOW;
		scroll.hscrollbar_policy = H_POLICY;
		scroll.vscrollbar_policy = V_POLICY;
		set(0, 0, 1, 1);
		
		// assemble
		scroll.add_with_viewport(box);
		add(scroll);
	}
	
	/**
	 * Adds a group to the {@link SourceList}, automatically setting up click
	 * signals.
	 *
	 * @param group The group to add.
	 */
	public void add_group(SourceGroup group)
	{
		box.pack_start(group, false, false, 0);
		
		group.clicked.connect((sender) => {
			// deselect the old selected widget, if any
			if (selected != null && selected != sender)
			{
				selected.selected = false;
			}
			
			// remove the bin's old child, if any
			var child = bin.get_child();
			if (child != null)
			{
				bin.remove(child);
			}
			
			// add the new child
			bin.add(sender.widget);
			bin.show_all();
			
			// select the sender
			sender.selected = true;
			selected = sender;
			
			// emit a clicked event
			clicked(sender);
		});
	}
}

