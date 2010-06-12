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

/**
 * Handles core actions in Ease
 *
 * When Ease starts, the  simple C main function calls a function in this
 * class. Main then initializes GTK, Clutter, and anything else.
 * 
 * Main keeps track of {@link EditorWindow}s, as well as the status of the
 * single {@link WelcomeWindow}. Main will end Ease if none of these are
 * shown on the screen.
 */
public static class Ease.Main : GLib.Object
{
	private static Gee.ArrayList<EditorWindow> windows;
	private static WelcomeWindow welcome;
	
	// options
	static string play_filename;
	static string[] filenames;
	public static bool presentation_windowed = false;
	
	private const OptionEntry[] options = {
		{ "play", 'p', 0, OptionArg.FILENAME, ref play_filename,
		   "Play the specified file", "FILE" },
		{ "window", 'w', 0, OptionArg.NONE, ref presentation_windowed,
		  "Display presentations in a window", null},
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref filenames, null, "FILE..." },
		{ null } };
	
	private static Player player;
	
	/**
	 * Start Ease to edit files.
	 * 
	 * If the user runs Ease with a filename as a parameter, this function
	 * will open an {@link EditorWindow}. Otherwise, a {@link WelcomeWindow}
	 * will be opened.
	 *
	 * @param args Program arguments.
	 */
	public static int main(string[] args)
	{	
		// parse command line options
		var context = new OptionContext(_(" - a presentation editor"));
		
		// TODO: set translation
		context.add_main_entries(options, null);

		// add library option groups
		context.add_group(Gtk.get_option_group(true));
		context.add_group(Clutter.get_option_group());
		
		try
		{
			if (!context.parse(ref args))
			{
				return 1;
			}
		}
		catch (OptionError e)
		{
			stdout.printf(_("error parsing options: %s\n"), e.message);
			return 1;
		}
	
		ClutterGst.init(ref args);

		// initalize static classes
		Transitions.init();
		OpenDialog.init();
		windows = new Gee.ArrayList<EditorWindow>();
		
		// Clutter settings
		var backend = Clutter.get_default_backend();
		var settings = Gtk.Settings.get_default();
		backend.set_double_click_time(settings.gtk_double_click_time);
		backend.set_double_click_distance(settings.gtk_double_click_distance);
	
		// open editor windows for each argument specified
		if (filenames != null)
		{
			for (int i = 0; filenames[i] != null; i++)
			{
				open_file(filenames[i]);
			}
		}
		
		// if --play is specified, play the presentation
		if (play_filename != null)
		{
			try
			{
				var doc = JSONParser.document(play_filename);
				player = new Player(doc);
			
				// if no editor windows are specified, quit when done
				if (filenames == null)
				{
					player.stage.hide.connect(() => {
						Gtk.main_quit();
					});
				}
			}
			catch (Error e)
			{
				error_dialog(_("Error Playing Document"), e.message);
			}
		}
		
		// if no files are given, show the new presentation window
		if (filenames == null && play_filename == null)
		{
			show_welcome();
		}
		
		test_sourceview();
	
		Gtk.main();
		
		Temp.clean();
	
		return 0;
	}

	/**
	 * Creates a new {@link EditorWindow}, or raises an existing one.
	 *
	 * If the passed filename does not have a window associated with it,
	 * a new window will be created to edit that file. Otherwise, the currently
	 * existing window will be raised.
	 *
	 * @param path The filename
	 */
	public static void open_file(string path)
	{
		foreach (var w in windows)
		{
			if (w.document.path == path)
			{
				w.present();
				
				return;
			}
		}
		
		try
		{
			var doc = JSONParser.document(path);
			add_window(new EditorWindow(doc));
		}
		catch (Error e)
		{
			error_dialog(_("Error Opening Document"), e.message);
			return;
		}
	}

	/**
	 * Removes an {@link EditorWindow} from Ease's internal store of windows.
	 * 
	 * Ease tracks the current windows in order to properly quit when there
	 * are no {@link EditorWindow}s on screen and the {@link WelcomeWindow} is
	 * hidden. This function will quit Ease if the removed window is the final
	 * window and the {@link WelcomeWindow} is hidden.
	 *
	 * @param win The {@link EditorWindow}.
	 */
	public static void remove_window(EditorWindow win)
	{
		windows.remove(win);
		if (windows.size == 0 && welcome == null)
		{
			Gtk.main_quit();
		}
	}

	/**
	 * Adds an {@link EditorWindow} to Ease's internal store of windows.
	 * 
	 * Ease tracks the current windows in order to properly quit when there
	 * are no {@link EditorWindow}s on screen and the {@link WelcomeWindow} is
	 * hidden. 
	 *
	 * @param win The {@link EditorWindow}.
	 */
	public static void add_window(EditorWindow win)
	{
		windows.add(win);
	}

	/**
	 * Shows the {@link WelcomeWindow}
	 * 
	 * Shows the {@link WelcomeWindow}, or raises it to the top if it is not
	 * already displayed.
	 *
	 */
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

	/**
	 * Hides the {@link WelcomeWindow}.
	 * 
	 * It's important to call this function when the {@link WelcomeWindow} is
	 * hidden, so that Ease can properly exit when all windows are closed.
	 * When the {@link WelcomeWindow} is shown via show_welcome, this function
	 * is automatically added in that window's hide signal handler.
	 */
	public static void remove_welcome()
	{
		welcome.hide_all();
		welcome = null;
		if (windows.size == 0)
		{
			Gtk.main_quit();
		}
	}
	
	public static void test_sourceview()
	{
		Source.View view = new Source.View();
		
		var group = new Source.Group("Test Group 1");
		var text = new Gtk.TextView();
		var item = new Source.Item.from_stock("gtk-new", text);
		group.add_item(item);
		text = new Gtk.TextView();
		item = new Source.Item.from_stock("gtk-open", text);
		group.add_item(item);
		text = new Gtk.TextView();
		item = new Source.Item.from_stock("gtk-undo", text);
		group.add_item(item);
		text = new Gtk.TextView();
		item = new Source.Item.from_stock("gtk-redo", text);
		group.add_item(item);
		view.add_group(group);
		
		group = new Source.Group("Test Group 2");
		text = new Gtk.TextView();
		item = new Source.Item.from_stock("gtk-add", text);
		group.add_item(item);
		text = new Gtk.TextView();
		item = new Source.Item.from_stock("gtk-about", text);
		group.add_item(item);
		text = new Gtk.TextView();
		item = new Source.Item.from_stock("gtk-floppy", text);
		group.add_item(item);
		view.add_group(group);
		
		item.selected = true;
		
		text = new Gtk.TextView();
		
		var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
		window.add(view);
		//window.add(new Source.Item.from_stock("gtk-new", text));
		window.set_size_request(640, 480);
		window.show_all();
	}
}

