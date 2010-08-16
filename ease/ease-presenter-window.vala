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
	
	/* other data */
	Timer timer;

	internal PresenterWindow (Document doc)
	{
		document = doc;
		slide_index = -1;

		timer = new Timer ();
		this.title = _("Presenter window");

		var embed = new GtkClutter.Embed ();
		embed.set_size_request (doc.width, doc.height);
		this.add (embed);
		stage = embed.get_stage () as Clutter.Stage;

		current_display = new Clutter.Group ();
		bottom_display = new Clutter.Group ();

		int docsize = doc.length;
		var slidenum = @"Slide n°$slide_index / $docsize";
		var elapsed = (uint)timer.elapsed ();
		slides_elapsed = new Clutter.Text.full ("Sans 20",
												slidenum,
											    Clutter.Color.from_string ("white"));
		time_elapsed = new Clutter.Text.full ("Sans 20",
											  @"$elapsed s",
											  Clutter.Color.from_string ("white"));
		time_elapsed.set_position (stage.width - time_elapsed.width,
								   stage.height - time_elapsed.height);
		bottom_display.set_position (0, stage.height/4*3);
		bottom_display.add (slides_elapsed,
							time_elapsed,
							null);
		stage.add (current_display,
				   bottom_display);
		stage.color = { 0, 0, 0, 255 };
		stage.set_fullscreen (true);
		stage.show_all ();
	}
}