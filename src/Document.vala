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
	 * The file path of the Document.
	 */
	public string path { get; set; }

	/**
	 * Default constructor, used for new documents.
	 * 
	 * Creates a new, empty document with no slides. Used for creating new
	 * documents (which can then add a default slide).
	 */
	public Document() { }
	
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
	
	public void export_to_html(Gtk.Window window)
	{
		// make an HTMLExporter
		var exporter = new HTMLExporter();
		
		if (!exporter.request_path(window))
		{
			return;
		}
	
		// intialize the html string
		var html = """<!DOCTYPE html>
<html>
<head>
	<title>Presentation</title>
	%s
	<style>
		.slide {
			width: %ipx;
			height: %ipx;
			display: none;
			overflow: hidden;
			position: relative;
			margin: 20px auto 20px auto;
		}
		html {
			padding: 0px;
			margin: 0px;
			background-color: black;
		}
	</style>
</head>
<body onload=load()>""".printf(exporter.js, width, height);
	
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

