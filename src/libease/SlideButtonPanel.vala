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
 * Panel on the left side of an {@link EditorWindow}
 * 
 * A SlideButtonPanel contains a {@link SlideButton} for each
 * {@link Slide} in the current {@link Document}.
 */
public class Ease.SlideButtonPanel : Gtk.ScrolledWindow
{
	private Document document;
	private EditorWindow owner;
	public Gtk.VBox slides_box;
	
	/**
	 * Creates a SlideButtonPanel
	 * 
	 * A SlideButtonPanel forms the left edge of an {@link EditorWindow}.
	 *
	 * @param d The Document that the {@link EditorWindow} displays.
	 * @param win The {@link EditorWindow} that this SlideButtonPanel is
	 * part of.
	 */
	public SlideButtonPanel(Document d, EditorWindow win)
	{			
		document = d;
		owner = win;

		// set the scrollbar policy
		vscrollbar_policy = Gtk.PolicyType.AUTOMATIC;
		hscrollbar_policy = Gtk.PolicyType.NEVER;
		
		slides_box = new Gtk.VBox(true, 1);
		for (int i = 0; i < document.slides.size; i++)
		{
			var button = new SlideButton(i, document.slides.get(i), owner, this);
			slides_box.pack_start(button, false, false, 0);
		}
		var align = new Gtk.Alignment(0, 0, 1, 0);
		align.add(slides_box);
		var viewport = new Gtk.Viewport(null, null);
		viewport.set_shadow_type(Gtk.ShadowType.NONE);
		viewport.add(align);
		add(viewport);
	}
}

