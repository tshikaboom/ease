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
	
	// tree view
	private Gtk.TreeView slides;
	private Gtk.ListStore list_store;
	private Gtk.CellRendererPixbuf renderer;
	
	// thumbnails on disk
	private static string m_temp_dir;
	private static string? temp_dir
	{
		get
		{
			if (m_temp_dir != null) return m_temp_dir;
			try { return m_temp_dir = Temp.request_str("thumbnails"); }
			catch (GLib.Error e)
			{
				critical("Could not create temporary directory for thumbnails");
			}
			return null;
		}
	}
	private static int temp_count = 0;
	
	private const int WIDTH_REQUEST = 100;
	private const int PREV_WIDTH = 76;
	private const int PADDING = 4;
	
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
		width_request = WIDTH_REQUEST;

		// set the scrollbar policy
		vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		hscrollbar_policy = Gtk.PolicyType.NEVER;
		shadow_type = Gtk.ShadowType.IN;
		
		// create the list store and add all current slides
		list_store = new Gtk.ListStore(3, typeof(Gdk.Pixbuf), typeof(Slide),
		                                  typeof(string));
		Gtk.TreeIter iter;
		foreach (var slide in document.slides)
		{
			list_store.append(out iter);
			string path = "";
			var pb = pixbuf(slide, PREV_WIDTH, out path);
			list_store.set(iter, 0, pb, 1, slide, 2, path);
		}
		
		// create the tree view
		slides = new Gtk.TreeView();
		slides.headers_visible = false;
		renderer = new Gtk.CellRendererPixbuf();
		renderer.set_padding(PADDING, PADDING);
		slides.insert_column_with_attributes(-1, "Slides", renderer,
		                                     "pixbuf", 0);
		slides.set_model(list_store);
		
		// add the tree view with a viewport
		var viewport = new Gtk.Viewport(null, null);
		viewport.set_shadow_type(Gtk.ShadowType.NONE);
		viewport.add(slides);
		add(viewport);
		
		// switch slides when the selection changes
		slides.get_selection().changed.connect((sender) => {
			slides.get_selection().selected_foreach((m, p, itr) => {
				Slide s = new Slide();
				m.get(itr, 1, ref s);
				owner.load_slide(document.slides.index_of(s));
			});
		});
		
		// handle the document's slide_added signal
		document.slide_added.connect((slide, index) => {
			Gtk.TreeIter itr;
			list_store.insert(out itr, index);
			string path = "";
			var pb = pixbuf(slide, PREV_WIDTH, out path);
			list_store.set(itr, 0, pb, 1, slide, 2, path);
		});
		
		// redraw all slides when the size allocation changes
		/*viewport.size_allocate.connect((sender, alloc) => {
			var width = alloc.width - 2 * PADDING;
			
			Gtk.TreeIter itr;
			if (!list_store.get_iter_first(out itr)) return;
			for (; list_store.iter_next(ref itr);)
			{
				Slide s = new Slide();
				list_store.get(itr, 1, ref s);
				list_store.set(itr, 0, pixbuf(s, width));
			}
		});*/
	}
	
	/**
	 * Creates a Gdk.Pixbuf for a given slide.
	 *
	 * @param slide The slide to create a pixbuf of.
	 */
	private Gdk.Pixbuf? pixbuf(Slide slide, int width, out string path)
	{
		var height = (int)((float)width * slide.parent.height /
		                                  slide.parent.width);
		var surface = new Cairo.ImageSurface(Cairo.Format.RGB24, width, height);
		
		var context = new Cairo.Context(surface);
		context.save();
		context.scale((float)width / slide.parent.width,
		              (float)height / slide.parent.height);
		
		try
		{
			slide.cairo_render_sized(context, width, height);
		}
		catch (GLib.Error e)
		{
			critical(_("Error drawing slide preview: %s"), e.message);
		}
		
		// render a black rectangle around the slide
		/*context.rectangle(0, 0, width, height);
		context.set_source_rgb(0, 0, 0);
		context.stroke();*/
		
		context.restore();
		
		// HACK: write it to a PNG, load it and return
		path = Path.build_filename(temp_dir,
		                           (temp_count++).to_string() + ".png");
		surface.write_to_png(path);
		
		/*return new Gdk.Pixbuf.from_data(surface.get_data(), Gdk.Colorspace.RGB,
		                                true, 8,
		                                surface.get_width(),
		                                surface.get_height(),
		                                surface.get_stride(), null);*/
		try { return new Gdk.Pixbuf.from_file(path); }
		catch (GLib.Error e) { error(e.message); return null; }
	}
}

