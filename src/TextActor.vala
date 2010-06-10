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
	 * Instantiates a new TextActor from an Element.
	 * 
	 * TextActor uses {@link Clutter.Text} for rendering.
	 *
	 * @param e The represented element.
	 * @param c The context of this Actor (Presentation, Sidebar, Editor)
	 */
	public TextActor(ref Element e, ActorContext c)
	{
		base(ref e, c);
		
		var text = new Clutter.Text();

		// set actor properties
		text.use_markup = true;
		text.line_wrap = true;
		text.line_wrap_mode = Pango.WrapMode.WORD_CHAR;
		text.color = e.color;
		text.set_markup(e.get("text"));
		text.font_name = e.font_description.to_string();
		text.line_alignment = e.text_align;
		
		contents = text;
		
		add_actor(contents);
		contents.width = e.width;
		contents.height = e.height;
		x = e.x;
		y = e.y;
	}
	
	/**
	 * {@inheritDoc}
	 */
	public override void edit(EditorEmbed sender)
	{
		// set text to editable
		var text = contents as Clutter.Text;
		text.editable = true;
		text.reactive = true;
		text.text_changed.connect(text_changed);
		
		// grab key focus
		((Clutter.Stage)get_stage()).set_key_focus(text);
		sender.key_focus();
	}
	
	/**
	 * {@inheritDoc}
	 */
	public override void end_edit(EditorEmbed sender)
	{
		// release key focus
		((Clutter.Stage)get_stage()).set_key_focus(null);
		
		// disable text editing
		var text = contents as Clutter.Text;
		text.editable = false;
		text.reactive = false;
		text.text_changed.disconnect(text_changed);
	}
	
	private void text_changed(Clutter.Text sender)
	{
		element.set("text", sender.text);
	}
}

