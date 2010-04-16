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
	public class SlideButton : Gtk.Button
	{
		public int slide_id { get; set; }
		public Slide slide { get; set; }

		// the clutter view
		private GtkClutter.Embed slide_image;

		// the clutter actor
		private SlideActor2 actor;

		// the frame to maintain the aspect ratio
		private Gtk.AspectFrame aspect;
		
		public SlideButton(int id, Slide s)
		{
			slide = s;
			slide_id = id;

			// make the embed
			slide_image = new GtkClutter.Embed();
			var color = Clutter.Color();
			color.from_string("Black");
			((Clutter.Stage)(slide_image.get_stage())).set_color(color);

			// make the slide actor
			actor = new SlideActor2.from_slide(s.parent, s, true);
			actor.width = s.parent.width;
			actor.height = s.parent.height;
			((Clutter.Stage)(slide_image.get_stage())).add_actor(actor);

			// make the aspect frame
			aspect = new Gtk.AspectFrame("Slide", 0, 0,
			                             (float)slide.parent.width /
			                                    slide.parent.height,
			                             false);
			aspect.set_size_request(75, 50);
			aspect.label = null;
			aspect.add(slide_image);

			// place things together
			var align = new Gtk.Alignment(0.5f, 0.5f, 0, 0);
			align.set_padding(5, 5, 5, 5);
			align.add(aspect);

			// set the style of the button
			aspect.shadow_type = Gtk.ShadowType.IN;
			relief = Gtk.ReliefStyle.NONE;
			focus_on_click = false;
			show_all();
			add(align);

			// resize the slide actor appropriately
			slide_image.size_allocate.connect((rect) => {
				actor.set_scale_full(rect.width / actor.width, rect.height / actor.height, 0, 0);
			});
		}
	}
}
