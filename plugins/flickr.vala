using Rest;
using Json;
using Gtk;


/*
  TODO :
  - launching multiple requests
  - escaping the description tags
  - wrapping the long fields (emo-descriptions)
  - asyncing
  - getting licence and author's realname based on the IDs we get right now
  - make a nice combo-box for licenses
  - make the UI prettier
  - split out in a common Ease.ResourceImporter dialog or something
  - raise accuracy (ie use the keywords to search tags _and_ description, and others)
  - get the next set of photos
  - show a tiny spinner when loading
*/

public class FlickrFetcher {

	/* Flickr stuff */
	private const string api_key = "17c40bceda03e0d6f947b001e7c62058";
	private const string secret = "a7c16179a409418b";

	private Rest.FlickrProxy proxy;
	// TODO : FlickrProxyCall is broken?
	private Rest.ProxyCall call;

	/* Json parser */
	private Json.Parser parser;

	/* UI elements */
	private Gtk.Dialog dialog;
	private Gtk.Entry search_entry;
	private Gtk.Button search_button;
	private Gtk.IconView iconview;
	private Gtk.Builder builder;
	private Gtk.VBox vbox;
	private Gtk.Label infos;

	private Gtk.ListStore store;

	private Gdk.Pixbuf? gdk_pixbug_from_uri (string uri) {

		var file = File.new_for_uri (uri);
		FileInputStream filestream = null;
		try {
			filestream = file.read (null);
		} catch (Error e) {
			error ("Couldn't read distant file : %s", e.message);
		}
		assert (filestream != null);
		Gdk.Pixbuf pix;
		try {
			pix = new Gdk.Pixbuf.from_stream_at_scale (filestream,
														   150,
														   150,
														   true,
														   null);
		} catch (Error e) {
			error ("Couldn't create pixbuf from file: %s", e.message);
			pix = null;
		}
		return pix;
	}


	private string get_flickr_photos_from_tags (string tags) {

		call.set_function ("flickr.photos.search");
		call.add_params ("tags", tags,
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
		// TODO : asyncing
		try {
			call.run (null);
		} catch (Error e) {
			print ("Couldn't make call: %s\n", e.message);
		}

		string answer = call.get_payload ();
		assert (answer != null);
		return answer;
	}

	private void parse_flickr_photos (string jsondata) {

		try {
			parser.load_from_data (jsondata);
		} catch (Error e) {
			error ("Couldn't parse JSON data: %s", e.message);
		}

		print ("Payload: %s\nDELIMIT", jsondata);
		Json.Object obj = parser.get_root().get_object ();
		var photos = obj.get_object_member ("photos");
		var photo_array = photos.get_array_member ("photo");

		// TODO : optimization
		photo_array.foreach_element ( (array, index, element) =>
			{
				Gtk.TreeIter iter;
				Json.Object photo = element.get_object ();
				int64 farm_int = photo.get_int_member ("farm");

				string farm = @"$farm_int";
				string secret = photo.get_string_member ("secret");
				string server = photo.get_string_member ("server");
				string id = photo.get_string_member ("id");
				string http = "http://farm";
				string stat = ".static.flickr.com/";

				string uri = http + farm + stat + server + "/" + id + "_" + secret + "_t.jpg";
				// TODO : unittest to track Flickr's URIs changes.

				var pixbuf = gdk_pixbug_from_uri (uri);

				string title = photo.get_string_member ("title");
				string description = photo.get_object_member ("description").get_string_member ("_content");
				string author = photo.get_string_member ("owner");
				// We did specified license in the extras, but it doesn't appear in the payload
				// string licence = photo.get_string_member ("license");

				/* Adding to the IconView */
				store.append (out iter);
				store.set (iter,
						   0, id,
						   1, title,
						   2, pixbuf,
						   3, description,
						   4, author,
//						   5, licence,
						   -1);
				// FIXME : window is not updated till the whole function finishes.
			});
	}


	[CCode (instance_pos = -1)]
	public void on_item_activated (Gtk.IconView view, Gtk.TreePath path) {

		debug ("We have a signal.");

	}

	[CCode (instance_pos = -1)]
	public void on_search_button (Button? b) {

		string entry = this.search_entry.get_text ();
		// convert spaces to comas
		string tags = entry.delimit (" ", ',');
		search_entry.set_text (tags);

		string answer = get_flickr_photos_from_tags (tags);
		parse_flickr_photos (answer);
	}

	[CCode (instance_pos = -1)]
	public void on_selection_changed (Gtk.IconView view) {

		string description;
		string title;
		string author;
		string license;

		List<Gtk.TreePath> selected = view.get_selected_items ();
		Gtk.TreeIter iter;
		store.get_iter (out iter, selected.data);
		store.get (iter,
				   1, out title,
				   3, out description,
				   4, out author,
				   5, out license, -1);

		string informations = Markup.printf_escaped ("<b>Title : </b>%s\n" +
													 "<b>Description : </b>%s\n" +
													 "<b>Author : </b>: %s",
													 title, description, author);
		infos.set_markup (informations);
	}

	[CCode (instance_pos = -1)]
	public void on_dialog_response (Gtk.Dialog dialog, int response) {

		stdout.printf ("In!\n");
	}

	public FlickrFetcher() {

		proxy = new Rest.FlickrProxy (api_key, secret);
		call = proxy.new_call ();
		parser = new Json.Parser ();
		builder = new Gtk.Builder ();

		try {
			builder.add_from_file ("flickr.ui");
		} catch (Error e) {
			stdout.printf ("Error parsing UI : %s\n", e.message);
			builder = null;
		}

		assert (builder != null);

		dialog = builder.get_object ("dialog1") as Gtk.Dialog;
		iconview = builder.get_object ("iconview1") as Gtk.IconView;
		search_button = builder.get_object ("searchbutton") as Gtk.Button;
		search_entry = builder.get_object ("searchentry") as Gtk.Entry;
		store = builder.get_object ("liststore1") as Gtk.ListStore;
		vbox = builder.get_object ("vbox1") as Gtk.VBox;
		infos = builder.get_object ("infos_label") as Gtk.Label;

		iconview.set_pixbuf_column (2);
		iconview.set_text_column (1);

		search_button.grab_default ();
		search_entry.set_activates_default (true);
		builder.connect_signals (this);
	}

	public void run () {
		dialog.run ();
	}
}


public static int main (string []args)
{
	Gtk.init (ref args);

	var dial = new FlickrFetcher ();
	dial.run ();

	Gtk.main ();
	return 0;
}