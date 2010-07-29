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
	public bool play_auto { get; set; default = false; }
	
	public VideoElement()
	{
		signals();
	}
	
	internal VideoElement.from_json(Json.Object obj)
	{
		play_auto = obj.get_string_member(Theme.VIDEO_PLAY_AUTO).to_bool();
		base.from_json(obj);
	}	
	
	public override Actor actor(ActorContext c)
	{
		return new VideoActor(this, c);
	}
	
	public override Json.Object to_json()
	{
		var obj = base.to_json();
		obj.set_string_member(Theme.VIDEO_PLAY_AUTO, play_auto.to_string());
		return obj;
	}
	
	public override string html_render(HTMLExporter exporter)
	{
		// open the tag
		var html = "<video class=\"video element\" ";
		
		// set the video's style
		html += "style=\"";
		html += "left:" + x.to_string() + "px;";
		html += " top:" + y.to_string() + "px;";
		html += " position: absolute;\" ";
		
		// set the video's size
		html += " width=\"" + width.to_string() + "\" ";
		html += " height=\"" + width.to_string() + "\" ";
		
		// set the video's source and controls
		html += "src=\"" + exporter.path + " " +
		        filename + "\" " +
		        "controls=\"yes\">" +
		        _("Your browser does not support the video tag") + 
		        "</video>";
		        
		// copy the video file
		exporter.copy_file(filename, parent.parent.path);
		
		return html;
	}
	
	public override Gtk.Widget inspector_widget()
	{
		var label = new Gtk.Label("No inspector for videos right now...");
		label.show();
		return label;
	}

	public override void cairo_render(Cairo.Context context) throws Error
	{
		warning("Video elements don't support Cairo right now...");
	}
}

