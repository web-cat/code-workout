# CodeWorkout

CodeWorkout is an online system for people learning a programming language for the first time.
It is a free, open-source solution for practicing small programming problems.
Students may practice coding exercises or multiple-choice-questions on a variety of programming concepts in a web browser and receive immediate feedback.

CodeWorkout was inspired by many great systems built by others, but aims to bring together the best from earlier forerunners while adding important new features.
It provides comprehensive support for teachers who want to use coding exercises in their courses, while also maintaining flexibility for self-paced learners who aren't part of an organized course.

Try it out at https://codeworkout.cs.vt.edu.
You can play around without signing up if you like.

## Contents
* [Setting up a Development Environment Using Docker](#setting-up-a-development-environment-using-docker)
  - [Clone this repository](#clone-this-repository)
  - [Install Docker and build the containers](#install-docker-and-build-the-containers)
  - [Set up some development data](#set-up-some-development-data)
  - [Run servers](#run-servers)
  - [Other notes](#other-notes)
* [Making an exercise](#making-an-exercise)

## Setting up a Development Environment Using Docker

> Note: If you are comfortable setting up a Rails application, i.e., installing Ruby (2.3.8), Rails (4.2), and MySQL (5.7) on your own machine, you can just do that instead of using Docker. You'll need to change the `host` keys in [config/database.yml](config/database.yml) to `localhost`.

The following steps will help set up a development environment for CodeWorkout using Docker and Docker Compose.
You can do your editing on your own machine using an editor of your choice; changes will be reflected in the Docker container.

### Clone this repository

```bash
$ git clone git@github.com:web-cat/code-workout.git
$ cd code-workout
```

Check out the `staging` branch. Most new changes won't be accepted directly into the `master` branch.
```bash
$ git checkout staging
```

### Install Docker and build the containers

Instructions to install Docker may be found at the [Docker website](https://docs.docker.com/get-docker/).

These instructions were written with Docker version `19.03.8` in mind. We don't do anything fancy, so things should work as long as you're reasonably up to date.

We use [Docker Compose](https://docs.docker.com/get-docker/) to tie multiple containers together. One for the web application, and one each for the test and development databases.
Docker Compose comes installed with Docker automatically.

Inside the `code-workout` directory, do the following:
```bash
$ docker-compose up # build and start containers for the web application and the databases
```

This step builds the `web` container using the provided [Dockerfile](Dockerfile) to install Ruby, Rails, and required dependencies. It also builds the `db_dev` and `db_test` containers, each of which pull a ready-to-use MySQL image from DockerHub. Two databases are set up:
* `codeworkout`, running on port 3306 on the `db_dev` container and port 3307 on the host
* `codeworkout_test`, running on port 3306 on the `db_test` container and port 3308 on the host

Credentials for both databases:
* username: `codeworkout`
* pwd: `codeworkout`

The first time you do this, it will take a bit of time to build all the containers. Subsequent runs of this command will just start the existing containers.

Output from the containers will appear in your console. Do `Ctrl-C` to exit and stop the containers.

Do the following if you want to run the containers in the background and get your terminal back:
```bash
$ docker-compose up -d
```

You can `docker-compose down` to stop and remove the containers (or just `docker-compose stop` to stop without removing).

### Set up some development data 

This next step sets up the database and populates it with fake data for development.
Do the following in the `code-workout` directory on your machine.

```bash
$ docker-compose run web rake db:populate
```

The above command is telling Docker to "run the command `rake db:populate` on the `web` container and exit".
This rake task is defined in [lib/tasks/sample_data.rake](lib/tasks/sample_data.rake), and runs the following tasks in order:

```bash
$ rake db:drop        # drop the database
$ rake db:create      # create the database
$ rake db:schema:load # load the schema from db/schema.rb
$ rake db:seed        # load the seeded data (like timezones, seasons, etc.)
$ rake db:populate    # load sample data; this is a custom rake task
```

> Run `rake -T` in your project root to see a list of available rake tasks. [What's rake?](https://github.com/ruby/rake)

The initial database population is defined by [lib/tasks/sample_data.rake](lib/tasks/sample_data.rake).
It uses the factories defined in [spec/factories](spec/factories) to generate entities.
If you add new model classes and want to generate test data in the database, please add to the `sample_data.rake` file so that this population will happen automatically for everyone. 
The `sample_data.rake` contains only "sample/try out" data for use during development, and it won't
appear on the production server. 
Initial database contents provided for all new installs, including the production server, is described in db/seeds.rb instead.

- The initial database includes the following accounts:
  - admin@codeworkout.org (pass: adminadmin), has admin-level access
  - example-1@railstutorial.org (pass: hokiehokie), has instructor access
  - example-*@railstutorial.org (pass: hokiehokie) 50 students

  It also includes the following other objects:
  - six terms (spring, summer I, summer II, fall, and winter of the current year),
  - one organization (VT)
  - one course (CS 1114)
  - two offerings of 1114 (one each semester)
    - one course offering is set up with the admin and instructor
      as instructors, and all other sample accounts as students

- To reset the database to the initial state do the following:
  - `$ cd code-workout`
  - `$ docker-compose run web rake db:populate`

**A note on setting up a development database.**

We load the schema directly from [db/schema.rb](db/schema.rb), because database migrations tend to go stale over time&mdash;running over 100 migrations, many of which are years old, is likely to run into errors. Migrations are useful for making *new* changes or reversing *recent* changes to the schema.

### Run servers
To run the development server, do the following in the `code-workout` directory:

```bash
$ docker-compose up # this may take a minute
```

In your browser, navigate to [https://localhost:9292](https://localhost:9292) and you should see the CodeWorkout homepage. (Make sure you have `https` in front of the URL.)

You can edit files on your own machine; changes will be reflected in container.

### Other notes 

**NOTE 1**: Since the Rails application is running on the `web` container, your typical `rails` or `rake` commands are run as you see above, i.e., with `docker-compose run web` in front of it. For example, to generate a model you would do `docker-compose run web rails g model MyModel`.

**NOTE 2**: To end up in a bash shell in the container (i.e., to "SSH" into the server), do the following:
```bash
docker-compose run web bash
```
Note that this does not set up the port forwarding, so if you do this and manually run the server (`./runservers.sh`), you won't be able to access it from your browser.

**NOTE 3**: These docs and the Docker setup are recent. Please submit an issue if something is missing, incorrect, or unclear.

## Making an Exercise

For instructions on how to make an exercise, see [making_an_exercise.md](making_an_exercise.md). Note that this functionality is not directly available through the web interface for most users. Please get in touch if you want to add exercises to CodeWorkout. 
