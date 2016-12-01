package aspectj_server;

/** 
 * @author Gursimran Singh
 * @rollno 2014041
 */

import java.util.logging.Logger;

public class Server {
//	private String serverName;
	private Logger mLogger;
	
	public Server() {
		super();
//		this.serverName = serverName;
		this.mLogger = Logger.getLogger ("aspectj_server");
	}

	public void start () {
//		mLogger.info ("SERVER STARTING: @name=" + serverName);
		mLogger.info ("SERVER STARTING");
	}
	
	public void stop () {
//		mLogger.info ("SERVER STOPPING: @name=" + serverName);
		mLogger.info ("SERVER STOPPING");
	}
	
	public void process (int millis) {
		try {
			Thread.sleep (millis);
		}
		catch (InterruptedException e) {
			e.printStackTrace();
		}

//		mLogger.info ("SERVER PROCESSING: @param=" + millis + " @name=" + serverName);
		mLogger.info ("SERVER PROCESSING: @param=" + millis);
	}
}
