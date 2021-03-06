// Copyright (c) 2018, the Dart Reddit API Wrapper project authors.
// Please see the AUTHORS file for details. All rights reserved.
// Use of this source code is governed by a BSD-style license that
// can be found in the LICENSE file.

import 'dart:async';

import 'package:draw/draw.dart';
import 'package:test/test.dart';

import '../test_utils.dart';

Future<void> main() async {
  test('lib/inbox/all', () async {
    final reddit =
        await createRedditTestInstance('test/inbox/lib_inbox_all.json');
    final messages = <Message>[];
    await for (final message in reddit.inbox.all()) {
      messages.add(message);
    }
    expect(messages.length, equals(9));
    expect(messages[0].author, equals('XtremeCheese'));
    expect(messages[0].subject, equals('Test'));
    expect(messages[0].body, equals('BLOCK ME I DARE YOU'));
  });

  test('lib/inbox/collapse_uncollapse', () async {
    final reddit = await createRedditTestInstance(
        'test/inbox/lib_inbox_collapse_uncollapse.json');
    final message = await reddit.inbox.message('t4_awl3r7');

    // There's no way to tell if a comment or message is collapsed, so we just
    // exercise the API here as a sanity check.
    await reddit.inbox.collapse([message]);
    await reddit.inbox.uncollapse([message]);
  });

  test('lib/inbox/commentReplies', () async {
    final reddit = await createRedditTestInstance(
        'test/inbox/lib_inbox_comment_replies.json');
    final comments = <Comment>[];
    await for (final comment in reddit.inbox.commentReplies()) {
      comments.add(comment);
    }
    expect(comments.length, equals(1));
    final comment = comments[0];
    expect(comment.author, equals('XtremeCheese'));
    expect(comment.body, equals('Testing reply inbox'));
  });

  test('lib/inbox/markReadUnread', () async {
    final reddit = await createRedditTestInstance(
        'test/inbox/lib_inbox_mark_read_unread.json');

    // We expect 1 unread comment.
    var message = await reddit.inbox.unread().first as Comment;
    expect(message.newItem, isTrue);
    expect(message.author, equals('XtremeCheese'));
    await reddit.inbox.markRead([message]);

    // Check to make sure we have no unread messages in our inbox.
    await for (final message in reddit.inbox.unread()) {
      expect(true, isFalse);
    }

    // Mark the same messages as unread and check to make sure it was marked unread.
    await reddit.inbox.markUnread([message]);
    message = await reddit.inbox.unread().first as Comment;
    expect(message.newItem, isTrue);
    expect(message.author, equals('XtremeCheese'));
  });

  test('lib/inbox/mentions', () async {
    final reddit =
        await createRedditTestInstance('test/inbox/lib_inbox_mentions.json');
    final comments = <Comment>[];
    await for (final comment in reddit.inbox.mentions()) {
      comments.add(comment);
    }
    expect(comments.length, equals(1));
    final comment = comments[0];
    expect(comment.subject, equals('username mention'));
    expect(comment.author, equals('XtremeCheese'));
    expect(comment.body, equals('/u/DRAWApiOfficial mention test'));
  });

  test('lib/inbox/message', () async {
    final reddit =
        await createRedditTestInstance('test/inbox/lib_inbox_message.json');
    final message = await reddit.inbox.message('t4_awl3r7');
    expect(message.id, equals('awl3r7'));
    expect(message.body, equals('Hi!'));
    expect(message.replies.length, equals(2));
  });

  test('lib/inbox/messages', () async {
    final reddit =
        await createRedditTestInstance('test/inbox/lib_inbox_messages.json');
    final messages = <Message>[];
    await for (final message in reddit.inbox.messages()) {
      messages.add(message);
    }
    expect(messages.length, equals(14));
    expect(messages[0].author, equals('XtremeCheese'));
    expect(messages[0].subject, equals('Test'));
    expect(messages[0].body, equals('BLOCK ME I DARE YOU'));
  });

  test('lib/inbox/sent', () async {
    final reddit =
        await createRedditTestInstance('test/inbox/lib_inbox_sent.json');
    final messages = <Message>[];
    await for (final message in reddit.inbox.sent()) {
      messages.add(message);
    }
    expect(messages.length, equals(5));
    final message = messages[0];
    expect(message.author, equals('DRAWApiOfficial'));
    expect(message.subject, equals('you are an approved submitter'));
  });

  test('lib/inbox/submissionReplies', () async {
    final reddit = await createRedditTestInstance(
        'test/inbox/lib_inbox_submission_replies.json');
    final message = await reddit.inbox.submissionReplies().first;
    expect(message.author, equals('XtremeCheese'));
    expect(message.body, equals('Great talk!'));
    expect(message.subject, equals('post reply'));
    expect(message.wasComment, isTrue);
  });

  // TODO(bkonyi): implement
  test('lib/inbox/uncollapse', () async {});

  test('lib/inbox/unread', () async {
    final reddit =
        await createRedditTestInstance('test/inbox/lib_inbox_unread.json');
    final message = await reddit.inbox.unread().first as Comment;
    expect(message.author, equals('XtremeCheese'));
    expect(message.body, equals('Great talk!'));
    expect(message.subject, equals('post reply'));
    expect(message.wasComment, isTrue);
  });
}
