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
 * {@link Actor} for blocks of text
 * 
 * TextActor uses {@link Clutter.Text} for rendering.
 */
public class Ease.TextActor : Actor
{
	/**
	 * The opacity of the selection highlight.
	 */
	private const uchar SELECTION_ALPHA = 200;
	
	/**
	 * {@link UndoAction} for an edit.
	 */
	private UndoAction undo_action;
	
	/**
	 * The CairoTexture that is rendered onto.
	 */
	private Clutter.CairoTexture texture;

	/**
	 * Instantiates a new TextActor from an Element.
	 * 
	 * TextActor uses {@link Clutter.Text} for rendering.
	 *
	 * @param e The represented element.
	 * @param c The context of this Actor (Presentation, Sidebar, Editor)
	 */
	public TextActor(TextElement e, ActorContext c)
	{
		base(e, c);
		
		texture = new Clutter.CairoTexture((uint)e.width, (uint)e.height);
		contents = texture;
		
		// automatically render when the size of the texture changes
		texture.allocation_changed.connect(() => {
			texture.clear();
			render_text();
		});
		
		add_actor(contents);
		contents.width = e.width;
		contents.height = e.height;
		x = e.x;
		y = e.y;
	}
	
	public override void edit(Gtk.Widget sender, float mouse_x, float mouse_y)
	{
		
	}
	
	/**
	 * Renders the TextElement's text to the CairoTexture.
	 */
	private void render_text()
	{
		texture.set_surface_size((uint)texture.width, (uint)texture.height);
		var cr = texture.create();
		(element as TextElement).text.render(cr, (int)texture.width,
		                                         (int)texture.height);
	}
}

