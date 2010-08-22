public class Ease.OCAService : Plugin.ImportService
{	
	private const string REST_URL =
		"http://www.openclipart.org/media/feed/rss/";
	
	protected override Rest.Proxy create_proxy()
	{
		return new Rest.Proxy(REST_URL, false);
	}

	protected override Rest.ProxyCall create_call(Rest.Proxy proxy,
	                                              string search)
	{
		var call = proxy.new_call();
		call.set_function(search);
		return call;
	}
	
	public override void parse_data(string data)
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
				OCAMedia image = new OCAMedia();
				
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
				
				add_media(image);
			}
		}
	}
}

