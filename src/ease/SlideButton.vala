namespace Ease
{
	public class SlideButton : Gtk.Button
	{
		public int slide_id { get; set; }
		public Slide slide { get; set; }
		public Gtk.Label number { get; set; }
		public Gtk.Image slide_image { get; set; }
		
		public SlideButton(int id, Slide s)
		{
			slide = s;
			slide_id = id;
			
			var hbox = new Gtk.HBox(false, 5);
			number = new Gtk.Label("<big>" + (slide_id + 1).to_string() + "</big>");
			number.use_markup = true;
			var align = new Gtk.Alignment(0, 0.1f, 0, 0);
			align.add(number);
			hbox.pack_start(align, false, false, 0);
			slide_image = new Gtk.Image.from_stock("gtk-new", Gtk.IconSize.DIALOG);
			hbox.pack_start(slide_image, true, true, 0);
			
			this.relief = Gtk.ReliefStyle.NONE;
			this.focus_on_click = false;
			this.show_all();
			this.add(hbox);
		}
	}
}