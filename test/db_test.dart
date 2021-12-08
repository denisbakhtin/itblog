import 'package:injector/injector.dart';
import 'package:itblog/models/data.dart';
import 'package:itblog/models/db.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  Setup();
  CleanDB();
  final db = Injector.appInstance.get<DB>();

  //____________________ HELPERS & MISC ______________
  test("toSlug translits and removes non alpha-numeric", () {
    expect(toSlug('Привет  Андрей!%#.,'), 'privet_andrej_');
    expect(toSlug(''), '_');
  });

  test("toStr transforms value to string", () {
    expect(toStr(123), '123');
    expect(toStr(null), '');
    expect(toStr('234'), '234');
    expect(toStr(2.34), '2.34');
  });

  test("toInt transforms value to int", () {
    expect(toInt(null), 0);
    expect(toInt(123), 123);
    expect(toInt('234'), 234);
  });

  test("toCryptoHash creates a sha256 hash", () {
    expect(
        toCryptoHash('123'),
        'A665A45920422F9D417E4867EFDC4FB8A04A1F3FFF1FA07E998E86F7F7A27AE3'
            .toLowerCase());
    expect(
        toCryptoHash('4567'),
        'DB2E7F1BD5AB9968AE76199B7CC74795CA7404D5A08D78567715CE532F9D2669'
            .toLowerCase());
  });

  test("Establishes connection specified in config.json", () {
    expect(db.db.handle != null, true);
  });

  //____________________ PAGES _______________________
  test("Creates a new page in db", () {
    var listBefore = db.pages();
    var page = Page(title: 'Page title', content: 'Content');
    var count = db.createPage(page);
    expect(count, 1);
    var listAfter = db.pages();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Reads pages from db", () {
    var list = db.pages();
    expect(list.length > 0, true);
    list.forEach((p) {
      expect(p.id > 0, true);
      expect(p.title.length > 0, true);
      expect(p.content.length > 0, true);
    });
  });

  test("Reads page from db", () {
    var page = Page(
        title: 'Page title new',
        content: 'Content',
        metaKeywords: 'keywords',
        metaDescription: 'description',
        published: 1);
    db.createPage(page);
    var page2 = db.pages().last;
    expect(page2.id > 0, true);
    expect(page2.title, page.title);
    expect(page2.content, page.content);
    expect(page2.slug, 'page_title_new');
    expect(page2.metaKeywords, 'keywords');
    expect(page2.metaDescription, 'description');
    expect(page2.published, 1);
  });

  test("Updates a page in db", () {
    var page = db.pages().last;
    var newPage = Page(
        id: page.id,
        title: page.title + "upd",
        content: page.content + "upd",
        metaKeywords: page.metaKeywords + "upd",
        metaDescription: page.metaDescription + "upd",
        slug: page.slug + "upd",
        published: (page.published + 1) % 2);
    var count = db.updatePage(newPage);
    expect(count, 1);
    var updatedPage = db.page(page.id);
    expect(updatedPage.id, newPage.id);
    expect(updatedPage.title, newPage.title);
    expect(updatedPage.content, newPage.content);
    expect(updatedPage.published, newPage.published);
    expect(updatedPage.metaKeywords, newPage.metaKeywords);
    expect(updatedPage.metaDescription, newPage.metaDescription);
    expect(updatedPage.slug, newPage.slug);
  });

  test("Deletes a page in db", () {
    var page = db.pages().last;
    var count = db.deletePage(page.id);
    expect(count, 1);
    try {
      db.page(page.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });

  //____________________ POSTS _______________________
  test("Creates a new post in db", () {
    var listBefore = db.posts();
    var post = Post(title: 'Post title', content: 'Content', published: 1);
    var count = db.createPost(post);
    expect(count, 1);
    var listAfter = db.posts();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Reads posts from db", () {
    var list = db.posts();
    expect(list.length > 0, true);
    list.forEach((p) {
      expect(p.id > 0, true);
      expect(p.title.length > 0, true);
      expect(p.content.length > 0, true);
      expect(p.slug.length > 0, true);
      expect(p.created, isNotNull);
    });
    var listP = db.posts(published: 1);
    expect(listP.indexWhere((p) => p.published == 0), -1);
    var listU = db.posts(published: 0);
    expect(listU.indexWhere((p) => p.published == 1), -1);
  });

  test("Reads recent posts from db", () {
    var list = db.recentPosts();
    expect(list.length > 0 && list.length <= 4, true);
    list.forEach((p) {
      expect(p.id > 0, true);
      expect(p.title.length > 0, true);
      expect(p.content.length > 0, true);
      expect(p.slug.length > 0, true);
      expect(p.published == 1, true);
    });
  });

  test("Reads post from db", () {
    var post = Post(
        title: 'Post title new',
        content: 'Content',
        metaKeywords: 'keywords',
        metaDescription: 'description',
        published: 1);
    db.createPost(post);

    var post2 = db.posts().last;
    expect(post2.id > 0, true);
    expect(post2.title, post.title);
    expect(post2.content, post.content);
    expect(post2.slug, 'post_title_new');
    expect(post2.metaKeywords, 'keywords');
    expect(post2.metaDescription, 'description');
    expect(post2.published, 1);
  });

  test("Updates a post in db", () {
    var post = db.posts().last;
    var newPost = Post(
        id: post.id,
        title: post.title + "upd",
        content: post.content + "upd",
        metaKeywords: post.metaKeywords + "upd",
        metaDescription: post.metaDescription + "upd",
        slug: post.slug + "upd",
        published: (post.published + 1) % 2);
    var count = db.updatePost(newPost);
    expect(count, 1);
    var updatedPost = db.post(post.id);
    expect(updatedPost.id, newPost.id);
    expect(updatedPost.title, newPost.title);
    expect(updatedPost.content, newPost.content);
    expect(updatedPost.published, newPost.published);
    expect(updatedPost.metaKeywords, newPost.metaKeywords);
    expect(updatedPost.metaDescription, newPost.metaDescription);
    expect(updatedPost.slug, newPost.slug);
  });

  test("Deletes a post in db", () {
    var post = db.posts().last;
    var count = db.deletePost(post.id);
    expect(count, 1);
    try {
      db.post(post.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });

  //____________________ TAGS _______________________
  test("Creates a new tag in db", () {
    var listBefore = db.tags();
    var tag = Tag(title: 'Tag title', content: 'Content');
    var count = db.createTag(tag);
    expect(count, 1);
    var listAfter = db.tags();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Reads tags from db", () {
    var list = db.tags();
    expect(list.length > 0, true);
    list.forEach((p) {
      expect(p.id > 0, true);
      expect(p.title.length > 0, true);
      expect(p.content.length > 0, true);
      expect(p.slug.length > 0, true);
    });
  });

  test("Reads tag from db", () {
    var tag = Tag(
        title: 'tag title new',
        content: 'Content',
        metaKeywords: 'keywords',
        metaDescription: 'description',
        published: 1);
    db.createTag(tag);
    var tag2 = db.tags().last;
    expect(tag2.id > 0, true);
    expect(tag2.title, tag.title);
    expect(tag2.content, tag.content);
    expect(tag2.slug, 'tag_title_new');
    expect(tag2.metaKeywords, 'keywords');
    expect(tag2.metaDescription, 'description');
    expect(tag2.published, 1);
  });

  test("Updates a tag in db", () {
    var tag = db.tags().last;
    var newTag = Tag(
        id: tag.id,
        title: tag.title + "upd",
        content: tag.content + "upd",
        metaKeywords: tag.metaKeywords + "upd",
        metaDescription: tag.metaDescription + "upd",
        slug: tag.slug + "upd",
        published: (tag.published + 1) % 2);
    var count = db.updateTag(newTag);
    expect(count, 1);
    var updatedTag = db.tag(tag.id);
    expect(updatedTag.id, newTag.id);
    expect(updatedTag.title, newTag.title);
    expect(updatedTag.content, newTag.content);
    expect(updatedTag.published, newTag.published);
    expect(updatedTag.metaKeywords, newTag.metaKeywords);
    expect(updatedTag.metaDescription, newTag.metaDescription);
    expect(updatedTag.slug, newTag.slug);
  });

  test("Deletes a tag in db", () {
    var tag = db.tags().last;
    var count = db.deleteTag(tag.id);
    expect(count, 1);
    try {
      db.tag(tag.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });

  //____________________ COMMENTS _______________________
  test("Creates a new comment in db", () {
    var listBefore = db.comments();
    var comment = Comment(content: 'Content');
    var count = db.createComment(comment);
    expect(count, 1);
    var listAfter = db.comments();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Reads comments from db", () {
    var list = db.comments();
    expect(list.length > 0, true);
    list.forEach((p) {
      expect(p.id > 0, true);
      expect(p.content.length > 0, true);
    });
  });

  test("Reads comment from db", () {
    var post = db.posts().first;
    var comment = Comment(
        content: 'Content', postId: post.id, userName: 'user1', published: 1);
    db.createComment(comment);
    var c2 = db.comments().last;
    expect(c2.id > 0, true);
    expect(c2.content, comment.content);
    expect(c2.postId, comment.postId);
    expect(c2.userName, comment.userName);
    expect(c2.published, 1);
  });

  test("Updates a comment in db", () {
    var c = db.comments().last;
    var newC = Comment(
        id: c.id,
        content: c.content + "upd",
        postId: c.postId,
        userName: c.userName + "upd",
        published: (c.published + 1) % 2);
    var count = db.updateComment(newC);
    expect(count, 1);
    var updatedC = db.comment(c.id);
    expect(updatedC.id, newC.id);
    expect(updatedC.content, newC.content);
    expect(updatedC.published, newC.published);
    expect(updatedC.userName, newC.userName);
    expect(updatedC.postId, newC.postId);
  });

  test("Deletes a comment in db", () {
    var c = db.comments().last;
    var count = db.deleteComment(c.id);
    expect(count, 1);
    try {
      db.comment(c.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });

  //____________________ USERS _______________________
  test("Validates a user model", () {
    var u = User(name: 'User Name', email: 'me@email.com', password: '23456');
    //does not throw
    u.validate();
    u = User(email: 'me@email.com', password: '23456');
    try {
      u.validate();
      expect(true, false, reason: "Should throw");
    } on NotValidException {} catch (e) {
      expect(true, false, reason: e.toString());
    }
    u = User(name: 'User Name', password: '23456');
    try {
      u.validate();
      expect(true, false, reason: "Should throw");
    } on NotValidException {} catch (e) {
      expect(true, false, reason: e.toString());
    }
    u = User(name: 'User Name', email: 'me@email.com');
    try {
      u.validate();
      expect(true, false, reason: "Should throw");
    } on NotValidException {} catch (e) {
      expect(true, false, reason: e.toString());
    }
  });

  test("Creates a new user in db", () {
    var listBefore = db.users();
    var u = User(name: 'User Name', email: 'me@email.com', password: '23456');
    final user = db.createUser(u);
    expect(user.id > 0, true);
    expect(user.name, 'User Name');
    expect(user.email, 'me@email.com');
    expect(user.hasPassword('23456'), true);
    var listAfter = db.users();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Creating existing user throws exception", () {
    var u =
        User(name: 'Some User Name', email: 'me@email.com', password: '23456');
    try {
      db.createUser(u);
      expect(true, false,
          reason: "Must not create another user with same email");
    } on ExistsException {} catch (e) {
      expect(e, null, reason: e.toString());
    }
  });

  test("Reads users from db", () {
    var list = db.users();
    expect(list.length > 0, true);
    list.forEach((p) {
      expect(p.id > 0, true);
      expect(p.name.length > 0, true);
      expect(p.email.length > 0, true);
      expect(p.password.length > 0, true);
    });
  });

  test("Reading inexistent user throws exception", () {
    try {
      db.user(11111111);
      expect(true, false,
          reason: "Should throw exception on reading inexistent user");
    } on NotFoundException {} catch (e) {
      expect(e, null, reason: e.toString());
    }
  });

  test("Reads user from db", () {
    var u =
        User(name: 'User nname', email: 'user@email.com', password: '12345');
    db.createUser(u);
    var u2 = db.users().last;
    expect(u2.id > 0, true);
    expect(u2.name, u.name);
    expect(u2.email, u.email);
    expect(u2.password, toCryptoHash('12345'));
  });

  test("Updates a user in db", () {
    var u = db.users().last;
    var newU = User(
      id: u.id,
      name: u.name + "upd",
      email: u.email + "upd",
      password: '111',
    );
    var count = db.updateUser(newU);
    expect(count, 1);
    var updatedU = db.user(u.id);
    expect(updatedU.id, newU.id);
    expect(updatedU.name, newU.name);
    expect(updatedU.email, newU.email);
    expect(updatedU.password, toCryptoHash('111'));
  });

  test("Deletes a user in db", () {
    var u = db.users().last;
    var count = db.deleteUser(u.id);
    expect(count, 1);
    try {
      db.user(u.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });

  //____________________ SUBSCRIBER _______________________
  test("Creates a new subscriber in db", () {
    var listBefore = db.subscribers();
    var ms = DateTime.now().microsecondsSinceEpoch;
    var s = Subscriber(email: 'my_$ms@email.com');
    var count = db.createSubscriber(s);
    expect(count, 1);
    var listAfter = db.subscribers();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Reads subscribers from db", () {
    var list = db.subscribers();
    expect(list.length > 0, true);
    list.forEach((s) {
      expect(s.id > 0, true);
      expect(s.email.length > 0, true);
      expect(s.email, s.email.toLowerCase().trim());
    });
  });

  test("Reads subscriber from db", () {
    var s = Subscriber(
      email: 'some@email.com',
    );
    db.createSubscriber(s);

    var s2 = db.subscribers().last;
    expect(s2.id > 0, true);
    expect(s2.email, s.email);
    expect(s2.created, isNotNull);
  });

  test("Updates a subscriber in db", () {
    var s = db.subscribers().last;
    var newS = Subscriber(
      id: s.id,
      email: s.email + "upd",
      createdAt: s.createdAt,
    );
    var count = db.updateSubscriber(newS);
    expect(count, 1);
    var updatedS = db.subscriber(s.id);
    expect(updatedS.id, newS.id);
    expect(updatedS.email, newS.email);
    expect(updatedS.created, newS.created);
  });

  test("Deletes a subscriber in db", () {
    var s = db.subscribers().last;
    var count = db.deleteSubscriber(s.id);
    expect(count, 1);
    try {
      db.subscriber(s.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });

  //____________________ MAILING _______________________
  test("Creates a new mailing in db", () {
    var listBefore = db.mailings();
    var m = Mailing(title: 'first title', content: 'first content');
    var count = db.createMailing(m);
    expect(count, 1);
    var listAfter = db.mailings();
    expect(listAfter.length, listBefore.length + 1);
  });

  test("Reads mailings from db", () {
    var list = db.mailings();
    expect(list.length > 0, true);
    list.forEach((m) {
      expect(m.id > 0, true);
      expect(m.title, isNotEmpty);
      expect(m.content, isNotEmpty);
    });
  });

  test("Reads mailing from db", () {
    var m = Mailing(
      title: 'second title',
      content: 'second content',
    );
    db.createMailing(m);

    var m2 = db.mailings().last;
    expect(m2.id > 0, true);
    expect(m2.title, m.title);
    expect(m2.content, m.content);
    expect(m2.created, isNotNull);
  });

  test("Updates a mailing in db", () {
    var m = db.mailings().last;
    var newM = Mailing(
      id: m.id,
      title: m.title + "upd",
      content: m.content + "upd",
      createdAt: m.createdAt,
    );
    var count = db.updateMailing(newM);
    expect(count, 1);
    var updatedM = db.mailing(m.id);
    expect(updatedM.id, newM.id);
    expect(updatedM.title, newM.title);
    expect(updatedM.content, newM.content);
    expect(updatedM.created, newM.created);
  });

  test("Deletes a mailing in db", () {
    var m = db.mailings().last;
    var count = db.deleteMailing(m.id);
    expect(count, 1);
    try {
      db.mailing(m.id);
      expect(false, true, reason: 'Should throw a NotFoundException');
    } on NotFoundException {} catch (e) {
      expect(false, true, reason: 'Should throw a NotFoundException');
    }
  });
}
