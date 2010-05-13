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
	 * A Clutter actor for a Slide
	 *
	 * SlideActor is a subclass of Clutter.Group. It is used in both the
	 * editor and player, as well as assorted other preview screens.
	 */
	public class SlideActor : Clutter.Group
	{
		// the represented slide
		private Slide slide;

		// the slide's background
		public Clutter.Actor background;

		// the slide's contents
		//public Gee.ArrayList<Actor> contents_list;

		// the group of the slide's contents
		public Clutter.Group contents;
		
		public SlideActor.from_slide(Document document, Slide s, bool clip,
		                              ActorContext context)
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

			contents = new Clutter.Group();
			
			foreach (var e in slide.elements)
			{
				// load the proper type of actor
				switch (e.data.get("element_type"))
				{
					case "image":
						contents.add_actor(new ImageActor(e, context));
						break;
					case "text":
						contents.add_actor(new TextActor(e, context));
						break;
					case "video":
						contents.add_actor(new VideoActor(e, context));
						break;
				}
			}

			add_actor(contents);
		}

		// stack the actor, removing children from container if needed
		public void stack(Clutter.Actor container)
		{
			if (background.get_parent() != this)
			{
				background.reparent(this);
			}
			if (contents.get_parent() != this)
			{
				contents.reparent(this);
			}
		}

		// unstack the actor, layering it with another actor 
		public void unstack(SlideActor other, Clutter.Actor container)
		{
			if (other.background.get_parent() != container)
			{
				other.background.reparent(container);
			}
			if (background.get_parent() != container)
			{
				background.reparent(container);
			}
			if (contents.get_parent() != container)
			{
				contents.reparent(container);
			}
			if (other.contents.get_parent() != container)
			{
				other.contents.reparent(container);
			}
		}
	}
}

