namespace Ease
{
	public class MainToolbar : Gtk.Toolbar
	{
		public Gtk.ToolButton new_slide { get; set; }
		public Gtk.ToolButton play { get; set; }
		public Gtk.ToolButton inspector { get; set; }
		public Gtk.ToolButton slides { get; set; }
	
		public MainToolbar()
		{
			// tool buttons
			new_slide = new Gtk.ToolButton.from_stock("gtk-add");
			play = new Gtk.ToolButton.from_stock("gtk-media-play");
			slides = new Gtk.ToolButton.from_stock("gtk-dnd-multiple");
			inspector = new Gtk.ToolButton.from_stock("gtk-info");
			
			// add buttons
			this.insert(new_slide, -1);
			this.insert(play, -1);
			this.insert(slides, -1);
			this.insert(inspector, -1);
			
			// format toolbar
			this.toolbar_style = Gtk.ToolbarStyle.ICONS;
		}
	}
}