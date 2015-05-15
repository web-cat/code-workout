module CodeWorkout
  module Config

    CLASSPATH = 'usr/resources/Java/JavaTddPluginSupport.jar:'\
        'usr/resources/Java/student.jar:'\
        'usr/resources/Java/junit-4.8.2.jar:'\
        'usr/resources/Java/hamcrest-core-1.3.jar'

    JAVA = {
      classpath: CLASSPATH,
      compile_cmd: "javac -cp #{CLASSPATH}",
      run_cmd: "java -ea -cp #{CLASSPATH}"
    }

  end
end
