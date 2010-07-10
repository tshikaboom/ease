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
	private bool dragging = false;

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
	private const uint FOCUS_OPACITY = 100;
	private const uint FOCUS_RADIUS = 25;

	// focus actors
	private Clutter.Group shader;
	private Clutter.Rectangle shader_top;
	private Clutter.Rectangle shader_bottom;
	private Clutter.Rectangle shader_left;
	private Clutter.Rectangle shader_right;
	
	public Player(Document doc)
	{
		document = doc;
		slide_index = -1;
		
		stage = new Clutter.Stage ();
		stage.width = document.width * scale;
		stage.height = document.height * scale;
		stage.title = _("Ease Presentation");
		stage.use_fog = false;
		stage.set_fullscreen (true);

		debug ("Screen size should be : %fx%f", stage.width, stage.height);
		// scale the presentation if needed
		if (stage.width < document.width || stage.height < document.height)
		{
			var x = ((float)stage.width) / document.width;
			var y = ((float)stage.height) / document.height;
            
			scale = x < y ? x : y;
		}

		// keyboard handling
		stage.key_press_event.connect ( (ev) => 
			{
				on_key_press (ev);
				return true;
			});

		// mouse handling
		stage.button_press_event.connect ( (ev) =>
			{
				on_button_press (ev);
				return true;
			});

		stage.motion_event.connect ( (ev) =>
			{
				on_motion (ev);
				return true;
			});

		stage.button_release_event.connect ( (ev) =>
			{
				on_button_release (ev);
				return true;
			});
		// FIXME : do I really have to do lambda functions each time ?
		
		// TODO : auto hide/show of the cursor.
		// stage.hide_cursor();
		
		stage.color = {0, 0, 0, 255};
		Clutter.grab_keyboard(stage);

		// focusing
		shader_top = new Clutter.Rectangle.with_color (Clutter.Color.from_string ("black"));
		shader_right = new Clutter.Rectangle.with_color (Clutter.Color.from_string ("black"));
		shader_bottom = new Clutter.Rectangle.with_color (Clutter.Color.from_string ("black"));
		shader_left = new Clutter.Rectangle.with_color (Clutter.Color.from_string ("black"));

		shader = new Clutter.Group ();
		shader.opacity = 0;
		shader.add (shader_top, 
					shader_right,
					shader_bottom,
					shader_left);

		stage.add (shader);

		// make the stacking container
		container = new Clutter.Group();
		stage.add_actor(container);
		container.scale_x = scale;
		container.scale_y = scale;
		
		// start the presentation
		stage.show_all ();

		can_animate = true;
		advance();
	}

	public void on_motion (Clutter.MotionEvent event)
	{
		if (dragging) {
			// FIXME : duplicate code
			shader_top.set_size (stage.width, event.y - FOCUS_RADIUS);
			shader_bottom.set_size (stage.width, (stage.height - event.y) + 2*FOCUS_RADIUS);
			shader_left.set_size (event.x - FOCUS_RADIUS, FOCUS_RADIUS * 2);
			shader_right.set_size (stage.width - event.x + 2 * FOCUS_RADIUS, 2 * FOCUS_RADIUS);
			
			shader_left.set_position (0, event.y - FOCUS_RADIUS);
			shader_right.set_position (event.x + 2 * FOCUS_RADIUS, event.y - FOCUS_RADIUS);
			shader_bottom.set_position (0, event.y + FOCUS_RADIUS);
			shader.show_all ();
			stage.raise_child (shader, null);
		} else {
			// fade out
		}
	}

	public void on_button_release (Clutter.ButtonEvent event)
	{
		dragging = false;
		// FIXME : should the focus fade time be a constant ?
		shader.animate (Clutter.AnimationMode.LINEAR, 150,
						"opacity", 0);
	}

	public void on_button_press (Clutter.ButtonEvent event)
	{
		dragging = true;
		debug ("Got a mouse click at %f, %f", event.x, event.y);
		shader_top.set_size (stage.width, event.y - FOCUS_RADIUS);
		shader_bottom.set_size (stage.width, (stage.height - event.y) + 2*FOCUS_RADIUS);
		shader_left.set_size (event.x - FOCUS_RADIUS, FOCUS_RADIUS * 2);
		shader_right.set_size (stage.width - event.x + 2 * FOCUS_RADIUS, 2 * FOCUS_RADIUS);

		shader_left.set_position (0, event.y - FOCUS_RADIUS);
		shader_right.set_position (event.x + 2 * FOCUS_RADIUS, event.y - FOCUS_RADIUS);
		shader_bottom.set_position (0, event.y + FOCUS_RADIUS);
		shader.show_all ();
		shader.animate (Clutter.AnimationMode.LINEAR, 150,
						"opacity", FOCUS_OPACITY);
		stage.raise_child (shader, null);
	}

	public void on_key_press (Clutter.KeyEvent event)
	{
		/* Coded with /usr/include/clutter-1.0/clutter/clutter-keysyms.h */
		/* Ask developers about the use of that file and the lack of doc */
		debug ("Got a key press, keyval = %u", event.keyval);
		switch (event.keyval) {
		case 0xff1b:
			// Escape
			debug ("Quitting player.");
			stage.hide ();
			break;
		case 0xff53:
			// Right arrow
			debug ("Advancing to next slide.");
			advance ();
			break;
		case 0xff51:
			// Left arrow
			debug ("Retreating to previous slide");
			retreat ();
			break;
		default:
			debug ("Key not handled.");
			break;
		}
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
		if (slide_index == 0) {
			return;
		}
		
		if (old_slide.animation_time != null) {
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
		/* Would it be better to return a new SlideActor instead ? */
		/* And then in the code : current_slide = create_current_slide (... */
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
}