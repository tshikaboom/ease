public class OCA.Dialog : Ease.PluginImportDialog
{	
	private const string REST_URL =
		"http://www.openclipart.org/media/feed/rss/";
	
	private const Sexy.IconEntryPosition ICON_POS =
		Sexy.IconEntryPosition.PRIMARY;
	
	private const Gtk.IconSize SIZE = Gtk.IconSize.MENU;
	private const int SPIN_SIZE = 40;
	
	public Dialog()
	{
		base();
	}
	
	protected override Rest.Proxy get_proxy()
	{
		return proxy = new Rest.Proxy(REST_URL, false);
	}

	protected override Rest.ProxyCall get_call()
	{
		call = proxy.new_call();
		call.set_function(search.text);
		return call;
	}
	
	public override void parse_image_data(string data)
	{	
		Xml.Parser.init();
		
		Xml.Doc* doc = Xml.Parser.parse_doc(data);
		// TODO: better error handling
		if (doc == null) return;
		
		Xml.Node* root = doc->get_root_element();
		
		// find the "channel" node
		Xml.Node* channel = root->children;
		for (; channel->name != "channel"; channel = channel->next);
		
		// loop over outermost nodes
		for (Xml.Node* itr = channel->children;
		     itr != null; itr = itr->next)
		{
			if (itr->type != Xml.ElementType.ELEMENT_NODE) continue;
			
			// if the node is an item, add it
			if (itr->name == "item")
			{
				OCA.Image image = new OCA.Image();
				
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
				
				images_list.add(image);
			}
		}
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
