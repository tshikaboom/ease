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
 * Base class for an "import media" dialog that searches a website for media.
 *
 * PluginImportDialog offers a generic interface and almost entirely controls
 * the user interface for the dialog. Therefore, by using PluginImportDialog
 * to write a plugin, the author ensures that it fits in with all similar
 * plugins. PluginImportDialog also automatically manages the downloading
 * of images and image data - subclasses only need to provide a REST call,
 * and parse the response to generate a list of data.
 */
public abstract class Ease.PluginImportDialog : Gtk.Dialog
{
	/**
	 * Primary icon view for display of results.
	 */
	private Gtk.IconView icons;
	
	/**
	 * Scrolled window for icon view.
	 */
	private Gtk.ScrolledWindow icons_scroll;
	
	/**
	 * Search field.
	 */
	protected Sexy.IconEntry search;
	
	/**
	 * Search button.
	 */
	private Gtk.Button button;
	
	/**
	 * Progress bar, displaying the percentage of images downloaded so far.
	 */
	private Gtk.ProgressBar progress;
	
	/**
	 * Alignment placing progress bar at the bottom.
	 */
	private Gtk.Alignment progress_align;
	
	/**
	 * REST Proxy for retrieving image data.
	 */
	protected Rest.Proxy proxy;
	
	/**
	 * REST Call for retrieving image data.
	 */
	protected Rest.ProxyCall call;
	
	/**
	 * Main VBox for packing widgets.
	 */
	private Gtk.VBox main_vbox;
	
	/**
	 * Stores the images to download. As each image is downloaded, it is
	 * removed from the list.
	 */
	protected Gee.LinkedList<PluginImportImage?> images_list;
	
	/**
	 * ListStore for the icon view.
	 */
	private Gtk.ListStore model;
	
	/**
	 * The total amount of images to download.
	 */
	private double list_size;
	
	/**
	 * This base constructor must be called by subclasses to set up the
	 * interface and search functionality.
	 */
	public PluginImportDialog()
	{
		// search field
		search = new Sexy.IconEntry();
		search.add_clear_button();
		
		// search button
		button = new Gtk.Button.from_stock("gtk-find");
		button.clicked.connect((sender) => {
			// create the rest proxy call
			proxy = get_proxy();
			call = get_call();
			
			// remove the icons, if needed
			if (icons_scroll.get_parent() == main_vbox)
			{
				main_vbox.remove(icons_scroll);
			}
			
			// add the progress
			main_vbox.pack_end(progress_align, false, false, 0);
			progress.pulse();
			progress_align.show_all();
			
			// run the call
			try { call.run_async(on_call_finish, this); }
			catch (Error e) { error(e.message); }
		});
		
		// progress
		progress = new Gtk.ProgressBar();
		progress_align = new Gtk.Alignment(0, 1, 1, 0);
		progress_align.add(progress);
		
		// icon view
		icons = new Gtk.IconView();
		icons_scroll = new Gtk.ScrolledWindow(null, null);
		icons_scroll.add_with_viewport(icons);
		icons_scroll.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
		
		// pack search field and button
		var hbox = new Gtk.HBox(false, 5);
		hbox.pack_start(search, true, true, 0);
		hbox.pack_start(button, false, false, 0);
		
		// pack top and bottom
		main_vbox = new Gtk.VBox(false, 5);
		main_vbox.pack_start(hbox, false, false, 0);
		(get_content_area() as Gtk.Box).pack_start(main_vbox, true, true, 0);
	}
	
	/**
	 * Subclasses must override this function to parse the data returned from
	 * their Rest.ProxyCall.
	 *
	 * This method should construct images_list, a Gee.LinkedList of
	 * {@link PluginImportImage}s (or a subclass specific to your plugin).
	 * PluginImportDialog will then automatically download the images.
	 *
	 * @param data The data returned from the REST call.
	 */
	protected abstract void parse_image_data(string data);
	
	/**
	 * Allows subclasses to provide a Rest.Proxy for their website.
	 */
	protected abstract Rest.Proxy get_proxy();
	
	/**
	 * Allows subclasses to provide a Rest.ProxyCall for their website.
	 */
	protected abstract Rest.ProxyCall get_call();
	
	/**
	 * Signal handler for Rest.ProxyCall completion.
	 *
	 * @param call The completed Rest.ProxyCall.
	 */
	private void on_call_finish(Rest.ProxyCall call)
	{
		// update UI
		main_vbox.pack_start(icons_scroll, true, true, 0);
		icons_scroll.show_all();
		
		// create list and model
		model = new Gtk.ListStore(2, typeof(Gdk.Pixbuf), typeof(string));
		images_list = new Gee.LinkedList<PluginImportImage?>();
		
		// parse the image data (done by subclasses)
		parse_image_data(call.get_payload());
		
		// remember the list size for the progress bar
		list_size = images_list.size;
		
		// set icons
		icons.set_model(model);
		icons.text_column = Column.TEXT;
		icons.pixbuf_column = Column.PIXBUF;
		
		// if threads are supported, get the pixbufs in a thread
		if (Thread.supported())
		{
			try { Thread.create(threaded_get_pixbufs, false); }
			catch { threaded_get_pixbufs(); }
		}
		else
		{
			threaded_get_pixbufs();
		}
	}
	
	/**
	 * Retrieves the first pixbuf in "images_list", then calls itself again if
	 * there are more images.
	 *
	 * As its name implies, threaded_get_pixbufs should be used in a thread,
	 * because getting images from the web can be slow. While it will work
	 * when not run in a thread (if, for example, threads are not supported),
	 * this will lock up the user interface and be a bad experience for the
	 * user.
	 */
	private void* threaded_get_pixbufs()
	{
		// get the next image
		PluginImportImage image;
		lock (images_list) { image = images_list.poll_head(); }
		
		// get the pixbuf for this image
		var pixbuf = gdk_pixbuf_from_uri(image.thumb_link == null ?
		                                 image.file_link : 
		                                 image.thumb_link);
		
		// append to the model
		var tree_itr = Gtk.TreeIter();
		lock (model)
		{
			model.append(out tree_itr);
			model.set(tree_itr, Column.PIXBUF, pixbuf,
				                Column.TEXT, image.title);
		}
		
		// set the progress bar
		lock (progress)
		{
			progress.set_fraction(1 - (images_list.size / list_size));
		}
			
		// continue if there are more images
		lock (images_list)
		{
			if (images_list.size > 0) threaded_get_pixbufs();
		}
			
		// otherwise, remove the progress bar and return
		lock (main_vbox)
		{
			if (progress_align.get_parent() == main_vbox)
			{
				main_vbox.remove(progress_align);
			}
		}
		return null;
	}
	
	/**
	 * Loads and returns a pixbuf from a URI. Best used threaded, to prevent 
	 * lock up.
	 *
	 * @param uri The URI to load from.
	 */
	private Gdk.Pixbuf? gdk_pixbuf_from_uri (string uri) {

		File file = File.new_for_uri (uri);
		FileInputStream filestream;
		try {
			filestream = file.read (null);
		} catch (Error e) {
			filestream = null;
			error ("Couldn't read distant file : %s", e.message);
		}
		assert (filestream != null);
		Gdk.Pixbuf pix;
		try {
			pix = new Gdk.Pixbuf.from_stream_at_scale (filestream,
														   200,
														   200,
														   true,
														   null);
		} catch (Error e) {
			error ("Couldn't create pixbuf from file: %s", e.message);
			pix = null;
		}
		return pix;
	}
	
	/**
	 * Enumerator for columns in the "model" ListStore.
	 */
	private enum Column
	{
		/**
		 * The column storing Gdk.Pixbufs, downloaded from the internet.
		 * Note that these pixbufs are often only the thumbnails.
		 */
		PIXBUF = 0,
		
		/**
		 * The column for the label displayed in the Gtk.IconView.
		 */
		TEXT = 1
	}
}
