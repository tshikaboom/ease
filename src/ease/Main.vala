using Ease;

public class Main : GLib.Object
{
	public static int main(string[] args)
	{
		// initalize static classes
		Transitions.init();
		
		test_editor(args);
		
		return 0;
	}
	
	private static void test_editor(string[] args)
	{
		Gtk.init(ref args);
		Clutter.init(null);
		var window = new EditorWindow("Examples/Example.ease/");
		window.destroy.connect(Gtk.main_quit);				
		Gtk.main();
	}
}
