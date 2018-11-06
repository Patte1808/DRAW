// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:reply/reply.dart';

import 'package:draw/src/auth.dart';
import 'package:draw/src/draw_config_context.dart';
import 'package:draw/src/exceptions.dart';

const redirectResponseStr = 'DRAWRedirectResponse';
const notFoundExceptionStr = 'DRAWNotFoundException';

/// A drop-in replacement for [Authenticator], used for recording and replaying
/// Reddit API interactions, used primarily for testing.
class TestAuthenticator extends Authenticator {
  final String _recordingPath;
  final Authenticator _recordAuth;
  final _recorder = Recorder<List, dynamic>();
  bool get isRecording => (_recordAuth == null);
  Recording _recording;

  /// Creates a [TestAuthenticator] object which either reads a recording from
  /// [recordingPath] or records Reddit API requests and responses if
  /// [recordAuth] is provided. If [recordAuth] is provided, it must be a
  /// valid Authenticator with valid OAuth2 credentials that is capable of
  /// making requests to the Reddit API. Note: when recording Reddit API
  /// interactions, [writeRecording] must be called to write all prior records
  /// to the file at [recordingPath].
  TestAuthenticator(String recordingPath, {Authenticator recordAuth})
      : _recordingPath = recordingPath,
        _recordAuth = recordAuth,
        super(DRAWConfigContext(), null) {
    if (isRecording) {
      final rawRecording = File(recordingPath).readAsStringSync();
      final recording = json.decode(rawRecording).cast<Map<String, dynamic>>();

      _recording = Recording.fromJson(recording,
          toRequest: (q) => q,
          toResponse: (r) => r,
          requestEquality: const ListEquality());
    }
  }

  @override
  Future refresh() async {
    if (isRecording) {
      throw DRAWAuthenticationError('cannot refresh a TestAuthenticator.');
    }
    return _recordAuth.refresh();
  }

  @override
  Future revoke() async {
    if (isRecording) {
      throw DRAWAuthenticationError('cannot revoke a TestAuthenticator.');
    }
    return _recordAuth.revoke();
  }

  dynamic _copyResponse(response) {
    if (response == null) {
      return '';
    }
    // This is a way to do a recursive deep-copy of the response so we don't
    // accidentally overwrite data in the tests.
    return json.decode(json.encode(response));
  }

  @override
  Future<dynamic> get(Uri path,
      {Map<String, String> params, bool followRedirects: false}) async {
    var result;
    if (isRecording) {
      result = _recording.reply([path.toString(), params.toString()]);
      if ((result is List) &&
          result.isNotEmpty) {
        final type = result[0];
        switch(type) {
          case redirectResponseStr:
            throw DRAWRedirectResponse(result[1], null);
          case notFoundExceptionStr:
            throw DRAWNotFoundException(result[1], result[2]);
          default:
            throw DRAWInternalError('Could not determine exception type: $type');
        }
      }
    } else {
      try {
        result = await _recordAuth.get(path,
            params: params, followRedirects: followRedirects);
      } on DRAWRedirectResponse catch (e) {
        _recorder.given([path.toString(), params.toString()]).reply(
            [redirectResponseStr, e.path]).once();
        throw e;
      } on DRAWNotFoundException catch (e) {
        _recorder.given([path.toString(), params.toString()]).reply(
            [notFoundExceptionStr, e.reason, e.message]).once();
        throw e;
      }
      _recorder
          .given([path.toString(), params.toString()])
          .reply(_copyResponse(result))
          .once();
    }
    return result;
  }

  @override
  Future<dynamic> post(Uri path, Map<String, String> body) async {
    var result;
    if (isRecording) {
      result = _recording.reply([path.toString(), body.toString()]);
      if ((result is List) &&
          result.isNotEmpty &&
          (result[0] == notFoundExceptionStr)) {
        throw DRAWNotFoundException(result[1], result[2]);
      }
    } else {
      try {
        result = await _recordAuth.post(path, body);
      } on DRAWNotFoundException catch (e) {
        _recorder.given([path.toString(), body.toString()]).reply(
            [notFoundExceptionStr, e.reason, e.message]).once();
        throw e;
      }
      _recorder
          .given([path.toString(), body.toString()])
          .reply(_copyResponse(result))
          .once();
    }
    return (result == '') ? null : result;
  }

  @override
  Future<dynamic> put(Uri path,
      {/* Map<String, String>, String */ body}) async {
    var result;
    if (isRecording) {
      result = _recording.reply([path.toString(), body.toString()]);
    } else {
      result = await _recordAuth.put(path, body: body);
      _recorder
          .given([path.toString(), body.toString()])
          .reply(_copyResponse(result))
          .once();
    }
    return result;
  }

  @override
  Future<dynamic> delete(Uri path,
      {/* Map<String, String>, String */ body}) async {
    var result;
    if (isRecording) {
      result = _recording.reply([path.toString(), body.toString()]);
    } else {
      result = await _recordAuth.delete(path, body: body);
      _recorder
          .given([path.toString(), body.toString()])
          .reply(_copyResponse(result) ?? '')
          .once();
    }
    return (result == '') ? null : result;
  }

  @override
  bool get isValid {
    return _recordAuth?.isValid ?? true;
  }

  /// Writes the recorded Reddit API requests and their corresponding responses
  /// to [recordingPath] and returns a [Future<File>], which is the file that
  /// has been written to, when in recording mode. When not in recording mode,
  /// does nothing and returns null.
  Future<File> writeRecording() {
    if (!isRecording) {
      return (File(_recordingPath)).writeAsString(json
          .encode(_recorder.toRecording().toJsonEncodable(
              encodeRequest: (q) => q, encodeResponse: (r) => r))
          .toString());
    }
    return null;
  }
}
