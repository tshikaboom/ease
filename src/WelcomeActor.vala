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
 * {@link Theme} tiles on the {@link WelcomeWindow}
 *
 * Each WelcomeActor is a preview of a {@link Theme}. The user can
 * click on these to create a new {@link Document} with that {@link Theme}.
 */
public class Ease.WelcomeActor : Clutter.Rectangle
{
	private Gee.ArrayList<WelcomeActor> others;
	private bool is_selected = false;
	
	// constants
	private const int FADE_TIME = 200;
	private const int FADE_INIT_TIME = 1000;
	private const int FADE_EASE = Clutter.AnimationMode.EASE_IN_OUT_SINE;
	private const int FADE_VALUE = 100;
	
	public signal void selected();
	
	public WelcomeActor(int w, Gee.ArrayList<WelcomeActor> o)
	{
		width = w;
		others = o;
		height = w * 3 / 4; // 4:3
	
		// TODO: make this an actual preview
		color = {200, 200, 200, 255};
		
		border_color = {255, 255, 255, 255};
		border_width = 2;
		reactive = true;
		
		opacity = 0;
		animate(FADE_EASE, FADE_INIT_TIME, "opacity", 255);
	}
	
	public void clicked()
	{
		if (!is_selected)
		{
			// unfade the others
			foreach (var a in others)
			{
				if (a != this)
				{
					a.fade();
				}
			}
			unfade();
			selected();
		}
	}
	
	private void fade()
	{
		is_selected = false;
		animate(FADE_EASE, FADE_TIME, "opacity", FADE_VALUE);
	}
	
	private void unfade()
	{
		is_selected = true;
		animate(FADE_EASE, FADE_TIME, "opacity", 255);
	}
}

