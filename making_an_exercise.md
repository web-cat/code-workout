## YAML Exercise Format Explanations

Coding exercises are added using a YAML file. See [http://www.yaml.org/refcard.html](http://www.yaml.org/refcard.html) for a cheatsheet on YAML syntax. An exercise file must include the following fields:

**external_id**

Each exercise needs an ID so that if the exercise is updated the same exercise isn't added to the database twice. When changed, the software will recognize that there is an exercise with the same ID and update the original exercise. 

**is_public**

If this is set to true, the exercise will be open to access publicly on CodeWorkout. If false, it will be in the database, but will not be online to access. 

**experience**

Each student on CodeWorkout can gain experience points for doing exercises and workouts through CodeWorkout generally to show how often they have practiced and give them a way to track progress. This field takes an integer for the amount of experience points the student will gain from completing this exercise.

**language_list**

This field is for a list of programming languages associated with the exercise, although this would generally be just one. This is used for sorting and grouping exercises.

**style_list**

This is the type of question used in the exercise. For example, this field could be multiple choice, single answer, code writing, etc. This is also used for grouping exercises. 

**tag_list**

This is a list of other tags that should indicate the subject matter of the exercise. This could include things such as methods, classes, for-loops, recursion, arithmetic, etc. This is used for grouping exercises by tags.

**current_version**

The most current version of this particular exercise. This includes the following attributes:

    **version**

This is a simple integer stating the current version of the exercise. This works with the external_id (seen above) to indicate if this is a new exercise or a new version of one. Each version of an exercise is stored in the database so that an older version can be accessed at any point. This is important in a situation that a student would want to review feedback from an exercise they had previously received, but the exercise had since been altered in the database. The student would be able to access the information to the version of the exercise they completed.

**creator**

This should include the email of the person submitting the exercise or the update to the exercise. 

**prompts**

        Everything under prompts should include the actual layout of the exercise. This

includes the prompt and answers. Each exercise can contain multiple prompts, and each prompt should begin with the type of prompt it is: multiple_choice_prompt or coding_prompt. 

*Position and question must be included for EACH prompt.*

**position**

(Included under each prompt) This is an integer representing the question’s position in the exercise. (The YAML file allows for multiple part exercises)  

**question** 

This should include the text for the actual question in the particular prompt.

**FOR MULTIPLE CHOICE QUESTIONS**

**allow_multiple** 

If set to false, the student will only be allowed to choose one answer choice. If true, they can select one or many answers.

**choices**

This includes the text for the answer. Wrap multiline strings in ~~~  For each option under choices you must have an answer, a position and a value:

**answer**

Text of the multiple choice option.

**position**

This is the similar to the position option for the prompts. It decides the order of the answer choices.

**value**

This determines the integer value of the answer. Let's say there is only one correct answer, every wrong answer could be set to 0 and the correct one to 1. Some answers could be more correct than others and some could offer partial credit. Some could even take multiple answers and the numbers could all be equal except for the wrong answer in order to determine the score.

**FOR CODING QUESTIONS**

**class_name and method_name**

These should include the names of the class and method being worked with in the code given, assuming that both are needed. 

**starter_code**

This includes the code that is already in the answer section before the student begins to answer it. This should include a triple underscore ___ where the student's cursor should be defaulted when starting the exercise.

**wrapper_code**

This is the code that will wrap around the student's code after they submit an attempt. This would depend on the individual language requirements. A triple underscore ___ is used here as well to indicate where the student's code would be injected. Wrapper code is not displayed to the user.

**tests**

This includes a list of test values to check the student's response to the code. These include up to 3 columns of test values separated by commas. The first column is the test value itself, the second is the correct output if given that test value, the third value may be either ‘example’ or  ‘hidden’. If ‘example’ is given, the test case will be given before the user begins. If ‘hidden’ is given the test case will not be displayed after running tests. 

## Example File

- external_id: if-else-mcq

  is_public: false

  experience: 50

  language_list: Java

  style_list: multiple choice, single answer

  tag_list: conditional

  current_version:

    version: 1

    creator: stoebelj@berea.edu

    prompts:

    - multiple_choice_prompt:

        position: 1

        question: |

        Which of the following is the correct way to set up an if/else statement in Java?

        allow_multiple: false

        choices:

        - answer: |

            ~~~

            if (condition) {

                //do something

            } else {

                //do something else

            }

            ~~~

            position: 1

            value: 1

        - answer: |

            ~~~

            if condition {

                //do something

            } else {

                //do something else

            }

            ~~~

            position: 2

            value: 0

        - answer: |

            ~~~

            if condition than{

                //do something

            } else {

                //do something else

            }

            ~~~

            position: 3

            value: 0

        - answer: A or B.

            position: 4

            value: 0

        - answer: None of the above.

            position: 4

            value: 0

- external_id: gotoClass

  is_public: false

  experience: 50

  language_list: Java

  style_list: code writing

  tag_list: conditional

  current_version:

    version: 1

    creator: stoebelj@berea.edu

    prompts:

    - coding_prompt:

        position: 1

        question: |

        Write a function that takes in month of the year as an integer (Jan=1, Dec=12) and outputs the string "summer break!" if the month is May-July or "go to class!" for any other month. If any other number is input, output the string "invalid month".

        class_name: Month

        method_name: monthChecker

        starter_code: |

        public int monthChecker(int month)

        {

            ___

        }

        wrapper_code: |

        public class Month

        {

            ___

            public static class Math {}

            public static class java

            {

                public static class lang

                {

                    public static class Math {}

                }

            }

        }

        tests: |

        "1","go to class!",example

        "6","summer break!",example

        "13","invalid month"

        "-1","invalid month",hidden
