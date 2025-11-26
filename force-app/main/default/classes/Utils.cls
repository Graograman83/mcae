public class Utils {
    public static String buildQueryString(Map<String, String> urlParams) {
        String queryString = '?';
        List<String> expressions = new List<String>();
        for (String key : urlParams.keySet()) {
            expressions.add(key + '=' + urlParams.get(key));
        }
        queryString += String.join(expressions, '&');
        return queryString;
    }
}