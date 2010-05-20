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

/*
 * A widget containing a Gtk.HScale and two zoom buttons
 */
public class Ease.ZoomSlider : Gtk.Alignment
{
	private Gtk.HScale zoom_slider;
	private Gtk.Button zoom_in;
	private Gtk.Button zoom_out;
	private int[] values;
	
	public Gtk.PositionType value_pos
	{
		get { return zoom_slider.value_pos; }
		set { zoom_slider.value_pos = value; }
	}
	
	public int digits
	{
		get { return zoom_slider.digits; }
		set { zoom_slider.digits = value; }
	}	

	public ZoomSlider(Gtk.Adjustment adjustment, int[] button_values)
	{
		values = button_values;
		
		var hbox = new Gtk.HBox(false, 5);
		
		// create zoom slider
		zoom_slider = new Gtk.HScale(adjustment);
		zoom_slider.width_request = 200;
		zoom_slider.draw_value = false;
		zoom_slider.digits = 0;
		
		// zoom in button
		zoom_in = new Gtk.Button();
		zoom_in.add(new Gtk.Image.from_stock("gtk-zoom-in", Gtk.IconSize.MENU));
		zoom_in.relief = Gtk.ReliefStyle.NONE;
		
		// zoom out button
		zoom_out = new Gtk.Button();
		zoom_out.add(new Gtk.Image.from_stock("gtk-zoom-out", Gtk.IconSize.MENU));
		zoom_out.relief = Gtk.ReliefStyle.NONE;
		
		// put it all together
		var align = new Gtk.Alignment(0, 0.5f, 1, 0);
		align.add(zoom_out);
		hbox.pack_start(align, false, false, 0);
		
		align = new Gtk.Alignment(0, 0.5f, 1, 0);
		align.add(zoom_slider);
		hbox.pack_start(align, false, false, 0);
		
		align = new Gtk.Alignment(0, 0.5f, 1, 0);
		align.add(zoom_in);
		hbox.pack_start(align, false, false, 0);
		
		set(1, 1, 1, 1);
		add(hbox);
		
		zoom_slider.value_changed.connect(() => value_changed());
		
		zoom_in.clicked.connect(() => {
			for (var i = 0; i < values.length; i++)
			{
				if (zoom_slider.get_value() < values[i])
				{
					zoom_slider.set_value(values[i]);
					break;
				}
			}
		});
		
		zoom_out.clicked.connect(() => {
			for (var i = values.length - 1; i > -1; i--)
			{
				if (zoom_slider.get_value() > values[i])
				{
					zoom_slider.set_value(values[i]);
					break;
				}
			}
		});
		
		zoom_slider.format_value.connect(val => {
			return "%i%%".printf((int)val);
		});
	}
	
	public double get_value()
	{
		return zoom_slider.get_value();
	}
	
	public signal void value_changed();
}
