package aspectj_server;

import java.util.Random;

public class MyServer
{
	int time;

	public int getTime() 
	{
		return time;
	}

	public void start()
	{
		System.out.println("Server starting");
	}

	public void stop()
	{
		System.out.println("Server stopping");
	}

	public void process() throws InterruptedException
	{
		Random r = new Random();
		int processTime = r.nextInt(5);
		time = time + processTime;
		if(time <= 3)
		{
			System.out.println("Server processing");
			Thread.sleep(processTime*1000);
		}
	}
}
