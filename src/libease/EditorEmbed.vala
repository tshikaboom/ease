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
	public class EditorEmbed : ScrollableEmbed
	{
		// overall display
		private Clutter.Rectangle view_background;

		// the current slide's actor
		private SlideActor2 slide_actor;
		
		private Document document;
		public float zoom;
		public bool zoom_fit;
		
		public EditorEmbed(Document d)
		{
			base(true);

			// set up the background
			view_background = new Clutter.Rectangle();
			var color = Clutter.Color();
			color.from_string("Gray");
			view_background.color = color;
			contents.add_actor(view_background);
			
			document = d;
			this.set_size_request(320, 240);

			zoom = 1;
			zoom_fit = false;

			// reposition everything when resized
			size_allocate.connect(() => {
				if (zoom_fit)
				{
					zoom = width / height > (float)document.width / document.height
					     ? height / document.height
					     : width / document.width;
					reposition_group();
				}
				else
				{
					reposition_group();
				}

				// set the size of the background
				view_background.width = (float)Math.fmax(width, slide_actor.width);
				view_background.height = height;
			});
		}
		
		public void set_zoom(float z)
		{
			zoom = z / 100;
			reposition_group();
		}
		
		public void set_slide(Slide slide)
		{
			if (slide == null)
			{
				return;
			}
			
			// clean up the previous slide
			if (slide_actor != null)
			{
				contents.remove_actor(slide_actor);
			}
			
			slide_actor = new SlideActor2.from_slide(document, slide, false);
			
			contents.add_actor(slide_actor);
			reposition_group();
		}
		
		public void reposition_group()
		{
			var w = zoom * document.width;
			var h = zoom * document.height;
			
			slide_actor.set_scale_full(zoom, zoom, 0, 0);

			slide_actor.x = w < width
			              ? width / 2 - w / 2
		                  : 0;
			        
			slide_actor.y = h < height
			              ? height / 2 - h / 2
			              : 0;
		}
	}
}
