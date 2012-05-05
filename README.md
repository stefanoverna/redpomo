# Redpomo
## Redmine, Pomodoro.app and Todo-txt. Together.

[![Build Status](https://secure.travis-ci.org/stefanoverna/redpomo.png)](http://travis-ci.org/stefanoverna/redpomo)

Redpomo is the classic "scratch your own itch" project:

* It makes it really easy to manage Redmine issues from the command-line;
* It is able to sync Redmine issues with your local Todo.txt tasks;
* It can start Pomodoro.app timer on a specific Todo.txt task, and is
  able to "push" the logged pomodoros as Redmine timetracks.

## Usage

    › redpomo help
    Tasks:
      redpomo close TASK    # Marks a todo.txt task as complete, and closes the related Redmine issue
      redpomo help [TASK]   # Describe available tasks or one specific task
      redpomo open TASK     # Opens up the Redmine issue page of the selected task
      redpomo pull          # Imports Redmine open issues into local todo.txt
      redpomo push LOGFILE  # Parses Pomodoro export file and imports to Redmine clients
      redpomo start TASK    # Starts a Pomodoro session for the selected task

## Installation

Add this line to your application's Gemfile:

    gem 'redpomo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redpomo

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
