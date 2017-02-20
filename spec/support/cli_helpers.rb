require 'stringio'
require 'open3'

module Spec
  module CLIHelpers

    attr_reader :out, :err, :exitstatus

    def capture(*streams)
      streams.map! { |stream| stream.to_s }
      begin
        result = StringIO.new
        streams.each { |stream| eval "$#{stream} = result" }
        yield
      ensure
        streams.each { |stream| eval("$#{stream} = #{stream.upcase}") }
      end
      result.string
    end

    def cli_redpomo(cmd)
      @out = capture(:stdout) do
        cmd = cmd.kind_of?(Array) ? cmd : cmd.split
        cmd += "--config #{config_path}".split
        Redpomo::CLI.start(cmd)
      end
    end

    def redpomo(cmd, options = {})
      expect_err  = options.delete(:expect_err)
      exitstatus = options.delete(:exitstatus)
      options["no-color"] = true unless options.key?("no-color")

      redpomo_bin = File.expand_path('../../../bin/redpomo', __FILE__)

      env = (options.delete(:env) || {}).map{|k,v| "#{k}='#{v}' "}.join
      args = options.map do |k,v|
        v == true ? " --#{k}" : " --#{k} #{v}" if v
      end.join

      cmd = "#{env}#{Gem.ruby} -I#{lib} #{redpomo_bin} #{cmd}#{args}"

      if exitstatus
        sys_status(cmd)
      else
        sys_exec(cmd, expect_err){|i| yield i if block_given? }
      end
    end

    def sys_exec(cmd, expect_err = false)
      Open3.popen3(cmd.to_s) do |stdin, stdout, stderr|
        @in_p, @out_p, @err_p = stdin, stdout, stderr

        yield @in_p if block_given?
        @in_p.close

        @out = @out_p.read_available_bytes.strip
        @err = @err_p.read_available_bytes.strip
      end

      puts @err if !expect_err && @err.present?
      @out
    end

    def sys_status(cmd)
      @err = nil
      @out = %x{#{cmd}}.strip
      @exitstatus = $?.exitstatus
    end

    def lib
      File.expand_path('../../../lib', __FILE__)
    end

  end
end
