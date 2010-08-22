public class Ease.ImportWidget : Gtk.Alignment
{
	/**
	 * Primary icon view for display of results.
	 */
	internal Gtk.IconView icons;
	
	/**
	 * Scrolled window for icon view.
	 */
	internal Gtk.ScrolledWindow icons_scroll;
	
	/**
	 * Search field.
	 */
	internal Gtk.Entry search;
	
	/**
	 * Search button.
	 */
	internal Gtk.Button button;
	
	/**
	 * Progress bar, displaying the percentage of images downloaded so far.
	 */
	internal Gtk.ProgressBar progress;
	
	/**
	 * Alignment placing progress bar at the bottom.
	 */
	internal Gtk.Alignment progress_align;
	
	/**
	 * Spinner displayed while REST call is being made.
	 */
	internal Gtk.Spinner spinner;
	
	/**
	 * Alignment containing the spinner.
	 */
	internal Gtk.Alignment spinner_align;
	
	/**
	 * Main VBox for packing widgets.
	 */
	internal Gtk.VBox main_vbox;
	
	/**
	 * Size of the spinner
	 */
	private const int SPINNER_SIZE = 40;

	internal ImportWidget(Plugin.ImportService service)
	{
		// search field
		search = new Gtk.Entry();
		search.set_icon_from_icon_name(Gtk.EntryIconPosition.SECONDARY,
		                               "gtk-clear");
		search.icon_press.connect (() => search.text = "");
		
		// search button
		button = new Gtk.Button.from_stock("gtk-find");
		button.clicked.connect(service.run);
		
		// progress
		progress = new Gtk.ProgressBar();
		progress_align = new Gtk.Alignment(0, 1, 1, 0);
		progress_align.add(progress);
		
		// spinner
		spinner = new Gtk.Spinner();
		spinner_align = new Gtk.Alignment(0.5f, 0.5f, 0, 0);
		spinner_align.add(spinner);
		spinner.set_size_request(SPINNER_SIZE, SPINNER_SIZE);
		
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
		add(main_vbox);
	}
}
