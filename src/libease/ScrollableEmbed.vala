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
	public class ScrollableEmbed : Gtk.Table
	{
		// actors
		private GtkClutter.Embed embed;
		private GtkClutter.Viewport viewport;
		private Clutter.Group contents;

		// scrolling
		private Gtk.HScrollbar h_scrollbar;
		private Gtk.VScrollbar v_scrollbar;
		private Gtk.Adjustment h_adjust;
		private Gtk.Adjustment v_adjust;
		private Gtk.Adjustment z_adjust;
		
		public bool has_horizontal { get; private set; }
	
		public ScrollableEmbed(bool horizontal)
		{
			has_horizontal = horizontal;
			
			// create children
			embed = new GtkClutter.Embed();
			h_adjust = new Gtk.Adjustment(0, 0, 1, 0.1, 0.1, 0.1);
			h_scrollbar = new Gtk.HScrollbar(h_adjust);
			v_adjust = new Gtk.Adjustment(0, 0, 1, 0.1, 0.1, 0.1);
			v_scrollbar = new Gtk.VScrollbar(v_adjust);
			z_adjust = new Gtk.Adjustment(0, 0, 1, 0.1, 0.1, 0.1);

			// set up clutter actors
			viewport = new GtkClutter.Viewport(h_adjust, v_adjust, z_adjust);
			contents = new Clutter.Group();
			
			var stage = (Clutter.Stage)(embed.get_stage());
			//stage.add_actor(viewport);
			viewport.child = contents;

			var color = Clutter.Color();
			color.from_string("Black");
			stage.set_color(color);
			stage.width = 200;
			stage.height = 100;

			var rect = new Clutter.Rectangle.with_color(color);
			rect.width = 100;
			rect.height = 100;
			contents.add_actor(rect);
		
			// set up the table
			n_rows = has_horizontal ? 2 : 1;
			n_columns = 2;
			
			attach(embed,
			       0, 1, 0, 1,
			       Gtk.AttachOptions.EXPAND,
			       Gtk.AttachOptions.EXPAND,
			       0, 0);
			attach(v_scrollbar,
			       1, 2, 0, 1,
			       Gtk.AttachOptions.SHRINK,
			       Gtk.AttachOptions.FILL,
			       0, 0);
			if (has_horizontal)
			{
				attach(h_scrollbar,
				       0, 1, 1, 2,
				       Gtk.AttachOptions.FILL,
				       Gtk.AttachOptions.SHRINK,
				       0, 0);
			}
			get_stage().show_all();
			
			// scroll the view as is appropriate (with the mouse wheel)
			realize.connect(() => {
				get_window().set_events(Gdk.EventMask.ALL_EVENTS_MASK);
			});
			
			button_press_event.connect((event) => {
				return false;
			});
			
			scroll_event.connect((event) => {
				switch (event.direction)
				{
					case Gdk.ScrollDirection.UP:
						v_adjust.value = Math.fmax(0, v_adjust.value - 0.1);
						break;
					case Gdk.ScrollDirection.DOWN:
						v_adjust.value = Math.fmin(1, v_adjust.value + 0.1);
						break;
				}
				return false;
			});
		}
		
		public Clutter.Stage get_stage()
		{
			return (Clutter.Stage)(embed.get_stage());
		}
	}
}
