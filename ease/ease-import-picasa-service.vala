public class Ease.PicasaService : Plugin.ImportService
{
	private const string REST_URL = "http://picasaweb.google.com/data/feed/api/all?";
	
	protected override Rest.Proxy create_proxy()
	{
		return new Rest.Proxy(REST_URL, false);
	}
	
	protected override Rest.ProxyCall create_call(Rest.Proxy proxy,
	                                              string search)
	{
		var call = proxy.new_call();
		call.set_function(search);
		call.add_param("q", search);
		return call;
	}
	
	internal override void parse_data(string data)
	{
		Xml.Parser.init();
		
		Xml.Doc* doc = Xml.Parser.parse_doc(data);
		if(doc == null) return;
		
		Xml.Node* root = doc->get_root_element();
		if(root == null) return;
		
		// loop through all the nodes
		for (Xml.Node* iter = root->children; iter != null; iter = iter->next)
		{
			if(iter->name == "entry") 
			{
				OCAMedia image = new OCAMedia();
				
				for (Xml.Node* tag = iter->children; tag != null;
				    tag = tag->next)
				{
					switch (tag->name)
					{
						case "title":
							image.title = tag->children->content;
							break;
						case "group":
							for (Xml.Node* content = tag->children;
							     content != null; content = content->next)
							{
								if (content->name == "content")
								{
									image.link = content->get_prop("url");
									image.file_link = image.link;
									debug("\n%s\n\n", image.link);
								}
							}
							break;
						case "author":
							for (Xml.Node* author = tag->children;
							     author != null; author = author->next)
							{
								if (author->name == "name")
									image.creator = author->children->content;
							}
							break;
					}
				}
				
				add_media(image);
			}
		}
	}
}
