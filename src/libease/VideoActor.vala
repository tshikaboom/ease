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

namespace Ease
{
	/**
	 * {@link Actor} for videos
	 *
	 * VideoActor uses Clutter-GStreamer, and therefore supports any video
	 * format supported by the GStreamer plugins on the user's system.
	 */
	public class VideoActor : Actor
	{
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
		public VideoActor(Element e, ActorContext c)
		{
			base(e, c);

			var video = new ClutterGst.VideoTexture();
			video.set_filename(e.parent.parent.path + e.data.get_str("filename"));

			// play the video if it's in the presentation
			if (c == ActorContext.Presentation)
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
			contents.x = e.x;
			contents.y = e.y;
		}
	}
}
