library network_utils;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'cache_utils.dart';
import 'dialog_utils.dart';
class NetworkUtil {

  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  Future<dynamic> get(BuildContext context, String url) async {
    Map<String, String> headers = {};

    await getCache('jwt-token').then((result) {
      headers['Authorization'] = result;
    });

    try {
      final response = await http.get(url, headers: headers);
      final int statusCode = response.statusCode;
      print("${url}${headers}${response.headers}，${response.body}");

      if (response.headers.containsKey('authorization')) {
        setCache('jwt-token',response.headers['authorization']);
      }

      if (statusCode == 401) {
        return Navigator.of(context).pushReplacementNamed('/login');
      }
      if (statusCode == 404) {
        throw new Exception("404，${url}！");
      }
      if (statusCode == 500) {
        throw Exception("${response.body}");
      }
      if (statusCode == 200) {
        return json.decode(response.body);
      }
      throw new Exception("(HTTP:${statusCode})，");
    } on Exception catch (e) {
      showDialogSingleButton(context, "",
          e.toString().replaceAll(new RegExp(r'Exception: '), ''), "OK");
    }
  }

  Future<dynamic> post(BuildContext context, String url,
      {Map headers, body, encoding}) async {
    await getCache('jwt-token').then((result) {
      headers['Authorization'] = result;
    });

    try {
      final response = await http.post(url,
          body: body, headers: headers, encoding: encoding);
      final int statusCode = response.statusCode;
      print("${url}，${headers}，:${body}，${response.headers}，${response.body}");

      if (response.headers.containsKey('authorization')) {
         setCache('jwt-token',response.headers['authorization']);
      }

      if (statusCode == 401) {
        return Navigator.of(context).pushReplacementNamed('/login');
      }
      if (statusCode == 404) {
        throw new Exception("404，${url}！");
      }
      if (statusCode == 500) {
        throw Exception(",：${response.body}，");
      }
      if (statusCode == 200) {
        return json.decode(response.body);
      }
      throw new Exception(":(HTTP:${statusCode})，！");
    } on Exception catch (e) {
      showDialogSingleButton(context, "！",
          e.toString().replaceAll(new RegExp(r'Exception: '), ''), "OK");
    }
  }

  Future<dynamic> upload(
      BuildContext context, String url, List<http.MultipartFile > imageFileList,
      {Map headers, body, encoding}) async {
      await getCache('jwt-token').then((result) {
      headers['Authorization'] = result;
    });


    url = url + "?1=1";
    body.forEach((k, v) {
      url = url+"&${k}=${v}";
    });

    var uri = Uri.parse(url);

    var request = new http.MultipartRequest("POST", uri);


    imageFileList.forEach((imageFile){
      request.files.add(imageFile);
    });


    body.forEach((k, v) {
      //request.fields[k] = v;
    });

    headers.forEach((k, v) {
      request.headers[k] = v;
    });

    try {
      final responseStream = await request.send();
      String data = await Utf8Codec(allowMalformed: true)
          .decodeStream(responseStream.stream);
      final int statusCode = responseStream.statusCode;

      if (responseStream.headers.containsKey('authorization')) {
       setCache('jwt-token',responseStream.headers['authorization']);
      }

      if (statusCode == 401) {
        return Navigator.of(context).pushReplacementNamed('/login');
      }
      if (statusCode == 404) {
        throw new Exception("404，${url}！");
      }
      if (statusCode == 500) {
        throw Exception(",");
      }
      if (statusCode == 200) {
        print("${url}，${headers}，${body}，${data}");
        return json.decode(data);
      }
      throw new Exception(":(HTTP:${statusCode})，");
    } on Exception catch (e) {
      showDialogSingleButton(context, "！",
          e.toString().replaceAll(new RegExp(r'Exception: '), ''), "OK");
    }
  }
}
