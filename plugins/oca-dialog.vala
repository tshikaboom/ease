public class OCA.Dialog : Gtk.Dialog
{
	private Gtk.IconView icons;
	private Gtk.ScrolledWindow icons_scroll;
	private Sexy.IconEntry search;
	private Gtk.Button button;
	private Gtk.Spinner spinner;
	private Gtk.Alignment spinner_align;
	private Rest.Proxy proxy;
	private Rest.ProxyCall call;
	private Gtk.VBox main_vbox;
	
	private const string REST_URL =
		"http://www.openclipart.org/media/feed/rss/";
	
	private const Sexy.IconEntryPosition ICON_POS =
		Sexy.IconEntryPosition.PRIMARY;
	
	private const Gtk.IconSize SIZE = Gtk.IconSize.MENU;
	private const int SPIN_SIZE = 40;
	
	public Dialog()
	{
		// search field
		search = new Sexy.IconEntry();
		search.set_icon(ICON_POS, new Gtk.Image.from_stock("gtk-find", SIZE));
		search.add_clear_button();
		
		// search button
		button = new Gtk.Button.from_stock("gtk-find");
		button.clicked.connect((sender) => {
			// create the rest proxy call
			proxy = new Rest.Proxy(REST_URL, false);
			call = proxy.new_call();
			call.set_function(search.text);
			
			// remove the icons, if needed
			if (icons_scroll.get_parent() == main_vbox)
			{
				main_vbox.remove(icons_scroll);
			}
			
			// add the spinner
			main_vbox.pack_end(spinner_align, true, true, 0);
			spinner.start();
			spinner_align.show_all();
			
			// run the call
			call.run_async(on_call_finish, this);
		});
		
		// spinner
		spinner = new Gtk.Spinner();
		spinner.set_size_request(SPIN_SIZE, SPIN_SIZE);
		spinner_align = new Gtk.Alignment(0.5f, 0.5f, 0, 0);
		spinner_align.add(spinner);
		
		// icon view
		icons = new Gtk.IconView();
		icons_scroll = new Gtk.ScrolledWindow(null, null);
		icons_scroll.add_with_viewport(icons);
		
		// pack search field and button
		var hbox = new Gtk.HBox(false, 5);
		hbox.pack_start(search, true, true, 0);
		hbox.pack_start(button, false, false, 0);
		
		// pack top and bottom
		main_vbox = new Gtk.VBox(false, 0);
		main_vbox.pack_start(hbox, false, false, 0);
		(get_content_area() as Gtk.Box).pack_start(main_vbox, true, true, 0);
	}
	
	private void on_call_finish(Rest.ProxyCall call)
	{
		// update UI
		main_vbox.remove(spinner_align);
		main_vbox.pack_start(icons_scroll, true, true, 0);
		icons_scroll.show_all();
		
		Xml.Parser.init();
		
		Xml.Doc* doc = Xml.Parser.parse_doc(call.get_payload());
		// TODO: better error handling
		if (doc == null) return;
		
		Xml.Node* root = doc->get_root_element();
		
		// find the "channel" node
		Xml.Node* channel = root->children;
		for (; channel->name != "channel"; channel = channel->next);
		
		// create list and iterator
		var model = new Gtk.ListStore(3, typeof(Gdk.Pixbuf), typeof(string),
		                                 typeof(OCA.Image));
		var tree_itr = Gtk.TreeIter();
		
		// loop over outermost nodes
		for (Xml.Node* itr = channel->children;
		     itr != null; itr = itr->next)
		{
			if (itr->type != Xml.ElementType.ELEMENT_NODE) continue;
			
			// if the node is an item, add it
			if (itr->name == "item")
			{
				OCA.Image image = OCA.Image();
				
				for (Xml.Node* tag = itr->children;
				     tag != null; tag = tag->next)
				{
					switch (tag->name)
					{
						case "title":
							image.title = tag->children->content;
							break;
						case "link":
							image.link = tag->children->content;
							break;
						case "dc:creator":
							image.creator = tag->children->content;
							break;
						case "license":
							image.license = tag->children->content;
							break;
						case "description":
							image.description = tag->children->content;
							break;
						case "enclosure":
							for (Xml.Attr* prop = tag->properties;
							     prop != null; prop = prop->next)
							{
								if (prop->name == "url")
								{
									image.file_link = prop->children->content;
								}
							}
							break;
						case "media:thumbnail":
							for (Xml.Attr* prop = tag->properties;
							     prop != null; prop = prop->next)
							{
								if (prop->name == "url")
								{
									image.thumb_link = prop->children->content;
								}
							}
							break;
					}
				}
				
				// get the pixbuf
				var pixbuf = gdk_pixbuf_from_uri(image.thumb_link == null ?
				                                 image.file_link : 
				                                 image.thumb_link);
				
				// append to the model
				model.append(out tree_itr);
				model.set(tree_itr, Column.PIXBUF, pixbuf,
				                    Column.TEXT, image.title);
			}
		}
		
		Xml.Parser.cleanup();
		
		// set icons
		icons.set_model(model);
		icons.text_column = Column.TEXT;
		icons.pixbuf_column = Column.PIXBUF;
	}
	
	private enum Column
	{
		PIXBUF = 0,
		TEXT = 1,
		OCA_IMAGE = 2
	}
	
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
}

public static int main(string[] args)
{
	Gtk.init(ref args);
	var dialog = new OCA.Dialog();
	dialog.show_all();
	dialog.run();
	
	return 0;
}
