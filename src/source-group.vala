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
 * A group in a {@link Source.List}.
 *
 * Source.Group can contain any amount of {@link Source.Item}s. Above these items,
 * a header is shown in order to categorize a {@link Source.List}.
 */
public class Source.Group : BaseGroup
{
	/**
	 * The Gtk.VBox containing the header and items_box.
	 */
	private Gtk.VBox all_box;
	
	/**
	 * Create a new, empty, Source.Group.
	 *
	 * @param title The header of the Source.Group.
	 */
	public Group(string title)
	{
		base(title);
		
		all_box = new Gtk.VBox(false, 0);
		all_box.pack_start(header_align, false, false, 0);
		all_box.pack_start(items_align, false, false, 0);
		add(all_box);
	}
}

