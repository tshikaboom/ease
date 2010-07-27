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

public interface ChangeSource : GLib.Object
{
	/**
	 * Classes that implement the ChangeSource interface should use this signal
	 * to notify a parent of a new change.
	 */
	public signal void changed();
	
	/**
	 * Emitted when a change is forwarded.
	 */
	protected signal void change_forwarded();
	
	/**
	 * Forwards a change notification onwards.
	 */
	public void forward_changes()
	{
		changed();
		change_forwarded();
	}
	
	/**
	 * Listens for incoming changes from the specified ChangeSource, and
	 * forwards them onwards.
	 */
	protected void listen_changes(ChangeSource source)
	{
		source.changed.connect(forward_changes);
	}
	
	/**
	 * Stops listening to an ChangeSource.
	 */
	protected void silence_changes(ChangeSource source)
	{
		source.changed.disconnect(forward_changes);
	}
}
