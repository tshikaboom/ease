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
 * A window containing an {@link Inspector}. Includes static methods for using
 * a single InspectorWindow across the entire application.
 */
public class Ease.InspectorWindow : Gtk.Window
{
	private Inspector inspector;
	
	public InspectorWindow()
	{
		inspector = new Inspector();
		
		add(inspector);
	}
	
	// static implemention
	private static InspectorWindow instance;
	
	/**
	 * Toggles the visibility of the single InspectorWindow.
	 */
	public static void toggle()
	{
		if (instance == null)
		{
			instance = new InspectorWindow();
		}
		
		if (instance.visible)
		{
			instance.hide();
		}
		else
		{
			instance.show_all();
			instance.present();
		}
	}
	
	private static Slide slide_priv;
	
	/**
	 * The slide visible in the {@link Inspector} of the single InspectorWindow.
	 */
	public static Slide slide
	{
		get { return slide_priv; }
		set
		{
			if (slide_priv != value)
			{
				instance.inspector.slide = value;
				slide_priv = value;
			}
		}
	}
}
