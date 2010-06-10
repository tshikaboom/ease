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
 * A {@link MediaElement} subclass for playing a vide. Linked with
 * {@link VideoActor}.
 */
public class Ease.VideoElement : MediaElement
{
	/**
	 * Create a new element, with an empty {@link ElementMap}.
	 */
	public VideoElement()
	{
		data = new ElementMap();
	}
	
	/**
	 * Creates a completely empty VideoElement, without an {@link ElementMap}.
	 */
	public VideoElement.empty() {}	

	public override Element copy()
	{
		var element = new VideoElement.empty();
		element.parent = parent;
		element.data = data.copy();
		
		return element;
	}
	
	public override Actor actor(ActorContext c)
	{
		return new VideoActor(this, c);
	}
	
	public override void write_html(ref string html, HTMLExporter exporter)
	{
		// open the tag
		html += "<video class=\"video element\" ";
		
		// set the video's style
		html += "style=\"";
		html += "left:" + data.get("x") + "px;";
		html += " top:" + data.get("y") + "px;";
		html += " position: absolute;\" ";
		
		// set the video's size
		html += " width=\"" + data.get("width") + "\" ";
		html += " height=\"" + data.get("height") + "\" ";
		
		// set the video's source and controls
		html += "src=\"" + exporter.path + " " +
		        data.get("filename") + "\" " +
		        "controls=\"yes\">" +
		        _("Your browser does not support the video tag") + 
		        "</video>";
		        
		// copy the video file
		exporter.copy_file(data.get("filename"),
		                   parent.parent.path);
	}

	public override void cairo_render(Cairo.Context context) throws Error
	{
		stdout.printf("Video rendering not supported yet...\n");
	}
}

