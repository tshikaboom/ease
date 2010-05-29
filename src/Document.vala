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
public class Ease.Document : GLib.Object
{
	public Gee.ArrayList<Slide> slides { get; set; }
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
	 * The file path of the Document.
	 */
	public string path { get; set; }
	
	/**
	 * The number of {@link Slide}s in the Document.
	 */
	public int length { get { return slides.size; } }

	/**
	 * Default constructor, used for new documents.
	 * 
	 * Creates a new, empty document with no slides. Used for creating new
	 * documents (which can then add a default slide).
	 */
	public Document()
	{
		slides = new Gee.ArrayList<Slide>();
	}
	
	/**
	 * Inserts a new {@link Slide} into the Document
	 *
	 * @param s The {@link Slide} to insert.
	 * @param index The position of the new {@link Slide} in the Document.
	 */
	public void add_slide(int index, Slide s)
	{
		s.parent = this;
		slides.insert(index, s);
	}
	
	public void export_to_html(Gtk.Window window)
	{
		// make an HTMLExporter
		var exporter = new HTMLExporter();
		
		if (!exporter.request_path(window))
		{
			return;
		}
	
		// intialize the html string
		var html = "<!DOCTYPE html>\n<html>\n";
		
		// make the header
		html += "<head>\n<title>Presentation</title>\n" + HTMLExporter.js;
		html += "<style>\n.slide {\ndisplay:none;\nwidth:" + width.to_string() +
		        "px;\noverflow:hidden;height:" + height.to_string() +
		        "px; position: relative;margin: 20px auto 20px auto}\n" + 
		        "html { padding: 0px; margin: 0px; background-color:" +
		        "black;}\n</style>\n</head>\n";
		
		// make the body
		html += "<body onload=\"load()\">\n";
		
		// add each slide
		for (var i = 0; i < slides.size; i++)
		{
			slides.get(i).to_html(ref html, exporter, 1.0 / slides.size, i);
		}
		
		// finish the document
		html += "</body>\n</html>\n";
		
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
			var dialog = new Gtk.MessageDialog(null,
			                                   Gtk.DialogFlags.NO_SEPARATOR,
			                                   Gtk.MessageType.ERROR,
			                                   Gtk.ButtonsType.CLOSE,
			                                   _("Error exporting: %s"),
			                                   e. message);
			dialog.title = _("Error Exporting");
			dialog.border_width = 5;
			dialog.run();
		}
		
		exporter.finish();
	}
}

