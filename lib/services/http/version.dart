import 'package:http/http.dart' as http;


class version {

  Future<http.Response> get() async {
    const String url = "https://us-central1-mlkit-66aba.cloudfunctions.net/version";
    http.Response response = await http.get(
        Uri.encodeFull(url),
        headers: {"Accept": "application/json"}
    );
    return response;
  }
}