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
	
	private const OptionEntry[] options = {
		{ "play", 'p', 0, OptionArg.FILENAME, ref play_filename,
		   "Play the specified file", "FILE" },
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
	
		// open editor windows for each argument specified
		if (filenames != null)
		{
			for (int i = 0; filenames[i] != null; i++)
			{
				test_editor(filenames[i]);
			}
		}
		
		// if --play is specified, play the presentation
		if (play_filename != null)
		{
			var doc = new Document.from_file(play_filename);
			player = new Player(doc);
			
			// if no editor windows are specified, quit when done
			if (filenames == null)
			{
				player.stage.hide.connect(() => {
					Gtk.main_quit();
				});
			}
		}
		
		// if no files are given, show the new presentation window
		if (filenames == null && play_filename == null)
		{
			show_welcome();
		}
	
		Gtk.main();
	
		return 0;
	}

	public static void test_editor(string path)
	{
		add_window(new EditorWindow(path));
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
}

