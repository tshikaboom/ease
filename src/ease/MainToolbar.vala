namespace Ease
{
	public class MainToolbar : Gtk.Toolbar
	{
		public Gtk.ToolButton new_slide { get; set; }
		public Gtk.ToolButton play { get; set; }
	
		public MainToolbar()
		{			
			new_slide = new Gtk.ToolButton.from_stock("gtk-new");
			play = new Gtk.ToolButton.from_stock("gtk-media-play");
			
			// add buttons
			this.insert(new_slide, 0);
			this.insert(play, 1);
		}
	}
}