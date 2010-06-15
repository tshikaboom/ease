/*
Copyright 2010 Nate Stedman. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of
conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list
of conditions and the following disclaimer in the documentation and/or other materials
provided with the distribution.

THIS SOFTWARE IS PROVIDED BY NATE STEDMAN ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NATE STEDMAN OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
 * A widget for switching between multiple data sources.
 *
 * Source.List contains {@link Source.Group}s, which in turn contain
 * {@link Source.Item}s. Each Source.Item is linked to a Gtk.Widget, which
 * is displayed in the Source.List's linked Gtk.Bin when clicked.
 *
 * For a simple Source.List next to bin implementation, use {@link Source.View}.
 */
public class Source.List : Gtk.Alignment
{
	/**
	 * The child of this widget, provides scrollbars if necessary.
	 */
	private Gtk.ScrolledWindow scroll;
	
	/**
	 * Gtk.VBox to contain this Source.List's {@link Source.Group}s.
	 */
	private Gtk.VBox box;
	
	/**
	 * The bin used by this widget's {@link Source.Item}s to display their
	 * linked widgets.
	 */
	private Gtk.Bin bin;
	
	/**
	 * The currently selected {@link Source.Item}.
	 */
	private Source.Item selected;
	
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
	 * Padding around the Source.List
	 */
	public const int PADDING = 5;
	
	/**
	 * Padding between groups.
	 */
	public const int GROUP_PADDING = 5;
	
	/**
	 * Emitted when a {@link Source.Item} in this Source.List is clicked.
	 *
	 * @param sender The Source.Item that was clicked.
	 */
	public signal void clicked(Source.Item sender);

	/**
	 * Creates a Source.List and links it to a Gtk.Bin
	 *
	 * @param linked_bin The Gtk.Bin to link this Source.View with.
	 */
	public List(Gtk.Bin linked_bin)
	{
		// create widgets
		scroll = new Gtk.ScrolledWindow(null, null);
		box = new Gtk.VBox(false, GROUP_PADDING);
		var viewport = new Gtk.Viewport(null, null);
		
		// set properties
		bin = linked_bin;
		scroll.shadow_type = SHADOW;
		viewport.shadow_type = SHADOW;
		scroll.hscrollbar_policy = H_POLICY;
		scroll.vscrollbar_policy = V_POLICY;
		set(0, 0, 1, 1);
		set_padding(PADDING, PADDING, PADDING, PADDING);
		
		// assemble
		viewport.add(box);
		scroll.add(viewport);
		add(scroll);
	}
	
	/**
	 * Adds a group to the {@link Source.List}, automatically setting up click
	 * signals.
	 *
	 * @param group The group to add.
	 */
	public void add_group(Source.BaseGroup group)
	{
		box.pack_start(group, false, false, 0);
		
		group.clicked.connect((sender) => {
			// deselect the old selected widget, if any
			if (selected != null && selected != sender)
			{
				selected.selected = false;
			}
			
			if (sender.widget != null)
			{
				// remove the bin's old child, if any
				var child = bin.get_child();
				if (child != null)
				{
					bin.remove(child);
				}
			
				// add the new child
				bin.add(sender.widget);
				bin.show_all();
			}
			
			// select the sender
			sender.selected = true;
			selected = sender;
		
			// emit a clicked event
			clicked(sender);
		});
	}
}

