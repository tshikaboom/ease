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
 * Inspector widget for editing slide properties
 */
public class Ease.Inspector : Gtk.Notebook
{
	private TransitionPane transition_pane;
	private SlidePane slide_pane;
	
	// constants
	private const int REQUEST_WIDTH = 200;
	private const int REQUEST_HEIGHT = 0;
	
	private Slide slide_priv;
	
	/**
	 * The {@link Slide} that this Inspector is currently affecting.
	 */
	public Slide slide
	{
		get { return slide_priv; }
		set {
			slide_priv = value;
			transition_pane.slide = value;
			slide_pane.slide = value;
		}
	}
	
	public Inspector()
	{
		set_size_request(REQUEST_WIDTH, REQUEST_HEIGHT);
	
		transition_pane = new TransitionPane();
		slide_pane = new SlidePane();
		
		// add pages
		append_page(slide_pane,
		            new Gtk.Image.from_stock("gtk-page-setup",
		                                     Gtk.IconSize.SMALL_TOOLBAR));
		append_page(transition_pane,
		            new Gtk.Image.from_stock("gtk-media-forward",
		                                     Gtk.IconSize.SMALL_TOOLBAR));
	}
}

