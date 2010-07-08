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
	
	// current and transitioning out slide
	private SlideActor current_slide;
	private SlideActor old_slide;
	private Clutter.Group container;
	
	// automatic advance alarm
	private Clutter.Timeline advance_alarm;
	
	// scale the presentation, if needed
	private float scale = 1;
	
	// constants
	private const uint FADE_IN_TIME = 1000;

	public Player(Document doc)
	{
		document = doc;
		slide_index = -1;
		
		stage = new Clutter.Stage ();
		stage.width = document.width * scale;
		stage.height = document.height * scale;
		stage.title = _("Ease Presentation");
		stage.use_fog = false;
		
		stage.hide_cursor();
		
		stage.show_all();
		stage.color = {0, 0, 0, 255};
		Clutter.grab_keyboard(stage);

		// make the stacking container
		container = new Clutter.Group();
		stage.add_actor(container);
		container.scale_x = scale;
		container.scale_y = scale;
		
		// start the presentation
		stage.set_fullscreen (true);
		stage.show_all ();

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
		
		// stop the advance alarm
		if (advance_alarm != null)
		{
			advance_alarm.stop();
			advance_alarm = null;
		}
	
		slide_index++;
		if (slide_index == document.slides.size) // slideshow complete
		{
			stage.hide_all();
			return;
		}
		
		var slide = document.slides.get(slide_index);
		
		// the first slide simply fades in
		if (slide_index == 0)
		{
			create_current_slide(slide);
			current_slide.stack(container);
			current_slide.opacity = 0;
			current_slide.animate(Clutter.AnimationMode.EASE_IN_SINE,
			                      FADE_IN_TIME, "opacity", 255);
			
			advance_alarm = new Clutter.Timeline(FADE_IN_TIME);
			advance_alarm.completed.connect(animation_complete);
			advance_alarm.start();
			
			can_animate = false;
		}
		
		// otherwise, animate as usual
		else
		{
			old_slide = current_slide;
			create_current_slide(slide);
			container.add_actor(current_slide);
			
			if (old_slide.slide.transition_time > 0)
			{
				old_slide.transition(current_slide, container);
				old_slide.animation_time.completed.connect(animation_complete);
				can_animate = false;
			}
			else
			{
				animation_complete();
			}
		}
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
		
		container.remove_all();
		create_current_slide(document.slides.get(slide_index));
		current_slide.stack(container);
		container.add_actor(current_slide);
	}
	
	private void create_current_slide(Slide slide)
	{
		current_slide = new SlideActor.from_slide(document, slide, true,
		                                          ActorContext.PRESENTATION);
	}
	
	private void animation_complete()
	{
		container.remove_all();
		
		can_animate = true;
		current_slide.stack(container);
		
		// prepare to automatically advance if necessary
		if (current_slide.slide.automatically_advance)
		{
			uint time = (uint)(1000 * current_slide.slide.advance_delay);
			
			advance_alarm = new Clutter.Timeline(time);
			advance_alarm.completed.connect(() => {
				advance();
			});
			advance_alarm.start();
		}
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

