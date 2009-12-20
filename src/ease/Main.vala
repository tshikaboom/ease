using Ease;

public class Main : GLib.Object
{
	public static int main(string[] args)
	{
		// initalize static classes
		Transitions.init();
		
		test_editor(args);

		//test_player("../../../../Examples/Example.ease/");
		
		return 0;
	}
	
	private static void test_player(string filename)
	{
		Document doc = new Document.from_file(filename);
		//doc.print_representation();
		
		Clutter.init(null);
		var player = new Player(doc);
		player.stage.hide.connect(Clutter.main_quit);
		
		Clutter.main();
	}
	
	private static void test_editor(string[] args)
	{
		Gtk.init(ref args);
		Clutter.init(null);
		var Window = new Window("../../../../Examples/Example.ease/");
		
		Window.destroy.connect(Gtk.main_quit);				
		Gtk.main();
	}
}