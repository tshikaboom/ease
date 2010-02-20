

namespace Ease
{
	public class WelcomeWindow : Gtk.Window
	{
		private Gtk.Button new_button;
		private Gtk.Button open_button;
		private Gtk.ComboBox resolution;
		private Gtk.SpinButton x_res;
		private Gtk.SpinButton y_res;
		private GtkClutter.Embed embed;
		private Gtk.ScrolledWindow container;
		private Gtk.Alignment embed_align;
		private Clutter.Group preview_container;
		private Gtk.HScale zoom_slider;
		private Gtk.Button zoom_in;
		private Gtk.Button zoom_out;
		
		// the size of the thumbnail previews (they are 4:3)
		private int preview_width = 100;
		
		// the thumbnail previews
		private Gee.ArrayList<WelcomeActor> previews = new Gee.ArrayList<WelcomeActor>();
		
		// constants
		private const int[] RESOLUTIONS_X = {800,
		                                     1024,
		                                     1280,
		                                     1280,
		                                     1920};
		private const int[] RESOLUTIONS_Y = {600,
		                                     768,
		                                     1024,
		                                     720,
		                                     1080};
		private const int RESOLUTION_COUNT = 5;
		private const int PREVIEW_PADDING = 20;
		
		public WelcomeWindow()
		{
			this.title = "Ease";
			this.set_default_size(640, 480);
			
			// build the bottom UI
			var hbox = new Gtk.HBox(false, 5);
			resolution = new Gtk.ComboBox.text();
			resolution.append_text("Custom");
			for (var i = 0; i < RESOLUTION_COUNT; i++)
			{
				resolution.append_text("%ix%i".printf(RESOLUTIONS_X[i], RESOLUTIONS_Y[i]));
			}
			resolution.set_active(2);
			
			var align = new Gtk.Alignment(0, 0.5f, 0, 0);
			align.add(resolution);
			hbox.pack_start(align, false, false, 0);
			
			x_res = new Gtk.SpinButton.with_range(320, 1920, 1);
			x_res.set_value(1024);
			align = new Gtk.Alignment(0, 0.5f, 0, 0);
			align.add(x_res);
			hbox.pack_start(align, false, false, 0);
			
			y_res = new Gtk.SpinButton.with_range(240, 1920, 1);
			y_res.set_value(768);
			align = new Gtk.Alignment(0, 0.5f, 0, 0);
			align.add(y_res);
			hbox.pack_start(align, false, false, 0);
			
			new_button = new Gtk.Button.with_label("New Presentation");
			new_button.image = new Gtk.Image.from_stock("gtk-new", Gtk.IconSize.BUTTON);
			align = new Gtk.Alignment(0, 0.5f, 0, 0);
			align.add(new_button);
			hbox.pack_start(align, false, false, 0);
			
			hbox.pack_start(create_zoom_bar(), false, false, 0);
			
			open_button = new Gtk.Button.from_stock("gtk-open");
			align = new Gtk.Alignment(0, 0.5f, 0, 0);
			align.add(open_button);
			hbox.pack_end(align, false, false, 0);
			
			// create the upper UI - the embed
			container = new Gtk.ScrolledWindow(null, null);
			container.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
			container.set_shadow_type(Gtk.ShadowType.NONE);
			embed_align = new Gtk.Alignment(0, 0, 1, 1);
			embed = new GtkClutter.Embed();
			embed_align.add(embed);
			var viewport = new Gtk.Viewport(null, null);
			viewport.set_shadow_type(Gtk.ShadowType.NONE);
			viewport.add(embed_align);
			container.add(viewport);
			
			var stage = (Clutter.Stage)embed.get_stage();
			var color = Clutter.Color();
			color.from_string("Black");
			stage.set_color(color);
			stage.height = 1000;
			
			// add previews to the embed's stage
			preview_container = new Clutter.Group();
			for (var i = 0; i < 50; i++)
			{
				var act = new WelcomeActor(preview_width, ref previews);
				previews.add(act);
				preview_container.add_actor(act);
			}
			stage.add_actor(preview_container);
			stage.show_all();
			
			// put it all together
			var vbox = new Gtk.VBox(false, 0);
			align = new Gtk.Alignment(0, 1, 1, 0);
			align.add(hbox);
			align.set_padding(5, 5, 5, 5);
			vbox.pack_end(align, false, false, 0);
			vbox.pack_end(new Gtk.HSeparator(), false, false, 0);
			vbox.pack_start(container, true, true, 0);
			
			this.add(vbox);
			this.show_all();
			reflow_previews();
			
			// ui signals
			// changing resolution values
			x_res.value_changed.connect(() => {
				set_resolution_box((int)(x_res.get_value()), (int)(y_res.get_value()));
			});
			
			y_res.value_changed.connect(() => {
				set_resolution_box((int)(x_res.get_value()), (int)(y_res.get_value()));
			});
			
			resolution.changed.connect(() => {
				var val = resolution.get_active();
				if (val > 0)
				{
					x_res.set_value(RESOLUTIONS_X[val - 1]);
					y_res.set_value(RESOLUTIONS_Y[val - 1]);
				}
			});
			
			// reflow the stage
			embed.size_allocate.connect(() => {
				reflow_previews();
			});
			
			// click on previews
			foreach (var a in previews)
			{
				a.button_press_event.connect(e => {
					((WelcomeActor)(e.button.source)).clicked();
					return false;
				});
			}
			
			// change the zoom of the previews when the zoom slider is moved
			zoom_slider.value_changed.connect(() => {
				preview_width = (int)zoom_slider.get_value();
				reflow_previews();
			});
		}
		
		private void set_resolution_box(int width, int height)
		{
			for (var i = 0; i < RESOLUTION_COUNT; i++)
			{
				if (width == RESOLUTIONS_X[i] && height == RESOLUTIONS_Y[i])
				{
					resolution.set_active(i + 1);
					return;
				}
			}
			resolution.set_active(0);
		}
		
		private void reflow_previews()
		{
			var stage = embed.get_stage();
			var width = 1;
			for (; width * preview_width + 2 * PREVIEW_PADDING < stage.width; width++);
			if (--width < 1)
			{
				width = 1;
			}
			var x_position = 0;
			var y_pixels = PREVIEW_PADDING;
			for (var i = 0; i < previews.size; i++)
			{
				previews.get(i).x = x_position * (PREVIEW_PADDING + preview_width);
				previews.get(i).y = y_pixels;
				if (++x_position >= width)
				{
					x_position = 0;
					y_pixels += PREVIEW_PADDING + preview_width * 3 / 4; // 4:3
				}
				previews.get(i).width = preview_width;
				previews.get(i).height = preview_width * 3 / 4;
			}
			
			// resize the align, and in effect, the stage so that everything is visible
			embed_align.height_request = y_pixels + PREVIEW_PADDING;
			
			preview_container.x = stage.width / 2;
			preview_container.y = PREVIEW_PADDING;
			preview_container.set_anchor_point(preview_container.width / 2, 0);
		}
		
		private Gtk.Alignment create_zoom_bar()
		{
			var hbox = new Gtk.HBox(false, 5);
			
			// create zoom slider
			zoom_slider = new Gtk.HScale(new Gtk.Adjustment(100, 100, 400, 10, 50, 50));
			zoom_slider.width_request = 200;
			zoom_slider.draw_value = false;
			zoom_slider.digits = 0;
			
			// zoom in button
			zoom_in = new Gtk.Button();
			zoom_in.add(new Gtk.Image.from_stock("gtk-zoom-in", Gtk.IconSize.MENU));
			zoom_in.relief = Gtk.ReliefStyle.NONE;
			
			// zoom out button
			zoom_out = new Gtk.Button();
			zoom_out.add(new Gtk.Image.from_stock("gtk-zoom-out", Gtk.IconSize.MENU));
			zoom_out.relief = Gtk.ReliefStyle.NONE;
			
			// put it all together
			var align = new Gtk.Alignment(0, 0.5f, 1, 0);
			align.add(zoom_out);
			hbox.pack_start(align, false, false, 0);
			
			align = new Gtk.Alignment(0, 0.5f, 1, 0);
			align.add(zoom_slider);
			hbox.pack_start(align, false, false, 0);
			
			align = new Gtk.Alignment(0, 0.5f, 1, 0);
			align.add(zoom_in);
			hbox.pack_start(align, false, false, 0);
			
			align = new Gtk.Alignment(1, 1, 1, 1);
			align.add(hbox);
			return align;
		}
	}
}
