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
 * {@link Theme} tiles within the {@link WelcomeWindow}
 *
 * Each WelcomeActor is a preview of a {@link Theme}. The user can
 * click on these to create a new {@link Document} with that {@link Theme}.
 */
public class Ease.WelcomeActor : Clutter.Group
{
	/**
	 * If this WelcomeActor is currently selected.
	 */
	private bool is_selected = false;
	
	/**
	 * A CairoTexture used to render the slide preview.
	 */
	private Clutter.CairoTexture slide_actor;
	
	/**
	 * A black background rectangle placed behind the slide preview.
	 *
	 * When the slide preview's opacity is lowered, this rectangle causes the
	 * preview to appear dark, rather than translucent.
	 */
	private Clutter.Rectangle rect;
	
	/**
	 * The theme previewed by this WelcomeActor.
	 */
	public Theme theme;
	
	// display the name of the theme
	private const string FONT_NAME = "Sans 8";
	private const float TEXT_OFFSET = 5;
	private const float TEXT_HEIGHT = 12;
	private Clutter.Text text;
	
	// fade constants
	private const int FADE_TIME = 200;
	private const int FADE_INIT_TIME = 1000;
	private const int FADE_EASE = Clutter.AnimationMode.EASE_IN_OUT_SINE;
	private const int FADE_OPACITY = 150;
	
	/**
	 * The slide identifier to display as a preview.
	 */
	private const string PREVIEW_SLIDE = Theme.TITLE;
	
	/**
	 * Triggered when the slide preview is selected (single click).
	 */
	public signal void selected(WelcomeActor sender);
	
	/**
	 * Triggered when the slide preview is double clicked.
	 */
	public signal void double_click(WelcomeActor sender);
	
	/**
	 * Instantiates a WelcomeActor.
	 *
	 * @param t The theme that this WelcomeActor will display.
	 */
	public WelcomeActor(Theme t)
	{
		theme = t;
		reactive = true;
		
		// create the background rectangle actor
		rect = new Clutter.Rectangle();
		rect.color = {0, 0, 0, 255};
		add_actor(rect);
		
		// create the theme title actor
		text = new Clutter.Text.full (FONT_NAME,
									  theme.title,
									  {255, 255, 255, 255});
		text.height = TEXT_HEIGHT;
		text.line_alignment = Pango.Alignment.RIGHT;
		add_actor(text);
		
		// create the slide preview texture
		slide_actor = new Clutter.CairoTexture(1024, 768);
		add_actor(slide_actor);
		
		// fade the preview in
		opacity = 0;
		animate(FADE_EASE, FADE_INIT_TIME, "opacity", 255);
		
		// respond to click events
		button_press_event.connect((self, event) => {
            if (event.click_count == 2) {
				double_click(this);
				return false;
			}
			
			if (!is_selected) selected(this);
			return false;
		});
	}
	
	/**
	 * Sets the slide preview size.
	 *
	 * @param w The width of the slide.
	 * @param h The height of the slide.
	 */
	public void set_slide_size(int w, int h)
	{
		// set the surface size
		slide_actor.set_surface_size((uint)w, (uint)h);
		
		// render
		try
		{
			create_slide(w, h).cairo_render_sized(slide_actor.create(), w, h);
		}
		catch (GLib.Error e)
		{
			critical(_("Error rendering preview: %s"), e.message);
		}
	}
	
	/**
	 * Sets the size of the slide preview actor.
	 *
	 * This method does not redraw the preview, it simply scales it.
	 *
	 * @param w The width of the actor.
	 * @param h The height of the actor.
	 */
	public void set_actor_size(float w, float h)
	{
		rect.width = w;
		rect.height = h;
		
		text.x = roundd(rect.width / 2 - text.width / 2);
		text.y = roundd(h + TEXT_OFFSET);
		
		if (slide_actor != null)
		{
			slide_actor.width = rect.width;
			slide_actor.height = rect.height;
		}
	}
	
	/**
	 * Brings the preview to full brightness.
	 */
	public void fade()
	{
		is_selected = false;
		animate(FADE_EASE, FADE_TIME, "opacity", FADE_OPACITY);
	}
	
	/**
	 * Dims the preview.
	 */
	public void unfade()
	{
		is_selected = true;
		animate(FADE_EASE, FADE_TIME, "opacity", 255);
	}
	
	/**
	 * Creates a slide for preview of the given width and height.
	 *
	 * This method creates a slide from the WelcomeActor's {@link Theme},
	 * and substitutes some appropriate "preview" properties for specified
	 * elements. For example, the user's "real name" is placed in the "author"
	 * field.
	 *
	 * @param w The width of the slide to create.
	 * @param h The height of the slide to create.
	 */
	private Slide create_slide(int w, int h)
	{
		var slide = theme.create_slide(PREVIEW_SLIDE, w, h);
		
		foreach (var element in slide.elements)
		{
			switch (element.identifier)
			{
				case Theme.TITLE_TEXT:
					(element as TextElement).text = "Hello World!";
					break;
				case Theme.AUTHOR_TEXT:
					(element as TextElement).text = Environment.get_real_name();
					break;
			}
		}
		
		return slide;
	}
}

