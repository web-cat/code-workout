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
#      ant_cmd: "ant -logger org.apache.tools.ant.listener.ProfileLogger " \
#        "-Dattempt_dir=%{attempt_dir} " \
#        "-l %{attempt_dir}/ant.log " \
#        "-f usr/resources/Java/build.xml"

#        "-Djava.security.manager=net.sf.webcat.plugins.javatddplugin.ProfilingSecurityManager " \
#        "-DProfilingSecurityManager.output=security.txt " \
#        "LOCALCLASSPATH=#{APP_DIR}/usr/resources/Java/JavaTddPluginSupport.jar " \
#        "ant -logger org.apache.tools.ant.listener.ProfileLogger " \
#        "--execdebug " \
      ant_cmd: "cd \"%{attempt_dir}\" ; ANT_OPTS=\"-ea " \
      "-Dant.home=#{ANT_HOME} " \
      "-Dresource_dir=#{APP_DIR}/usr/resources/Java " \
      "-Dwork_dir=#{APP_DIR}/%{attempt_dir} " \
      "-Djava.security.manager " \
      "-Djava.security.policy==file:#{APP_DIR}/usr/resources/Java/java.policy\" " \
      "ant " \
      "-Dattempt_dir=%{attempt_dir} " \
      "-Dbasedir=. " \
      "-l ant.log " \
      "-f ../../../../usr/resources/Java/build.xml",
      daemon_url: "http://localhost:8080/javadaemon/cr?dir=%{attempt_dir}"
      }

  end
end