using Ease;

public static class Main : GLib.Object
{
	private static Gee.ArrayList<EditorWindow> windows;
	private static WelcomeWindow welcome;
	
	public static int main_editor(int argc, char** argv)
	{
		string[] args = new string[argc];
		for (var i = 0; i < argc; i++)
		{
			args[i] = (string)argv[i];
		}
	
		// initalize static classes
		Transitions.init();
		windows = new Gee.ArrayList<EditorWindow>();
		
		// initialize libraries
		Gtk.init(ref args);
		Clutter.init(null);
		
		if (args.length == 2)
		{
			test_editor(args[1]);
		}
		else
		{
			test_welcome();
		}
		
		Gtk.main();
		
		return 0;
	}
	
	private static void test_welcome()
	{
		show_welcome();
	}
	
	private static void test_editor(string path)
	{
		add_window(new EditorWindow(path));
	}
	
	public static void remove_window(EditorWindow win)
	{
		windows.remove(win);
		if (windows.size == 0 && welcome == null)
		{
			Gtk.main_quit();
		}
	}
	
	public static void add_window(EditorWindow win)
	{
		windows.add(win);
	}
	
	public static void show_welcome()
	{
		welcome = new WelcomeWindow();
		welcome.hide.connect(() => remove_welcome());
	}
	
	public static void remove_welcome()
	{
		welcome.hide_all();
		welcome = null;
		if (windows.size == 0)
		{
			Gtk.main_quit();
		}
	}
}

