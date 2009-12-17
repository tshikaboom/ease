using GLib;
using Ease;

public class Main : GLib.Object
{
	public static int main(string[] args)
	{
		Document doc = new Document.from_file("../../../../Examples/Example.ease/");
		doc.print_representation();
		/*Gtk.init(ref args);
		Clutter.init(null);
		var Window = new Window();
		
		Window.destroy.connect(Gtk.main_quit);
		
		Window.show_all();
		Window.embed.show();
		
		((Clutter.Stage)Window.embed.get_stage()).add_actor(new Clutter.Text.with_text("Myriad Pro Light 50", "Hello "));
		
		//var player = new Player();
		
		Gtk.main();*/
		return 0;
	}
}