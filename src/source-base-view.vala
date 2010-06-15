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
 * Abstract base for a simple implementation of a widget using
 * {@link Source.List}.
 *
 * Source.BaseView creates a {@link Source.List} and a Gtk.Bin. These can be
 * placed into container widgets by subclasses.
 */
public abstract class Source.BaseView : Gtk.Alignment
{
	/**
	 * The content view.
	 */
	protected Gtk.Alignment bin;
	
	/**
	 * The {@link Source.List} for this Source.BaseView.
	 */
	protected Source.List list;
	
	/**
	 * The width request of this Source.BaseView's {@link Source.List}.
	 */
	public int list_width_request
	{
		get { return list.width_request; }
		set { list.width_request = value; }
	}
	
	/**
	 * Creates the list and bin widgets. Should be called by subclass
	 * constructors.
	 */
	public BaseView()
	{
		// create widgets
		bin = new Gtk.Alignment(0, 0, 1, 1);
		list = new Source.List(bin);
		
		// set properties
		set(0, 0, 1, 1);
	}
	
	/**
	 * Adds a {@link Source.BaseGroup} subclass to this
	 * Source.BaseView's {@link Source.List}.
	 *
	 * @param group The group to add.
	 */
	public void add_group(Source.BaseGroup group)
	{
		list.add_group(group);
	}
}

