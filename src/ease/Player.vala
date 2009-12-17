using Clutter;

namespace Ease
{
	public class Player : GLib.Object
	{
		public Player()
		{
			Clutter.init(null);
			var stage = new Clutter.Stage();
			stage.set_fullscreen(true);
			stage.show_all();
			Clutter.main();
		}
	}
}