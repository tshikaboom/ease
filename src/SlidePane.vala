/*  Ease, a GTK presentation application
    Copyright (C) 2010 Nate Stedman

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
 * The inspector pane concerning slides
 */
public class Ease.SlidePane : Gtk.VBox
{
	public Gtk.ComboBox effect;
	public Gtk.SpinButton duration;
	public Gtk.ComboBox variant;
	public Gtk.Label variant_label;
	public Gtk.ComboBox start_transition;
	public Gtk.SpinButton delay;
	
	public Slide slide { get; set; }

	public SlidePane()
	{
		homogeneous = false;
		spacing = 0;
		
		set_size_request(200, 0);
		
		// effect selection
		var vbox = new Gtk.VBox(false, 0);
		var hbox = new Gtk.HBox(false, 0);
		var align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label(_("Effect")));
		vbox.pack_start(align, false, false, 0);
		effect = new Gtk.ComboBox();
		align = new Gtk.Alignment(0, 0, 1, 1);
		align.add(effect);
		vbox.pack_start(align, false, false, 0);
		hbox.pack_start(vbox, true, true, 5);
		
		// effect duration
		vbox = new Gtk.VBox(false, 0);
		align = new Gtk.Alignment(0, 0, 0, 0);
		align.add(new Gtk.Label(_("Duration")));
		vbox.pack_start(align, false, false, 0);
		duration = new Gtk.SpinButton.with_range(0, 10, 0.25);
		duration.digits = 2;
		align = new Gtk.Alignment(0, 0.5f, 1, 1);
		align.add(duration);
		vbox.pack_start(align, true, true, 0);
		hbox.pack_start(vbox, false, false, 5);
		pack_start(hbox, false, false, 5);
	}
}

