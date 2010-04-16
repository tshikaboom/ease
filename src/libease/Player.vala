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
	public class Player : GLib.Object
	{
		public Document document { get; set; }
		public int slide_index { get; set; }
		public Clutter.Stage stage { get; set; }
		private bool can_animate { get; set; }
		private Gtk.Window window;
		
		// current and transitioning out slide
		private SlideActor2 current_slide;
		private SlideActor2 old_slide;
		private Clutter.Group stack_container;
		
		// timelines
		private Clutter.Timeline animation_time { get; set; }
		private Clutter.Alpha animation_alpha { get; set; }
		private Clutter.Timeline time1;
		private Clutter.Timeline time2;
		private Clutter.Alpha alpha1;
		private Clutter.Alpha alpha2;
		
		// effect constants
		public const float FLIP_DEPTH = -400;
		public const float ZOOM_OUT_SCALE = 0.75f;
		public const bool PRESENTATION_FULLSCREEN = true;
	
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
			align.key_press_event.connect((a, e) => {
				key_press(a, e);
				return false;
			});

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
				this.create_current_slide(slide);
				current_slide.stack(stack_container);
				current_slide.opacity = 0;
				current_slide.animate(Clutter.AnimationMode.EASE_IN_SINE, 1000, "opacity", 255);
			}
			else
			{
				//FIXME: these live here (used for pivot)
				var xpos = 0f;
				var ypos = 0f;
				var angle = 90f;
				var property = "";
				
				var prev_slide = document.slides.get(slide_index - 1);
				old_slide = current_slide;
				old_slide.contents = current_slide.contents;
				old_slide.background = current_slide.background;
				
				this.create_current_slide(slide);
				
				var length = 1000;
				animation_time = new Clutter.Timeline(length);
				animation_time.completed.connect(animation_complete);
				animation_time.start();
				can_animate = false;
				
				switch (prev_slide.transition)
				{
					case "Fade":
						prepare_slide_transition();
						current_slide.opacity = 0;
						current_slide.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 255);
						break;
					case "Slide":
						prepare_slide_transition();
						switch (prev_slide.variant)
						{
							case "Up":
								current_slide.y = stage.height;
								current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
								old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", -stage.height);
								break;
							case "Down":
								current_slide.y = -stage.height;
								current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
								old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", stage.height);
								break;
							case "Left":
								current_slide.x = stage.width;
								current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
								old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", -stage.width);
								break;
							case "Right":
								current_slide.x = -stage.width;
								current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
								old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", stage.width);
								break;
						}
						break;
					case "Drop":
						prepare_slide_transition();
						current_slide.y = -stage.height;
						current_slide.animate(Clutter.AnimationMode.EASE_OUT_BOUNCE, length, "y", 0);
						break;
					case "Pivot":
						prepare_slide_transition();
						
						switch (prev_slide.variant)
						{
							case "Top Right":
								xpos = stage.width;
								angle = -90;
								break;
							case "Bottom Left":
								ypos = stage.height;
								angle = -90;
								break;
							case "Bottom Right":
								xpos = stage.width;
								ypos = stage.height;
								break;
						}
						current_slide.set_rotation(Clutter.RotateAxis.Z_AXIS, angle, xpos, ypos, 0);
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
						animation_time.new_frame.connect((m) => {
							current_slide.set_rotation(Clutter.RotateAxis.Z_AXIS, angle * (1 - animation_alpha.get_alpha()), xpos, ypos, 0);
						});
						break;
					case "Flip":
						prepare_slide_transition();
						current_slide.opacity = 0;				
						time1 = new Clutter.Timeline(length / 2);
						time2 = new Clutter.Timeline(length / 2);
						alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_SINE);
						alpha2 = new Clutter.Alpha.full(time2, Clutter.AnimationMode.EASE_OUT_SINE);
						switch (prev_slide.variant)
						{
							case "Bottom to Top":
								time1.new_frame.connect((m) => {
									old_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90 * alpha1.get_alpha(), 0, stage.height / 2, 0);
									old_slide.depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
								});
								time2.new_frame.connect((m) => {
									current_slide.opacity = 255;
									current_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
									current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * (1 - alpha2.get_alpha()), 0, stage.height / 2, 0);
								});
								break;
							case "Top to Bottom":
								time1.new_frame.connect((m) => {
									old_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * alpha1.get_alpha(), 0, stage.height / 2, 0);
									old_slide.depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
								});
								time2.new_frame.connect((m) => {
									current_slide.opacity = 255;
									current_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
									current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90 * (1 - alpha2.get_alpha()), 0, stage.height / 2, 0);
								});
								break;
							case "Left to Right":
								time1.new_frame.connect((m) => {
									old_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * alpha1.get_alpha(), stage.width / 2, 0, 0);
									old_slide.depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
								});
								time2.new_frame.connect((m) => {
									current_slide.opacity = 255;
									current_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
									current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * (1 - alpha2.get_alpha()), stage.width / 2, 0, 0);
								});
								break;
							case "Right to Left":
								time1.new_frame.connect((m) => {
									old_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * alpha1.get_alpha(), stage.width / 2, 0, 0);
									old_slide.depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
								});
								time2.new_frame.connect((m) => {
									current_slide.opacity = 255;
									current_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
									current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * (1 - alpha2.get_alpha()), stage.width / 2, 0, 0);
								});
								break;
						}
						time1.completed.connect(() => {
							old_slide.opacity = 0;
							current_slide.depth = FLIP_DEPTH;
							time2.start();
						});
						time1.start();
						break;
					case "Revolving Door":
						prepare_slide_transition();
						old_slide.depth = 1; //ugly, but works
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_OUT_SINE);
						switch (prev_slide.variant)
						{
							case "Left":
								current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90, 0, 0, 0);
								animation_time.new_frame.connect((m) => {
									current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * (1 - animation_alpha.get_alpha()), 0, 0, 0);
									old_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -110 * animation_alpha.get_alpha(), 0, 0, 0);
								});
								break;
							case "Right":
								current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90, stage.width, 0, 0);
								animation_time.new_frame.connect((m) => {
									current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * (1 - animation_alpha.get_alpha()), stage.width, 0, 0);
									old_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 110 * animation_alpha.get_alpha(), stage.width, 0, 0);
								});
								break;
							case "Top":
								current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90, 0, 0, 0);
								animation_time.new_frame.connect((m) => {
									current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * (1 - animation_alpha.get_alpha()), 0, 0, 0);
									old_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 110 * animation_alpha.get_alpha(), 0, 0, 0);
								});
								break;
							case "Bottom":
								current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90, 0, stage.height, 0);
								animation_time.new_frame.connect((m) => {
									current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90 * (1 - animation_alpha.get_alpha()), 0, stage.height, 0);
									old_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -110 * animation_alpha.get_alpha(), 0, stage.height, 0);
								});
								break;
						}
						break;
					case "Fall":
						prepare_slide_transition();
						old_slide.depth = 1; //ugly, but works
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_QUART);
						animation_time.new_frame.connect((m) => {
							old_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * animation_alpha.get_alpha(), 0, stage.height, 0);
						});
						break;
					case "Spin Contents":
						prepare_stack_transition(false);
						current_slide.contents.opacity = 0;	
						old_slide.background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);			
						time1 = new Clutter.Timeline(length / 2);
						time2 = new Clutter.Timeline(length / 2);
						alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_SINE);
						alpha2 = new Clutter.Alpha.full(time2, Clutter.AnimationMode.EASE_OUT_SINE);
						angle = prev_slide.variant == "Left" ? -90 : 90;
						time1.completed.connect(() => {
							old_slide.contents.opacity = 0;
							time2.start();
						});
						time1.new_frame.connect((m) => {
							old_slide.contents.set_rotation(Clutter.RotateAxis.Y_AXIS, angle * alpha1.get_alpha(), stage.width / 2, 0, 0);
						});
						time2.new_frame.connect((m) => {
							current_slide.contents.opacity = 255;
							current_slide.contents.set_rotation(Clutter.RotateAxis.Y_AXIS, -angle * (1 - alpha2.get_alpha()), stage.width / 2, 0, 0);
						});
						time1.start();
						break;
					case "Swing Contents":
						prepare_stack_transition(false);
						current_slide.contents.opacity = 0;	
						old_slide.background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
						alpha1 = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_SINE);
						alpha2 = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.LINEAR);
						animation_time.new_frame.connect((m) => {
							unowned GLib.List<Clutter.Actor>* itr;
							old_slide.contents.opacity = clamp_opacity(455 - 555 * alpha1.get_alpha());
							current_slide.contents.opacity = clamp_opacity(-100 + 400 * alpha2.get_alpha());
							for (itr = old_slide.contents.get_children(); itr != null; itr = itr->next)
							{
								((Clutter.Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS, 540 * alpha1.get_alpha(), 0, 0, 0);
							}
							for (itr = current_slide.contents.get_children(); itr != null; itr = itr->next)
							{
								((Clutter.Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS, -540 * (1 - alpha2.get_alpha()), 0, 0, 0);
							}
						});
						break;
					case "Zoom":
						prepare_slide_transition();
						switch (prev_slide.variant)
						{
							case "Center":
								current_slide.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
								break;
							case "Top Left":
								current_slide.set_scale_full(0, 0, 0, 0);
								break;
							case "Top Right":
								current_slide.set_scale_full(0, 0, stage.width, 0);
								break;
							case "Bottom Left":
								current_slide.set_scale_full(0, 0, 0, stage.height);
								break;
							case "Bottom Right":
								current_slide.set_scale_full(0, 0, stage.width, stage.height);
								break;
						}
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
						animation_time.new_frame.connect((m) => {
							current_slide.set_scale(animation_alpha.get_alpha(), animation_alpha.get_alpha());
						});
						//current_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_x", 1);
						//current_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_y", 1);
						break;
					case "Slide Contents":
						prepare_stack_transition(true);
						old_slide.background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
						switch (prev_slide.variant)
						{
							case "Right":
								current_slide.contents.x = -stage.width;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
								old_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", stage.width);
								break;
							case "Left":
								current_slide.contents.x = stage.width;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
								old_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", -stage.width);
								break;
							case "Up":
								current_slide.contents.y = stage.height;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
								old_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", -stage.height);
								break;
							case "Down":
								current_slide.contents.y = -stage.height;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
								old_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", stage.height);
								break;
						}
						break;
					case "Spring Contents":
						prepare_stack_transition(true);
						old_slide.background.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
						switch (prev_slide.variant)
						{
							case "Up":
								current_slide.contents.y = stage.height * 1.2f;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", 0);
								old_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", -stage.height * 1.2);
								break;
							case "Down":
								current_slide.contents.y = -stage.height * 1.2f;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", 0);
								old_slide.contents.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", stage.height * 1.2);
								break;
						}
						break;
					case "Zoom Contents":
						prepare_stack_transition(prev_slide.variant == "Out");
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_OUT_SINE);
						old_slide.background.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
						switch (prev_slide.variant)
						{
							case "In":
								current_slide.contents.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
								old_slide.contents.set_scale_full(1, 1, stage.width / 2, stage.height / 2);
								old_slide.contents.animate(Clutter.AnimationMode.LINEAR, length / 2, "opacity", 0);
								animation_time.new_frame.connect((m) => {
									current_slide.contents.set_scale(animation_alpha.get_alpha(),
									                                animation_alpha.get_alpha());
									old_slide.contents.set_scale(1.0 + 2 * animation_alpha.get_alpha(),
									   	                        1.0 + 2 * animation_alpha.get_alpha());
								});
								break;
							case "Out":
								current_slide.contents.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
								old_slide.contents.set_scale_full(1, 1, stage.width / 2, stage.height / 2);
								current_slide.contents.opacity = 0;
								current_slide.contents.animate(Clutter.AnimationMode.EASE_IN_SINE, length / 2, "opacity", 255);
								animation_time.new_frame.connect((m) => {
									current_slide.contents.set_scale(1.0 + 2 * (1 - animation_alpha.get_alpha()),
									                                1.0 + 2 * (1 - animation_alpha.get_alpha()));
									old_slide.contents.set_scale(1 - animation_alpha.get_alpha(),
									   	                         1 - animation_alpha.get_alpha());
								});
								break;
						}
						break;
					case "Panel":
						prepare_slide_transition();
						switch (prev_slide.variant)
						{
							case "Up":
								xpos = stage.height;
								property = "y";
								break;
							case "Down":
								xpos = -stage.height;
								property = "y";
								break;
							case "Left":
								xpos = stage.width;
								property = "x";
								break;
							case "Right":
								xpos = -stage.width;
								property = "x";
								break;
						}
						
						time1 = new Clutter.Timeline(length / 4);
						time2 = new Clutter.Timeline(3 * length / 4);
						current_slide.set_scale_full(ZOOM_OUT_SCALE, ZOOM_OUT_SCALE, stage.width / 2, stage.height / 2);
						current_slide.set_property(property, xpos);
						alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_OUT_SINE);
						
						time1.new_frame.connect((m) => {
							old_slide.set_scale_full(ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * (1 - alpha1.get_alpha()),
							                         ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * (1 - alpha1.get_alpha()),
							                         stage.width / 2,
							                         stage.height / 2);
						});
						time1.completed.connect(() => {
							old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2, property, -xpos);
							// I have no explanation for why that is required, but nothing else worked properly
							current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2, property, 0.0f);
						});
						time2.completed.connect(() => {
							time1.new_frame.connect((m) => {
								current_slide.set_scale_full(ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * alpha1.get_alpha(),
								                             ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * alpha1.get_alpha(),
								                             stage.width / 2,
								                             stage.height / 2);
							});
							time1.start();
						});
						time1.start();
						time2.start();
						break;
				}
			}
			stage.add_actor(current_slide);
		}
		
		private void retreat()
		{
			if (slide_index == 0)
			{
				return;
			}
			
			if (animation_time != null)
			{
				animation_time.stop();
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
			current_slide = new SlideActor2.from_slide(document, slide, true);
		}
		
		private void prepare_slide_transition()
		{
			current_slide.stack(stack_container);
			old_slide.stack(stack_container);
		}
		
		private void prepare_stack_transition(bool current_on_top)
		{
			old_slide.unstack(current_slide, stack_container);
		}
		
		private void animation_complete()
		{
			stage.remove_actor(old_slide);
			can_animate = true;
			current_slide.stack(stack_container);
		}
		
		private void key_press(Gtk.Widget sender, Gdk.EventKey event)
		{
			switch (event.keyval)
			{
				case 65307: // escape
					stage.hide();
					break;
				case 65293: // enter
				case 65363: // right arrow
				case 65364: // up arrow
					this.advance();
					break;
				case 65288: // backspace
				case 65362: // up arrow
				case 65361: // left arrow
					this.retreat();
					break;
			}
			//stdout.printf("%u\n", event.key.keyval);
		}
		
		// animation utility functions
		private double min(double a, double b)
		{
			if (a > b)
			{
				return b;
			}
			return a;
		}
		
		private double max(double a, double b)
		{
			if (a > b)
			{
				return a;
			}
			return b;
		}
		
		private uint8 clamp_opacity(double o)
		{
			return (uint8)(max(0, min(255, o)));
		}
	}
}
