package aspectj_server;

/** 
 * @author Gursimran Singh
 * @rollno 2014041
 */

import java.util.HashMap;
import java.util.Set;

import exceptions.MultipleStartsException;
import exceptions.NoStartForStopException;
import exceptions.NoStopForStartException;
import exceptions.ProcessAfterStopException;
import exceptions.ProcessTimeoutException;
import exceptions.ProcessWithoutStartException;

/*
 * For use with the provided MyServer Class.
 */

public aspect ServerAspect
{
	/*
	 * Fields used to ensure specified properties
	 */
	
	// HashMap signifying Server --> isStarted?
	HashMap<MyServer, Integer> onlineServers = new HashMap<>();
	
	/*
	 * Various Pointcuts for the program
	 */
	pointcut serverStart(MyServer S): call (void MyServer.start()) && target(S);
	pointcut serverStop (MyServer S): call (void MyServer.stop()) && target(S);
	pointcut serverProcess (MyServer S): call (void MyServer.process() throws InterruptedException) && target(S);
	pointcut mainMethod(): execution (public static void main(String[]));
	pointcut systemExit(): call (* System.exit(int));

	/*
	 * Specifying various actions at different JoinPoints
	 */
	
	// [0] There can be more than one servers.
	// Implicitly taken care of as we monitor references "Server S"
	// and use target(S) in pointcuts.
	
	before(MyServer S): serverStart(S) {
		if (onlineServers.containsKey(S)) {
			if (onlineServers.get(S) == 1) {
				// [4] Two or more consecutive starts are unacceptable.
				throw (new MultipleStartsException());
			}
			// [5] A server that is stopped can be restarted.
		}
		// Server started for the first time.
	}
	
	after(MyServer S) returning: serverStart(S) {
		onlineServers.put (S, 1);
		// Reset time monitor. (Done here because time is not initialized in constructor, although default value given by java
		// is 0 but just for safety). If that's not a concern can also do in after serverStop().
		S.time = 0;
	}
	
	before(MyServer S): serverStop(S) {
		if (!onlineServers.containsKey(S)) {
			// [2] A start must precede every stop.
			throw (new NoStartForStopException());
		}
		// [3] Two or more consecutive stops are acceptable.
		// Taken care of as not enforcing the server to be in start state.
	}
	
	after(MyServer S): serverStop(S) {
		onlineServers.put(S, 2);
	}
	
	before(MyServer S): serverProcess(S) {
		if (onlineServers.containsKey(S)) {
			if (onlineServers.get(S) == 2) {
				// [6] No Processing between consecutive stops.
				throw (new ProcessAfterStopException());
			}
			// Processing allowed between a start and stop.
		}
		else {
			// [6] No Processing without a start.
			throw (new ProcessWithoutStartException());
		}
	}
	
	after(MyServer S) returning: serverProcess(S) {
		if (S.getTime() > 3) {
			// [7] The total process time between every pair of start and  stop must not exceed three seconds.
			throw (new ProcessTimeoutException("Total time taken by processes: " + S.getTime() + " seconds."));
		}
	}
	
	after() returning: mainMethod() {
		Set<MyServer> keySet = onlineServers.keySet();
		for (MyServer S: keySet) {
			if (onlineServers.get(S) == 1) {
				// [1] Every server start must be followed by a stop.
				throw (new NoStopForStartException());
			}
		}
	}
	
	before(): systemExit() {
		Set<MyServer> keySet = onlineServers.keySet();
		for (MyServer S: keySet) {
			if (onlineServers.get(S) == 1) {
				// [1] Every server start must be followed by a stop.
				throw (new NoStopForStartException());
			}
		}
	}
}

/*
 * For use with the self written Server Class.
 */

//public aspect ServerAspect
//{
//	/*
//	 * Fields used to ensure specified properties
//	 */
//	
//	// HashMap signifying Server --> isStarted?
//	HashMap<Server, Integer> onlineServers = new HashMap<>();
//	
//	// HashMap to store processingTimes between start() and stop()
//	HashMap<Server, Long> serverProcessingTimes = new HashMap<>();
//	
//	// Temporary variable to calculate time elapsed during processing
//	long processStartingTime;
//	
//	/*
//	 * Various Pointcuts for the program
//	 */
//	pointcut serverStart(Server S): call (void Server.start()) && target(S);
//	pointcut serverStop (Server S): call (void Server.stop()) && target(S);
//	pointcut serverProcess (Server S): call (void Server.process(int)) && target(S);
//	pointcut mainMethod(): execution (public static void main(String[]));
//	pointcut systemExit(): call (* System.exit(int));
//
//	/*
//	 * Specifying various actions at different JoinPoints
//	 */
//	
//	// [0] There can be more than one servers.
//	// Implicitly taken care of as we monitor references "Server S"
//	// and use target(S) in pointcuts.
//	
//	before(Server S): serverStart(S) {
//		if (onlineServers.containsKey(S)) {
//			if (onlineServers.get(S) == 1) {
//				// [4] Two or more consecutive starts are unacceptable.
//				throw (new MultipleStartsException());
//			}
//			// [5] A server that is stopped can be restarted.
//		}
//		// Server started for the first time.
//	}
//	
//	after(Server S) returning: serverStart(S) {
//		onlineServers.put (S, 1);
//		serverProcessingTimes.put (S, 0L);
//	}
//	
//	before(Server S): serverStop(S) {
//		if (!onlineServers.containsKey(S)) {
//			// [2] A start must precede every stop.
//			throw (new NoStartForStopException());
//		}
//		// [3] Two or more consecutive stops are acceptable.
//		// Taken care of as not enforcing the server to be in start state.
//	}
//	
//	after(Server S): serverStop(S) {
//		onlineServers.put(S, 2);
//		serverProcessingTimes.remove(S);
//	}
//	
//	before(Server S): serverProcess(S) {
//		if (onlineServers.containsKey(S)) {
//			if (onlineServers.get(S) == 2) {
//				// [6] No Processing between consecutive stops.
//				throw (new ProcessAfterStopException());
//			}
//			// Processing allowed between a start and stop.
//		}
//		else {
//			// [6] No Processing without a start.
//			throw (new ProcessWithoutStartException());
//		}
//		
//		// Get current System Time.
//		processStartingTime = System.currentTimeMillis();
//	}
//	
//	after(Server S) returning: serverProcess(S) {
//		// Get total processing time uptill now.
//		long currentTotal = serverProcessingTimes.get(S);
//		// Add to the total this processing time.
//		currentTotal += System.currentTimeMillis() - processStartingTime;
//	
//		processStartingTime = 0;
//		
//		// Update total time.
//		serverProcessingTimes.put (S, currentTotal);
//	
//		if (currentTotal > 3000) {
//			// [7] The total process time between every pair of start and  stop must not exceed three seconds.
//			throw (new ProcessTimeoutException("Total time taken by processes: " + currentTotal + " milliseconds."));
//		}
//	}
//	
//	after() returning: mainMethod() {
//		Set<Server> keySet = onlineServers.keySet();
//		for (Server S: keySet) {
//			if (onlineServers.get(S) == 1) {
//				// [1] Every server start must be followed by a stop.
//				throw (new NoStopForStartException());
//			}
//		}
//	}
//	
//	before(): systemExit() {
//		Set<Server> keySet = onlineServers.keySet();
//		for (Server S: keySet) {
//			if (onlineServers.get(S) == 1) {
//				// [1] Every server start must be followed by a stop.
//				throw (new NoStopForStartException());
//			}
//		}
//	}
//}