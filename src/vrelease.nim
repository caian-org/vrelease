import httpclient

let client = newHttpClient()

let url = "https://caian-org.s3.amazonaws.com/public.gpg"
let response = client.request(url, httpMethod = HttpGet)

echo response.body
