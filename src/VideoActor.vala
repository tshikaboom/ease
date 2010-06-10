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
 * {@link Actor} for videos
 *
 * VideoActor uses Clutter-GStreamer, and therefore supports any video
 * format supported by the GStreamer plugins on the user's system.
 */
public class Ease.VideoActor : Actor, Clutter.Media
{
	private ClutterGst.VideoTexture video;

	/**
	 * Instantiates a new VideoActor from an Element.
	 * 
	 * The VideoActor's context is particularly important due to playback.
	 * Playing back automatically in the editor would, of course, not be
	 * desired.
	 *
	 * @param e The represented element.
	 * @param c The context of this Actor (Presentation, Sidebar, Editor)
	 */
	public VideoActor(ref Element e, ActorContext c)
	{
		base(ref e, c);

		video = new ClutterGst.VideoTexture();
		video.set_filename(Path.build_filename(e.parent.parent.path,
		                                       e.get("filename")));

		// play the video if it's in the presentation
		if (c == ActorContext.PRESENTATION)
		{
			video.set_playing(true);
		}
		else
		{
			// FIXME: toggle playback to get a frame
			video.set_playing(true);
			video.set_playing(false);
		}
		
		contents = video;

		add_actor(contents);
		contents.width = e.width;
		contents.height = e.height;
		x = e.x;
		y = e.y;
	}
	
	public double get_audio_volume()
	{
		return video.get_audio_volume();
	}
	
	public double get_buffer_fill()
	{
		return video.get_buffer_fill();
	}
	
	public bool get_can_seek()
	{
		return video.get_can_seek();
	}
	
	public double get_duration()
	{
		return video.get_duration();
	}
	
	public bool get_playing()
	{
		return video.get_playing();
	}
	
	public double get_progress()
	{
		return video.get_progress();
	}
	
	public unowned string get_subtitle_font_name()
	{
		return video.get_subtitle_font_name();
	}
	
	public unowned string get_subtitle_uri()
	{
		return video.get_subtitle_uri();
	}
	
	public unowned string get_uri()
	{
		return video.get_uri();
	}
	
	public void set_audio_volume(double volume)
	{
		video.set_audio_volume(volume);
	}
	
	public void set_filename(string filename)
	{
		video.set_filename(filename);
	}
	
	public void set_playing(bool playing)
	{
		video.set_playing(playing);
	}
	
	public void set_progress(double progress)
	{
		video.set_progress(progress);
	}
	
	public void set_subtitle_font_name(string font_name)
	{
		video.set_subtitle_font_name(font_name);
	}
	
	public void set_subtitle_uri(string uri)
	{
		video.set_subtitle_uri(uri);
	}
	
	public void set_uri(string uri)
	{
		video.set_uri(uri);
	}
}

