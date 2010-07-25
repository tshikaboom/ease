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
 * The internal representation of Ease documents. Contains {@link Slide}s.
 *
 * The Ease Document class is generated from JSON and writes back to JSON
 * when saved.
 */
public class Ease.Document : SlideSet
{
	/**
	 * The JSON filename in a document archive.
	 */
	private const string JSON_FILE = "Document.json";
	
	/**
	 * The default master title for newly created {@link Slide}s.
	 */
	public const string DEFAULT_SLIDE = Theme.CONTENT_HEADER;
	
	/**
	 * The default master slide for the first slide.
	 */
	private const string DEFAULT_FIRST = Theme.TITLE;
	
	/**
	 * Path of the Document's {@link Theme} data files.
	 */
	public const string THEME_PATH = "Theme";

	/**
	 * The {@link Theme} linked to this Document.
	 */
	public Theme theme { get; set; }
	
	/**
	 * The width of the Document, in pixels.
	 */
	public int width { get; set; }
	
	/**
	 * The height of the Document, in pixels.
	 */
	public int height { get; set; }
	
	/**
	 * The aspect ratio of the Document.
	 */
	public float aspect { get { return (float)width / (float)height; } }
	
	/**
	 * Emitted when a {@link Slide} is deleted from the Document.
	 */
	public signal void slide_deleted(Slide slide, int index);
	
	/**
	 * Emitted when a {@link Slide} is added to the Document.
	 */
	public signal void slide_added(Slide slide, int index);

	/**
	 * Default constructor, creates an empty Document.
	 * 
	 * Creates a new, empty document with no slides. Sets up base properties
	 */
	public Document() { }
	
	public Document.from_saved(string file_path) throws GLib.Error
	{
		this();
		
		filename = absolute_path(file_path);
		path = Temp.extract(filename);
	
		var parser = new Json.Parser();
		
		// attempt to load the file
		parser.load_from_file(Path.build_filename(path, JSON_FILE));
		
		// grab the root object
		var root = parser.get_root().get_object();
		
		// set document properties
		width = (int)root.get_string_member("width").to_int();
		height = (int)root.get_string_member("height").to_int();
		
		// add all slides
		var slides = root.get_array_member("slides");
		
		for (var i = 0; i < slides.get_length(); i++)
		{
			var node = slides.get_object_element(i);
			add_slide(length, new Slide.from_json(node));
		}
		
		// get the document's theme
		var theme_path = Path.build_filename(THEME_PATH, Theme.JSON_PATH);
		var theme_full_path = Path.build_filename(path, theme_path);
		
		if (File.new_for_path(theme_full_path).query_exists(null))
		{
			theme = new Theme.json(theme_full_path);
			theme.path = theme_full_path;
		}
	}
	
	/**
	 * Theme constructor, used for new documents.
	 *
	 * @param doc_theme The {@link Theme} for this Document.
	 * @param w The width of the new Document.
	 * @param h The height of the new Document.
	 */
	public Document.from_theme(Theme doc_theme,
	                           int w, int h) throws GLib.Error
	{
		assert(doc_theme != null);
		
		// set the document's dimensions
		width = w;
		height = h;
		
		// allocate a temp directory for the new document
		path = Temp.request();
		
		// copy the theme to a path within the document
		theme = doc_theme.copy_to_path(Path.build_filename(path, THEME_PATH));
		
		// copy media to the new path
		theme.copy_media(path);
		
		// get the master for the first slide
		var slide = theme.create_slide(DEFAULT_FIRST, width, height);
		slide.parent = this;
		append_slide(slide);
	}
	
	public void to_json() throws GLib.Error
	{
		var root = new Json.Node(Json.NodeType.OBJECT);
		var obj = new Json.Object();
		
		// set basic document properties
		obj.set_string_member("width", width.to_string());
		obj.set_string_member("height", height.to_string());
		
		// add the document's slides
		var slides_json = new Json.Array();
		foreach (var s in slides)
		{
			slides_json.add_element(s.to_json());
		}
		obj.set_array_member("slides", slides_json);
		
		// set the root object
		root.set_object(obj);
		
		// write to JSON file
		var generator = new Json.Generator();
		generator.set_root(root);
		generator.pretty = true;
		generator.to_file(Path.build_filename(path, JSON_FILE));
		
		// archive
		Temp.archive(path, filename);
	}
	
	/**
	 * Inserts a new {@link Slide} into the Document
	 *
	 * @param s The {@link Slide} to insert.
	 * @param index The position of the new {@link Slide} in the Document.
	 */
	public override void add_slide(int index, Slide s)
	{
		s.parent = this;
		base.add_slide(index, s);
		slide_added(s, index);
	}
	
	/**
	 * {@inheritDoc}
	 */
	public override void append_slide(Slide s)
	{
		base.append_slide(s);
		slide_added(s, slides.size - 1);
	}
	
	/**
	 * Removes the specified {@link Slide}, returning an Slide that the editor
	 * can safely jump to.
	 *
	 * @param s The slide to remove.
	 */
	public Slide rm_slide(Slide s)
	{
		int ind = index_of(s);
		
		slides.remove(s);
		slide_deleted(s, ind);
		
		if (ind == 0) return slides.get(0);
		return slides.get(ind - 1);
	}
	
	/**
	 * Returns whether or not the Document has a {@link Slide} after the
	 * passed in {@link Slide}.
	 */
	public bool has_next_slide(Slide slide)
	{
		for (int i = 0; i < slides.size - 1; i++)
		{
			if (slides.get(i) == slide)
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Exports this as a PDF file.
	 *
	 * @param win The window that dialogs should be modal for.
	 */
	public void export_to_pdf(Gtk.Window win)
	{
		string path;
		
		var dialog = new Gtk.FileChooserDialog(_("Export to PDF"),
		                                       win,
		                                       Gtk.FileChooserAction.SAVE,
		                                       "gtk-save",
		                                       Gtk.ResponseType.ACCEPT,
		                                       "gtk-cancel",
		                                       Gtk.ResponseType.CANCEL,
		                                       null);
		
		if (dialog.run() == Gtk.ResponseType.ACCEPT)
		{
			// clean up the file dialog
			path = dialog.get_filename();
			dialog.destroy();
		}
		else
		{
			dialog.destroy();
			return;
		}
		
		try
		{
			// create a PDF surface
			var surface = new Cairo.PdfSurface(path, width, height);
			var context = new Cairo.Context(surface);
		
			foreach (var s in slides)
			{
				s.cairo_render(context);
				context.show_page();
			}
		
			surface.flush();
			surface.finish();
		}
		catch (Error e)
		{
			error_dialog(_("Error Exporting to PDF"), e.message);
		}
	}
	
	/**
	 * Exports this Document to an HTML file.
	 *
	 * @param window The window that the progress dialog should be modal for.
	 */
	public void export_to_html(Gtk.Window window)
	{
		// make an HTMLExporter
		var exporter = new HTMLExporter();
		
		if (!exporter.request_path(window))
		{
			return;
		}
	
		// intialize the html string
		var html = exporter.HEADER.printf(width, height);
	
		// substitute in the values
		
		// add each slide
		for (var i = 0; i < slides.size; i++)
		{
			slides.get(i).to_html(ref html, exporter, 1.0 / slides.size, i);
		}
		
		// finish the document
		html += "\n</body>\n</html>\n";
		
		// write the document to file
		try
		{
			var file = File.new_for_path(exporter.path);
			var stream = file.replace(null, true, FileCreateFlags.NONE, null);
			var data_stream = new DataOutputStream(stream);
			data_stream.put_string(html, null);
		}
		catch (GLib.Error e)
		{
			error_dialog(_("Error exporting as HTML"), e.message);
		}
		
		exporter.finish();
	}
}

