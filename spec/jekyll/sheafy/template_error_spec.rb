require "jekyll/sheafy/template_error"

describe Jekyll::Sheafy::TemplateError do
  subject { Jekyll::Sheafy::TemplateError } # avoids instantiation

  describe ".build" do
    it "requires an argument" do
      expect { subject.build.new }.to raise_error(ArgumentError)
    end

    it "requires a string argument" do
      expect { subject.build(42).new }.to raise_error(ArgumentError)
    end

    it "creates classes accepting no parameters" do
      expect(subject.
        build("Hello, World!").
        new()).
        to have_attributes(message: "Hello, World!")
    end

    it "creates classes accepting one parameter" do
      expect(subject.
        build("Hello, %s!").
        new("Bob")).
        to have_attributes(message: "Hello, Bob!")
    end

    it "creates classes accepting multiple parameters" do
      expect(subject.
        build("Hello, %s and %s!").
        new("Bob", "Alice")).
        to have_attributes(message: "Hello, Bob and Alice!")
    end

    it "creates classes accepting an hash parameter" do
      expect(subject.
        build("Hello, %{first} and %{last}!").
        new({ first: "Bob", last: "Alice" })).
        to have_attributes(message: "Hello, Bob and Alice!")
    end
  end
end
