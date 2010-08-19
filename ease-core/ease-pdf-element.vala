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
 * Displays a PDF document in a presentation.
 */
public class Ease.PdfElement : MediaElement
{
	private const string UI_FILE = "inspector-element-pdf.ui";	
	
	/**
	 * The page of the PDF file that is initially displayed.
	 */
	public int default_page { get; set; default = 0; }
	
	internal Poppler.Document pdf_doc;
	
	public PdfElement(string filename)
	{
		pdf_doc = new Poppler.Document.from_file(
			Filename.to_uri(filename),
			null);
		signals();
	}
	
	internal PdfElement.from_json(Json.Object obj)
	{
		base.from_json(obj);
		default_page = obj.get_string_member(Theme.PDF_DEFAULT_PAGE).to_int();
		
		pdf_doc = new Poppler.Document.from_file(
			Filename.to_uri(full_filename),
			null);
	}	
	
	public override Actor actor(ActorContext c)
	{
		return new PdfActor(this, c);
	}
	
	public override Json.Object to_json()
	{
		var obj = base.to_json();
		obj.set_string_member(Theme.PDF_DEFAULT_PAGE, default_page.to_string());
		return obj;
	}
	
	/**
	 * Renders this PdfElement as HTML.
	 */
	public override string html_render(HTMLExporter exporter)
	{
		var dir = Temp.request();
		var surface = new Cairo.ImageSurface(Cairo.Format.ARGB32,
		                                     (int)width, (int)height);
		var cr = new Cairo.Context(surface);
		cairo_render(cr);
		
		var path = Path.build_filename(dir, exporter.render_index.to_string());
		surface.write_to_png(path);
		var output = exporter.copy_rendered(path);
		
		// open the img tag
		var html = "<img class=\"pdf element\" ";
		
		// set the image's style
		html += "style=\"";
		html += "left:" + x.to_string() + "px;";
		html += " top:" + y.to_string() + "px;";
		html += " width:" + width.to_string() + "px;";
		html += " height:" + height.to_string() + "px;";
		html += " position: absolute;\" ";
		
		// add the image
		return html + "src=\"" +
		              (exporter.basename +
		               " Media/" + output).replace(" ", "%20") +
		              "\" alt=\"PDF\" />";
	}
	
	public override void cairo_render(Cairo.Context context) throws Error
	{
		// get the current page
		var page = pdf_doc.get_page(default_page);
		
		// scale the context
		double w = 0, h = 0;
		page.get_size(out w, out h);
		context.scale(width / w, height / h);
		
		// render
		page.render(context);
	}
	
	public override Gtk.Widget inspector_widget()
	{
		var builder = new Gtk.Builder();
		try
		{
			builder.add_from_file(data_path(Path.build_filename(Temp.UI_DIR,
				                                                UI_FILE)));
		}
		catch (Error e) { error("Error loading UI: %s", e.message); }
		
		var scale = builder.get_object("disp-page") as Gtk.HScale;
		scale.adjustment.upper = pdf_doc.get_n_pages();
		
		// format the scale value's display
		scale.format_value.connect((s, value) => {
			return "%i".printf((int)value + 1);
		});
		
		// connect the slider's changed signal
		scale.value_changed.connect(() => {
			// create an undo acton
			var action = new UndoAction(this, "default-page");
			
			default_page = (int)scale.adjustment.value;
			
			// emit the undoaction
			undo(action);
		});
		
		// return the root widget
		return builder.get_object("root") as Gtk.Widget;
	}
}
