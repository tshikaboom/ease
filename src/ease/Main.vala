using Ease;

public class Main : GLib.Object
{
	public static int main(string[] args)
	{	
		test_editor(args);

		test_player("../../../../Examples/Example.ease/");
		
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
		
		Window.show_all();
		Window.embed.show();
		
		((Clutter.Stage)Window.embed.get_stage()).add_actor(new Clutter.Text.with_text("Myriad Pro Light 50", "Hello "));
				
		Gtk.main();
	}
}