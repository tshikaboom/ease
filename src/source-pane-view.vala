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
 * An implementation of {@link Source.BaseView} with a Gtk.HPaned
 *
 * Source.View consists of a {@link Source.List}, a separator, and a Gtk.Bin
 * packed into a Gtk.HBox.
 */
public class Source.PaneView : BaseView
{	
	/**
	 * Creates an empty Source.View. Add groups with add_group().
	 *
	 * @param with_separator If true, a Gtk.Separator is included to the right
	 * of the drag handle.
	 */
	public PaneView(bool with_separator)
	{
		// create base widgets
		base();
		
		// create pane widgets and build the view
		var hpane = new Gtk.HPaned();
		hpane.pack1(list, false, false);
		
		// if a separator is requested, build an hbox with it and the bin
		if (with_separator)
		{
			var hbox = new Gtk.HBox(false, 0);
			hbox.pack_start(new Gtk.VSeparator(), false, false, 0);
			hbox.pack_start(bin, true, true, 0);
			hpane.pack2(hbox, true, false);
		}
		
		// otherwise, just pack the bin in
		else
		{
			hpane.pack2(bin, true, false);
		}
		
		// add the hpaned to the view
		add(hpane);
	}
}

