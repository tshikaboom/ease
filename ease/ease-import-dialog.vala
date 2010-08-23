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

internal class Ease.ImportDialog : Gtk.Window
{
	public signal void add_image(string filename);
	
	internal ImportDialog()
	{
		title = _("Import Media");
		set_default_size(640, 480);
		
		// create the source list
		var view = new Source.View();
		var group = new Source.Group(_("Images"));
		view.add_group(group);
		view.show_all();
		
		Plugin.ImportService service = new FlickrService();
		var flickr = create_item("Flickr", "gtk-go-down", service);
		group.add_item(flickr);
		service = new OCAService();
		group.add_item(create_item("OpenClipArt", "gtk-go-down", service));
		
		add(view);
		view.show_all();
		flickr.select();
	}
	
	internal void run()
	{
		show();
	}
	
	private Source.Item create_item(string title, string stock_id,
	                                Plugin.ImportService service)
	{
		var widget = new ImportWidget(service);
		var item = new Source.SpinnerItem.from_stock_icon(title, stock_id,
		                                                  widget);
		
		widget.add_media.connect((media) => {
			var temp = Temp.request();
			
			var file = File.new_for_uri(media.file_link);
			var copy = File.new_for_path(Path.build_filename(temp, "media"));
			try
			{
				file.copy(copy, FileCopyFlags.OVERWRITE, null, null);
				add_image(copy.get_path());
			}
			catch (Error e)
			{
				critical("Couldn't read file: %s", e.message);
				return;
			}
		});
		
		service.started.connect(() => item.start());
		service.no_results.connect(() => item.stop());
		service.loading_complete.connect(() => item.stop());
		
		return item;
	}
}
