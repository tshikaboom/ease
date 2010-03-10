namespace Ease
{
	public class ScrollableEmbed : Gtk.Table
	{
		private GtkClutter.Embed embed;
		private Gtk.HScrollbar h_scrollbar;
		private Gtk.VScrollbar v_scrollbar;
		private Gtk.Adjustment h_adjust;
		private Gtk.Adjustment v_adjust;
		
		public bool has_horizontal { get; private set; }
	
		public ScrollableEmbed(bool horizontal)
		{
			has_horizontal = horizontal;
			
			// create children
			embed = new GtkClutter.Embed();
			h_adjust = new Gtk.Adjustment(0, 0, 1, 0.1, 0.1, 0.1);
			h_scrollbar = new Gtk.HScrollbar(h_adjust);
			v_adjust = new Gtk.Adjustment(0, 0, 1, 0.1, 0.1, 0.1);
			v_scrollbar = new Gtk.VScrollbar(v_adjust);
		
			// set up the table
			n_rows = has_horizontal ? 2 : 1;
			n_columns = 2;
			
			attach(embed,
			       0, 1, 0, 1,
			       Gtk.AttachOptions.EXPAND,
			       Gtk.AttachOptions.EXPAND,
			       0, 0);
			attach(v_scrollbar,
			       1, 2, 0, 1,
			       Gtk.AttachOptions.SHRINK,
			       Gtk.AttachOptions.FILL,
			       0, 0);
			if (has_horizontal)
			{
				attach(h_scrollbar,
				       0, 1, 1, 2,
				       Gtk.AttachOptions.FILL,
				       Gtk.AttachOptions.SHRINK,
				       0, 0);
			}
			get_stage().show();
			
			var stage = (Clutter.Stage)embed.get_stage();
			var color = Clutter.Color();
			color.from_string("Black");
			stage.set_color(color);
		}
		
		public Clutter.Stage get_stage()
		{
			return (Clutter.Stage)(embed.get_stage());
		}
	}
}
