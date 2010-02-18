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
			
			open_button = new Gtk.Button.from_stock("gtk-open");
			align = new Gtk.Alignment(0, 0.5f, 0, 0);
			align.add(open_button);
			hbox.pack_end(align, false, false, 0);
			
			// create the upper UI - the embed
			container = new Gtk.ScrolledWindow(null, null);
			container.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
			embed_align = new Gtk.Alignment(0, 0, 1, 1);
			embed = new GtkClutter.Embed();
			embed_align.add(embed);
			container.add_with_viewport(embed_align);
			
			var stage = (Clutter.Stage)embed.get_stage();
			var color = Clutter.Color();
			color.from_string("Gray");
			stage.set_color(color);
			stage.height = 1000;
			
			// put it all together
			var vbox = new Gtk.VBox(false, 0);
			align = new Gtk.Alignment(0, 1, 1, 0);
			align.add(hbox);
			align.set_padding(5, 5, 5, 5);
			vbox.pack_end(align, false, false, 0);
			vbox.pack_start(container, true, true, 0);
			
			this.add(vbox);
			this.show_all();
			
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
	}
}
