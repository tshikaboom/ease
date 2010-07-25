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
 * A {@link MediaElement} subclass for displaying an image. Linked with
 * {@link ImageActor}.
 */
public class Ease.ImageElement : MediaElement
{
	/**
	 * Create a new element, with an empty {@link ElementMap}.
	 */
	public ImageElement()
	{
	}
	
	public ImageElement.from_json(Json.Object obj)
	{
		base.from_json(obj);
	}
	
	/**
	 * Creates a completely empty ImageElement, without an {@link ElementMap}.
	 */
	public ImageElement.empty() {}	
	
	public override Actor actor(ActorContext c)
	{
		return new ImageActor(this, c);
	}
	
	public override void write_html(ref string html, HTMLExporter exporter)
	{
		// open the img tag
		html += "<img class=\"image element\" ";
		
		// set the image's style
		html += "style=\"";
		html += "left:" + x.to_string() + "px;";
		html += " top:" + y.to_string() + "px;";
		html += " width:" + width.to_string() + "px;";
		html += " height:" + height.to_string() + "px;";
		html += " position: absolute;\" ";
		
		// add the image
		html += "src=\"" + exporter.basename + " " + filename +
		        "\" alt=\"Image\" />";
		
		// copy the image file
		exporter.copy_file(filename, parent.parent.path);
	}

	/**
	 * Renders an image Element with Cairo.
	 */
	public override void cairo_render(Cairo.Context context) throws Error
	{
		var filename = Path.build_path("/", parent.parent.path, filename);
		
		// load the image
		var pixbuf = new Gdk.Pixbuf.from_file_at_scale(filename,
		                                               (int)width,
		                                               (int)height,
		                                               false);
		
		Gdk.cairo_set_source_pixbuf(context, pixbuf, x, y);
		
		context.rectangle(x, y, width, height);
		context.fill();
	}
}
