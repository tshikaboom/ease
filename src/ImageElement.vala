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

public class Ease.ImageElement : MediaElement
{	
	public override Element copy()
	{
		var element = new ImageElement.empty();
		element.parent = parent;
		element.data = data.copy();
		
		return element;
	}
	
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
		html += "left:" + data.get("x") + "px;";
		html += " top:" + data.get("y") + "px;";
		html += " width:" + data.get("width") + "px;";
		html += " height:" + data.get("height") + "px;";
		html += " position: absolute;\" ";
		
		// add the image
		html += "src=\"" + exporter.path + " " +
		        data.get("filename") + "\" alt=\"Image\" />";
		
		// copy the image file
		exporter.copy_file(data.get("filename"),
		                   parent.parent.path);
	}

	/**
	 * Renders an image Element with Cairo.
	 */
	public override void cairo_render(Cairo.Context context) throws Error
	{
		var filename = Path.build_path("/",
		                               parent.parent.path,
		                               data.get("filename"));
		
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
