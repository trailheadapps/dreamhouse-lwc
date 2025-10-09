import java.io.*;
import java.net.*;
import java.sql.*;
import java.security.*;
import java.util.*;

// A deliberately bad example for educational purposes.
// BUG/VULN comments are inline. DO NOT ship this.

public class BadExample {
    // BUG1: Hard-coded credentials (sensitive data in source)
    private static final String DB_USER = "admin";
    private static final String DB_PASS = "P@ssw0rd"; // VULN1: Hard-coded secret

    // BUG2: Global mutable state without synchronization
    private static int requestCount = 0; // race condition (BUG3)

    public static void main(String[] args) {
        try {
            // BUG4: Silent catch later, but here we ignore exceptions poorly
            greetUser(null); // BUG5: Passing null to purposely cause NPE
        } catch (Exception ignored) {
            // BUG6: swallowing exception, hides root cause
            System.out.println("Something happened"); // leaks info but hides stack
        }

        // BUG7: insecure randomness, predictable tokens (VULN2)
        String token = generateToken();
        System.out.println("Token: " + token);

        // BUG8: Dangerous runtime exec with unsanitized input (VULN3)
        try {
            String cmd = "echo " + System.getenv("USER"); // uses env but could be any user input
            Runtime.getRuntime().exec(cmd);
        } catch (IOException e) {
            // BUG9: ignore exception handling
        }

        // BUG10: insecure DB access with SQL concatenation (VULN4)
        try {
            getUserFromDb("alice' OR '1'='1"); // simulate SQL injection payload
        } catch (Exception e) {
            // BUG11: print stack trace to stdout (leaks implementation details)
            e.printStackTrace();
        }

        // BUG12: insecure deserialization (VULN5)
        try {
            byte[] data = new byte[0]; // pretend payload
            Object o = insecureDeserialize(new ByteArrayInputStream(data));
            System.out.println("Deserialized: " + o);
        } catch (Exception e) {
            // BUG13: ignore exceptions
        }

        // BUG14: off-by-one / array index error
        int[] arr = new int[3];
        for (int i = 0; i <= arr.length; i++) { // BUG15: should be < not <=
            try {
                arr[i] = i; // will throw ArrayIndexOutOfBoundsException
            } catch (Exception e) {
                // BUG16: continue silently
            }
        }

        // BUG17: path traversal - writing to file from user input
        try {
            writeFile("../tmp/" + getFilenameFromUser(), "hello"); // unvalidated filename
        } catch (IOException e) {
            // BUG18: poor error message
            System.out.println("Can't write file.");
        }

        // BUG19: weak hashing (MD5) used for passwords
        String hash = weakHash("password123"); // BUG20
        System.out.println("Hash: " + hash);

        // BUG21: infinite loop potential
        while (false) { // harmless here, but demonstrates dead code; change could cause infinite loop
            System.out.println("This will never print");
        }

        // BUG22: improper equals usage leading to logic bug
        Integer a = 1000, b = 1000;
        if (a == b) { // should use a.equals(b)
            System.out.println("Equal");
        } else {
            System.out.println("Not equal");
        }

        // BUG23: leaking sensitive info in logs
        System.out.println("DB user/pass: " + DB_USER + "/" + DB_PASS);

        // BUG24: not closing resources in DB method (resource leak)
        try {
            // pretend to do work
            requestCount++; // race condition increment
        } catch (Exception e) {
            // swallow
        }
    }

    // BUG25: method may throw NPE if name == null
    public static void greetUser(String name) {
        System.out.println("Hello, " + name.toUpperCase()); // will throw if name == null
    }

    public static String generateToken() {
        // VULN2: using java.util.Random for tokens - predictable
        Random rnd = new Random(12345); // seeded with constant -> predictable
        return Long.toHexString(rnd.nextLong());
    }

    public static void getUserFromDb(String username) throws SQLException {
        // BUG26: using DriverManager directly without closing connection, statement, or resultset
        Connection conn = DriverManager.getConnection("jdbc:fake://localhost/db", DB_USER, DB_PASS);
        Statement st = conn.createStatement();
        // VULN4: SQL injection via concatenation
        String sql = "SELECT * FROM users WHERE name = '" + username + "'";
        ResultSet rs = st.executeQuery(sql);
        if (rs.next()) {
            System.out.println("Found user: " + rs.getString("name"));
        }
        // BUG27: never closes rs, st, conn -> resource leak
    }

    public static Object insecureDeserialize(InputStream in) throws IOException, ClassNotFoundException {
        // VULN5: deserializing untrusted data (dangerous)
        ObjectInputStream ois = new ObjectInputStream(in);
        Object obj = ois.readObject();
        // BUG28: not validating class types
        ois.close();
        return obj;
    }

    public static String getFilenameFromUser() {
        // BUG29: reads from console without validation
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        try {
            System.out.print("Enter filename: ");
            return br.readLine();
        } catch (IOException e) {
            return "default.txt";
        } // BUG30: not closing BufferedReader (resource leak); also returns user input unsanitized
    }

    public static void writeFile(String filename, String content) throws IOException {
        // BUG31: no path sanitization -> path traversal
        FileWriter fw = new FileWriter(filename);
        fw.write(content);
        fw.close(); // might fail to close in face of exception; should use try-with-resources
    }

    public static String weakHash(String s) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5"); // VULN6: MD5 is weak
            byte[] d = md.digest(s.getBytes("UTF-8"));
            // BUG32: converting bytes to string incorrectly
            return new String(d);
        } catch (Exception e) {
            return "";
        }
    }
}
