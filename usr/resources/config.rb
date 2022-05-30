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
    CMD = {
      java: {
#          "-Djava.security.manager=net.sf.webcat.plugins.javatddplugin.ProfilingSecurityManager " \
#          "-DProfilingSecurityManager.output=security.txt " \
#          "ant -logger org.apache.tools.ant.listener.ProfileLogger " \
#          "--execdebug " \

        cmd: 'cd "%{attempt_dir}" ; ANT_OPTS="-ea ' \
          "-Dant.home=#{ANT_HOME} " \
          "-Dresource_dir=#{APP_DIR}/usr/resources/Java " \
          '-Djava.security.manager ' \
          "-Djava.security.policy==file:#{APP_DIR}/usr/resources/Java/java.policy\" " \
          "-Dwork_dir=#{APP_DIR}/%{attempt_dir}\" " \
          'ant ' \
          '-Dattempt_dir=%{attempt_dir} ' \
          '-Dbasedir=. ' \
          '-l ant.log ' \
          '-f ../../../../usr/resources/Java/build.xml',
        # daemon_url: "http://localhost:8080/javadaemon/cr?dir=%{attempt_dir}"
      },
      cpp: {
        docker_image: 'codeworkout/cpp',
        cmd: 'docker run --rm ' \
          '-v "$(pwd)/%{attempt_dir}:/attempt" ' \
          '-v "$(pwd)/usr/resources/C++:/resources:ro" ' \
          "%{docker_image} " \
          'bash /resources/run.sh'
      },
      python: {
        docker_image: 'codeworkout/python:0.0.1',
        cmd: 'docker run --rm ' \
          '-v "$(pwd)/%{attempt_dir}:/attempt" ' \
          '-v "$(pwd)/usr/resources/Python:/resources:ro" ' \
          "%{docker_image} " \
          'bash /resources/run.sh'
      },
      ruby: {
        docker_image: 'codeworkout/ruby',
        cmd: 'docker run --rm ' \
          '-v "$(pwd)/%{attempt_dir}:/attempt" ' \
          '-v "$(pwd)/usr/resources/Ruby:/resources:ro" ' \
          "%{docker_image} " \
          'bash /resources/run.sh'
      },
    }
  end
end
