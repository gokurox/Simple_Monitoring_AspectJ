package aspectj_server;

/** 
 * @author Gursimran Singh
 * @rollno 2014041
 */

public class Evil {
	public static void main(String[] args) throws Exception
	{
		MyServer s;
		s = new MyServer();
		
		s.start();
		
		s.process();
		
		s.stop();
		s.start();
		
		s.process();
		s.process();
		s.process();
		s.process();
		s.process();
		s.process();
		s.process();
		s.process();
		s.process();
		
		s.stop();
	}
}
