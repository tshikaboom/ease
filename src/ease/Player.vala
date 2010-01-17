namespace Ease
{
	public class Player : GLib.Object
	{
		public Document document { get; set; }
		public int slide_index { get; set; }
		public Clutter.Stage stage { get; set; }
		private bool can_animate { get; set; }
		
		// current and transitioning out slide
		private Clutter.Group current_slide_content { get; set; }
		private Clutter.Group current_slide_bg { get; set; }
		private Clutter.Group current_slide { get; set; }
		private Clutter.Group old_slide_content { get; set; }
		private Clutter.Group old_slide_bg { get; set; }
		private Clutter.Group old_slide { get; set; }
		
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
		public const bool PRESENTATION_FULLSCREEN = false;
	
		public Player(Document doc)
		{
			stage = new Clutter.Stage();
			document = doc;
			slide_index = -1;
			
			stage.width = document.width;
			stage.height = document.height;
			stage.title = "Ease Presentation";
			
			stage.set_fullscreen(PRESENTATION_FULLSCREEN);
			stage.hide_cursor();
			
			stage.key_press_event.connect((a, e) => { key_press(a, e); });
			
			stage.show_all();
			Clutter.Color color = Clutter.Color();
			color.from_string("Black");
			stage.color = color;
			
			// move to the first slide
			can_animate = true;
			this.advance();
			
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
				stage.hide_all();
				return;
			}
			
			var slide = document.slides.get(slide_index);
			
			// the first slide simply fades in
			if (slide_index == 0)
			{
				this.create_current_slide(slide);
				current_slide.add_actor(current_slide_bg);
				current_slide.add_actor(current_slide_content);
				current_slide.opacity = 0;
				current_slide.animate(Clutter.AnimationMode.EASE_IN_SINE, 1000, "opacity", 255);
			}
			else
			{
				old_slide = current_slide;
				old_slide_content = current_slide_content;
				old_slide_bg = current_slide_bg;
				
				this.create_current_slide(slide);
				
				var length = 1000;
				animation_time = new Clutter.Timeline(length);
				animation_time.completed.connect(animation_complete);
				animation_time.start();
				can_animate = false;
				
				switch (document.slides.get(slide_index - 1).transition)
				{
					case "Fade":
						prepare_slide_transition();
						current_slide.opacity = 0;
						current_slide.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 255);
						break;
					case "Slide":
						prepare_slide_transition();
						current_slide.y = -stage.height;
						current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
						old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", stage.height);
						break;
					case "Drop":
						prepare_slide_transition();
						current_slide.y = -stage.height;
						current_slide.animate(Clutter.AnimationMode.EASE_OUT_BOUNCE, length, "y", 0);
						break;
					case "Pivot":
						prepare_slide_transition();
						current_slide.set_rotation(Clutter.RotateAxis.Z_AXIS, 90, 0, 0, 0);
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
						animation_time.new_frame.connect((m) => {
							current_slide.set_rotation(Clutter.RotateAxis.Z_AXIS, 90 * (1 - animation_alpha.get_alpha()), 0, 0, 0);
						});
						break;
					case "Flip":
						prepare_slide_transition();
						current_slide.opacity = 0;				
						time1 = new Clutter.Timeline(length / 2);
						time2 = new Clutter.Timeline(length / 2);
						alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_SINE);
						alpha2 = new Clutter.Alpha.full(time2, Clutter.AnimationMode.EASE_OUT_SINE);
						time1.completed.connect(() => {
							old_slide.opacity = 0;
							current_slide.depth = FLIP_DEPTH;
							time2.start();
						});
						time1.new_frame.connect((m) => {
							old_slide.set_rotation(Clutter.RotateAxis.X_AXIS, 90 * alpha1.get_alpha(), 0, stage.height / 2, 0);
							old_slide.depth = (float)(FLIP_DEPTH * alpha1.get_alpha());
						});
						time2.new_frame.connect((m) => {
							current_slide.opacity = 255;
							current_slide.depth = FLIP_DEPTH * (float)(1 - alpha2.get_alpha());
							current_slide.set_rotation(Clutter.RotateAxis.X_AXIS, -90 * (1 - alpha2.get_alpha()), 0, stage.height / 2, 0);
						});
						time1.start();
						break;
					case "Revolving Door":
						prepare_slide_transition();
						old_slide.depth = 1; //ugly, but works
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_OUT_SINE);
						current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90, 0, 0, 0);
						animation_time.new_frame.connect((m) => {
							current_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * (1 - animation_alpha.get_alpha()), 0, 0, 0);
							old_slide.set_rotation(Clutter.RotateAxis.Y_AXIS, -110 * animation_alpha.get_alpha(), 0, 0, 0);
						});
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
						current_slide_content.opacity = 0;	
						old_slide_bg.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);			
						time1 = new Clutter.Timeline(length / 2);
						time2 = new Clutter.Timeline(length / 2);
						alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_SINE);
						alpha2 = new Clutter.Alpha.full(time2, Clutter.AnimationMode.EASE_OUT_SINE);
						time1.completed.connect(() => {
							old_slide_content.opacity = 0;
							time2.start();
						});
						time1.new_frame.connect((m) => {
							old_slide_content.set_rotation(Clutter.RotateAxis.Y_AXIS, 90 * alpha1.get_alpha(), stage.width / 2, 0, 0);
						});
						time2.new_frame.connect((m) => {
							current_slide_content.opacity = 255;
							current_slide_content.set_rotation(Clutter.RotateAxis.Y_AXIS, -90 * (1 - alpha2.get_alpha()), stage.width / 2, 0, 0);
						});
						time1.start();
						break;
					case "Swing Contents":
						prepare_stack_transition(false);
						current_slide_content.opacity = 0;	
						old_slide_bg.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
						alpha1 = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_SINE);
						alpha2 = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.LINEAR);
						animation_time.new_frame.connect((m) => {
							unowned GLib.List* itr;
							old_slide_content.opacity = clamp_opacity(455 - 555 * alpha1.get_alpha());
							current_slide_content.opacity = clamp_opacity(-100 + 400 * alpha2.get_alpha());
							for (itr = old_slide_content.get_children(); itr != null; itr = itr->next)
							{
								((Clutter.Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS, 540 * alpha1.get_alpha(), 0, 0, 0);
							}
							for (itr = current_slide_content.get_children(); itr != null; itr = itr->next)
							{
								((Clutter.Actor*)itr->data)->set_rotation(Clutter.RotateAxis.X_AXIS, -540 * (1 - alpha2.get_alpha()), 0, 0, 0);
							}
						});
						break;
					case "Zoom":
						prepare_slide_transition();
						current_slide.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_OUT_SINE);
						animation_time.new_frame.connect((m) => {
							current_slide.set_scale(animation_alpha.get_alpha(), animation_alpha.get_alpha());
						});
						//current_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_x", 1);
						//current_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_y", 1);
						break;
					case "Slide Contents":
						prepare_stack_transition(true);
						old_slide_bg.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
						current_slide_content.x = -stage.width;
						current_slide_content.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
						old_slide_content.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", stage.width);
						break;
					case "Spring Contents":
						prepare_stack_transition(true);
						old_slide_bg.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "opacity", 0);
						current_slide_content.y = stage.height * 1.2f;
						current_slide_content.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", 0);
						old_slide_content.animate(Clutter.AnimationMode.EASE_IN_OUT_ELASTIC, length, "y", -stage.height * 1.2);
						break;
					case "Zoom Contents":
						prepare_stack_transition(false);
						animation_alpha = new Clutter.Alpha.full(animation_time, Clutter.AnimationMode.EASE_IN_OUT_SINE);
						old_slide_bg.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
						current_slide_content.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
						old_slide_content.set_scale_full(1, 1, stage.width / 2, stage.height / 2);
						old_slide_content.animate(Clutter.AnimationMode.LINEAR, length / 2, "opacity", 0);
						animation_time.new_frame.connect((m) => {
							current_slide_content.set_scale(animation_alpha.get_alpha(),
							                                animation_alpha.get_alpha());
							old_slide_content.set_scale(1.0 + 2 * animation_alpha.get_alpha(),
							   	                        1.0 + 2 * animation_alpha.get_alpha());
						});
						break;
					case "Panel":
						prepare_slide_transition();
						time1 = new Clutter.Timeline(length / 4);
						time2 = new Clutter.Timeline(3 * length / 4);
						current_slide.set_scale_full(ZOOM_OUT_SCALE, ZOOM_OUT_SCALE, stage.width / 2, stage.height / 2);
						current_slide.x = -stage.width;
						alpha1 = new Clutter.Alpha.full(time1, Clutter.AnimationMode.EASE_IN_OUT_SINE);
						time1.new_frame.connect((m) => {
							old_slide.set_scale_full(ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * (1 - alpha1.get_alpha()),
							                         ZOOM_OUT_SCALE + (1 - ZOOM_OUT_SCALE) * (1 - alpha1.get_alpha()),
							                         stage.width / 2,
							                         stage.height / 2);
						});
						time1.completed.connect(() => {
							old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2, "x", stage.width);
							// I have no explanation for why that is required, but nothing else worked properly
							current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length / 2, "x", 0.0f);
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
			current_slide.add_actor(current_slide_bg);
			current_slide.add_actor(current_slide_content);
			stage.add_actor(current_slide);
		}
		
		private void create_current_slide(Slide slide)
		{
			// create a new slide and its background
			current_slide = new Clutter.Group();
			current_slide.set_clip(0, 0, stage.width, stage.height);
			current_slide_bg = new Clutter.Group();
			current_slide_content = new Clutter.Group();
			Clutter.Actor background;
			if (slide.background_image != null)
			{
				background = new Clutter.Texture.from_file(document.path + slide.background_image);
				background.width = stage.width;
				background.height = stage.height;
			}
			else
			{
				background = new Clutter.Rectangle();
				((Clutter.Rectangle)background).set_color(slide.background_color);
				background.width = stage.width;
				background.height = stage.height;
			}
			current_slide_bg.add_actor(background);
			
			// add the slide's elements as actors
			for (var i = 0; i < slide.elements.size; i++)
			{
				try
				{
					Clutter.Actor actor = slide.elements.get(i).presentation_actor();
					current_slide_content.add_actor(actor);
				}
				catch (GLib.Error e)
				{
					stdout.printf("Error: %s\n", e.message);
				}
			}
		}
		
		private void prepare_slide_transition()
		{
			current_slide.add_actor(current_slide_bg);
			current_slide.add_actor(current_slide_content);
		}
		
		private void prepare_stack_transition(bool current_on_top)
		{
			old_slide.remove_all();
			if (current_on_top)
			{
				stage.add_actor(current_slide_bg);
				stage.add_actor(old_slide_bg);
				stage.add_actor(old_slide_content);
				stage.add_actor(current_slide_content);
			}
			else
			{
				stage.add_actor(current_slide_bg);
				stage.add_actor(old_slide_bg);
				stage.add_actor(current_slide_content);
				stage.add_actor(old_slide_content);
			}
		}
		
		private void animation_complete()
		{
			can_animate = true;
			
			if (current_slide_bg.get_parent() == stage)
			{
				stage.remove_all();
				current_slide.add_actor(current_slide_bg);
				current_slide.add_actor(current_slide_content);
				stage.add_actor(current_slide);
			}
		}
		
		private void key_press(Clutter.Actor actor, Clutter.Event event)
		{
			switch (event.key.keyval)
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
