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
 * Presents a {@link Document}
 * 
 * The Ease Player uses ClutterGtk to create a stage floated in the center
 * of a fullscreen Gtk.Window.
 */
public class Ease.Player : GLib.Object
{
	public Document document { get; set; }
	public int slide_index { get; set; }
	public Clutter.Stage stage { get; set; }
	private bool can_animate { get; set; }
	private Gtk.Window window;
	
	// current and transitioning out slide
	private SlideActor current_slide;
	private SlideActor old_slide;
	private Clutter.Group stack_container;
	
	// constants
	public const bool PRESENTATION_FULLSCREEN = false;

	public Player(Document doc)
	{
		document = doc;
		slide_index = -1;
		
		var embed = new GtkClutter.Embed();
		embed.set_size_request(document.width, document.height);
		
		stage = (Clutter.Stage)embed.get_stage();
		stage.width = document.width;
		stage.height = document.height;
		stage.title = "Ease Presentation";
		
		stage.set_fullscreen(PRESENTATION_FULLSCREEN);
		stage.hide_cursor();
		
		stage.show_all();
		Clutter.Color color = Clutter.Color();
		color.from_string("Black");
		stage.color = color;
		Clutter.grab_keyboard(stage);

		// make the stacking container
		stack_container = new Clutter.Group();
		stage.add_actor(stack_container);
		
		// make the window that everything will be displayed in
		window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
		Gdk.Color color2 = Gdk.Color();
		color2.red = 0;
		color2.green = 0;
		color2.blue = 0;
		window.modify_bg(Gtk.StateType.NORMAL, color2);
		
		// center the stage in the window
		var align = new Gtk.Alignment(0.5f, 0.5f, 0, 0);
		align.add(embed);

		// show the window
		if (PRESENTATION_FULLSCREEN)
		{
			window.fullscreen();
		}
		window.add(align);
		window.show_all();

		// register key presses and react
		align.get_parent_window().set_events(Gdk.EventMask.KEY_PRESS_MASK);
		align.key_press_event.connect(key_press);

		// start the presentation
		can_animate = true;
		advance();
	}
	
	public void advance()
	{
		// only advance when transitions are complete
		if (!can_animate)
		{
			return;
		}
	
		slide_index++;
		if (slide_index == document.slides.size) // slideshow complete
		{
			window.hide_all();
			return;
		}
		
		var slide = document.slides.get(slide_index);
		
		// the first slide simply fades in
		if (slide_index == 0)
		{
			create_current_slide(slide);
			current_slide.stack(stack_container);
			current_slide.opacity = 0;
			current_slide.animate(Clutter.AnimationMode.EASE_IN_SINE,
			                      1000, "opacity", 255);
		}
		else
		{			
			old_slide = current_slide;
			create_current_slide(slide);
			old_slide.transition(current_slide, stack_container);
			old_slide.animation_time.completed.connect(animation_complete);
			can_animate = false;
		}
		stage.add_actor(current_slide);
	}
	
	private void retreat()
	{
		if (slide_index == 0)
		{
			return;
		}
		
		if (old_slide.animation_time != null)
		{
			old_slide.animation_time.stop();
		}
		
		slide_index--;
		can_animate = true;
		stage.remove_all();
		
		create_current_slide(document.slides.get(slide_index));
		current_slide.stack(stack_container);
		stage.add_actor(current_slide);
	}
	
	private void create_current_slide(Slide slide)
	{
		current_slide = new SlideActor.from_slide(document, slide, true,
		                                          ActorContext.PRESENTATION);
	}
	
	private void animation_complete()
	{
		stage.remove_actor(old_slide);
		can_animate = true;
		current_slide.stack(stack_container);
	}
	
	private bool key_press(Gtk.Widget sender, Gdk.EventKey event)
	{
		switch (event.keyval)
		{
			case 65307: // escape
				stage.hide();
				break;
			case 65293: // enter
			case 65363: // right arrow
			case 65364: // up arrow
				advance();
				break;
			case 65288: // backspace
			case 65362: // up arrow
			case 65361: // left arrow
				retreat();
				break;
		}
		return false;
	}
}

