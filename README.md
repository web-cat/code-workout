Setting Up a Vagrant Environment for CodeWorkout
============================================

## Introduction:

Vagrant is designed to run on multiple platforms, including Mac OS X, Microsoft Windows, Debian, Ubuntu, CentOS, RedHat and Fedora. In this document we describe how to configure and run an CodeWorkout project virtual development environment through Vagrant.

## Installation Steps:

1. Install [Vagrant](https://www.vagrantup.com/downloads.html)
2. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
3. Clone this repository
4. `$ cd code-workout`
5. `$ vagrant up`
6. `$ vagrant ssh`
7. `$ cd /vagrant`
8. `$ ./runservers.sh`
9. After the provisioning script is complete you can go to:

  * https://192.168.33.10:9292 for CodeWorkout server

## Shut Down The Virtual Machine:

After you finish your work, you need to turn the virtual machine off.

1. Exit the virtual machine terminal by typing `exit`
2. `$ cd code-workout`
3. `$ vagrant halt`

## Re-run Development Servers:

If you decided to shut down the virtual machine using `vagrant halt`, you have to re-run the servers again after you do `vagrant up`.

1. `$ cd code-workout`
2. `$ vagrant up`
3. `$ vagrant ssh`
4. `$ cd /vagrant`
5. `$ ./runservers.sh`

## Reprovision The Virtual Machine:

If anything went wrong or you want to reprovision your virtual machine for any reason, follow these steps.

1. `$ cd code-workout`
2. `$ git pull`
3. `$ vagrant destroy`
4. `$ vagrant up`

## Virtual Machine sudo password:

sudo password is `vagrant` in case you need to execute any commands that require sudo.

## CodeWorkout Database Test Data

The initial database population is defined by lib/tasks/sample_data.rake.
It uses the factories defined in spec/factories/* to generate entities.
If you add new modael classes and want to generate test data in the
database, please add to the sample_data.rake file so that this population
will happen automatically for everyone.  The sample_data.rake contains
only "sample/try out" data for use during development, and it won't
appear on the production server.  Initial database contents provided
for all new installs, including the production server, is described
in db/seeds.rb instead.

  - The initial database includes the following accounts:
    - admin@codeworkout.org (pass: adminadmin), has admin-level access
    - example-1@railstutorial.org (pass: hokiehokie), has instructor access
    - example-*@railstutorial.org (pass: hokiehokie) 50 students

    It also includes the following other objects:
    - six terms (spring, summer I, summer II, fall, and winter 2016),
    - one organization (VT)
    - one course (CS 1114)
    - two offerings of 1114 (one each semester)
      - one course offering is set up with the admin and instructor
        as instructors, and all other sample accounts as students

## Upload and test programming exercises

Upload exercise files at the 'gym/exercises/upload' URL from CodeWorkout's root. Then use the /gym/workouts/new URL from CodeWorkout's home to create a new workout from existing exercises and simultaneously add it to a course offering.