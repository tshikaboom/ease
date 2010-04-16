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

// SlideActor2, a replacement for SlideActor that will work everywhere

namespace Ease
{
	internal class SlideActor2 : Clutter.Group
	{
		// the represented slide
		private Slide slide;

		// the slide's background
		private Clutter.Actor background;

		// the slide's contents
		private Gee.ArrayList<Actor> contents;

		// the group of the slide's contents
		private Clutter.Group contents_group;
		
		public SlideActor2.from_slide(Document document, Slide s, bool clip)
		{
			slide = s;
			
			// clip the actor's bounds
			if (clip)
			{
				set_clip(0, 0, document.width, document.height);
			}

			// set the background
			if (slide.background_image != null)
			{
				try
				{
					background = new Clutter.Texture.from_file(document.path + slide.background_image);
					background.width = document.width;
					background.height = document.height;
				}
				catch (GLib.Error e)
				{
					stdout.printf("Error loading background: %s", e.message);
				}
			}
			else // the background is a solid color
			{
				background = new Clutter.Rectangle();
				((Clutter.Rectangle)background).set_color(slide.background_color);
				background.width = document.width;
				background.height = document.height;
			}

			add_actor(background);

			foreach (var e in slide.elements)
			{
				// load the proper type of actor
				if (e.element_type == "image")
				{
					add_actor(new ImageActor(e));
				}
			}
		}

		// stack the actor, removing children from container if needed
		public void stack(Clutter.Container container)
		{
			
		}

		// unstack the actor, layering it with another actor 
		public void unstack(SlideActor other, Clutter.Container container)
		{
			
		}
	}
}

