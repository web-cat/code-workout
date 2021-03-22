class Template < Mustache
  self.template_path = __dir__

  def java
    java
  end
  
  def ruby
    ruby
  end

  def python
    python
  end

  def cpp
    cpp
  end

  def id
    id
  end

  def method_name
    method_name
  end

  def class_name
    class_name
  end

  def input
    input
  end

  def expected_output
    expected_output
  end
  
  def negative_feedback
    negative_feedback
  end 

  def array
    array
  end
end
