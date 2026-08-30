# User Guide: New Format for Assignment Dates

This guide explains how to use the new date format in YAML to configure due dates for your Canvas course assignments. This YAML-based system provides a structured and efficient way to manage assignment schedules, from course-wide defaults to specific overrides for individual assignments and students.

## Table of Contents

1.  [Introduction](#introduction)
2.  [Metadata](#metadata)
3.  [Specifying Dates](#specifying-dates)
4.  [Assignment Groups](#assignment-groups)
    *   [Hierarchical Inherited Settings](#hierarchical-inherited-settings)
    *   [Default Settings](#default-settings)
    *   [Section-Specific Settings](#section-specific-settings)
    *   [Due Date Inheritance](#due-date-inheritance)
    *  [Listing the Groups](#listing-the-groups)
    *  [Extensions](#extensions)
6.  [Quizzes](#quizzes)
7.  [Command-Line Usage](#command-line-usage)
8.  [Ideas](#ideas)
9.  [Complete Example](#complete-example)

---

## Introduction

This new YAML data format allows you to define due date patterns for different groups of assignments in your course. This approach simplifies the process of setting and adjusting due dates, especially for courses with many assignments and sections. The YAML file is divided into three main parts: front metadata, assignment groups, and quiz accommodations.

## Metadata

The initial metadata section contains general information about the course.
Additional longer-term configuration settings like the Canvas API key and
Canvas API url are separately read from an appropriate dot file.

```yaml
---
description: Dates for CS 1114 Fall 2025
course_id: 12345
starts_on: 2025-08-24
```

*   `description`: A brief description of the this data settings file.
*   `course_id`: The numeric ID of your course in Canvas.
*   `starts_on`: The start date of the course, in `YYYY-MM-DD` format. This date is used as a reference for calculating assignment due dates based on the week number.

## Specifying Dates

Sure, you could specify due dates as full date/time stamps:

```yaml
due:   2025-10-10 5:00pm
from:  2025-10-10 3:00pm
until: 2025-10-10 5:05pm
```

But it  will be more flexible to think of dates as being composed from two pieces: the date and the time.

```yaml
due:
  date: 2025-10-10
  time: 11:59pm
```

Splitting into two pieces makes it easier to think about allowing
relative time offsets instead of always requiring things to be fully
specified. Or relative date offsets. What if you could just specify the weekday?

```yaml
due:
  weekday: Wednesday
  time: 11:59pm
```

Imagine that a date/time is a combo of a "date" (or day of week plus week number)
and a "time". Since these are just keys in a hash, if both weekday and date are
specified, the date takes precedence. Then think about defaulting, along with
allowing relative time offsets (with an initial +/-):

```yaml
defaults:
  due:
    time: 11:59pm
  from:
    time: -2 hours
  until:
    time: +5 minutes

...

- name: Program 1
  date: 2025-10-10
- name: Program 2
  date: ...
```

Or, even better, use a weekday instead of a specific date, and let the
actual date be calculated automatically (assuming the "start" of the course
is week 1):

```yaml
defaults:
  due:
    weekday: Wednesday
    time: 11:59pm
  from:
    time: -2 hours
  until:
    time: +5 minutes

...

- name: Program 1
  week: 3
- name: Program 2
  week: 5
```

Here, the actual due date for a "week 3" program would be computed by
finding the week number of the course start date, adding (3 - 1) weeks,
and then finding the corresponding weekday, all using Python time/duration
libraries instead of coding it by hand.

Then, to bring it full circle, we can still imagine dates are
structured in these two parts (and even allow the full YAML structuring),
but we could also allow the two-part date/time values to be expressed as a
single compound value, just like before. This would provide a more natural
single-line date format that consists of an optional weekday/date component
(like "2025-10-10" or "Friday", or completely omitted) followed by a time:

```yaml
# Examples
due: 11:59pm             # just a time
due: 2025-10-10 11:59pm  # a full timestamp
due: Friday 11:59pm      # a weekday and time
due: Friday              # just a weekday, inherit the time
due: 2025-10-10          # just a date, inherit the time
```

### All Date Properties

```yaml
# The date constraints on a Canvas entity can be any combo
# of the following, intended to support inherited partial schemes
due: ...  # the "due date" slot, optional date specifier + optional time specifier
from:     # the "available from" date specifier
until:    # the "until" date specifier
unlocked_at: # synonym for "from", based on Canvas API naming
locked_at: # synonym for "until", based on Canvas API naming
week:     # the "week" number, relative to the course start date
week_offset: # A relative week number adjustment, added to the "week" to get the final value
```


## Assignment Groups

### Hierarchical Inherited Settings

So, it would be obvious to have a single assignment to specify *all the details*,
but it will be easier if we can just write down the pattern once, and let
all the assignments inherit the pattern. Then, any assignment only has to
specify the unique details, or the overrides of inherited values.

So think of a list of assignments:

```yaml
    assignments:
      - name: Program 1
        week: 3
      - name: Program 2
        week: 5
      - name: Program 3
        week: 7
      - name: Program 4
        week: 9
```

Let's put them in a group, because they all follow the same due date
pattern and we only want to write the pattern once. It would be easy to support
a Canvas id field in addition to or instead of a name, but names may be
simpler/easier for people to write/maintain/reuse. The script can use the
Canvas API to pull a list of assignment names + id numbers (and the same
for quizzes, see below) in order to support this.

### Default Settings

The `default` date pattern within an assignment group defines the baseline
due date for all assignments in that group.

```yaml
  - name: programs
    default:
      due:
        weekday: Wednesday
        time: 11:59pm
    assignments:
      - name: Program 1
        week: 3
      - name: Program 2
        week: 5
      - name: Program 3
        week: 7
      - name: Program 4
        week: 9
```

Here, the `default` section is inherited by all assignments in the group. In
this example, the defaults don't specify any specific course sections and so
apply to all. All students/sections would use the same due date,
and there is no from or until date (they are empty).

### Section-Specific Settings

You can specify different due dates for different sections as well.

```yaml
  - name: labs
    default:
      from: -2 hours
      until: +5 minutes
      sections:
        - name: crn1
          due: Friday 11:35am
        - name: crn2
          due: Thursday 7:30pm
        - name: crnx
          due: Monday 4:00pm
          week_offset: +1
        ...
    assignments:
      - name: Lab 1
        week: 1
      - name: Lab 2
        week: 2
        sections:
          - names: [crn3, crn4]
            due: Monday 11:59pm
      ...
```

Here, separate overrides are provided for each section. One can
provide section overrides using a single "name:" for one section,
or "names:" to specify a list of section names. Here, that is
done using YAML's inline "flow" style instead of the "block" style
used for the assignment list.

### Due Date Inheritance

The due date for an assignment is determined by a clear inheritance model, allowing for both general rules and specific exceptions. The order of precedence is as follows:

1.  Assignment-specific section-specific overrides (most specific)
2.  Assignment-specific Overrides
3.  Section-specific settings
4.  Default settings (least specific)


### Listing the Groups

The `assignment_groups` section is where these all go.
This section  allows you to group assignments and define due date patterns
for them. Each group has a name, a default pattern, and
a list of assignments that follow that pattern.

```yaml
assignment_groups:
  - name: programs
    default:
      ... constraints applying to all ...
      sections:
        - ... section-specific constraints ...
    assignments:
      - name: Program 1
        week: 3
      - name: Program 2
        week: 5
      ...
      - name: Program 5
        # example of overriding the default pattern
        week: 9
        due:
          weekday: Friday
          date: 2025-10-10
          time: 11:50pm
  - name: labs
    default:
      ... constraints applying to all ...
      sections:
        - ... section-specific constraints ...
    assignments:
      - name: Lab 1
        week: 1
      - name: Lab 2
        week: 2
```

*   `name`: The name of the assignment group (e.g., "programs", "labs", etc.).
*   `default`: A due date pattern that applies to all assignments in the group unless overridden.
    *   You can provide section-specific additions here, too.
    *   You can use the section name "all" to refer to all sections, if needed/desired.
*   `assignments`: A list of assignments in this group.
    *   `name`: The name of the assignment.
    *   `week`: (Optional) The week number in the semester when the assignment is due.
    *   `due`, `from`, `until`: (Optional) A specific due date/time (or weekday/time) for this assignment, which overrides the date pattern.

### Extensions

You can also provide extensions for specific students. This would typically be
listed under a single assignment. It can include the due/from/until time
overrides as needed, plus a list of students. The students could be specified
using their PID or full name, since the script can use the Canvas API to pull
the roster and throw it into a hash with both keys mapping to the id number
needed to enter the student extension info.

```yaml
extensions:
  - due:
      date: 2025-10-12
      time: 11:59pm
    students:
      - student1_pid
      - Firstname Lastname
      - student2_pid
```

## Quizzes

A nearly identical `quiz_groups` section is used to define the due dates for
quizzes. The same notions of defaults, section-specific overrides, and
assignment-specific overrides are used. In addition, however, the `quiz_groups`
section allows you to define accommodations for quizzes, such as extended time
or extra attempts.

```yaml
quiz_groups:
  - name: timed quizzes
    accommodations:
      - time_multiplier: 1.5
        students:
          - student3_pid
      - time_multiplier: 2
        extra_attempts: 1
        students:
          - student4_pid
    defaults:
      ... same as for assignment groups ...
    quizzes:
      - ... same as for assignment groups ...
```

*   `name`: The name of the quiz group.
*   `accommodations`: A list of accommodation rules.
    *   `time_multiplier`: A factor by which to multiply the quiz time limit.
    *   `extra_attempts`: The number of extra attempts allowed.
    *   `extra_time`: A fixed amount of extra time (in minutes), if you'd rather specify the duration instead of a multiplier.
    *   `students`: A list of student PIDs or full names to whom the accommodation applies.

The script would apply the extra time or extra attempts to all of the
listed students. Untimed vs. timed quizzes or that sort of thing can
be handled by using separate groups.

The main justification for separating the quiz groups from the assignment
groups is because quizzes use a different API endpoint than assignments,
and assignments do not support timed accommodation settings the way that
quizzes do.

YAML inline "flow" style could easily be used for the list of students
if the list is short enough (i.e., a one-line [...] style list).


## Complete Example

```yaml
---
description: Dates for CS 1114 Fall 2025
course_id: 12345
starts_on: 2025-08-24

assignment_groups:
  - name: programs
    default:
      due: Wednesday 11:59pm
      from: -2 hours
      until: +5 minutes
    assignments:
      - name: Program 1
        week: 3
      - name: Program 2
        week: 5
      - name: Program 3
        week: 7
        due: Thursday 11:59pm
      - name: Program 4
        week: 9
        due: 2025-10-10 11:50pm
        extensions:
          - due: 2025-10-12 11:59pm
            students: [student1_pid, "Firstname Lastname", ...]

  - name: labs
    default:
      from: -2 hours
      until: +5 minutes
      sections:
        - name: CRN 12345
          due: Friday 11:35am
        - name: CRN 67890
          due: Thursday 7:30pm
    assignments:
      - name: Lab 1
        week: 1
      - name: Lab 2
        week: 2
      - name: Lab 3
        week: 3

quiz_groups:
  - name: timed quizzes
    accommodations:
      - time_multiplier: 1.5
        students: [student3_pid, ...]
      - time_multiplier: 2
        extra_attempts: 1
        students: [student4_pid, ...]
    default:
      due: Sunday 11:59pm
    quizzes:
      - name: Quiz 1
        week: 1
      - name: Quiz 2
        week: 2
```


## Ideas

*  To support use of other Python libraries (like `canvasapi` for an OO
   version of the Canvas API features, or `durations` to parse relative
   time amounts, or command line argument parsing support, or whatever),
   we might convert this to a [poetry](https://python-poetry.org/) project
   to manage dependencies and make it easy to package up. Then users could
   just `pipx install` the script and have it available locally without
   needing to clone the git repository or do anything else to set it up.
*  We can move toward a proper dot file approach to managing settings,
   with ~/.canvas.yml holding global values (like the personal API key
   and canvas service url, etc.), along with another version in the current
   directory holding any local overrides, if needed.
*  It would be easy/natural to also add "file_groups" that allow for
   uploading groups of files and/or controlling locking/unlocking of
   file resources via scheduled dates.
*  It would be easy to support creation of assignments in a manner
   similar to Patrick Sullivan's script as well.
*  We can move to a (waltz)[https://github.com/acbart/waltz] style command
   line argument interface (see below).
*  We could eventually combine with `waltz` to allow for import/export of
   assignment content as well.


## Command-Line Usage

Waltz uses "command style" arguments--i.e., the "arguments" to the main
command look like subcommand words instead of flags. We could do something
similar. The YAML file providing all the course data could be provided
as a command-line argument, but just looking for it in the current
directory via naming conventions is probably easier (e.g.,
`course_properties.yaml`). By careful argument setup (and probably just
reusing the code from an appropriate python library for this), we might
be able to use the script like this:

```bash
# These examples assume we rename the main entry point to something like
# "canvas-cli" or just "canvas" or whatever.

# Apply all date settings
canvas-cli set dates

# Just for one assignment group or quiz group specified by name
canvas-cli set dates programs

# Just for one assignment or quiz specified by name
canvas-cli set dates "Program 1"

# Set the accommodations for a quiz or group
canvas-cli set accommodations timed_quizzes

# If we supported assignment creation ...
canvas-cli add labs

# If we supported file uploads
canvas-cli upload files_group

# Or some other hypotheticals
canvas-cli set all
canvas-cli get sections
canvas-cli get roster
calvas-cli get roster sections

# maybe even include commands to pull student access log data or
# quiz event log data, etc.
```
