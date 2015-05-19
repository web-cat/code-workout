module CodeWorkout
  module Config

    JAVA = {
      ant_cmd: "ant -Dattempt_dir=%{attempt_dir} " \
        "-l %{attempt_dir}/ant.log " \
        "-f usr/resources/Java/build.xml"
    }

  end
end
