using Clutter;

namespace Ease
{
	public class Player : GLib.Object
	{
		public Document document { get; set; }
		public int slide_index { get; set; }
		public Clutter.Stage stage { get; set; }
		private Clutter.Group current_slide_content { get; set; }
		private Clutter.Group current_slide_bg { get; set; }
		private Clutter.Group current_slide { get; set; }
		private Clutter.Group old_slide_content { get; set; }
		private Clutter.Group old_slide_bg { get; set; }
		private Clutter.Group old_slide { get; set; }
		private Clutter.Timeline animation_time { get; set; }
		private bool can_animate { get; set; }
	
		public Player(Document doc)
		{
			stage = new Clutter.Stage();
			document = doc;
			slide_index = -1;
			
			stage.width = document.width;
			stage.height = document.height;
			stage.title = "Ease Presentation";
			
			//stage.set_fullscreen(true);
			//stage.hide_cursor();
			
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
				Clutter.main_quit();
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
				
				switch (slide.transition)
				{
					case "fade":
						prepare_slide_transition();
						current_slide.opacity = 0;
						current_slide.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 255);
						break;
					case "slide":
						prepare_slide_transition();
						current_slide.y = -stage.height;
						current_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", 0);
						old_slide.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "y", stage.height);
						break;
					case "zoom":
						prepare_slide_transition();
						current_slide.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
						animation_time.new_frame.connect((m) => {
							current_slide.set_scale((float)m / (float)length,
							                        (float)m / (float)length);
						});
						//current_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_x", 1);
						//current_slide.animate(Clutter.AnimationMode.EASE_OUT_SINE, length, "scale_y", 1);
						break;
					case "contents_slide":
						prepare_stack_transition();
						old_slide_bg.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
						current_slide_content.x = -stage.width;
						current_slide_content.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", 0);
						old_slide_content.animate(Clutter.AnimationMode.EASE_IN_OUT_SINE, length, "x", stage.width);
						break;
					case "contents_zoom":
						prepare_stack_transition();
						old_slide_bg.animate(Clutter.AnimationMode.EASE_IN_SINE, length, "opacity", 0);
						current_slide_content.set_scale_full(0, 0, stage.width / 2, stage.height / 2);
						old_slide_content.set_scale_full(1, 1, stage.width / 2, stage.height / 2);
						old_slide_content.animate(Clutter.AnimationMode.LINEAR, length, "opacity", 0);
						animation_time.new_frame.connect((m) => {
							current_slide_content.set_scale((float)m / (float)length,
							                                (float)m / (float)length);
							old_slide_content.set_scale(1.0 + 2 * (float)m / (float)length,
							   	                        1.0 + 2 * (float)m / (float)length);
						});
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
		
		private void prepare_stack_transition()
		{
			old_slide.remove_all();
			stage.add_actor(current_slide_bg);
			stage.add_actor(old_slide_bg);
			stage.add_actor(old_slide_content);
			stage.add_actor(current_slide_content);
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
					Clutter.main_quit();
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
	}
}