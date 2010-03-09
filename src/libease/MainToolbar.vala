

namespace Ease
{
	public class MainToolbar : Gtk.Toolbar
	{
		public Gtk.ToolButton new_slide;
		public Gtk.ToolButton play;
		public Gtk.ToolButton save;
		public Gtk.ToolButton inspector;
		public Gtk.ToolButton slides;
	
		public MainToolbar()
		{
			// tool buttons
			new_slide = new Gtk.ToolButton.from_stock("gtk-add");
			play = new Gtk.ToolButton.from_stock("gtk-media-play");
			save = new Gtk.ToolButton.from_stock("gtk-save");
			slides = new Gtk.ToolButton.from_stock("gtk-dnd-multiple");
			inspector = new Gtk.ToolButton.from_stock("gtk-info");
			
			// add buttons
			insert(new_slide, -1);
			insert(play, -1);
			insert(save, -1);
			insert(slides, -1);
			insert(inspector, -1);
			
			// format toolbar
			toolbar_style = Gtk.ToolbarStyle.ICONS;
		}
	}
}
