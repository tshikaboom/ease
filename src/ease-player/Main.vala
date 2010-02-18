using EasePlayer;
using libease;

public class Main
{
	public static int main(string[] args)
	{
		if (args.length < 2)
		{
			return 0;
		}
		
		Clutter.init(null);
		
		var doc = new Document.from_file(args[1]);
		var player = new Player(doc);
		
		Clutter.main();
		
		return 1;
	}
}
