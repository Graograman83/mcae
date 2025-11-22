@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private final String body;

    global MockHttpResponseGenerator(String body) {
        this.body = body;
    }

    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setBody(body);
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        return res;
    }
}
