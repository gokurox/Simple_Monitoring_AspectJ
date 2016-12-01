package exceptions;

public class ProcessTimeoutException extends RuntimeException {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	public ProcessTimeoutException(String s) {
		super (s);
	}
}
