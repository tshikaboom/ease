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
	class SlideActor : Clutter.Group
	{
		public Clutter.Actor background;
		public Clutter.Group contents;
		private Clutter.Texture slide_texture;
		private Clutter.Group slide_texture_group;
		private bool stacked { get; set; }
		private static const bool OFFSCREEN = false;//Cogl.features_available(Cogl.FeatureFlags.OFFSCREEN);
		private float swidth;
		private float sheight;
		
		public SlideActor.from_slide(Document document, Slide slide, Clutter.Stage stage)
		{
			stacked = false;
			swidth = stage.width;
			sheight = stage.height;
			this.set_clip(0, 0, stage.width, stage.height);
			contents = new Clutter.Group();
			if (slide.background_image != null)
			{
				background = new Clutter.Texture.from_file(document.path + slide.background_image);
				background.width = stage.width;
				background.height = stage.height;
			}
			else // the background is a solid color
			{
				background = new Clutter.Rectangle();
				((Clutter.Rectangle)background).set_color(slide.background_color);
				background.width = stage.width;
				background.height = stage.height;
			}
			
			// add the slide's elements as actors
			for (var i = 0; i < slide.elements.size; i++)
			{
				try
				{
					//Clutter.Actor actor = slide.elements.get(i).presentation_actor();
					//contents.add_actor(actor);
				}
				catch (GLib.Error e)
				{
					stdout.printf("Error: %s\n", e.message);
				}
			}
		}
		
		public void stack()
		{
			if (stacked) return;
			stacked = true;
			
			var target = OFFSCREEN ? slide_texture_group = new Clutter.Group() : this;
			target.add_actor(background);
			target.add_actor(contents);
			if (OFFSCREEN)
			{
				slide_texture_group.show_all();
				slide_texture = new Clutter.Texture.from_actor(slide_texture_group);
				slide_texture.width = swidth;
				slide_texture.height = sheight;
				this.add_actor(slide_texture);
			}
		}
		
		public void unstack()
		{
			if (!stacked) return;
			stacked = false;
			if (OFFSCREEN)
			{
				slide_texture_group.remove_actor(background);
				slide_texture_group.remove_actor(contents);
				this.remove_actor(slide_texture);
				slide_texture = null;
			}
			else
			{
				this.remove_actor(background);
				this.remove_actor(contents);
			}
		}
	}
}
