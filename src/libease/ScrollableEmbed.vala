namespace Ease
{
	public class ScrollableEmbed : Gtk.Table
	{
		private GtkClutter.Embed embed;
		private Gtk.HScrollbar h_scrollbar;
		private Gtk.VScrollbar v_scrollbar;
	
		public ScrollableEmbed()
		{
			// create children
			embed = new GtkClutter.Embed();
			h_scrollbar = new Gtk.HScrollbar(null);
			v_scrollbar = new Gtk.VScrollbar(null);
		
			// set up the table
			n_rows = 2;
			n_columns = 2;
			
			attach(embed, 0, 1, 0, 1, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.EXPAND, 0, 0);
			attach(h_scrollbar, 0, 1, 1, 2, Gtk.AttachOptions.EXPAND, Gtk.AttachOptions.SHRINK, 0, 0);
			attach(v_scrollbar, 1, 2, 0, 1, Gtk.AttachOptions.SHRINK, Gtk.AttachOptions.EXPAND, 0, 0);
		}
		
		public Clutter.Stage get_stage()
		{
			return (Clutter.Stage)(embed.get_stage());
		}
	}
}
