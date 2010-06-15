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
 * Buttons for switching between slides in an {@link EditorWindow}
 * 
 * The SlideButtons for a {@link Document} are displayed in a
 * {@link SlideButtonPanel} at the left of an{@link EditorWindow}.
 */
public class Ease.SlideButton : Gtk.Button
{
	public int slide_id { get; set; }
	public Slide slide { get; set; }

	private Gtk.AspectFrame aspect;
	private Gtk.Alignment align;

	// the Slide preview
	private Gtk.DrawingArea drawing;

	// the editor window this button is in
	private EditorWindow owner;

	// the panel the button is in
	private SlideButtonPanel panel;

	bool dont_loop;
	
	/**
	 * Creates a new SlideButton.
	 * 
	 * The SlideButtons are displayed in a column at the left of an
	 * {@link EditorWindow}.
	 *
	 * @param id The ID number of this SlideButton, from 1 up.
	 * @param s  The {@link Slide} that this SlideButton displays.
	 * @param win The {@link EditorWindow} that this SlideButton is
	 * displayed in.
	 * @param pan The {@link SlideButtonPanel} that this SlideButton is
	 * displayed in.
	 */
	public SlideButton(int id, Slide s, EditorWindow win, SlideButtonPanel pan)
	{
		slide = s;
		slide_id = id;
		owner = win;
		panel = pan;

		// make the slide thumbnail
		drawing = new Gtk.DrawingArea();
		
		// make the aspect frame
		aspect = new Gtk.AspectFrame("", 0.5f, 0.5f, s.parent.aspect, false);
		aspect.label = null;
		aspect.add(drawing);

		// place things together
		align = new Gtk.Alignment(0.5f, 0.5f, 1, 1);
		align.set_padding(0, 0, 0, 0);

		// set the style of the button
		relief = Gtk.ReliefStyle.NONE;
		focus_on_click = false;
		show_all();
		add(aspect);

		clicked.connect(() => {
			for (unowned GLib.List<Gtk.Widget>* itr =
			     panel.slides_box.get_children();
			     itr != null; itr = itr->next)
			{
				((SlideButton*)(itr->data))->set_relief(Gtk.ReliefStyle.NONE);
			}
			
			relief = Gtk.ReliefStyle.NORMAL;
			owner.load_slide(slide_id);
		});
		
		aspect.size_allocate.connect((rect) => {
			if (dont_loop)
			{
				dont_loop = false;
				return;
			}
			aspect.set_size_request(0, (int)(rect.width / slide.parent.aspect));
			dont_loop = true;
		});
		
		drawing.expose_event.connect((area, event) => {
			draw();
			return false;
		});
	}
	
	/**
	 * Draws the SlideButton's preview.
	 */
	public void draw()
	{
		// get a context for the drawing area
		var context = Gdk.cairo_create(drawing.get_window());
		
		// get the size of the drawing area
		var allocation = Gtk.Allocation();
		drawing.get_allocation(out allocation);
		
		context.save();
		context.scale(((float)allocation.width) / slide.parent.width,
		              ((float)allocation.height) / slide.parent.height);
		
		// write the slide
		try { PDFExporter.write_slide(slide, context); }
		catch (Error e)
		{
			log("", LogLevelFlags.LEVEL_WARNING, "%s\n", e.message);
		}
		context.restore();
	}
}

