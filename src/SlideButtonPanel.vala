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
 * Panel on the left side of an {@link EditorWindow}
 * 
 * A SlideButtonPanel contains a {@link SlideButton} for each
 * {@link Slide} in the current {@link Document}.
 */
public class Ease.SlideButtonPanel : Gtk.ScrolledWindow
{
	private Document document;
	private EditorWindow owner;
	public Gtk.VButtonBox slides_box;
	private Gtk.Alignment align;
	
	/**
	 * Creates a SlideButtonPanel
	 * 
	 * A SlideButtonPanel forms the left edge of an {@link EditorWindow}.
	 *
	 * @param d The Document that the {@link EditorWindow} displays.
	 * @param win The {@link EditorWindow} that this SlideButtonPanel is
	 * part of.
	 */
	public SlideButtonPanel(Document d, EditorWindow win)
	{			
		document = d;
		owner = win;

		// set the scrollbar policy
		vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		hscrollbar_policy = Gtk.PolicyType.NEVER;
		
		slides_box = new Gtk.VButtonBox();
		for (int i = 0; i < document.slides.size; i++)
		{
			var button = new SlideButton(i, document.slides.get(i), owner, this);
			slides_box.pack_start(button, false, false, 0);
		}
		align = new Gtk.Alignment(0, 0, 1, 0);
		align.add(slides_box);
		var viewport = new Gtk.Viewport(null, null);
		viewport.set_shadow_type(Gtk.ShadowType.NONE);
		viewport.add(align);
		add(viewport);
		
//		slides_box.size_allocate.connect((box, rect) => {
//			slides_box.child_min_height = (int)(rect.width / document.aspect);
//			slides_box.child_min_width = rect.width;
//		});
//		
//		size_allocate.connect((self, rect) => {
//			var allocation = Gtk.Allocation();
//			slides_box.get_allocation(allocation);
//			
//			stdout.printf("\nasdf %i %i\n", rect.width, allocation.width);
//			
//			if (allocation.width > rect.width)
//			{
//				stdout.printf("\nsmaller");
//				slides_box.child_min_width = 0;
//			}
//		});
	}
	
	/**
	 * Adds a new {@link Slide} to the SlideButtonPanel.
	 *
	 * @param index The index of the new {@link Slide} in the {@link Document}.
	 * @param slide The {@link Slide} to add.
	 */
	public void add_slide(int index, Slide slide)
	{
		// create a new button
		var button = new SlideButton(index, slide, owner, this);
		
		// add the new button to the box
		slides_box.pack_start(button, false, false, 0);
		
		// put the button in the proper position
		slides_box.reorder_child(button, index);
		
		int i = 0;
		for (unowned GLib.List<Gtk.Widget>* itr = slides_box.get_children();
		     itr != null; itr = itr->next)
		{
			((SlideButton*)(itr->data))->slide_id = i;
			i++;
		}
		
		button.show_all();
	}
}

