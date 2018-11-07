// Copyright (c) 2017, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

/// Thrown when there is an error during the authentication flow.
class DRAWAuthenticationError implements Exception {
  DRAWAuthenticationError(this.message);
  final String message;
  String toString() => 'DRAWAuthenticationError: $message';
}

/// Thrown due to invalid arguments being provided to a DRAW method.
class DRAWArgumentError implements Exception {
  DRAWArgumentError(this.message);
  final String message;
  String toString() => 'DRAWArgumentError: $message';
}

/// Thrown due to a fatal error encountered inside DRAW. If you're not adding
/// functionality to DRAW you should never see this. Otherwise, please file a
/// bug at github.com/draw-dev/DRAW/issues.
class DRAWInternalError implements Exception {
  DRAWInternalError(this.message);
  final String message;
  String toString() => 'DRAWInternalError: $message';
}

/// Thrown due to a error on the side of the client due to incorrect integration of DRAW.
class DRAWClientError implements Exception {
  DRAWClientError(this.message);
  final String message;
  String toString() =>
      'DRAWClientError: $message This is likely due to issues with your ini file.';
}

/// Thrown when a redirect is requested after a network call. Used to notify
/// various APIs that additional work needs to be done.
class DRAWRedirectResponse implements Exception {
  final String path;
  final response;
  DRAWRedirectResponse(this.path, this.response);
  String toString() => 'DRAWRedirectResponse: Unexpected redirect to ${path}.';
}

/// Thrown if a call to gild a [Comment], [Redditor], or [Submission] fails.
class DRAWGildingException implements Exception {
  final Map<String, String> response;
  DRAWGildingException(this.response);
  String get explanation => response['explanation'];
  String get message => response['message'];
  String get reason => response['reason'];
  String toString() => 'DRAWGildingException: $explanation (reason: $reason)';
}

/// Thrown by unfinished code that hasn't yet implemented all the features it
/// needs.
class DRAWUnimplementedError extends UnimplementedError {
  DRAWUnimplementedError([String message]) : super(message);
}

class DRAWNotFoundException implements Exception {
  final String reason;
  final String message;
  DRAWNotFoundException(this.reason, this.message);
  String toString() =>
      'DRAWNotFoundException(Reason: "$reason", Message: "$message")';
}

class DRAWInvalidCommentException implements Exception {
  final String commentId;
  DRAWInvalidCommentException(this.commentId);
  String toString() =>
      'DRAWInvalidCommentException: "$commentId" is not a valid comment ID.';
}

class DRAWInvalidRedditorException implements Exception {
  final String redditorName;
  DRAWInvalidRedditorException(this.redditorName);
  String toString() =>
      'DRAWInvalidRedditorException: "$redditorName" is not a valid redditor.';
}

class DRAWInvalidSubmissionException implements Exception {
  final String submissionId;
  DRAWInvalidSubmissionException(this.submissionId);
  String toString() =>
      'DRAWInvalidSubmissionException: "$submissionId" is not a valid submission ID.';
}

class DRAWInvalidSubredditException implements Exception {
  final String subredditName;
  DRAWInvalidSubredditException(this.subredditName);
  String toString() =>
      'DRAWInvalidSubredditException: "$subredditName" is not a valid subreddit.';
}

class DRAWUnknownResponseException implements Exception {
  final int status;
  final String message;
  DRAWUnknownResponseException(this.status, this.message);
  String toString() => 'DRAWUnknownResponse: $message (status: $status)';
}
