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

## current_version 

The most current version of this particular exercise. This includes the following attributes:

**version**
This is a simple integer stating the current version of the exercise. This works with the external_id (seen above) to indicate if this is a new exercise or a new version of one. Each version of an exercise is stored in the database so that an older version can be accessed at any point. This is important in a situation that a student would want to review feedback from an exercise they had previously received, but the exercise had since been altered in the database. The student would be able to access the information to the version of the exercise they completed.

**creator**

This should include the email of the person submitting the exercise or the update to the exercise. 

**prompts**

Everything under prompts should include the actual layout of the exercise.This includes the prompt and answers. Each exercise can contain multiple prompts, and each prompt should begin with the type of prompt it is: multiple_choice_prompt or coding_prompt. 

*Position and question must be included for EACH prompt.*

**position**

(Included under each prompt) This is an integer representing the question’s position in the exercise. (The YAML file allows for multiple part exercises)  

**question** 

This should include the text for the actual question in the particular prompt.


###Multiple Choice Questions

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

###Coding Questions

**class_name and method_name**

These should include the names of the class and method being worked with in the code given, assuming that both are needed. 

**starter_code**

This includes the code that is already in the answer section before the student begins to answer it. This should include a triple underscore (\_\_\_) where the student's cursor should be defaulted when starting the exercise.

**wrapper_code**

This is the code that will wrap around the student's code after they submit an attempt. This would depend on the individual language requirements. A triple underscore (\_\_\_) is used here as well to indicate where the student's code would be injected. Wrapper code is not displayed to the user.

**tests**

This includes a list of test values to check the student's response to the code. These include up to 3 columns of test values separated by commas. The first column is the test value itself, the second is the correct output if given that test value, the third value may be either ‘example’ or  ‘hidden’. If ‘example’ is given, the test case will be given before the user begins. If ‘hidden’ is given the test case will not be displayed after running tests. 

## Example File

For an example of an exercise file see [here](example_exercise.yaml)