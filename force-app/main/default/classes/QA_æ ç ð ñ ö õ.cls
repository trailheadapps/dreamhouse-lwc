import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class SpecialSymbolChecker {

    public static void main(String[] args) {
        String inputString = "Hello,  QA_æ ç ð ñ ö õ @world! How are you? #JavaProgramming!";

        if (containsSpecialSymbols(inputString)) {
            System.out.println("The string contains special symbols.");
        } else {
            System.out.println("The string does not contain special symbols.");
        }
    }

    public static boolean containsSpecialSymbols(String input) {
        // Define a regular expression pattern for detecting special symbols
        Pattern pattern = Pattern.compile("[^a-zA-Z0-9\\s]");

        // Create a matcher with the input string
        Matcher matcher = pattern.matcher(input);

        // Check if the matcher finds any special symbols
        return matcher.find();
    }
}

