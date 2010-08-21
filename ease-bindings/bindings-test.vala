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

public int main(string[] args)
{
	Gtk.init(ref args);
	
	// create bound GTK widgets
	var scale = new Gtk.HScale.with_range(0, 10, 0.1);
	var spin = new Gtk.SpinButton.with_range(0, 10, 0.1);
	var entry = new Gtk.Entry();
	
	// bind the scale and spin buttons together
	Binding.connect(spin, "value", scale.adjustment, "value");
	Binding.transformed(spin, "value", (val) => {
		var number = GLib.Value(typeof(string));
		//number.set_string(val.get_double().to_string());
		return number;
	},                  entry, "text", (val) => {
		var number = GLib.Value(typeof(double));
		//number.set_double(val.get_string().to_double());
		return number;
	});
	
	// create a button to drop the binding
	var button = new Gtk.Button.with_label("Drop Binding");
	button.clicked.connect(() => {
		Binding.drop(spin, "value", scale.adjustment, "value");
	});
	
	// place in a window
	var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
	window.width_request = 400;
	var hbox = new Gtk.HBox(false, 5);
	hbox.pack_start(spin, false, false, 0);
	hbox.pack_start(scale, true, true, 0);
	hbox.pack_start(button, false, false, 0);
	var vbox = new Gtk.VBox(false, 5);
	vbox.pack_start(hbox, false, false, 0);
	vbox.pack_start(entry, false, false, 0);
	window.add(vbox);
	
	// show the window
	window.show_all();
	window.hide.connect(() => Gtk.main_quit());
	
	Gtk.main();
	
	return 0;
}
