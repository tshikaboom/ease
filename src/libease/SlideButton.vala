using libease;

namespace Ease
{
	public class SlideButton : Gtk.Button
	{
		public int slide_id { get; set; }
		public Slide slide { get; set; }
		public Gtk.Label number { get; set; }
		public GtkClutter.Embed slide_image { get; set; }
		public Gtk.AspectFrame aspect { get; set; }
		
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
			slide_image = new GtkClutter.Embed();
			var color = Clutter.Color();
			color.from_string("Red");
			((Clutter.Stage)(slide_image.get_stage())).set_color(color);
			aspect = new Gtk.AspectFrame("Slide", 0, 0, (float)slide.parent.width / slide.parent.height, false);
			aspect.set_size_request(0, 50);
			aspect.label = null;
			aspect.add(slide_image);
			hbox.pack_start(aspect, true, true, 0);
			align = new Gtk.Alignment(0.5f, 0.5f, 1, 1);
			align.add(hbox);
			
			this.relief = Gtk.ReliefStyle.NONE;
			this.focus_on_click = false;
			this.show_all();
			this.add(align);
		}
	}
}
