© 2021 Method R Corporation

import java.io.*;
import java.sql.*;
import oracle.jdbc.*;

public class GetTraceFile {

	private Connection conn;
	private CallableStatement stm;
	private String connurl;
	private String oradir;
	private int bufsz = 512;

	public GetTraceFile (String connurl, String oradir) {
		this.connurl = connurl;
		this.oradir = oradir;
	}

	private void read (OracleBfile b) throws Exception {
		b.openFile();
		InputStream s = b.getBinaryStream();
		InputStreamReader r = new InputStreamReader(s);
		int nb;
		byte[] ba = new byte[bufsz];
		while ((nb = s.read(ba)) != -1)
			System.out.write(ba, 0, nb);
		b.closeFile();
	}

	// Call this before calling get.
	public void init () throws Exception {
		if (conn == null)
			conn = DriverManager.getConnection(this.connurl);
	}

	// Call this after calling init.
	public void get (String trcfilename) throws Exception {
		if (this.stm == null)
			this.stm = conn.prepareCall("select bfilename(?,?) from dual");
		this.stm.setString(1, this.oradir);
		this.stm.setString(2, trcfilename);
		OracleResultSet r = (OracleResultSet) this.stm.executeQuery();
		while (r.next()) // By definition this has to iterate exactly 0 or 1 time
			read(r.getBFILE(1));
		r.close();
	}

	// Call this when you're done getting trace files.
	public void done () throws Exception {
		if (this.stm != null)
			this.stm.close();
		if (this.conn != null)
			this.conn.close();
	}

	// Use this if you want only one trace file.
	public static void main (String[] args) throws Exception {
		GetTraceFile gtf = new GetTraceFile(args[0], args[1]);
		gtf.init();
		gtf.get(args[2]);
		gtf.done();
	}

}

/*

$ javac -cp .:ojdbc8.jar GetTraceFile.java
$ java -cp .:ojdbc8.jar GetTraceFile jdbc:oracle:thin:jeff/jeff@localhost:55210:ora193 METHODR_UDUMP_1 ora193_dia0_8489_base_1.trc > x
$ head -1 x
Trace file /u01/app/oracle/diag/rdbms/ora193/ora193/trace/ora193_dia0_8489_base_1.trc
$ diff x /u01/app/oracle/diag/rdbms/ora193/ora193/trace/ora193_dia0_8489_base_1.trc
$

*/
