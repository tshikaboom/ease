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
 * The Ease Document class is generated from XML and writes back to XML
 * when saved.
 */
public class Ease.Document : SlideSet
{
	/**
	 * The default master title for newly created {@link Slide}s.
	 */
	private const string DEFAULT_SLIDE = "Standard";

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
	 * Default constructor, creates an empty Document.
	 * 
	 * Creates a new, empty document with no slides. Used for creating new
	 * documents (which can then add a default slide).
	 */
	public Document() { }
	
	/**
	 * Theme constructor, used for new documents.
	 *
	 * @param doc_theme The {@link Theme} for this Document.
	 * @param w The width of the new Document.
	 * @param h The height of the new Document.
	 */
	public Document.from_theme(Theme doc_theme, int w, int h) throws GLib.Error
	{
		width = w;
		height = h;
		theme = doc_theme;
		
		assert (doc_theme != null);

		// allocate a temp directory for the new document
		path = Temp.request();
		
		// copy media to the new path
		doc_theme.copy_media(path);
		
		// get the master
		var master = theme.slide_by_title(DEFAULT_SLIDE);
		
		// add the first slide
		append_slide(new Slide.from_master(master, this, width, height, true));
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

