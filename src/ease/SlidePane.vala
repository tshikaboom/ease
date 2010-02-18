namespace Ease
{
	public class SlidePane : Gtk.VBox
	{
		public Gtk.ComboBox effect { get; set; }
		public Gtk.SpinButton duration { get; set; }
		public Gtk.ComboBox variant { get; set; }
		public Gtk.Label variant_label { get; set; }
		public Gtk.ComboBox start_transition { get; set; }
		public Gtk.SpinButton delay { get; set; }
	
		public SlidePane()
		{
			homogeneous = false;
			spacing = 0;
			
			this.set_size_request(200, 0);
			
			// effect selection
			var vbox = new Gtk.VBox(false, 0);
			var hbox = new Gtk.HBox(false, 0);
			var align = new Gtk.Alignment(0, 0, 0, 0);
			align.add(new Gtk.Label("Effect"));
			vbox.pack_start(align, false, false, 0);
			effect = new Gtk.ComboBox();
			align = new Gtk.Alignment(0, 0, 1, 1);
			align.add(effect);
			vbox.pack_start(align, false, false, 0);
			hbox.pack_start(vbox, true, true, 5);
			
			// effect duration
			vbox = new Gtk.VBox(false, 0);
			align = new Gtk.Alignment(0, 0, 0, 0);
			align.add(new Gtk.Label("Duration"));
			vbox.pack_start(align, false, false, 0);
			duration = new Gtk.SpinButton.with_range(0, 10, 0.25);
			duration.digits = 2;
			align = new Gtk.Alignment(0, 0.5f, 1, 1);
			align.add(duration);
			vbox.pack_start(align, true, true, 0);
			hbox.pack_start(vbox, false, false, 5);
			this.pack_start(hbox, false, false, 5);
		}
	}
}