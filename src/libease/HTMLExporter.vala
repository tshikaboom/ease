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

namespace Ease
{
	public class HTMLExporter : GLib.Object
	{
		private Gtk.Dialog window;
		private Gtk.ProgressBar progress;
		
		public string path { get; private set; }
		
		public HTMLExporter()
		{
			progress = new Gtk.ProgressBar();
		}
		
		public bool request_path(Gtk.Window window)
		{
			var dialog = new Gtk.FileChooserDialog("Export to HTML",
			                                       window,
			                                       Gtk.FileChooserAction.SAVE,
			                                       "gtk-save",
			                                       Gtk.ResponseType.ACCEPT,
			                                       "gtk-cancel",
			                                       Gtk.ResponseType.CANCEL,
			                                       null);
			
			if (dialog.run() == Gtk.ResponseType.ACCEPT)
			{
				path = dialog.get_filename();
				dialog.destroy();
				return true;
			}
			else
			{
				dialog.destroy();
				return false;
			}
		}
		
		public void add_progress(double amount)
		{
			progress.fraction += amount;
		}
	}
}
