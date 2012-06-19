# Redpomo: Redmine, Pomodoro.app and Todo-txt. Together.

[![Build Status](https://secure.travis-ci.org/stefanoverna/redpomo.png)](http://travis-ci.org/stefanoverna/redpomo)

## Redpomo is for you if...

* You're an hopeless nerd and like CLIs;
* You (or you company) use Redmine to track issues and time spent on projects;
* You heard about [Todo.txt](http://todotxt.com/) and the [Pomodoro technique](http://www.pomodorotechnique.com/);

Still here? Great!

## What Redpomo can do for me?

Redpomo is an opinionated CLI tool that makes it darmn easy to:

* Manage multiple Redmine instances at once;
* Create, close and navigate Redmine issues assigned to you;
* Push your completed pomodoros to remote Redmine as project time-tracks;

## It integrates nicely with [Todo.txt](http://todotxt.com/)!

Instead of reinventing yet another time the weel, Redpomo talks with
your remote Redmine instances, and syncs all the issues assigned to
your local machine converting them into Todo.txt tasks.

Just launch `redpomo` from your command line, and you're done:

```
$ redpomo
Pulled 4 issues.

$ todo.sh ls
01 Write Redpomo README #1340 +redpomo @welaika
02 Publish to App Store #1140 +love-this-song @welaika
03 Meeting with client #1490 +nike @welaika
04 Call mom
--
TODO: 4 of 4 tasks shown
```

The generic syntax for the imported task will be the following (thanks to
[asciiflow](http://www.asciiflow.com/) for the drawing):

```
(A) 2012-11-25 Make some delicious coffee #1800 +next-big-project @welaika
|   |          |                          |     |                 |
|   |          |                          |     |                 +-> Redmine instance identifier
|   |          |                          |     |
|   |          |                          |     +-> Redmine project for the issue
|   |          |                          |
|   |          +-> Issue title            +-> Issue ID
|   |
|   +-> Issue expiration date (if present)
|
+-> Issue priority (A means Immediate)
```

### How to create new Redmine self-assigned issues

That's so simple:

```
$ redpomo add 'quote the project +random-project @welaika'
Issue created, see it at http://code.welaika.com/issues/3659
```

* If you specify a default project on your `~/.redpomo` configuration
  file, you can even left out the `+random-project` part.
* If you don't specify a task, your predefined editor will pop up and
  ask you to write the title and (optionally) the description for the
  issue;
* On iTerm 2 terminals, just command + click on the URL to open up the
  browser!

### How to close a Redmine issue

```
$ redpomo close 3 -m "Finally done"
Issue updated, see it at http://code.welaika.com/issues/1490
```

### Opening the browser to a specific Redmine issue

```
$ redpomo open 3
  # -> takes your browser to http://code.welaika.com/issues/1490
```

## It integrates nicely with [Pomodoro.app](https://github.com/ugol/pomodoro)!

If you need to start working on some Redmine issue, just use the `start`
command:

```
$ redpomo start 3
```

This will communicate via Applescript with Pomodoro.app, and will automatically
start a new pomodoro for you: the description of the pomodoro will contain both
the ID of the Redmine issue (ie. #1234), and the Redmine instance identifier
(ie. @welaika).

This is important: in this way we will be able to remap completed pomodoros back
to Redmine issues later on!

### Pushing local pomodoros as Redmine time-tracks

Here comes the best one. Open the "Pomodoro Stats" panel, and click on
the Export button. This will generate a CSV file full of all your completed
pomodoros.

Now we can pass this file to Redpomo:

```
$ redpomo push --dry-run --fuzzy ~/pomodoros.csv

+----------+------------+---------+------------------------+----------+-------+-------+
|                              Monday 06/18/12 - 8 hours                              |
+----------+------------+---------+------------------------+----------+-------+-------+
| Context  | Project    | Issue # | Description            | Duration | From  | To    |
+----------+------------+---------+------------------------+----------+-------+-------+
| welaika  | nike       | 1392    | Project publishing     | 2 hours  | 08:02 | 10:49 |
| welaika  | nike       | 1390    | Project subtitle       | 2 hours  | 10:49 | 13:05 |
| cantiere | railsyard  |         | Resource trees         | 2 hours  | 13:05 | 15:30 |
| welaika  | nike       | 1392    | Project publishing     | 32 mins  | 15:30 | 16:03 |
| cantiere | railsyard  |         | Resource trees         | 25 mins  | 16:03 | 16:28 |
+----------+------------+---------+------------------------+----------+-------+-------+
```

Isn't it awesome?!

* The `--dry-run` option tells Redpomo just to print out the parsed timetracks, without
  pushing timetracks to the various Redmine instances yet;
* The `--fuzzy` option merges contiguous pomodoros related to the same Redmine issue;

## Installation and setup

Install it yourself as:

```
$ gem install redpomo
```

And then configure it with the following command:

```
$ redpomo init
```

This will create a new `.redpomo` skeleton file to your home directory, where
you'll need to specify all the details of your Redmine instances. Easy
stuff.

## Contributing

Redpomo is still in its early development. Any help would be much appreciated!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

(The MIT License)

Copyright © 2011 Stefano Verna

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

