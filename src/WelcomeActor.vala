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
public class Ease.WelcomeActor : Clutter.Group
{
	private Gee.ArrayList<WelcomeActor> others;
	private bool is_selected = false;
	private Slide master;
	private Slide slide;
	private SlideActor slide_actor;
	private float slide_height;
	private Clutter.Rectangle rect;
	public Theme theme;
	
	// display the name of the theme
	private const string FONT_NAME = "Sans 8";
	private const float TEXT_OFFSET = 5;
	private const float TEXT_HEIGHT = 12;
	private Clutter.Text text;
	
	// constants
	private const int FADE_TIME = 200;
	private const int FADE_INIT_TIME = 1000;
	private const int FADE_EASE = Clutter.AnimationMode.EASE_IN_OUT_SINE;
	private const int FADE_VALUE = 150;
	private const float WIDTH = 1024;
	
	public signal void selected();
	
	public WelcomeActor(Theme t, Gee.ArrayList<WelcomeActor> o, Slide m)
	{
		others = o;
		slide_height = WIDTH * 3 / 4; // 4:3
		master = m;
		theme = t;
		
		rect = new Clutter.Rectangle();
		rect.color = {0, 0, 0, 255};
		add_actor(rect);
		
		text = new Clutter.Text();
		text.color = {255, 255, 255, 255};
		text.height = TEXT_HEIGHT;
		text.text = theme.title;
		text.font_name = FONT_NAME;
		text.line_alignment = Pango.Alignment.RIGHT;
		add_actor(text);
		
		reactive = true;
		
		opacity = 0;
		animate(FADE_EASE, FADE_INIT_TIME, "opacity", 255);
	}
	
	public void set_slide_size(int w, int h)
	{
		if (slide_actor != null)
		{
			remove_actor(slide_actor);
		}
		
		slide = new Slide.from_master(master, null,
		                              (int)WIDTH, (int)slide_height, false);
		slide.theme = theme;
		slide_actor = new SlideActor.with_dimensions(w, h, slide, true,
		                                             ActorContext.PRESENTATION);
		
		slide_actor.scale_x = w / WIDTH;
		slide_actor.scale_y = h / slide_height;
		slide_actor.height = rect.height;
		slide_actor.width = rect.width;
		
		add_actor(slide_actor);
	}
	
	public void set_dims(float w, float h)
	{
		rect.width = w;
		rect.height = h;
		
		text.x = Math.roundf(rect.width / 2 - text.width / 2);
		text.y = Math.roundf(h + TEXT_OFFSET);
		
		if (slide_actor != null)
		{
			slide_actor.scale_x = w / WIDTH;
			slide_actor.scale_y = h / slide_height;
			slide_actor.height = rect.height;
			slide_actor.width = rect.width;
		}
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
		this.animate(FADE_EASE, FADE_TIME, "opacity", FADE_VALUE);
	}
	
	private void unfade()
	{
		is_selected = true;
		this.animate(FADE_EASE, FADE_TIME, "opacity", 255);
	}
}

