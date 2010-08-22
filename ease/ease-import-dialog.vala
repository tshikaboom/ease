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
	internal ImportDialog()
	{
		title = _("Import Media");
		set_default_size(640, 480);
		
		// create the source list
		var view = new Source.View();
		var group = new Source.Group(_("Images"));
		view.add_group(group);
		view.show_all();
		
		Plugin.ImportService service = new OCAService();
		var oca = create_item("OpenClipArt", "gtk-go-down", service);
		group.add_item(oca);
		service = new FlickrService();
		group.add_item(create_item("Flickr", "gtk-go-down", service));
		
		add(view);
		view.show_all();
		oca.select();
	}
	
	internal void run()
	{
		show();
	}
	
	private Source.Item create_item(string title, string stock_id,
	                                Plugin.ImportService service)
	{
		var widget = new ImportWidget(service);
		
		return new Source.Item.from_stock_icon(title, stock_id, widget);
	}
}
