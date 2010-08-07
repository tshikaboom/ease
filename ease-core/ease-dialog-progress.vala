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
 * Controls a dialog displaying a progress bar, and optionally a cancel button
 * and label.
 *
 * Note that this class is not a subclass of Gtk.Dialog.
 */
public class Ease.Dialogs.Progress : GLib.Object
{
	private const string UI_FILE = "progress-dialog.ui";
	
	private Gtk.Dialog dialog;
	private Gtk.Button cancel;
	private Gtk.Label label;
	private Gtk.ProgressBar progress;
	private double max_val;
	
	/**
	 * Creates a progress dialog.
	 *
	 * @param title The title of the dialog.
	 * @param cancellable If the dialog should display a cancel button.
	 * @param max The maximum value of the dialog.
	 * @param modal The window the dialog should be modal for, or null.
	 */
	public Progress(string title, bool cancellable, double max,
	                Gtk.Window? modal)
	{
		max_val = max;
		
		var builder = new Gtk.Builder();
		try
		{
			builder.add_from_file(data_path(Path.build_filename(Temp.UI_DIR,
				                                                UI_FILE)));
		}
		catch (Error e) { error("Error loading UI: %s", e.message); }
		
		// get builder objects
		dialog = builder.get_object("dialog") as Gtk.Dialog;
		cancel = builder.get_object("cancel") as Gtk.Button;
		label = builder.get_object("label") as Gtk.Label;
		progress = builder.get_object("progress") as Gtk.ProgressBar;
		
		// set basic stuff
		dialog.title = title;
		cancel.visible = cancellable;
	}
	
	/**
	 * Shows the progress dialog.
	 */
	public void show()
	{
		dialog.show();
	}
	
	/**
	 * Hides the progress dialog.
	 */
	public void destroy()
	{
		dialog.destroy();
	}
	
	/**
	 * Sets (or unsets with null) the label of this dialog. Markup allowed.
	 */
	public void set_label(string? str)
	{
		if (str == null)
		{
			label.hide();
			return;
		}
		label.set_markup(str);
		label.show_all();
	}
	
	/**
	 * Sets the dialog's progress to a value relative to the maximum, specified
	 * in the constructor.
	 */
	public void set(double val)
	{
		progress.set_fraction(val / max_val);
	}
	
	/**
	 * Sets the dialog's progress to a fraction between 0 and 1.
	 */
	public void set_fraction(double val)
	{
		progress.set_fraction(val);
	}
	
	/**
	 * Adds a value, relative to the maximum specified in the constructor, to
	 * the progress bar.
	 */
	public void add(double val)
	{
		progress.set_fraction(progress.get_fraction() + val / max_val);
	}
	
	/**
	 * Adds a fractional value to the progress bar.
	 */
	public void add_fraction(double val)
	{
		progress.set_fraction(progress.get_fraction() + val);
	}
}
