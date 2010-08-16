/* © Nate Stedman 2010 */

/**
 * A window displaying presenter notes
 *
 * A PresenterWindow displays several hints about the currently playing
 *  document : current slide thumbnail, next slide thumbnail, presenter notes
 * (typed into the {@link EditorWindow}), number of slides left and time 
 * elapsed.
 */
internal class Ease.PresenterWindow : Gtk.Window
{
	internal Document document { get; set; }
	internal int slide_index { get; set; }
	internal Clutter.Stage stage { get; set; }

	/* current_display holds the current thumbnail and notes,
	 * bottom_display displays the rest. */
	private Clutter.Group current_display;
	private Clutter.Group bottom_display;

	private SlideActor current_slide;
	private SlideActor next_slide;
	private Clutter.Text notes;
	private Clutter.Text time_elapsed;
	private Clutter.Text slides_elapsed;
	
	internal PresenterWindow (Document doc)
	{
		document = doc;
		slide_index = -1;

		this.title = _("Presenter window");

		var embed = new GtkClutter.Embed ();
		this.add (embed);
		stage = embed.get_stage () as Clutter.Stage;

		stage.color = { 0, 0, 0, 255 };
		stage.set_fullscreen (true);
		stage.show_all ();
	}
}