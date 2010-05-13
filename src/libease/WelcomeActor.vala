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
	 * {@link Theme} tiles on the {@link WelcomeWindow}
	 *
	 * Each WelcomeActor is a preview of a {@link Theme}. The user can
	 * click on these to create a new {@link Document} with that {@link Theme}.
	 */
	public class WelcomeActor : Clutter.Rectangle
	{
		private Gee.ArrayList<WelcomeActor> others;
		private bool selected = false;
		private bool faded = false;
		
		public WelcomeActor(int w, ref Gee.ArrayList<WelcomeActor> o)
		{
			width = w;
			others = o;
			height = w * 3 / 4; // 4:3
		
			// TODO: make this an actual preview
			var color = Clutter.Color();
			color.from_hls((float)Random.next_double() * 360, 0.5f, 0.5f);
			color.from_string("Pink");
			set_color(color);
			
			color = Clutter.Color();
			color.from_string("White");
			set_border_color(color);
			set_border_width(2);
		}
		
		public void clicked()
		{
			stdout.printf("clicked!\n");
			if (selected)
			{
				// unfade the others
				foreach (var a in others)
					if (a != this)
						a.unfade();
				
				deselect();
			}
			else
			{
				// fade the others
				foreach (var a in others)
					if (a != this)
						a.fade();
				
				select();
			}
		}
		
		private void fade()
		{
			faded = true;
			animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 0.5f);
		}
		
		private void unfade()
		{
			faded = false;
			animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 1);
		}
		
		private void select()
		{
			selected = true;
			//animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 0.5f);
		}
		
		private void deselect()
		{
			selected = false;
			//animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, 250, "alpha", 1);
		}
	}
}
