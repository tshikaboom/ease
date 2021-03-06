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

internal class Ease.Main : Gtk.Application
{
	private static Gee.ArrayList<EditorWindowInfo> windows;
	private static WelcomeWindow welcome;

	// options
	static string play_filename;
	static string[] filenames;
	internal static bool presentation_windowed = false;
	private static bool debug_undo = false;

	private const OptionEntry[] options = {
		{ "play", 'p', 0, OptionArg.FILENAME, ref play_filename,
		   "Play the specified file", "FILE" },
		{ "window", 'w', 0, OptionArg.NONE, ref presentation_windowed,
		  "Display presentations in a window", null},
		{ "debug-undo", 0, 0, OptionArg.NONE, ref debug_undo,
		  "Display debugging messages about undo actions", null },
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref filenames, null, "FILE..." },
		{ null } };

	private static Player player;

	private enum UniqueCommand
	{
		OPEN_FILE = 1,
		PLAY_FILE = 2,
		SHOW_WELCOME = 3
	}

	public void on_app_activate() {
		welcome = new WelcomeWindow();
		this.add_window(welcome);
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
	internal static void open_file(string path)
	{
		// initalize static classes
		windows = new Gee.ArrayList<EditorWindowInfo>();
		foreach (var info in windows)
		{
			if (absolute_path(info.window.document.filename) ==
			    absolute_path(path))
			{
				info.window.present();
				return;
			}
		}

		try
		{
			var doc = new Document.from_saved(path);
			var win = new EditorWindow(doc);
			add_editor_window(win);
			win.show_now();
			win.present();
		}
		catch (Error e)
		{
			error_dialog(_("Error Opening Document"), e.message);
			return;
		}
	}

	/**
	 * Plays a file.
	 */
	internal static void play_file(string file, bool close_when_done)
	{
		if (player != null)
		{
			warning("Cannot play %s while another document is playing", file);
		}
		try
		{
			var doc = new Document.from_saved(file);
			player = new Player(doc);

			// if requested, quit ease when done
			if (close_when_done)
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

	/**
	 * Creates a new {@link EditorWindow} from a theme and size.
	 */
	internal static void new_from_theme(Theme theme, int width, int height)
	{
		try
		{
			var document = new Document.from_theme(theme, width, height);
			var editor = new EditorWindow(document);
			add_editor_window(editor);
			editor.present();
		}
		catch (Error e)
		{
			error_dialog(_("Error creating new document"), e.message);
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
	private static void remove_window(EditorWindow win)
	{
		foreach (var info in windows)
		{
			if (info.window == win)
			{
				windows.remove(info);
				break;
			}
		}
		win.play.disconnect(on_play);
		win.close.disconnect(on_close);

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
	private static void add_editor_window(EditorWindow win)
	{
		windows.add(new EditorWindowInfo(win));
		win.play.connect(on_play);
		win.close.connect(on_close);
	}

	/**
	 * Handles the {@link EditorWindow.play} signal.
	 *
	 * Hides all visible windows and displays the presentation.
	 */
	private static void on_play(Document document)
	{
		player = new Player(document);
		player.present();

		player.complete.connect(() => {
				player.destroy ();
			foreach (var info in windows)
			{
				info.window.show();
				info.window.move(info.x, info.y);
			}
		});

		foreach (var info in windows)
		{
			info.window.get_position(out info.x, out info.y);
			info.window.hide();
		}
	}

	/**
	 * Closes and removes an EditorWindow.
	 */
	private static void on_close(EditorWindow self)
	{
		self.hide();
		remove_window(self);
	}

	/**
	 * Shows the {@link WelcomeWindow}
	 *
	 * Shows the {@link WelcomeWindow}, or raises it to the top if it is not
	 * already displayed.
	 *
	 */
	internal static void show_welcome()
	{
		if (welcome == null)
		{
			// FIXME: Window below is unowned by any {@link Gtk.Application}
			//        which leading to error where it never be shown.
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
	internal static void remove_welcome()
	{
		welcome.hide();
		welcome = null;
		if (windows.size == 0)
		{
			Gtk.main_quit();
		}
	}

	private class EditorWindowInfo
	{
		public EditorWindow window;
		public int x = 0;
		public int y = 0;

		public EditorWindowInfo(EditorWindow win)
		{
			window = win;
		}
	}
}

/**
 * Start Ease to edit files.
 *
 * If the user runs Ease with a filename as a parameter, this function
 * will open an {@link EditorWindow}. Otherwise, a {@link WelcomeWindow}
 * will be opened.
 *
 * @param args Program arguments.
 */
 static int main(string[] args)
{
/*
	// parse command line options
	var context = new OptionContext(_(" - a presentation editor"));

	// TODO: set translation
	context.add_main_entries(options, null);

	// add library option groups
	context.add_group(Gtk.get_option_group(true));
	context.add_group(Clutter.get_option_group());

	try
	{
		if (!context.parse(ref args)) return 1;
	}
	catch (OptionError e)
	{
		stdout.printf(_("error parsing options: %s\n"), e.message);
		return 1;
	}
*/
	// init gstreamer
	Gst.init(ref args);

	// react to command line flags
	//UndoController.enable_debug = debug_undo;



	// Clutter settings
	Clutter.init(ref args);
	var backend = Clutter.get_default_backend();
	var settings = Gtk.Settings.get_default();
	backend.set_double_click_time(settings.gtk_double_click_time);
	backend.set_double_click_distance(
		settings.gtk_double_click_distance);




	Ease.Main app;
	app = new Ease.Main();
	app.set_application_id("org.gnome.Ease");
	app.activate.connect(app.on_app_activate);
	int status = app.run();
//	Temp.clean();


	return status;
}
