/*  Ease, a GTK presentation application
    Copyright (C) 2010 Nate Stedman

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

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
		
		Gtk.init(ref args);
		Clutter.init(null);
	
	
		// initalize static classes
		Transitions.init();
		OpenDialog.init();
		windows = new Gee.ArrayList<EditorWindow>();
		
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
	
	public static int main_player(int argc, char** argv)
	{
		string[] args = new string[argc];
		for (var i = 0; i < argc; i++)
		{
			args[i] = (string)argv[i];
		}
		
		if (args.length < 2)
		{
			return 0;
		}
		
		Gtk.init(ref args);
		Clutter.init(null);
		
		var doc = new Document.from_file(args[1]);
		var player = new Player(doc);
		player.stage.hide.connect(() => {
			Gtk.main_quit();
		});
		
		Gtk.main();
		
		return 1;
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
		if (welcome == null)
		{
			welcome = new WelcomeWindow();
			welcome.hide.connect(() => remove_welcome());
		}
		else
		{
			welcome.present();
		}
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

