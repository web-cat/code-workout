module CodeWorkout
  module Config

    def self.which_path(cmd)
      cmd = cmd.to_s
      ENV['PATH'].split(File::PATH_SEPARATOR).find do |directory|
        File.executable?(File.join(directory, cmd))
      end
    end

    APP_DIR = Dir.pwd
    ANT_BIN = which_path('ant')
    ANT_HOME = ENV['ANT_HOME'] || (ANT_BIN && File.dirname(ANT_BIN))
    JAVA = {
      ant_cmd: "cd \"%{attempt_dir}\" ; ANT_OPTS=\"-ea " \
        "-Dant.home=#{ANT_HOME} " \
        "-Dresource_dir=#{APP_DIR}/usr/resources/Java " \
        "-Dwork_dir=#{APP_DIR}/%{attempt_dir} \" " \
        "ant " \
        "-Dattempt_dir=%{attempt_dir} " \
        "-Dbasedir=. " \
        "-l ant.log " \
        "-f ../../../../usr/resources/Java/build.xml",
      # daemon_url: "http://localhost:8080/javadaemon/cr?dir=%{attempt_dir}"
    }

  end
end
