/*
Copyright 2010 Nate Stedman. All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are
permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of
conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list
of conditions and the following disclaimer in the documentation and/or other materials
provided with the distribution.

THIS SOFTWARE IS PROVIDED BY NATE STEDMAN ``AS IS'' AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NATE STEDMAN OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

/**
 * An expandable group in a {@link Source.List}.
 *
 * Source.ExpandableGroup can contain any amount of {@link Source.Item}s.
 * Above these items, a header is shown in order to categorize a
 * {@link Source.List}. Unlike {@link Source.Group}, which is VBox based,
 * ExpandableGroup can be expanded and contracted.
 */
public class Source.ExpandableGroup : BaseGroup
{
	/**
	 * The Gtk.Expander containing the header and items_box.
	 */
	private Gtk.Expander expander = new Gtk.Expander("");
	
	/**
	 * If the ExpandableGroup's expander is expanded.
	 */
	public bool expanded
	{
		get { return expander.expanded; }
		set { expander.expanded = value; }
	}
	
	/**
	 * Create a new, empty, Source.ExpandableGroup.
	 *
	 * @param title The header of the Source.Group.
	 * @param expanded If the group should be expanded by default.
	 */
	public ExpandableGroup(string title, bool expanded)
	{
		base(title);
		
		expander.label_widget = header_align;
		expander.can_focus = false;
		expander.set_expanded(expanded);
		expander.add(items_align);
		add(expander);
	}
}
