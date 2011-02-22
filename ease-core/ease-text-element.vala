/*  Ease, a GTK presentation application
    Copyright (C) 2010-2011 individual contributors (see AUTHORS)

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
 * An {@link Element} subclass for displaying text. Linked with {@link TextActor}.
 */
public class Ease.TextElement : Element
{
	private const string UI_FILE_PATH = "inspector-element-text.ui";
	private bool freeze = false;
	private const string DEFAULT_TEXT = _("Double click to edit");
	
	/**
	 * Creates a default text element with an empty block of text.
	 */
	public TextElement(string str, Pango.FontDescription font_description)
	{
		text = new Text.with_text(str, font_description);
	}
	
	/**
	 * Create a TextElement from a JsonObject
	 */
	internal TextElement.from_json(Json.Object obj)
	{
		base.from_json(obj);
	}
	
	internal override Json.Object to_json()
	{
		var obj = base.to_json();
		return obj;
	}
	
	public override Actor actor(ActorContext c)
	{
		return new TextActor(this, c);
	}
	
	public override Gtk.Widget inspector_widget()
	{
		var builder = new Gtk.Builder();
		try
		{
			builder.add_from_file(data_path(Path.build_filename(Temp.UI_DIR,
				                                                UI_FILE_PATH)));
		}
		catch (Error e) { error("Error loading UI: %s", e.message); }
		/*
		// connect signals
		builder.connect_signals(this);
		
		// get the alignment buttons
		var left = builder.get_object("left-button") as Gtk.Button;
		var center = builder.get_object("center-button") as Gtk.Button;
		var right = builder.get_object("right-button") as Gtk.Button;
		
		// highlight the current alignment
		switch (text_align)
		{
			case Pango.Alignment.LEFT:
				left.relief = Gtk.ReliefStyle.NORMAL;
				break;
			case Pango.Alignment.CENTER:
				center.relief = Gtk.ReliefStyle.NORMAL;
				break;
			case Pango.Alignment.RIGHT:
				right.relief = Gtk.ReliefStyle.NORMAL;
				break;
		}
		
		// when the alignment is changed, select the correct button
		notify["text-align"].connect((obj, spec) => {
			switch (text_align)
			{
				case Pango.Alignment.LEFT:
					left.relief = Gtk.ReliefStyle.NORMAL;
					center.relief = Gtk.ReliefStyle.NONE;
					right.relief = Gtk.ReliefStyle.NONE;
					break;
				case Pango.Alignment.CENTER:
					left.relief = Gtk.ReliefStyle.NONE;
					center.relief = Gtk.ReliefStyle.NORMAL;
					right.relief = Gtk.ReliefStyle.NONE;
					break;
				case Pango.Alignment.RIGHT:
					left.relief = Gtk.ReliefStyle.NONE;
					center.relief = Gtk.ReliefStyle.NONE;
					right.relief = Gtk.ReliefStyle.NORMAL;
					break;
			}
		});
		
		// set up the font button
		var font = builder.get_object("font-button") as Gtk.FontButton;
		font.set_font_name(font_description.to_string());
		
		font.font_set.connect((button) => {
			var action = new UndoAction(this, "font-description");
			undo(action);
			font_description =
				Pango.FontDescription.from_string(font.font_name);
		});
		
		notify["font-description"].connect((obj, spec) => {
			font.set_font_name(font_description.to_string());
		});
		
		// set up the color button
		var color_b = builder.get_object("color-button") as Gtk.ColorButton;
		color_b.set_color(color.gdk);
		
		color_b.color_set.connect((button) => {
			var action = new UndoAction(this, "color");
			undo(action);
			color = new Color.from_gdk(color_b.color);
		});
		
		notify["color"].connect((obj, spec) => {
			color_b.color = color.gdk;
		});*/
		
		// return the root
		return builder.get_object("root") as Gtk.Widget;
	}
	
	[CCode (instance_pos = -1)]
	public void on_inspector_alignment(Gtk.Widget sender)
	{
		/*(sender.get_parent() as Gtk.Container).foreach((widget) => {
			(widget as Gtk.Button).relief = Gtk.ReliefStyle.NONE;
		});
		
		(sender as Gtk.Button).relief = Gtk.ReliefStyle.NORMAL;
		
		var action = new UndoAction(this, "text-align");
		var old = text_align;
		
		text_align_from_string(
			(((sender as Gtk.Bin).get_child() as Gtk.Image).stock));
		
		if (text_align != old)
		{
			undo(action);
		}*/
	}

	protected override string html_render(HTMLExporter exporter)
	{
		critical("Fix HTML export for text please...");
		return "";
	}

	/**
	 * Renders a text Element with Cairo.
	 */
	public override void cairo_render(Cairo.Context context,
	                                  bool use_small) throws Error
	{
		text.render(context, (int)width, true);
	}
	
	/**
	 * The text value of this Element.
	 */
	public Text text { get; set; }
}
