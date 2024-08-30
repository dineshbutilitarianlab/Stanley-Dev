public class NumberToText {
    static final Integer DIGITS_PER_SET = 3;
    static final String ZERO = 'zero';
    public static Map<Integer,String> tens = new Map<Integer,String> {
        20 => 'twenty',
        30 => 'thirty',
        40 => 'forty',
        50 => 'fifty',
        60 => 'sixty',
        70 => 'seventy',
        80 => 'eighty',
        90 => 'ninety'
    };
    public static Map<Integer,String> smallNumbers = new Map<Integer,String> {
        0 => 'zero',
        1 => 'one',
        2 => 'two',
        3 => 'three',
        4 => 'four',
        5 => 'five',
        6 => 'six',
        7 => 'seven',
        8 => 'eight',
        9 => 'nine',
        10 => 'ten',
        11 => 'eleven',
        12 => 'twelve',
        13 => 'thirteen',
        14 => 'fourteen',
        15 => 'fifteen',
        16 => 'sixteen',
        17 => 'seventeen',
        18 => 'eighteen',
        19 => 'nineteen'
    };
    public static Map<Integer,String> modifiers = new Map<Integer,String> {
    
        1 => 'thousand ',
        2 => 'lakh',
        3 => 'crore'
    };    

    public static String convert(Integer value) {
        if (value == 0)
            return ZERO;

        String numberText = '';

        if (value < 0) {
            numberText = 'negative ';
            value *= -1;
        }

        String numberString = String.valueOf(value);

        while(numberString.length() > 0){
            Integer digits = Math.mod(numberString.length(), DIGITS_PER_SET) == 0 ?
                             DIGITS_PER_SET :
                             Math.mod(numberString.length(), DIGITS_PER_SET);

            String thisSet = numberString.substring(0, digits);

            Integer valueToConvert = Integer.valueOf(thisSet);

            numberString = numberString.substring(digits, numberString.length());

            if (valueToConvert > 0) {                
                String setText = generateText(valueToConvert);
                Integer modifierKey = (numberString.length()-1) / DIGITS_PER_SET;
                String modifier = modifierKey > 0 ? ' ' + modifiers.get(modifierKey) : '';
                numberText += setText + modifier;
            }
        }    
        System.debug('Text ::'+numberText.trim());
        string newtest = numberText.trim().replace('-',' ');

        String upperCase = newtest.toUppercase();
         System.debug('upperCase ::'+upperCase);
         return upperCase;
    }

    public static String generateText(Integer value) {
        if (value < 100)
            return generateTextForTwoDigits(value);
        String numberText = '';

        Integer hundreds = value / 100;
        if (hundreds > 0)
            numberText = generateTextForTwoDigits(hundreds) + ' hundred';

        Integer leftOver = Math.mod(value, 100);
        if (leftOver > 0)
            numberText += ' ' + generateTextForTwoDigits(leftOver);
        System.debug('numberText ::'+numberText);
        return numberText;
    }

    public static String generateTextForTwoDigits(Integer value) {
        if (value < 20) {
            return smallNumbers.get(value);
        }

        Integer tensKey = (value/10) * 10;
        String numberText = tens.get(tensKey);

        Integer leftOver = value - tensKey;

        if (leftOver > 0) {
            if (tensKey >= 20 && tensKey <= 90 && leftOver > 0) {
                numberText += '-';
            }
            numberText += generateTextForTwoDigits(leftOver);
        }
        
        return numberText;
    }
}