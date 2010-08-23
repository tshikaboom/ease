using Rest;
using Json;
using Gtk;

/*
  TODO :
  - escaping the description tags (or show the markup maybe?)
  - asyncing
  - getting licence and author's realname based on the IDs we get right now
  - make a nice combo-box for licenses
  - make the UI prettier
  - split out in a common Ease.ResourceImporter dialog or something
  - raise accuracy (ie use the keywords to search tags _and_ description, and others) 50% DONE
  - get the next set of photos (use the "page" param of flickr.photos.search)
  - show a tiny spinner when loading
*/

public class Ease.FlickrService : Plugin.ImportService {

	/* Flickr stuff */
	private const string api_key = "17c40bceda03e0d6f947b001e7c62058";
	private const string secret = "a7c16179a409418b";

	/* Json parser */
	private Json.Parser parser = new Json.Parser();
	
	public override Rest.Proxy create_proxy()
	{
		return new Rest.FlickrProxy(api_key, secret);
	}
	
	public override Rest.ProxyCall create_call(Rest.Proxy proxy, string search)
	{
		var call = proxy.new_call ();
		call.set_function ("flickr.photos.search");
		call.add_params ("tags", search,
						 "tag_mode", "all",
						 "per_page", "10",
						 "format", "json",
						 "sort", "relevance",
						 /* Flickr adds a function around the JSon payload,
							setting 'nojsoncallback' disable that : we get
							only plain JSON. */
						 "nojsoncallback", "1",
						 /* Extras info to fetch. */
						 "extras", "description,licence",
						 null);
		return call;
	}
	
	public override void parse_data(string jsondata) {

		if (jsondata == null) {
			return;
		}

		try {
			parser.load_from_data (jsondata);
		} catch (Error e) {
			error ("Couldn't parse JSON data: %s", e.message);
		}

		Json.Object obj = parser.get_root().get_object ();

		var stat = obj.get_string_member ("stat");
		if (stat != "ok") {
			warning("The request failed : \nError code: %G\nMessage: %s",
				    obj.get_int_member ("code"),
				    obj.get_string_member ("message"));
			return;
		}

		var photos = obj.get_object_member ("photos");
		var photo_array = photos.get_array_member ("photo");

		// TODO : optimization
		photo_array.foreach_element ( (array, index, element) => 
			{
			   iconview_add_thumbnail_from_json (array, index, element);
			});


	}
	
	public void iconview_add_thumbnail_from_json (Json.Array array, 
														uint index,
														Json.Node element)
	{
		Json.Object photo = element.get_object ();
		int64 farm_int = photo.get_int_member ("farm");
		
		string farm = @"$farm_int";
		string secret = photo.get_string_member ("secret");
		string server = photo.get_string_member ("server");
		string id = photo.get_string_member ("id");
		string http = "http://farm";
		string flickr = ".static.flickr.com/";
		
		var image = new FlickrMedia();
		image.file_link = http + farm + flickr + server + "/" + id + "_" + secret + "_b.jpg";
		image.thumb_link = http + farm + flickr + server + "/" + id + "_" + secret + "_m.jpg";
		// TODO : unittest to track Flickr API changes.
		// TODO : license
		image.title = photo.get_string_member ("title");
		image.description = photo.get_object_member ("description").get_string_member ("_content");
		image.author = photo.get_string_member ("owner");
		
		add_media(image);
	}
}

